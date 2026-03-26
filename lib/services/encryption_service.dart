import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/encrypted_file_model.dart';
import '../utils/helpers.dart';

class EncryptionService {
  static Future<EncryptedFileModel> encryptFile({
    required File file,
    required String password,
  }) async {
    final fileBytes = await file.readAsBytes();
    final originalSize = fileBytes.length;
    
    final key = _deriveKey(password);
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);
    
    final encryptedData = Uint8List.fromList(iv.bytes + encrypted.bytes);
    
    final appDir = await getApplicationDocumentsDirectory();
    final encryptedFileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}.enc';
    final encryptedFile = File('${appDir.path}/$encryptedFileName');
    await encryptedFile.writeAsBytes(encryptedData);
    
    final fileExtension = path.extension(file.path).replaceFirst('.', '');
    
    return EncryptedFileModel(
      id: Helpers.generateFileId(),
      originalName: path.basename(file.path),
      encryptedPath: encryptedFile.path,
      originalSize: originalSize,
      encryptedSize: encryptedData.length,
      dateEncrypted: DateTime.now(),
      fileType: fileExtension.isEmpty ? 'unknown' : fileExtension,
    );
  }
  
  static Future<File> decryptFile({
    required File encryptedFile,
    required String password,
  }) async {
    final encryptedBytes = await encryptedFile.readAsBytes();
    final ivBytes = encryptedBytes.sublist(0, 16);
    final encryptedData = encryptedBytes.sublist(16);
    
    final key = _deriveKey(password);
    final iv = IV(ivBytes);
    final encrypter = Encrypter(AES(key));
    final decryptedBytes = encrypter.decryptBytes(Encrypted(encryptedData), iv: iv);
    
    final appDir = await getApplicationDocumentsDirectory();
    final originalFileName = path.basename(encryptedFile.path).replaceAll('.enc', '');
    final decryptedFile = File('${appDir.path}/decrypted_$originalFileName');
    await decryptedFile.writeAsBytes(decryptedBytes);
    
    return decryptedFile;
  }
  
  static Key _deriveKey(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    final keyBytes = Uint8List.fromList(digest.bytes);
    return Key(keyBytes);
  }
}
