import 'package:equatable/equatable.dart';

class EpubMetadataDate extends Equatable {
  const EpubMetadataDate({
    this.date,
    this.event,
  });

  final String? date;
  final String? event;

  @override
  List<Object?> get props => [
    date,
    event,
  ];

  @override
  String toString() {
    return 'EpubMetadataDate{date: $date, event: $event}';
  }

  EpubMetadataDate copyWith({
    String? date,
    String? event,
  }) {
    return EpubMetadataDate(
      date: date ?? this.date,
      event: event ?? this.event,
    );
  }
}
