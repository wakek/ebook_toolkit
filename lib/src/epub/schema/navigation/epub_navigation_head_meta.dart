import 'package:equatable/equatable.dart';

class EpubNavigationHeadMeta extends Equatable {
  const EpubNavigationHeadMeta({
    this.name,
    this.content,
    this.scheme,
  });

  final String? name;
  final String? content;
  final String? scheme;

  @override
  List<Object?> get props => [
    name,
    content,
    scheme,
  ];

  @override
  String toString() {
    return 'EpubNavigationHeadMeta{name: $name, content: $content, scheme: $scheme}';
  }

  EpubNavigationHeadMeta copyWith({
    String? name,
    String? content,
    String? scheme,
  }) {
    return EpubNavigationHeadMeta(
      name: name ?? this.name,
      content: content ?? this.content,
      scheme: scheme ?? this.scheme,
    );
  }
}
