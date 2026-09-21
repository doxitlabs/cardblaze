import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cardblaze/models/deck.dart';
import 'package:cardblaze/models/flash_card.dart';
import 'package:cardblaze/services/isar_service.dart';

// ── Refresh counters (for one-shot FutureProviders) ───────────────────────────
final decksRefreshProvider = StateProvider<int>((_) => 0);
final cardsRefreshProvider = StateProvider<int>((_) => 0);

// ── FutureProviders (used by DeckDetailScreen) ────────────────────────────────
final allDecksProvider = FutureProvider<List<Deck>>((ref) {
  ref.watch(decksRefreshProvider);
  return ref.read(isarServiceProvider).getAllDecks();
});

final deckByIdProvider = FutureProvider.family<Deck?, int>((ref, id) {
  ref.watch(decksRefreshProvider);
  return ref.read(isarServiceProvider).getDeckById(id);
});

final cardsForDeckProvider = FutureProvider.family<List<FlashCard>, int>((ref, deckId) {
  ref.watch(cardsRefreshProvider);
  return ref.read(isarServiceProvider).getCardsForDeck(deckId);
});

final dueCardsCountProvider = FutureProvider.family<int, int>((ref, deckId) {
  ref.watch(cardsRefreshProvider);
  return ref.read(isarServiceProvider).getDueCards(deckId).then((l) => l.length);
});

final deckAnsweredCountProvider = FutureProvider.family<int, int>((ref, deckId) {
  ref.watch(cardsRefreshProvider);
  return ref.read(isarServiceProvider).getAnsweredCountForDeck(deckId);
});

final deckTotalCountProvider = StreamProvider.family<int, int>((ref, deckId) {
  return ref.read(isarServiceProvider).watchCardsForDeck(deckId).map((cards) => cards.length);
});

final deckHasSessionProvider = FutureProvider.family<bool, int>((ref, deckId) async {
  ref.watch(cardsRefreshProvider);
  return ref.read(isarServiceProvider).deckHasSession(deckId);
});

final deckWrongCountProvider = FutureProvider.family<int, int>((ref, deckId) async {
  ref.watch(cardsRefreshProvider);
  final hasSession = await ref.read(isarServiceProvider).deckHasSession(deckId);
  if (!hasSession) {
    // Never studied — all cards are pending
    final cards = await ref.read(isarServiceProvider).getCardsForDeck(deckId);
    return cards.length;
  }
  final prefs = await SharedPreferences.getInstance();
  final wrong = prefs.getStringList('wrong_cards_$deckId');
  return wrong?.length ?? 0;
});

// Returns {learned, pending} across all decks
final totalLearnedPendingProvider = FutureProvider<({int learned, int pending})>((ref) async {
  ref.watch(cardsRefreshProvider);
  final decks = await ref.read(isarServiceProvider).getAllDecks();
  final prefs = await SharedPreferences.getInstance();
  int learned = 0;
  int pending = 0;
  for (final deck in decks) {
    final cards = await ref.read(isarServiceProvider).getCardsForDeck(deck.id);
    final total = cards.length;
    final hasSession = await ref.read(isarServiceProvider).deckHasSession(deck.id);
    if (!hasSession) {
      pending += total;
    } else {
      final wrong = prefs.getStringList('wrong_cards_${deck.id}')?.length ?? 0;
      pending += wrong;
      learned += (total - wrong).clamp(0, total);
    }
  }
  return (learned: learned, pending: pending);
});

final totalWrongCountProvider = FutureProvider<int>((ref) async {
  ref.watch(cardsRefreshProvider);
  final decks = await ref.read(isarServiceProvider).getAllDecks();
  final prefs = await SharedPreferences.getInstance();
  int total = 0;
  for (final deck in decks) {
    final hasSession = await ref.read(isarServiceProvider).deckHasSession(deck.id);
    if (!hasSession) {
      final cards = await ref.read(isarServiceProvider).getCardsForDeck(deck.id);
      total += cards.length;
    } else {
      final wrong = prefs.getStringList('wrong_cards_${deck.id}');
      total += wrong?.length ?? 0;
    }
  }
  return total;
});

// ── StreamProviders (live Isar watchers) ──────────────────────────────────────
final decksStreamProvider = StreamProvider<List<Deck>>((ref) {
  return ref.read(isarServiceProvider).watchAllDecks();
});

final totalDueCountProvider = StreamProvider<int>((ref) {
  return ref.read(isarServiceProvider).watchTotalDueCount();
});

final deckDueCountProvider = StreamProvider.family<int, int>((ref, deckId) {
  return ref.read(isarServiceProvider).watchDueCountForDeck(deckId);
});

final deckStreamProvider = StreamProvider.family<Deck?, int>((ref, id) {
  return ref.read(isarServiceProvider).watchDeckById(id);
});

final cardsStreamProvider = StreamProvider.family<List<FlashCard>, int>((ref, deckId) {
  return ref.read(isarServiceProvider).watchCardsForDeck(deckId);
});
