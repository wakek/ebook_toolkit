import 'package:equatable/equatable.dart';

class EpubMetadataCreator extends Equatable {
  const EpubMetadataCreator({
    this.creator,
    this.fileAs,
    this.role,
  });

  final String? creator;
  final String? fileAs;
  final String? role;

  @override
  List<Object?> get props => [
    creator,
    fileAs,
    role,
  ];

  EpubMetadataCreator copyWith({
    String? creator,
    String? fileAs,
    String? role,
  }) {
    return EpubMetadataCreator(
      creator: creator ?? this.creator,
      fileAs: fileAs ?? this.fileAs,
      role: role ?? this.role,
    );
  }
}
