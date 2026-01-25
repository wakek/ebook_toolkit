import 'package:equatable/equatable.dart';

class EpubGuideReference extends Equatable {
  const EpubGuideReference({
    this.type,
    this.title,
    this.href,
  });

  final String? type;
  final String? title;
  final String? href;

  @override
  List<Object?> get props => [
    type,
    title,
    href,
  ];

  @override
  String toString() {
    return 'Type: $type, Href: $href';
  }

  EpubGuideReference copyWith({
    String? type,
    String? title,
    String? href,
  }) {
    return EpubGuideReference(
      type: type ?? this.type,
      title: title ?? this.title,
      href: href ?? this.href,
    );
  }
}
