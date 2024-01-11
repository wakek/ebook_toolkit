import 'package:ebook_toolkit/src/ebook_toolkit_method_channel.dart';
import 'package:ebook_toolkit/src/ebook_toolkit_platform_interface.dart';
import 'package:ebook_toolkit/src/pdf/entities/PdfPage.dart';
import 'package:flutter/services.dart';

class PdfDocument {
  final int id;

  /// File path, `asset:[ASSET_PATH]` or `memory:` depending on the content opened.
  final String sourceName;

  final int pageCount;

  /// PDF major version.
  final int verMajor;

  /// PDF minor version.
  final int verMinor;

  final List<PdfPage?> pages;

  PdfDocument({
    required this.id,
    required this.sourceName,
    required this.pageCount,
    required this.verMajor,
    required this.verMinor,
  }) : pages = List<PdfPage?>.filled(pageCount, null);

  Future<void> dispose() async {
    await methodChannel.invokeMethod('closePdf', id);
  }

  static Future<PdfDocument> openFromPath(String filePath) =>
      EbookToolkitPlatform.instance.openFromPath(filePath);

  static Future<PdfDocument> openAsset(String name) =>
      EbookToolkitPlatform.instance.openAsset(name);

  static Future<PdfDocument> openFromMemory(Uint8List data) =>
      EbookToolkitPlatform.instance.openFromMemory(data);

  Future<PdfPage> getPage(int pageIndex) async {
    if (pageIndex < 0 || pageIndex >= pageCount) {
      throw RangeError.range(pageIndex, 1, pageIndex, 'pageIndex');
    }
    var page = pages[pageIndex];

    if (page != null) {
      return page;
    }

    var map = (await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'getPageInfo',
      {'documentId': id, 'pageIndex': pageIndex},
    ))!;

    page = PdfPage(
      document: this,
      pageIndex: pageIndex,
      width: map['width'] as double,
      height: map['height'] as double,
    );
    pages[pageIndex] = page;

    return page;
  }

  @override
  String toString() => sourceName;

  @override
  int get hashCode => id;
}
