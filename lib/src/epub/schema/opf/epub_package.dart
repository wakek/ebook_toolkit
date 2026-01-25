import 'package:ebook_toolkit/src/epub/schema/opf/epub_guide.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_manifest.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_metadata.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_spine.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_version.dart';
import 'package:equatable/equatable.dart';

class EpubPackage extends Equatable {
  const EpubPackage({
    this.version,
    this.metadata,
    this.manifest,
    this.spine,
    this.guide,
  });

  final EpubVersion? version;
  final EpubMetadata? metadata;
  final EpubManifest? manifest;
  final EpubSpine? spine;
  final EpubGuide? guide;

  @override
  List<Object?> get props => [
    version,
    metadata,
    manifest,
    spine,
    guide,
  ];

  @override
  String toString() {
    return 'EpubPackage{version: $version, metadata: $metadata, manifest: $manifest, spine: $spine, guide: $guide}';
  }

  EpubPackage copyWith({
    EpubVersion? version,
    EpubMetadata? metadata,
    EpubManifest? manifest,
    EpubSpine? spine,
    EpubGuide? guide,
  }) {
    return EpubPackage(
      version: version ?? this.version,
      metadata: metadata ?? this.metadata,
      manifest: manifest ?? this.manifest,
      spine: spine ?? this.spine,
      guide: guide ?? this.guide,
    );
  }
}
