import 'package:ebook_toolkit/src/pdf/entities/PDFDocument.dart';

abstract class PDFPage {
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

  Future<void> dispose();

  @override
  bool operator ==(dynamic other) =>
      other is PDFPage &&
      other.document == document &&
      other.pageIndex == pageIndex;

  @override
  int get hashCode => document.hashCode ^ (pageIndex + 1);

  @override
  String toString() => '$document:page=$pageIndex';
}
