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
}

