import 'package:ebook_toolkit/src/pdf/entities/PDFDocument.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ebook_toolkit_platform_interface.dart';

/// An implementation of [EbookToolkitPlatform] that uses method channels.
class MethodChannelEbookToolkit extends EbookToolkitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ebook_toolkit');

  @override
  Future<PDFDocument> openAsset(String name) {
    // TODO: implement openAsset
    throw UnimplementedError();
  }

  @override
  Future<PDFDocument> openFromMemory(Uint8List data) {
    // TODO: implement openFromMemory
    throw UnimplementedError();
  }

  @override
  Future<PDFDocument> openFromPath(String filePath) {
    // TODO: implement openFromPath
    throw UnimplementedError();
  }
}
