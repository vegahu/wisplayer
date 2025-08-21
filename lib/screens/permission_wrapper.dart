import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'main_screen.dart';


class PermissionWrapper extends StatefulWidget {
  @override
  State<PermissionWrapper> createState() => _PermissionWrapperState();
}

class _PermissionWrapperState extends State<PermissionWrapper> {
  bool _hasPermission = false;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.storage.status;
    if (status.isGranted) {
      setState(() => _hasPermission = true);
    } else {
      _requestPermission();
    }
  }

  Future<void> _requestPermission() async {
    if (_isRequesting) return;
    setState(() => _isRequesting = true);

    if (Platform.isAndroid) {
      final androidSdkVersion = 30; // o detectar dinámico

      if (androidSdkVersion >= 30) {
        final granted = await Permission.manageExternalStorage.isGranted;
        print('MANAGE_EXTERNAL_STORAGE ya concedido? $granted');
        if (!granted) {
          // Mostrar diálogo para abrir configuración manual
          setState(() => _isRequesting = false);
          _showOpenSettingsDialog();
          return;
        }
        setState(() {
          _hasPermission = true;
          _isRequesting = false;
        });
        return;
      }
    }

    // Para android < 11 o iOS
    final status = await Permission.storage.request();
    print('Resultado solicitud permiso STORAGE: $status');

    setState(() {
      _isRequesting = false;
      _hasPermission = status.isGranted;
    });

    if (status.isPermanentlyDenied) {
      _showOpenSettingsDialog();
    }
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permiso requerido'),
        content: Text(
          'El permiso de almacenamiento fue denegado permanentemente. Por favor habilítalo desde la configuración.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: Text('Abrir configuración'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasPermission) {
      // Permiso concedido, mostrar la pantalla principal
      return MainScreen();
    } else if (_isRequesting) {
      // Mostrar indicador mientras solicita permiso
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      // Permiso no concedido, mostrar botón para pedir permiso
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: _requestPermission,
            child: Text('Permitir acceso al almacenamiento'),
          ),
        ),
      );
    }
  }
}
