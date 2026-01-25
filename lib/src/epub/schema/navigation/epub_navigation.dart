import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_doc_author.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_doc_title.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_head.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_list.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_map.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_page_list.dart';
import 'package:equatable/equatable.dart';

class EpubNavigation extends Equatable {
  const EpubNavigation({
    this.head,
    this.docTitle,
    this.docAuthors,
    this.navMap,
    this.pageList,
    this.navLists,
  });

  final EpubNavigationHead? head;
  final EpubNavigationDocTitle? docTitle;
  final List<EpubNavigationDocAuthor>? docAuthors;
  final EpubNavigationMap? navMap;
  final EpubNavigationPageList? pageList;
  final List<EpubNavigationList>? navLists;

  @override
  List<Object?> get props => [
    head,
    docTitle,
    docAuthors,
    navMap,
    pageList,
    navLists,
  ];

  @override
  String toString() {
    return 'EpubNavigation{head: $head, docTitle: $docTitle, docAuthors: $docAuthors, navMap: $navMap, pageList: $pageList, navLists: $navLists}';
  }

  EpubNavigation copyWith({
    EpubNavigationHead? head,
    EpubNavigationDocTitle? docTitle,
    List<EpubNavigationDocAuthor>? docAuthors,
    EpubNavigationMap? navMap,
    EpubNavigationPageList? pageList,
    List<EpubNavigationList>? navLists,
  }) {
    return EpubNavigation(
      head: head ?? this.head,
      docTitle: docTitle ?? this.docTitle,
      docAuthors: docAuthors ?? this.docAuthors,
      navMap: navMap ?? this.navMap,
      pageList: pageList ?? this.pageList,
      navLists: navLists ?? this.navLists,
    );
  }
}
