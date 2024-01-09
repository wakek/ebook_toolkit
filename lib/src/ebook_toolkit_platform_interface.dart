import 'dart:typed_data';

import 'package:ebook_toolkit/src/pdf/entities/PDFDocument.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ebook_toolkit_method_channel.dart';

abstract class EbookToolkitPlatform extends PlatformInterface {
  /// Constructs a EbookToolkitPlatform.
  EbookToolkitPlatform() : super(token: _token);

  static final Object _token = Object();

  static EbookToolkitPlatform _instance = MethodChannelEbookToolkit();

  /// The default instance of [EbookToolkitPlatform] to use.
  ///
  /// Defaults to [MethodChannelEbookToolkit].
  static EbookToolkitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [EbookToolkitPlatform] when
  /// they register themselves.
  static set instance(EbookToolkitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Opening the specified file.
  Future<PDFDocument> openFromPath(String filePath);

  /// Opening the specified asset.
  Future<PDFDocument> openAsset(String name);

  /// Opening the PDF on memory.
  Future<PDFDocument> openFromMemory(Uint8List data);
}
