import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FolderPicker extends StatelessWidget {
  final Function(String) onFolderSelected;

  const FolderPicker({required this.onFolderSelected});

  Future<void> _pickFolder(BuildContext context) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      onFolderSelected(selectedDirectory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _pickFolder(context),
      child: Text('Select Folder'),
    );
  }
}
