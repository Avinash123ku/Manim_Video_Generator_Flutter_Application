import 'dart:io';

class PdfDocument {
  final String name;
  final String path;
  final File file;
  final DateTime uploadedAt;
  final int size;

  PdfDocument({
    required this.name,
    required this.path,
    required this.file,
    required this.uploadedAt,
    required this.size,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'uploadedAt': uploadedAt.toIso8601String(),
      'size': size,
    };
  }

  factory PdfDocument.fromJson(Map<String, dynamic> json) {
    final file = File(json['path']);
    return PdfDocument(
      name: json['name'],
      path: json['path'],
      file: file,
      uploadedAt: DateTime.parse(json['uploadedAt']),
      size: json['size'] ?? file.lengthSync(),
    );
  }
}
