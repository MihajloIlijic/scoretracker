class Championship {
  final int? id;
  final String name;
  final String? description;
  final ChampionshipStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Championship({
    this.id,
    required this.name,
    this.description,
    this.status = ChampionshipStatus.draft,
    this.createdAt,
    this.updatedAt,
  });

  factory Championship.fromJson(Map<String, dynamic> json) {
    ChampionshipStatus parseStatus(String? status) {
      switch (status) {
        case 'finalized':
          return ChampionshipStatus.finalized;
        default:
          return ChampionshipStatus.draft;
      }
    }

    return Championship(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: parseStatus(json['status']),
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
      if (description != null) 'description': description,
      'status': status == ChampionshipStatus.finalized ? 'finalized' : 'draft',
    };
  }
}

enum ChampionshipStatus {
  draft,
  finalized,
}

