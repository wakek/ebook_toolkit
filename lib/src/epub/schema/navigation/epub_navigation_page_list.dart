import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_page_target.dart';
import 'package:equatable/equatable.dart';

class EpubNavigationPageList extends Equatable {
  const EpubNavigationPageList({
    this.targets,
  });

  final List<EpubNavigationPageTarget>? targets;

  @override
  List<Object?> get props => [
    targets,
  ];

  @override
  String toString() {
    return 'EpubNavigationPageList{targets: $targets}';
  }

  EpubNavigationPageList copyWith({
    List<EpubNavigationPageTarget>? targets,
  }) {
    return EpubNavigationPageList(
      targets: targets ?? this.targets,
    );
  }
}
