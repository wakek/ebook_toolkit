import 'package:equatable/equatable.dart';

class EpubMetadataIdentifier extends Equatable {
  const EpubMetadataIdentifier({this.id, this.scheme, this.identifier});

  final String? id;
  final String? scheme;
  final String? identifier;

  @override
  List<Object?> get props => [
    id,
    scheme,
    identifier,
  ];

  @override
  String toString() {
    return 'EpubMetadataIdentifier{id: $id, scheme: $scheme, identifier: $identifier}';
  }

  EpubMetadataIdentifier copyWith({
    String? id,
    String? scheme,
    String? identifier,
  }) {
    return EpubMetadataIdentifier(
      id: id ?? this.id,
      scheme: scheme ?? this.scheme,
      identifier: identifier ?? this.identifier,
    );
  }
}
