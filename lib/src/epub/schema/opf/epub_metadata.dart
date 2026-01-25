import 'package:ebook_toolkit/src/epub/schema/opf/epub_metadata_contributor.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_metadata_creator.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_metadata_date.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_metadata_identifier.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_metadata_meta.dart';
import 'package:equatable/equatable.dart';

class EpubMetadata extends Equatable {
  const EpubMetadata({
    this.titles,
    this.creators,
    this.subjects,
    this.description,
    this.publishers,
    this.contributors,
    this.dates,
    this.types,
    this.formats,
    this.identifiers,
    this.sources,
    this.languages,
    this.relations,
    this.coverages,
    this.rights,
    this.metaItems,
  });

  final List<String>? titles;
  final List<EpubMetadataCreator>? creators;
  final List<String>? subjects;
  final String? description;
  final List<String>? publishers;
  final List<EpubMetadataContributor>? contributors;
  final List<EpubMetadataDate>? dates;
  final List<String>? types;
  final List<String>? formats;
  final List<EpubMetadataIdentifier>? identifiers;
  final List<String>? sources;
  final List<String>? languages;
  final List<String>? relations;
  final List<String>? coverages;
  final List<String>? rights;
  final List<EpubMetadataMeta>? metaItems;

  @override
  List<Object?> get props => [
    titles,
    creators,
    subjects,
    description,
    publishers,
    contributors,
    dates,
    types,
    formats,
    identifiers,
    sources,
    languages,
    relations,
    coverages,
    rights,
    metaItems,
  ];

  EpubMetadata copyWith({
    List<String>? titles,
    List<EpubMetadataCreator>? creators,
    List<String>? subjects,
    String? description,
    List<String>? publishers,
    List<EpubMetadataContributor>? contributors,
    List<EpubMetadataDate>? dates,
    List<String>? types,
    List<String>? formats,
    List<EpubMetadataIdentifier>? identifiers,
    List<String>? sources,
    List<String>? languages,
    List<String>? relations,
    List<String>? coverages,
    List<String>? rights,
    List<EpubMetadataMeta>? metaItems,
  }) {
    return EpubMetadata(
      titles: titles ?? this.titles,
      creators: creators ?? this.creators,
      subjects: subjects ?? this.subjects,
      description: description ?? this.description,
      publishers: publishers ?? this.publishers,
      contributors: contributors ?? this.contributors,
      dates: dates ?? this.dates,
      types: types ?? this.types,
      formats: formats ?? this.formats,
      identifiers: identifiers ?? this.identifiers,
      sources: sources ?? this.sources,
      languages: languages ?? this.languages,
      relations: relations ?? this.relations,
      coverages: coverages ?? this.coverages,
      rights: rights ?? this.rights,
      metaItems: metaItems ?? this.metaItems,
    );
  }
}
