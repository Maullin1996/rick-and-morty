// To parse this JSON data, do
//
//     final characterModel = characterModelFromJson(jsonString);

class CharacterModel {
  final int id;
  final String name;
  final String status;
  final String species;
  final String gender;
  final OriginModel origin;
  final String image;
  final List<String> episode;

  CharacterModel({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.origin,
    required this.image,
    required this.episode,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) => CharacterModel(
    id: json["id"],
    name: json["name"],
    status: json["status"],
    species: json["species"],
    gender: json["gender"],
    origin: OriginModel.fromJson(json["origin"]),
    image: json["image"],
    episode: List<String>.from(json["episode"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "status": status,
    "species": species,
    "gender": gender,
    "origin": origin.toJson(),
    "image": image,
    "episode": List<dynamic>.from(episode.map((x) => x)),
  };
}

class OriginModel {
  final String name;
  final String url;

  OriginModel({required this.name, required this.url});

  factory OriginModel.fromJson(Map<String, dynamic> json) =>
      OriginModel(name: json["name"], url: json["url"]);

  Map<String, dynamic> toJson() => {"name": name, "url": url};
}
