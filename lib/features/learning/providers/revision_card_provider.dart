import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/revision_card.dart';

class RevisionCardNotifier extends StateNotifier<AsyncValue<List<RevisionCard>>> {
  RevisionCardNotifier() : super(const AsyncValue.loading()) {
    fetchCards();
  }

  final _supabase = Supabase.instance.client;

  Future<void> fetchCards() async {
    state = const AsyncValue.loading();
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final response = await _supabase
          .from('revision_cards')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final cards = (response as List).map((m) => RevisionCard.fromMap(m)).toList();
      state = AsyncValue.data(cards);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveCard(RevisionCard card) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final data = card.toMap();
      await _supabase.from('revision_cards').upsert(data);
      await fetchCards();
    } catch (e) {
      print("❌ Erreur sauvegarde fiche: $e");
      rethrow;
    }
  }

  Future<void> deleteCard(String id) async {
    try {
      await _supabase.from('revision_cards').delete().eq('id', id);
      await fetchCards();
    } catch (e) {
      print("❌ Erreur suppression fiche: $e");
      rethrow;
    }
  }
}

final revisionCardProvider = StateNotifierProvider<RevisionCardNotifier, AsyncValue<List<RevisionCard>>>((ref) {
  return RevisionCardNotifier();
});
