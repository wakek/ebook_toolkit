import 'package:ebook_toolkit/ebook_toolkit.dart';
import 'package:ebook_toolkit/src/epub/entities/epub_content_type.dart';
import 'package:ebook_toolkit/src/epub/ref_entities/epub_book_ref.dart';
import 'package:ebook_toolkit/src/epub/ref_entities/epub_byte_content_file_ref.dart';
import 'package:ebook_toolkit/src/epub/ref_entities/epub_content_file_ref.dart';
import 'package:ebook_toolkit/src/epub/ref_entities/epub_content_ref.dart';
import 'package:ebook_toolkit/src/epub/ref_entities/epub_text_content_file_ref.dart';

class ContentReader {
  factory ContentReader() {
    return _singleton;
  }

  ContentReader._internal();

  static final ContentReader _singleton = ContentReader._internal();

  static ContentReader get instance => _singleton;

  EpubContentRef parseContentMap(EpubBookRef bookRef) {
    final html = <String, EpubTextContentFileRef>{};
    final css = <String, EpubTextContentFileRef>{};
    final images = <String, EpubByteContentFileRef>{};
    final fonts = <String, EpubByteContentFileRef>{};
    final allFiles = <String, EpubContentFileRef>{};

    for (final manifestItem
        in bookRef.schema?.package?.manifest?.items ?? <EpubManifestItem>[]) {
      final fileName = Uri.decodeFull(manifestItem.href ?? '');
      final contentMimeType = manifestItem.mediaType ?? '';
      final contentType = getContentTypeByContentMimeType(contentMimeType);
      switch (contentType) {
        case EpubContentType.xhtml_1_1:
        case EpubContentType.css:
        case EpubContentType.oeb1Document:
        case EpubContentType.oeb1Css:
        case EpubContentType.xml:
        case EpubContentType.dtbook:
        case EpubContentType.dtbookNcx:
          final epubTextContentFile = EpubTextContentFileRef(
            epubBookRef: bookRef,
            fileName: fileName,
            contentMimeType: contentMimeType,
            contentType: contentType,
          );

          switch (contentType) {
            case EpubContentType.xhtml_1_1:
              html[fileName] = epubTextContentFile;
            case EpubContentType.css:
              css[fileName] = epubTextContentFile;
            case .dtbook:
            case .dtbookNcx:
            case .oeb1Document:
            case .xml:
            case .oeb1Css:
            case .imageGif:
            case .imageJpeg:
            case .imagePng:
            case .imageSvg:
            case .imageBmp:
            case .fontTruetype:
            case .fontOpentype:
            case .other:
              break;
          }
          allFiles[fileName] = epubTextContentFile;
        case EpubContentType.fontOpentype:
        case EpubContentType.imageGif:
        case EpubContentType.imageJpeg:
        case EpubContentType.imagePng:
        case EpubContentType.imageSvg:
        case EpubContentType.imageBmp:
        case EpubContentType.fontTruetype:
        case EpubContentType.other:
          final epubByteContentFile = EpubByteContentFileRef(
            epubBookRef: bookRef,
            fileName: fileName,
            contentMimeType: contentMimeType,
            contentType: contentType,
          );

          switch (contentType) {
            case .imageGif:
            case .imageJpeg:
            case .imagePng:
            case .imageSvg:
            case .imageBmp:
              images[fileName] = epubByteContentFile;
            case .fontTruetype:
            case .fontOpentype:
              fonts[fileName] = epubByteContentFile;
            case .xhtml_1_1:
            case .dtbook:
            case .dtbookNcx:
            case .oeb1Document:
            case .xml:
            case .css:
            case .oeb1Css:
            case .other:
              break;
          }
          allFiles[fileName] = epubByteContentFile;
      }
    }

    return EpubContentRef(
      html: html,
      css: css,
      images: images,
      fonts: fonts,
      allFiles: allFiles,
    );
  }

  EpubContentType getContentTypeByContentMimeType(
    String contentMimeType,
  ) {
    switch (contentMimeType.toLowerCase()) {
      case 'application/xhtml+xml':
      case 'text/html':
        return EpubContentType.xhtml_1_1;
      case 'application/x-dtbook+xml':
        return EpubContentType.dtbook;
      case 'application/x-dtbncx+xml':
        return EpubContentType.dtbookNcx;
      case 'text/x-oeb1-document':
        return EpubContentType.oeb1Document;
      case 'application/xml':
        return EpubContentType.xml;
      case 'text/css':
        return EpubContentType.css;
      case 'text/x-oeb1-css':
        return EpubContentType.oeb1Css;
      case 'image/gif':
        return EpubContentType.imageGif;
      case 'image/jpeg':
        return EpubContentType.imageJpeg;
      case 'image/png':
        return EpubContentType.imagePng;
      case 'image/svg+xml':
        return EpubContentType.imageSvg;
      case 'image/bmp':
        return EpubContentType.imageBmp;
      case 'font/truetype':
        return EpubContentType.fontTruetype;
      case 'font/opentype':
        return EpubContentType.fontOpentype;
      case 'application/vnd.ms-opentype':
        return EpubContentType.fontOpentype;
      default:
        return EpubContentType.other;
    }
  }
}
