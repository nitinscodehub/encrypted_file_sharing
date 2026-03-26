import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/encrypted_file_model.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static const String themeModeKey = 'theme_mode';
  static const String encryptedFilesKey = 'encrypted_files';
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  static Future<void> saveThemeMode(bool isDark) async {
    await _prefs.setBool(themeModeKey, isDark);
  }
  
  static Future<bool> getThemeMode() async {
    return _prefs.getBool(themeModeKey) ?? false;
  }
  
  static Future<void> saveEncryptedFiles(List<EncryptedFileModel> files) async {
    final filesJson = files.map((file) => file.toJson()).toList();
    await _prefs.setString(encryptedFilesKey, jsonEncode(filesJson));
  }
  
  static Future<List<EncryptedFileModel>> getEncryptedFiles() async {
    final filesString = _prefs.getString(encryptedFilesKey);
    if (filesString == null) return [];
    final filesJson = jsonDecode(filesString) as List;
    return filesJson.map((json) => EncryptedFileModel.fromJson(json)).toList();
  }
}
