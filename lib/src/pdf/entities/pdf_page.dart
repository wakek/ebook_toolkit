import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ebook_toolkit/src/ebook_toolkit_method_channel.dart';
import 'package:ebook_toolkit/src/ebook_toolkit_platform_interface.dart';
import 'package:ebook_toolkit/src/pdf/entities/pdf_document.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' as flutter_material;
import 'package:image/image.dart';

class PdfPage extends Equatable {
  const PdfPage({
    required this.document,
    required this.pageIndex,
    required this.width,
    required this.height,
  });

  final PdfDocument document;

  final int pageIndex;

  /// The page width in points (1/72").
  final double width;

  /// The page height in points (1/72").
  final double height;

  @override
  List<Object?> get props => [
    document,
    pageIndex,
    width,
    height,
  ];

  @override
  String toString() => '$document:page=$pageIndex';

  Future<PDFPageImage> render({
    int x = 0,
    int y = 0,
    int? width,
    int? height,
    double? fullWidth,
    double? fullHeight,
    bool? backgroundFill,
    bool? allowAntialiasingIOS,
  }) async {
    return PDFPageImage._render(
      document,
      pageIndex,
      x: x,
      y: y,
      width: width,
      height: height,
      fullWidth: fullWidth,
      fullHeight: fullHeight,
      backgroundFill: backgroundFill,
      allowAntialiasingIOS: allowAntialiasingIOS,
    );
  }
}

class PDFPageImage {
  PDFPageImage({
    required this.pageIndex,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.fullWidth,
    required this.fullHeight,
    required this.pageWidth,
    required this.pageHeight,
    required Uint8List pixels,
    Pointer<Uint8>? buffer,
  }) : _pixels = pixels,
       _buffer = buffer;
  final int pageIndex;

  /// Left X coordinate of the rendered area in pixels.
  final int x;

  /// Top Y coordinate of the rendered area in pixels.
  final int y;

  /// Width of the rendered area in pixels.
  final int width;

  /// Height of the rendered area in pixels.
  final int height;

  /// Full width of the rendered page image in pixels.
  final double fullWidth;

  /// Full height of the rendered page image in pixels.
  final double fullHeight;

  /// PDF page width in points (width in pixels at 72 dpi).
  final double pageWidth;

  /// PDF page height in points (height in pixels at 72 dpi).
  final double pageHeight;

  final Uint8List _pixels;
  Pointer<Uint8>? _buffer;
  Image? _imageCached;

  /// ARGB pixels in byte array.
  Uint8List get pixels => _pixels;

  /// Pointer to the internal ARGB image buffer if available; the size is calculated by `width*height*4`.
  Pointer<Uint8>? get buffer => _buffer;

  Future<void> dispose() async {
    _imageCached = null;
    if (_buffer != null) {
      await methodChannel.invokeMethod('releaseBuffer', _buffer!.address);
      _buffer = null;
    }
  }

  /// Create cached [Image] for the page.
  Image createImageIfNotAvailable() {
    _imageCached ??= _decodeArgb(width, height, _pixels);
    return _imageCached!;
  }

  /// Get [Image] for the object if available; otherwise null.
  /// If you want to ensure that the [Image] is available, call [createImageIfNotAvailable].
  Image? get imageIfAvailable => _imageCached;

  Image createImageDetached() => _decodeArgb(width, height, _pixels);

  static Future<PDFPageImage> _render(
    PdfDocument document,
    int pageIndex, {
    int? x,
    int? y,
    int? width,
    int? height,
    double? fullWidth,
    double? fullHeight,
    bool? backgroundFill,
    bool? allowAntialiasingIOS,
  }) async {
    final obj = (await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'render',
      {
        'documentId': document.id,
        'pageIndex': pageIndex,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'fullWidth': fullWidth,
        'fullHeight': fullHeight,
        'backgroundFill': backgroundFill,
        'allowAntialiasingIOS': allowAntialiasingIOS,
      },
    ))!;
    final retWidth = obj['width'] as int;
    final retHeight = obj['height'] as int;
    Pointer<Uint8>? ptr;
    final pixels =
        obj['data'] as Uint8List? ??
        () {
          final addr = obj['addr'] as int;
          final size = obj['size'] as int;
          ptr = Pointer<Uint8>.fromAddress(addr);
          return ptr!.asTypedList(size);
        }();

    return PDFPageImage(
      pageIndex: obj['pageIndex'] as int,
      x: obj['x'] as int,
      y: obj['y'] as int,
      width: retWidth,
      height: retHeight,
      fullWidth: obj['fullWidth'] as double,
      fullHeight: obj['fullHeight'] as double,
      pageWidth: obj['pageWidth'] as double,
      pageHeight: obj['pageHeight'] as double,
      pixels: pixels,
      buffer: ptr,
    );
  }

  /// Decode ARGB raw image from native code.
  static Image _decodeArgb(int width, int height, Uint8List pixels) {
    return Image.fromBytes(
      width: width,
      height: height,
      bytes: pixels.buffer,
      order: ChannelOrder.argb,
    );
  }
}

/// Very limited support for Flutter's [flutter_material.Texture] based drawing.
/// Because it does not transfer the rendered image via platform channel,
/// it could be faster and more efficient than the [PDFPageImage] based rendering process.
// ignore: must_be_immutable
class PdfPageImageTexture extends Equatable {
  PdfPageImageTexture({
    required this.pdfDocument,
    required this.pageIndex,
    required this.texId,
  });

  final PdfDocument pdfDocument;
  final int pageIndex;
  final int texId;

  int? _texWidth;
  int? _texHeight;

  @override
  List<Object?> get props => [
    pdfDocument,
    pageIndex,
    texId,
  ];

  int? get texWidth => _texWidth;

  int? get texHeight => _texHeight;

  bool get hasUpdatedTexture => _texWidth != null;

  PdfDocument get _document => pdfDocument;

  /// Create a new Flutter Texture. The object should be released by calling [dispose] method after use it.
  static Future<PdfPageImageTexture> create({
    required FutureOr<PdfDocument> pdfDocument,
    required int pageIndex,
  }) => EbookToolkitPlatform.instance.createTexture(
    pdfDocument: pdfDocument,
    pageIndex: pageIndex,
  );

  /// Extract sub-rectangle ([x],[y],[width],[height]) of the PDF page scaled to [fullWidth] x [fullHeight] size.
  /// If [backgroundFill] is true, the sub-rectangle is filled with white before rendering the page content.
  /// Returns true if succeeded.
  /// Returns true if succeeded.
  Future<bool> extractSubrect({
    required int width,
    required int height,
    int x = 0,
    int y = 0,
    double? fullWidth,
    double? fullHeight,
    bool backgroundFill = true,
    bool allowAntialiasingIOS = true,
  }) async {
    final result = (await methodChannel.invokeMethod<int>('updateTexture', {
      'documentId': _document.id,
      'pageIndex': pageIndex,
      'texId': texId,
      'width': width,
      'height': height,
      'srcX': x,
      'srcY': y,
      'fullWidth': fullWidth,
      'fullHeight': fullHeight,
      'backgroundFill': backgroundFill,
      'allowAntialiasingIOS': allowAntialiasingIOS,
    }))!;
    if (result >= 0) {
      _texWidth = width;
      _texHeight = height;
    }
    return result >= 0;
  }

  /// Release the object.
  Future<void> dispose() => methodChannel.invokeMethod('releaseTexture', texId);
}
