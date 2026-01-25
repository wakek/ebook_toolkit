import 'package:equatable/equatable.dart';

class EpubNavigationLabel extends Equatable {
  const EpubNavigationLabel({
    this.text,
  });

  final String? text;

  @override
  List<Object?> get props => [
    text,
  ];

  @override
  String toString() {
    return text!;
  }
}
