import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// ── Deck progress (same rules as DeckDetailScreen stats) ──────────────────────
// Derived from the cards' SM2 state, which StudyScreen saves after every
// answer — so it is correct even when a study session is left midway.
typedef DeckProgress = ({int total, int learned, int due});

bool isCardLearned(FlashCard c, [DateTime? now]) =>
    c.repetitions >= 1 && c.dueDate.isAfter(now ?? DateTime.now());

DeckProgress deckProgress(List<FlashCard> cards) {
  final now = DateTime.now();
  final due = cards.where((c) => !c.dueDate.isAfter(now)).length;
  final learned = cards.where((c) => isCardLearned(c, now)).length;
  return (total: cards.length, learned: learned, due: due);
}

final deckProgressProvider = StreamProvider.family<DeckProgress, int>((ref, deckId) {
  return ref.read(isarServiceProvider).watchCardsForDeck(deckId).map(deckProgress);
});

final totalProgressProvider = StreamProvider<DeckProgress>((ref) {
  return ref.read(isarServiceProvider).watchAllCards().map(deckProgress);
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
