import 'package:ebook_toolkit/src/pdf/entities/PDFDocument.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ebook_toolkit_platform_interface.dart';

const MethodChannel methodChannel = MethodChannel('ebook_toolkit');


/// An implementation of [EbookToolkitPlatform] that uses method channels.
class MethodChannelEbookToolkit extends EbookToolkitPlatform {

  PDFDocument _open(Map<dynamic, dynamic> map, String sourceName) {
    return PDFDocument._(
      sourceName: sourceName,
      docId: map['docId'] as int,
      pageCount: map['pageCount'] as int,
      verMajor: map['verMajor'] as int,
      verMinor: map['verMinor'] as int,
      isEncrypted: map['isEncrypted'] as bool,
      allowsCopying: map['allowsCopying'] as bool,
      allowsPrinting: map['allowsPrinting'] as bool,
      //isUnlocked: obj['isUnlocked'] as bool
    );
  }

  @override
  Future<PDFDocument> openAsset(String name) {
    return _open(await methodChannel.invokeMethod('file', filePath), filePath);
  }

  @override
  Future<PDFDocument> openFromMemory(Uint8List data) {
    return _open(await methodChannel.invokeMethod('asset', name), 'asset:$name');
  }

  @override
  Future<PDFDocument> openFromPath(String filePath) {
    return _open(await methodChannel.invokeMethod('data', data), 'memory:');
  }
}
