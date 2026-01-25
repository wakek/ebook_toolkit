import 'package:ebook_toolkit/src/epub/ref_entities/epub_book_ref.dart';
import 'package:ebook_toolkit/src/epub/ref_entities/epub_chapter_ref.dart';
import 'package:ebook_toolkit/src/epub/ref_entities/epub_text_content_file_ref.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_point.dart';

class ChapterReader {
  factory ChapterReader() {
    return _singleton;
  }

  ChapterReader._internal();

  static final ChapterReader _singleton = ChapterReader._internal();

  static ChapterReader get instance => _singleton;

  static List<EpubChapterRef> getChapters(EpubBookRef bookRef) {
    if (bookRef.schema!.navigation == null) {
      return <EpubChapterRef>[];
    }
    return getChaptersImpl(
      bookRef,
      bookRef.schema!.navigation!.navMap!.points!,
    );
  }

  static List<EpubChapterRef> getChaptersImpl(
    EpubBookRef bookRef,
    List<EpubNavigationPoint> navigationPoints,
  ) {
    final result = <EpubChapterRef>[];
    for (final navigationPoint in navigationPoints) {
      String? contentFileName;
      String? anchor;
      if (navigationPoint.content?.source == null) {
        continue;
      }

      final contentSourceAnchorCharIndex = navigationPoint.content!.source!
          .indexOf('#');

      if (contentSourceAnchorCharIndex == -1) {
        contentFileName = navigationPoint.content!.source;
        anchor = navigationPoint.content!.source;
      } else {
        contentFileName = navigationPoint.content!.source!.substring(
          0,
          contentSourceAnchorCharIndex,
        );
        anchor = navigationPoint.content!.source;
      }
      contentFileName = Uri.decodeFull(contentFileName!);
      EpubTextContentFileRef? htmlContentFileRef;
      if (!bookRef.content!.html!.containsKey(contentFileName)) {
        continue;
      }

      htmlContentFileRef = bookRef.content!.html![contentFileName];

      result.add(
        EpubChapterRef(
          epubTextContentFileRef: htmlContentFileRef,
          title: navigationPoint.navigationLabels!.first.text,
          contentFileName: contentFileName,
          anchor: Uri.decodeFull(anchor ?? ''),
          subChapters: getChaptersImpl(
            bookRef,
            navigationPoint.childNavigationPoints!,
          ),
        ),
      );
    }

    return result;
  }
}
