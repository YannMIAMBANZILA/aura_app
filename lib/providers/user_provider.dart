import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// AuraProvider: Gestion des Aura Points (Local + Supabase)

class AuraScoreNotifier extends StateNotifier<int> {
  AuraScoreNotifier() : super(0) {
    _initScore();
  }

  static const _storageKey = 'aura_score';

  Future<void> _initScore() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await _loadFromSupabase(user.id);
    } else {
      await _loadFromLocal();
    }
  }

  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_storageKey) ?? 100;
  }

  Future<void> _loadFromSupabase(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('aura_points')
          .eq('id', userId)
          .single();
      state = data['aura_points'] as int;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_storageKey, state);
    } catch (e) {
      _loadFromLocal();
    }
  }

  Future<void> addPoints(int points) async {
    state = state + points;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageKey, state);

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        await Supabase.instance.client
            .from('profiles')
            .update({'aura_points': state})
            .eq('id', user.id);
      } catch (e) {
        print("Erreur de sauvegarde Cloud: $e");
      }
    }
  }

  Future<void> syncLocalToCloud() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final localScore = prefs.getInt(_storageKey) ?? 100;

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('aura_points')
          .eq('id', user.id)
          .single();
      
      final cloudScore = data['aura_points'] as int;

      if (localScore > cloudScore) {
        await Supabase.instance.client
            .from('profiles')
            .update({'aura_points': localScore})
            .eq('id', user.id);
        state = localScore;
      } else {
        state = cloudScore;
        await prefs.setInt(_storageKey, cloudScore);
      }
    } catch (e) {
      print("Erreur Sync: $e");
    }
  }
}

// Provider de score existant
final auraProvider = StateNotifierProvider<AuraScoreNotifier, int>((ref) {
  return AuraScoreNotifier();
});


// L'état de l'utilisateur (Identité + Rang)
class UserState {
  final User? user;
  final String rank;

  UserState({this.user, this.rank = 'Apprenti'});
}

// La logique de l'utilisateur
class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState());

  // Appelé au démarrage de l'app ou après login
  Future<void> refreshUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Ici on pourrait charger le rang depuis la BDD plus tard
      state = UserState(user: user, rank: 'Apprenti'); 
    } else {
      state = UserState(user: null);
    }
  }

  // Appelé lors du logout pour tout nettoyer
  void clear() {
    state = UserState(user: null);
  }
}

// Le provider utilisateur global
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});