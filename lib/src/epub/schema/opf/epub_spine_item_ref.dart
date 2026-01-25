import 'package:equatable/equatable.dart';

class EpubSpineItemRef extends Equatable {
  const EpubSpineItemRef({
    this.idRef,
    this.isLinear,
  });

  @override
  List<Object?> get props => [idRef, isLinear];

  final String? idRef;
  final bool? isLinear;

  @override
  String toString() {
    return 'IdRef: $idRef';
  }
}
