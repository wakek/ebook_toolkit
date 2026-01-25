import 'package:ebook_toolkit/src/epub/schema/navigation/epub_metadata.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_label.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_page_target_type.dart';
import 'package:equatable/equatable.dart';

class EpubNavigationPageTarget extends Equatable {
  const EpubNavigationPageTarget({
    this.id,
    this.value,
    this.type,
    this.navigationClass,
    this.playOrder,
    this.navigationLabels,
    this.content,
  });

  final String? id;
  final String? value;
  final EpubNavigationPageTargetType? type;
  final String? navigationClass;
  final String? playOrder;
  final List<EpubNavigationLabel>? navigationLabels;
  final EpubNavigationContent? content;

  @override
  List<Object?> get props => [
    id,
    value,
    type,
    navigationClass,
    playOrder,
    navigationLabels,
    content,
  ];

  EpubNavigationPageTarget copyWith({
    String? id,
    String? value,
    EpubNavigationPageTargetType? type,
    String? navigationClass,
    String? playOrder,
    List<EpubNavigationLabel>? navigationLabels,
    EpubNavigationContent? content,
  }) {
    return EpubNavigationPageTarget(
      id: id ?? this.id,
      value: value ?? this.value,
      type: type ?? this.type,
      navigationClass: navigationClass ?? this.navigationClass,
      playOrder: playOrder ?? this.playOrder,
      navigationLabels: navigationLabels ?? this.navigationLabels,
      content: content ?? this.content,
    );
  }
}
