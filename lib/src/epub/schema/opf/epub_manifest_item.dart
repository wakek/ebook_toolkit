import 'package:equatable/equatable.dart';

class EpubManifestItem extends Equatable {
  const EpubManifestItem({
    this.id,
    this.href,
    this.mediaType,
    this.mediaOverlay,
    this.requiredNamespace,
    this.requiredModules,
    this.fallback,
    this.fallbackStyle,
    this.properties,
  });

  final String? id;
  final String? href;
  final String? mediaType;
  final String? mediaOverlay;
  final String? requiredNamespace;
  final String? requiredModules;
  final String? fallback;
  final String? fallbackStyle;
  final String? properties;

  @override
  List<Object?> get props => [
    id,
    href,
    mediaType,
    mediaOverlay,
    requiredNamespace,
    requiredModules,
    fallback,
    fallbackStyle,
    properties,
  ];

  @override
  String toString() {
    return 'Id: $id, Href = $href, MediaType = $mediaType, Properties = $properties, MediaOverlay = $mediaOverlay';
  }

  EpubManifestItem copyWith({
    String? id,
    String? href,
    String? mediaType,
    String? mediaOverlay,
    String? requiredNamespace,
    String? requiredModules,
    String? fallback,
    String? fallbackStyle,
    String? properties,
  }) {
    return EpubManifestItem(
      id: id ?? this.id,
      href: href ?? this.href,
      mediaType: mediaType ?? this.mediaType,
      mediaOverlay: mediaOverlay ?? this.mediaOverlay,
      requiredNamespace: requiredNamespace ?? this.requiredNamespace,
      requiredModules: requiredModules ?? this.requiredModules,
      fallback: fallback ?? this.fallback,
      fallbackStyle: fallbackStyle ?? this.fallbackStyle,
      properties: properties ?? this.properties,
    );
  }
}
