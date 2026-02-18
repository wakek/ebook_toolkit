import 'dart:async';

import 'package:ebook_toolkit/src/ebook_toolkit_platform_interface.dart';
import 'package:ebook_toolkit/src/pdf/entities/pdf_document.dart';
import 'package:ebook_toolkit/src/pdf/entities/pdf_page.dart';
import 'package:flutter/services.dart';

const MethodChannel methodChannel = MethodChannel('ebook_toolkit');

/// An implementation of [EbookToolkitPlatform] that uses method channels.
class MethodChannelEbookToolkit extends EbookToolkitPlatform {
  PdfDocument _open(Map<dynamic, dynamic> map, String sourceName) {
    return PdfDocument(
      id: map['documentId'] as int,
      sourceName: sourceName,
      pageCount: map['pageCount'] as int,
      verMajor: map['verMajor'] as int,
      verMinor: map['verMinor'] as int,
    );
  }

  @override
  Future<PdfDocument> openFromPath(String filePath) async {
    return _open(
      await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
            'openPdfFromFilePath',
            filePath,
          ) ??
          {},
      filePath,
    );
  }

  @override
  Future<PdfDocument> openAsset(String assetName) async {
    return _open(
      await methodChannel.invokeMethod<Map<dynamic, dynamic>?>(
            'openAssetPdf',
            assetName,
          ) ??
          {},
      'asset:$assetName',
    );
  }

  @override
  Future<PdfDocument> openFromMemory(Uint8List data) async {
    return _open(
      await methodChannel.invokeMethod<Map<dynamic, dynamic>?>(
            'openPdfFromMemory',
            data,
          ) ??
          {},
      'memory:${data.hashCode}',
    );
  }

  @override
  Future<PdfPageImageTexture> createTexture({
    required FutureOr<PdfDocument> pdfDocument,
    required int pageIndex,
  }) async {
    final textureId = await methodChannel.invokeMethod<int>('allocTexture');
    if (textureId == null) {
      throw Exception('Could not allocate texture');
    }

    return PdfPageImageTexture(
      pdfDocument: await pdfDocument,
      pageIndex: pageIndex,
      texId: textureId,
    );
  }
}
