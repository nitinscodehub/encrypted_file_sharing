import 'package:flutter/material.dart';
import '../models/encrypted_file_model.dart';
import '../services/storage_service.dart';

class FileProvider extends ChangeNotifier {
  List<EncryptedFileModel> _files = [];
  List<EncryptedFileModel> get files => _files;
  
  FileProvider() {
    loadFiles();
  }
  
  Future<void> loadFiles() async {
    _files = await StorageService.getEncryptedFiles();
    notifyListeners();
  }
  
  Future<void> addFile(EncryptedFileModel file) async {
    _files.add(file);
    await StorageService.saveEncryptedFiles(_files);
    notifyListeners();
  }
  
  Future<void> deleteFile(String fileId) async {
    _files.removeWhere((file) => file.id == fileId);
    await StorageService.saveEncryptedFiles(_files);
    notifyListeners();
  }
}
