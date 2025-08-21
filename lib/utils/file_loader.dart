import 'dart:io';
import '../models/audio_file.dart';

/// Escanea la carpeta dada y devuelve una lista ordenada de AudioFile
Future<List<AudioFile>> loadAudioFilesFromDirectory(String directoryPath) async {
  final dir = Directory(directoryPath);
  if (!await dir.exists()) return [];

  final List<FileSystemEntity> entities = await dir.list().toList();

  final audioFiles = entities.whereType<File>().where((file) {
    final ext = file.path.split('.').last.toLowerCase();
    return ext == 'mp3'; // Filtro solo mp3
  }).map((file) {
    // Por simplicidad, título null y duración null (puedes extender para extraer metadatos)
    return AudioFile(path: file.path, title: null, duration: null);
  }).toList();

  audioFiles.sort((a, b) => a.path.compareTo(b.path));
  return audioFiles;
}
