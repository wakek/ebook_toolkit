import 'dart:typed_data';

import 'package:ebook_toolkit/ebook_toolkit_platform_interface.dart';
import 'package:ebook_toolkit/src/pdf/entities/PDFPage.dart';

abstract class PDFDocument {
  /// File path, `asset:[ASSET_PATH]` or `memory:` depending on the content opened.
  final String sourceName;

  final int pageCount;

  /// PDF major version.
  final int verMajor;

  /// PDF minor version.
  final int verMinor;

  final bool isEncrypted;

  final bool allowsCopying;

  final bool allowsPrinting;

  PDFDocument({
    required this.sourceName,
    required this.pageCount,
    required this.verMajor,
    required this.verMinor,
    required this.isEncrypted,
    required this.allowsCopying,
    required this.allowsPrinting,
  });

  Future<void> dispose();

  static Future<PDFDocument> openFromPath(String filePath) =>
      EbookToolkitPlatform.instance.openFromPath(filePath);

  static Future<PDFDocument> openAsset(String name) =>
      EbookToolkitPlatform.instance.openAsset(name);

  static Future<PDFDocument> openFromMemory(Uint8List data) =>
      EbookToolkitPlatform.instance.openFromMemory(data);

  Future<PDFPage> getPage(int pageNumber);

  @override
  String toString() => sourceName;
}
