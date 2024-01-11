import 'dart:async';

import 'package:ebook_toolkit/src/pdf/entities/PdfDocument.dart';
import 'package:ebook_toolkit/src/pdf/entities/PdfPage.dart';
import 'package:flutter/services.dart';

import 'ebook_toolkit_platform_interface.dart';

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
      await methodChannel.invokeMethod('openPdfFromFilePath', filePath),
      filePath,
    );
  }

  @override
  Future<PdfDocument> openAsset(String assetName) async {
    return _open(
      await methodChannel.invokeMethod('openAssetPdf', assetName),
      'asset:$assetName',
    );
  }

  @override
  Future<PdfDocument> openFromMemory(Uint8List data) async {
    return _open(
      await methodChannel.invokeMethod('openPdfFromMemory', data),
      'memory:${data.hashCode}',
    );
  }

  @override
  Future<PdfPageImageTexture> createTexture({
    required FutureOr<PdfDocument> pdfDocument,
    required int pageIndex,
  }) async {
    final textureId = await methodChannel.invokeMethod<int>('allocTexture');

    return PdfPageImageTexture(
      pdfDocument: await pdfDocument,
      pageIndex: pageIndex,
      texId: textureId!,
    );
  }
}
