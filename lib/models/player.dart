import 'championship.dart';

class Player {
  final int? id;
  final String name;
  final List<Championship>? championships;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Player({
    this.id,
    required this.name,
    this.championships,
    this.createdAt,
    this.updatedAt,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    List<Championship>? championshipsList;
    if (json['championships'] != null) {
      final List<dynamic> champs = json['championships'];
      championshipsList = champs.map((c) => Championship.fromJson(c)).toList();
    }
    
    return Player(
      id: json['id'],
      name: json['name'],
      championships: championshipsList,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (championships != null)
        'championship_ids': championships!.map((c) => c.id).where((id) => id != null).toList(),
    };
  }
}

