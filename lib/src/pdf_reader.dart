import 'dart:typed_data';

import 'package:ebook_toolkit/src/ebook_toolkit_method_channel.dart';
import 'package:ebook_toolkit/src/pdf/entities/pdf_document.dart';

/// A class that provides the primary interface to read PDF files.
class PdfReader {
  factory PdfReader() {
    return _singleton;
  }

  PdfReader._internal();

  static final PdfReader _singleton = PdfReader._internal();

  static PdfReader get instance => _singleton;

  Future<PdfDocument> loadPdfFromPath(
    String filePath,
  ) => MethodChannelEbookToolkit().openFromPath(filePath);

  Future<PdfDocument> loadPdfFromAssets(
    String assetName,
  ) => MethodChannelEbookToolkit().openAsset(assetName);

  Future<PdfDocument> loadPdfFromMemory(
    Uint8List fileInMemory,
  ) => MethodChannelEbookToolkit().openFromMemory(fileInMemory);
}
