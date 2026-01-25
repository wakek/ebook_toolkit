import 'package:equatable/equatable.dart';

class EpubNavigationContent extends Equatable {
  const EpubNavigationContent({
    this.id,
    this.source,
  });

  final String? id;
  final String? source;

  @override
  List<Object?> get props => [
    id,
    source,
  ];

  @override
  String toString() {
    return 'Source: $source';
  }

  EpubNavigationContent copyWith({
    String? id,
    String? source,
  }) {
    return EpubNavigationContent(
      id: id ?? this.id,
      source: source ?? this.source,
    );
  }
}
