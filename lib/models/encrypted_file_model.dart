class EncryptedFileModel {
  final String id;
  final String originalName;
  final String encryptedPath;
  final int originalSize;
  final int encryptedSize;
  final DateTime dateEncrypted;
  final String fileType;

  EncryptedFileModel({
    required this.id,
    required this.originalName,
    required this.encryptedPath,
    required this.originalSize,
    required this.encryptedSize,
    required this.dateEncrypted,
    required this.fileType,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'originalName': originalName,
    'encryptedPath': encryptedPath,
    'originalSize': originalSize,
    'encryptedSize': encryptedSize,
    'dateEncrypted': dateEncrypted.toIso8601String(),
    'fileType': fileType,
  };

  factory EncryptedFileModel.fromJson(Map<String, dynamic> json) {
    return EncryptedFileModel(
      id: json['id'],
      originalName: json['originalName'],
      encryptedPath: json['encryptedPath'],
      originalSize: json['originalSize'],
      encryptedSize: json['encryptedSize'],
      dateEncrypted: DateTime.parse(json['dateEncrypted']),
      fileType: json['fileType'],
    );
  }
}
