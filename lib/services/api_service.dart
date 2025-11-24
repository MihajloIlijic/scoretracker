import 'dart:convert';
import 'package:http/http.dart' as http;

class Match {
  final int? id;
  final int championshipId;
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
    required this.championshipId,
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
      championshipId: json['championship_id'] ?? 0,
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
      'championship_id': championshipId,
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


  static Future<List<Match>> getAllMatches({int? championshipId}) async {
    try {
      String url = '$baseUrl/matches';
      if (championshipId != null) {
        url += '?championship_id=$championshipId';
      }
      final response = await http.get(Uri.parse(url));
      
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

  // Championship methods
  static Future<List<Championship>> getAllChampionships() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/championships'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Championship.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load championships: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching championships: $e');
    }
  }

  static Future<Championship> createChampionship(Championship championship) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/championships'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(championship.toJson()),
      );
      
      if (response.statusCode == 201) {
        return Championship.fromJson(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to create championship: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating championship: $e');
    }
  }

  static Future<void> deleteChampionship(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/championships/$id'));
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete championship: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting championship: $e');
    }
  }

  // Player methods
  static Future<List<Player>> getAllPlayers({int? championshipId}) async {
    try {
      String url = '$baseUrl/players';
      if (championshipId != null) {
        url += '?championship_id=$championshipId';
      }
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Player.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load players: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching players: $e');
    }
  }

  static Future<Player> createPlayer(Player player) async {
    try {
      final requestBody = {
        'name': player.name,
        'championship_ids': player.championships?.map((c) => c.id).where((id) => id != null).toList() ?? [],
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/players'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 201) {
        return Player.fromJson(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to create player: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating player: $e');
    }
  }

  static Future<Player> updatePlayer(Player player) async {
    try {
      if (player.id == null) {
        throw Exception('Player ID is required for update');
      }
      
      // Always send championship_ids, even if empty
      final championshipIds = player.championships?.map((c) => c.id).where((id) => id != null).cast<int>().toList() ?? [];
      
      final requestBody = <String, dynamic>{
        'championship_ids': championshipIds, // Always include, even if empty array
      };
      
      // Only include name if it's not empty
      if (player.name.isNotEmpty) {
        requestBody['name'] = player.name;
      }
      
      final url = '$baseUrl/players/${player.id}';
      final body = json.encode(requestBody);
      
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      
      if (response.statusCode == 200) {
        return Player.fromJson(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to update player: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating player: $e');
    }
  }

  static Future<void> deletePlayer(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/players/$id'));
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete player: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting player: $e');
    }
  }
}

class Championship {
  final int? id;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Championship({
    this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Championship.fromJson(Map<String, dynamic> json) {
    return Championship(
      id: json['id'],
      name: json['name'],
      description: json['description'],
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
    };
  }
}

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

