import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisplayer/screens/permission_wrapper.dart';
import 'providers/settings_provider.dart';
import 'providers/audio_provider.dart';
import 'screens/main_screen.dart';
import 'screens/storage_permission_and_list.dart';
import 'screens/audio_player_test.dart';
import 'screens/permission_debug.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/permission_wrapper.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(
          create: (context) => AudioProvider(
            settings: context.read<SettingsProvider>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


Future<void> checkPermission() async {
  var status = await Permission.storage.status;
  print('Estado actual storage permission: $status');
  
  if (status.isDenied) {
    print('Permiso denegado, solicitando permiso...');
    var result = await Permission.storage.request();
    print('Resultado solicitud permiso: $result');
  } else if (status.isPermanentlyDenied) {
    print('Permiso denegado permanentemente, abrir configuración');
    // Aquí deberías mostrar diálogo para abrir configuración
  } else if (status.isGranted) {
    print('Permiso concedido');
  }
}


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wis Player',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //home: MainScreen(),
      //home: StoragePermissionAudioPlayer(),
      //home: AudioPlayerTest(),
      home: PermissionWrapper(),

    );
  }
}
