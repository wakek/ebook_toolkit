import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:ui';

import 'package:ebook_toolkit/src/ebook_toolkit_method_channel.dart';
import 'package:ebook_toolkit/src/pdf/entities/PDFDocument.dart';

class PDFPage {
  final PDFDocument document;

  final int pageIndex;

  /// The page width in points (1/72").
  final double width;

  /// The page height in points (1/72").
  final double height;

  PDFPage({
    required this.document,
    required this.pageIndex,
    required this.width,
    required this.height,
  });

  @override
  bool operator ==(dynamic other) =>
      other is PDFPage &&
      other.document == document &&
      other.pageIndex == pageIndex;

  @override
  int get hashCode => document.hashCode ^ (pageIndex + 1);

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
  })  : _pixels = pixels,
        _buffer = buffer;

  /// RGBA pixels in byte array.
  Uint8List get pixels => _pixels;

  /// Pointer to the internal RGBA image buffer if available; the size is calculated by `width*height*4`.
  Pointer<Uint8>? get buffer => _buffer;

  void dispose() {
    _imageCached?.dispose();
    _imageCached = null;
    if (_buffer != null) {
      methodChannel.invokeMethod('releaseBuffer', _buffer!.address);
      _buffer = null;
    }
  }

  /// Create cached [Image] for the page.
  Future<Image> createImageIfNotAvailable() async {
    _imageCached ??= await _decodeRgba(width, height, _pixels);
    return _imageCached!;
  }

  /// Get [Image] for the object if available; otherwise null.
  /// If you want to ensure that the [Image] is available, call [createImageIfNotAvailable].
  Image? get imageIfAvailable => _imageCached;

  Future<Image> createImageDetached() async =>
      await _decodeRgba(width, height, _pixels);

  static Future<PDFPageImage> _render(
    PDFDocument document,
    int pageNumber, {
    int? x,
    int? y,
    int? width,
    int? height,
    double? fullWidth,
    double? fullHeight,
    bool? backgroundFill,
    bool? allowAntialiasingIOS,
  }) async {
    final obj =
        (await methodChannel.invokeMethod<Map<dynamic, dynamic>>('render', {
      'docId': document.id,
      'pageNumber': pageNumber,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'fullWidth': fullWidth,
      'fullHeight': fullHeight,
      'backgroundFill': backgroundFill,
      'allowAntialiasingIOS': allowAntialiasingIOS,
    }))!;
    final retWidth = obj['width'] as int;
    final retHeight = obj['height'] as int;
    Pointer<Uint8>? ptr;
    var pixels = obj['data'] as Uint8List? ??
        () {
          final addr = obj['addr'] as int;
          final size = obj['size'] as int;
          ptr = Pointer<Uint8>.fromAddress(addr);
          return ptr!.asTypedList(size);
        }();

    return PDFPageImage(
        pageIndex: obj['pageNumber'] as int,
        x: obj['x'] as int,
        y: obj['y'] as int,
        width: retWidth,
        height: retHeight,
        fullWidth: obj['fullWidth'] as double,
        fullHeight: obj['fullHeight'] as double,
        pageWidth: obj['pageWidth'] as double,
        pageHeight: obj['pageHeight'] as double,
        pixels: pixels,
        buffer: ptr);
  }

  /// Decode RGBA raw image from native code.
  static Future<Image> _decodeRgba(int width, int height, Uint8List pixels) {
    final comp = Completer<Image>();
    decodeImageFromPixels(
      pixels,
      width,
      height,
      PixelFormat.rgba8888,
      (image) => comp.complete(image),
    );
    return comp.future;
  }
}
