import 'package:equatable/equatable.dart';

class EpubMetadataContributor extends Equatable {
  const EpubMetadataContributor({
    this.contributor,
    this.fileAs,
    this.role,
  });

  final String? contributor;
  final String? fileAs;
  final String? role;

  @override
  List<Object?> get props => [
    contributor,
    fileAs,
    role,
  ];

  EpubMetadataContributor copyWith({
    String? contributor,
    String? fileAs,
    String? role,
  }) {
    return EpubMetadataContributor(
      contributor: contributor ?? this.contributor,
      fileAs: fileAs ?? this.fileAs,
      role: role ?? this.role,
    );
  }
}
