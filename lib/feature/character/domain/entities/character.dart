import 'package:freezed_annotation/freezed_annotation.dart';

part 'character.freezed.dart';
part 'character.g.dart'; // Importante para JSON

@freezed
abstract class Character with _$Character {
  const factory Character({
    required int id,
    required String name,
    required String gender,
    required String status,
    required String species,
    required String image,
    required Origin origin,
    required List<String> episodes,
  }) = _Character;

  // Métodos para JSON
  factory Character.fromJson(Map<String, dynamic> json) =>
      _$CharacterFromJson(json);
}

@freezed
abstract class Origin with _$Origin {
  const factory Origin({required String name, required String url}) = _Origin;

  factory Origin.fromJson(Map<String, dynamic> json) => _$OriginFromJson(json);
}
