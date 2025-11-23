import 'dart:convert';
import 'package:http/http.dart' as http;

class Score {
  final int? id;
  final String player;
  final int points;
  final String game;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Score({
    this.id,
    required this.player,
    required this.points,
    required this.game,
    this.createdAt,
    this.updatedAt,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      id: json['id'],
      player: json['player'],
      points: json['points'],
      game: json['game'],
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
      'player': player,
      'points': points,
      'game': game,
    };
  }
}

class Match {
  final int? id;
  final String player1;
  final String player2;
  final String game;
  final String winner;
  final int player1Score;
  final int player2Score;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Match({
    this.id,
    required this.player1,
    required this.player2,
    required this.game,
    required this.winner,
    required this.player1Score,
    required this.player2Score,
    this.createdAt,
    this.updatedAt,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      player1: json['player1'],
      player2: json['player2'],
      game: json['game'],
      winner: json['winner'],
      player1Score: json['player1_score'],
      player2Score: json['player2_score'],
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
      'player1': player1,
      'player2': player2,
      'game': game,
      'winner': winner,
      'player1_score': player1Score,
      'player2_score': player2Score,
    };
  }
}

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );

  static Future<List<Score>> getAllScores() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/scores'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Score.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load scores: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching scores: $e');
    }
  }

  static Future<Score> getScore(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/scores/$id'));
      
      if (response.statusCode == 200) {
        return Score.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Score not found');
      } else {
        throw Exception('Failed to load score: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching score: $e');
    }
  }

  static Future<Score> createScore(Score score) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/scores'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(score.toJson()),
      );
      
      if (response.statusCode == 201) {
        return Score.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create score: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating score: $e');
    }
  }

  static Future<Score> updateScore(Score score) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/scores/${score.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(score.toJson()),
      );
      
      if (response.statusCode == 200) {
        return Score.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update score: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating score: $e');
    }
  }

  static Future<void> deleteScore(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/scores/$id'));
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete score: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting score: $e');
    }
  }

  static Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking health: $e');
    }
  }

  static Future<List<String>> getPlayers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/players'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> players = data['players'];
        return players.map((p) => p.toString()).toList();
      } else {
        throw Exception('Failed to load players: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching players: $e');
    }
  }

  static Future<List<Match>> getAllMatches() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/matches'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Match.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load matches: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching matches: $e');
    }
  }

  static Future<Match> getMatch(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/matches/$id'));
      
      if (response.statusCode == 200) {
        return Match.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Match not found');
      } else {
        throw Exception('Failed to load match: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching match: $e');
    }
  }

  static Future<Match> createMatch(Match match) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/matches'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(match.toJson()),
      );
      
      if (response.statusCode == 201) {
        return Match.fromJson(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to create match: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating match: $e');
    }
  }

  static Future<void> deleteMatch(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/matches/$id'));
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete match: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting match: $e');
    }
  }
}

