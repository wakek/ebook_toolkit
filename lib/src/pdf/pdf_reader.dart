import 'dart:typed_data';

import 'package:ebook_toolkit/src/pdf/entities/PDFPage.dart';

/// A class that provides the primary interface to read PDF files.
class PDFReader {
  String? filePath;
  String? assetName;
  Uint8List? memoryFile;

  PDFReader.openFile({
    required this.filePath,
  });
  PDFReader.openAsset({
    required this.filePath,
  });
  PDFReader.openMemoryFile({
    required this.filePath,
  });

  Future<List<PDFPage>> getPages() async {}

  Future<dynamic> getThumbnail() async {}

  Future<int> getPageCount() async {}

  Future<List<String>> getTextContent() async {}
}
