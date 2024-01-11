import 'dart:typed_data';

import 'package:ebook_toolkit/src/ebook_toolkit_method_channel.dart';
import 'package:ebook_toolkit/src/pdf/entities/PdfDocument.dart';

/// A class that provides the primary interface to read PDF files.
class PdfReader {
  static Future<PdfDocument> loadPdfFromPath(
    String filePath,
  ) =>
      MethodChannelEbookToolkit().openFromPath(filePath);

  static Future<PdfDocument> loadPdfFromAssets(
    String assetName,
  ) =>
      MethodChannelEbookToolkit().openAsset(assetName);

  static Future<PdfDocument> loadPdfFromMemory(
    Uint8List fileInMemory,
  ) =>
      MethodChannelEbookToolkit().openFromMemory(fileInMemory);
}
