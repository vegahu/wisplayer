import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionDebugScreen extends StatefulWidget {
  const PermissionDebugScreen({super.key});

  @override
  State<PermissionDebugScreen> createState() => _PermissionDebugScreenState();
}

class _PermissionDebugScreenState extends State<PermissionDebugScreen> {
  String _status = 'Iniciando...';

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    var status = await Permission.storage.status;

    if (status.isGranted) {
      setState(() => _status = 'Permiso STORAGE concedido.');
      return;
    }

    if (status.isPermanentlyDenied) {
      setState(() => _status = 'Permiso denegado permanentemente.');
      _showOpenSettingsDialog();
      return;
    }

    if (status.isDenied) {
      setState(() => _status = 'Permiso denegado, solicitando permiso...');
      var result = await Permission.storage.request();
      setState(() => _status = 'Resultado solicitud: $result');
      if (result.isPermanentlyDenied) {
        _showOpenSettingsDialog();
      }
    }
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso necesario'),
        content: const Text(
            'Por favor, activa el permiso de almacenamiento manualmente en la configuración de la app.'),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text('Abrir configuración'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug permisos storage')),
      body: Center(child: Text(_status)),
    );
  }
}
