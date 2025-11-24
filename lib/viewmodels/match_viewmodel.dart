import 'package:flutter/foundation.dart';
import '../models/match.dart';
import '../services/api_service.dart';

class MatchViewModel extends ChangeNotifier {
  List<Match> _matches = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Match> get matches => _matches;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMatches({int? championshipId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _matches = await ApiService.getAllMatches(championshipId: championshipId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading matches: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Match?> createMatch(Match match) async {
    try {
      final created = await ApiService.createMatch(match);
      await loadMatches();
      return created;
    } catch (e) {
      _errorMessage = 'Error creating match: $e';
      notifyListeners();
      return null;
    }
  }
}

class MatchDetailViewModel extends ChangeNotifier {
  Match _match;
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;

  MatchDetailViewModel(this._match);

  Match get match => _match;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;

  Future<void> loadMatch() async {
    if (_match.id == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _match = await ApiService.getMatch(_match.id!);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading match: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startMatch() async {
    if (_match.id == null) return false;

    _isUpdating = true;
    notifyListeners();

    try {
      _match = await ApiService.startMatch(_match.id!);
      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error starting match: $e';
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateScore(int player1Score, int player2Score) async {
    if (_match.id == null) return false;

    _isUpdating = true;
    notifyListeners();

    try {
      _match = await ApiService.updateMatchScore(_match.id!, player1Score, player2Score);
      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating score: $e';
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> finishMatch() async {
    if (_match.id == null) return false;

    _isUpdating = true;
    notifyListeners();

    try {
      _match = await ApiService.finishMatch(_match.id!);
      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error finishing match: $e';
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }
}

