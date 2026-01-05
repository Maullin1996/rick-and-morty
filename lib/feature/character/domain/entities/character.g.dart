// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Character _$CharacterFromJson(Map<String, dynamic> json) => _Character(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  gender: json['gender'] as String,
  status: json['status'] as String,
  species: json['species'] as String,
  image: json['image'] as String,
  origin: Origin.fromJson(json['origin'] as Map<String, dynamic>),
  episodes: (json['episodes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CharacterToJson(_Character instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'gender': instance.gender,
      'status': instance.status,
      'species': instance.species,
      'image': instance.image,
      'origin': instance.origin,
      'episodes': instance.episodes,
    };

_Origin _$OriginFromJson(Map<String, dynamic> json) =>
    _Origin(name: json['name'] as String, url: json['url'] as String);

Map<String, dynamic> _$OriginToJson(_Origin instance) => <String, dynamic>{
  'name': instance.name,
  'url': instance.url,
};
