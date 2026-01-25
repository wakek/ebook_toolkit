import 'package:equatable/equatable.dart';

class EpubMetadataMeta extends Equatable {
  const EpubMetadataMeta({
    this.name,
    this.content,
    this.id,
    this.refines,
    this.property,
    this.scheme,
    this.attributes,
  });

  final String? name;
  final String? content;
  final String? id;
  final String? refines;
  final String? property;
  final String? scheme;
  final Map<String, String>? attributes;

  @override
  List<Object?> get props => [
    name,
    content,
    id,
    refines,
    property,
    scheme,
    attributes,
  ];

  EpubMetadataMeta copyWith({
    String? name,
    String? content,
    String? id,
    String? refines,
    String? property,
    String? scheme,
    Map<String, String>? attributes,
  }) {
    return EpubMetadataMeta(
      name: name ?? this.name,
      content: content ?? this.content,
      id: id ?? this.id,
      refines: refines ?? this.refines,
      property: property ?? this.property,
      scheme: scheme ?? this.scheme,
      attributes: attributes ?? this.attributes,
    );
  }
}
