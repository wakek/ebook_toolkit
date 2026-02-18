import 'package:ebook_toolkit/src/epub/entities/epub_content_type.dart';
import 'package:ebook_toolkit/src/epub/ref_entities/epub_book_ref.dart';
import 'package:ebook_toolkit/src/epub/ref_entities/epub_byte_content_file_ref.dart';
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
    const result = EpubContentRef();

    for (final manifestItem in bookRef.schema!.package!.manifest!.items!) {
      final fileName = Uri.decodeFull(manifestItem.href ?? '');
      final contentMimeType = manifestItem.mediaType!;
      final contentType = getContentTypeByContentMimeType(contentMimeType);
      switch (contentType) {
        case .xhtml_1_1:
        case .css:
        case .oeb1Document:
        case .oeb1Css:
        case .xml:
        case .dtbook:
        case .dtbookNcx:
          final epubTextContentFile = EpubTextContentFileRef(
            epubBookRef: bookRef,
            fileName: fileName,
            contentMimeType: contentMimeType,
            contentType: contentType,
          );

          switch (contentType) {
            case EpubContentType.xhtml_1_1:
              (result.html ?? {})[fileName] = epubTextContentFile;
            case EpubContentType.css:
              (result.css ?? {})[fileName] = epubTextContentFile;
            case EpubContentType.dtbook:
            case EpubContentType.dtbookNcx:
            case EpubContentType.oeb1Document:
            case EpubContentType.xml:
            case EpubContentType.oeb1Css:
            case EpubContentType.imageGif:
            case EpubContentType.imageJpeg:
            case EpubContentType.imagePng:
            case EpubContentType.imageSvg:
            case EpubContentType.imageBmp:
            case EpubContentType.fontTruetype:
            case EpubContentType.fontOpentype:
            case EpubContentType.other:
              break;
          }
          result.allFiles![fileName] = epubTextContentFile;
        case .fontOpentype:
        case .imageGif:
        case .imageJpeg:
        case .imagePng:
        case .imageSvg:
        case .imageBmp:
        case .fontTruetype:
        case .other:
          final epubByteContentFile = EpubByteContentFileRef(
            epubBookRef: bookRef,
            fileName: fileName,
            contentMimeType: contentMimeType,
            contentType: contentType,
          );

          switch (contentType) {
            case EpubContentType.imageGif:
            case EpubContentType.imageJpeg:
            case EpubContentType.imagePng:
            case EpubContentType.imageSvg:
            case EpubContentType.imageBmp:
              (result.images ?? {})[fileName] = epubByteContentFile;
            case EpubContentType.fontTruetype:
            case EpubContentType.fontOpentype:
              (result.fonts ?? {})[fileName] = epubByteContentFile;
            case EpubContentType.css:
            case EpubContentType.xhtml_1_1:
            case EpubContentType.dtbook:
            case EpubContentType.dtbookNcx:
            case EpubContentType.oeb1Document:
            case EpubContentType.xml:
            case EpubContentType.oeb1Css:
            case EpubContentType.other:
              break;
          }
          result.allFiles![fileName] = epubByteContentFile;
      }
    }
    return result;
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
