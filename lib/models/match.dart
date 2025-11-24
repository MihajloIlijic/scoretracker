class Match {
  final int? id;
  final int championshipId;
  final String player1;
  final String player2;
  final String game;
  final MatchStatus status;
  final String? winner;
  final int player1Score;
  final int player2Score;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Match({
    this.id,
    required this.championshipId,
    required this.player1,
    required this.player2,
    required this.game,
    this.status = MatchStatus.pending,
    this.winner,
    this.player1Score = 0,
    this.player2Score = 0,
    this.startedAt,
    this.finishedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    MatchStatus parseStatus(String? status) {
      switch (status) {
        case 'started':
          return MatchStatus.started;
        case 'finished':
          return MatchStatus.finished;
        default:
          return MatchStatus.pending;
      }
    }

    return Match(
      id: json['id'],
      championshipId: json['championship_id'] ?? 0,
      player1: json['player1'],
      player2: json['player2'],
      game: json['game'],
      status: parseStatus(json['status']),
      winner: json['winner'],
      player1Score: json['player1_score'] ?? 0,
      player2Score: json['player2_score'] ?? 0,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,
      finishedAt: json['finished_at'] != null
          ? DateTime.parse(json['finished_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    String statusString() {
      switch (status) {
        case MatchStatus.started:
          return 'started';
        case MatchStatus.finished:
          return 'finished';
        default:
          return 'pending';
      }
    }

    return {
      if (id != null) 'id': id,
      'championship_id': championshipId,
      'player1': player1,
      'player2': player2,
      'game': game,
      'status': statusString(),
      if (winner != null) 'winner': winner,
      'player1_score': player1Score,
      'player2_score': player2Score,
    };
  }
}

enum MatchStatus {
  pending,
  started,
  finished,
}

