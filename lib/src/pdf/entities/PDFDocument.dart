import 'package:ebook_toolkit/src/ebook_toolkit_method_channel.dart';
import 'package:ebook_toolkit/src/ebook_toolkit_platform_interface.dart';
import 'package:ebook_toolkit/src/pdf/entities/PDFPage.dart';
import 'package:flutter/services.dart';

class PDFDocument {
  final int id;

  /// File path, `asset:[ASSET_PATH]` or `memory:` depending on the content opened.
  final String sourceName;

  final int pageCount;

  /// PDF major version.
  final int verMajor;

  /// PDF minor version.
  final int verMinor;

  final bool isEncrypted;

  final bool allowsCopying;

  final bool allowsPrinting;

  final List<PDFPage?> pages;

  PDFDocument({
    required this.id,
    required this.sourceName,
    required this.pageCount,
    required this.verMajor,
    required this.verMinor,
    required this.isEncrypted,
    required this.allowsCopying,
    required this.allowsPrinting,
  }) : pages = List<PDFPage?>.filled(pageCount, null);

  Future<void> dispose() async {
    await methodChannel.invokeMethod('close', id);
  }

  static Future<PDFDocument> openFromPath(String filePath) =>
      EbookToolkitPlatform.instance.openFromPath(filePath);

  static Future<PDFDocument> openAsset(String name) =>
      EbookToolkitPlatform.instance.openAsset(name);

  static Future<PDFDocument> openFromMemory(Uint8List data) =>
      EbookToolkitPlatform.instance.openFromMemory(data);

  Future<PDFPage> getPage(int pageIndex) async {
    if (pageIndex < 0 || pageIndex > pageIndex) {
      throw RangeError.range(pageIndex, 1, pageIndex, 'pageIndex');
    }
    var page = pages[pageIndex];

    if (page != null) {
      return page;
    }

    var map = (await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'getPage',
      {'docId': id, 'pageIndex': pageIndex},
    ))!;

    page = PDFPage(
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
