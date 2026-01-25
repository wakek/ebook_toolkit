import 'package:ebook_toolkit/src/epub/schema/navigation/epub_metadata.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_label.dart';
import 'package:equatable/equatable.dart';

class EpubNavigationTarget extends Equatable {
  const EpubNavigationTarget({
    this.id,
    this.navigationClass,
    this.value,
    this.playOrder,
    this.navigationLabels,
    this.content,
  });

  final String? id;
  final String? navigationClass;
  final String? value;
  final String? playOrder;
  final List<EpubNavigationLabel>? navigationLabels;
  final EpubNavigationContent? content;

  @override
  List<Object?> get props => [
    id,
    navigationClass,
    value,
    playOrder,
    navigationLabels,
    content,
  ];

  @override
  String toString() {
    return 'EpubNavigationTarget{id: $id, navigationClass: $navigationClass, value: $value, playOrder: $playOrder, navigationLabels: $navigationLabels, content: $content}';
  }

  EpubNavigationTarget copyWith({
    String? id,
    String? navigationClass,
    String? value,
    String? playOrder,
    List<EpubNavigationLabel>? navigationLabels,
    EpubNavigationContent? content,
  }) {
    return EpubNavigationTarget(
      id: id ?? this.id,
      navigationClass: navigationClass ?? this.navigationClass,
      value: value ?? this.value,
      playOrder: playOrder ?? this.playOrder,
      navigationLabels: navigationLabels ?? this.navigationLabels,
      content: content ?? this.content,
    );
  }
}
