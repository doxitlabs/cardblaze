import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cardblaze/models/deck.dart';
import 'package:cardblaze/models/flash_card.dart';
import 'package:cardblaze/models/study_session.dart';

class IsarService {
  late final Isar _isar;


  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [DeckSchema, FlashCardSchema, StudySessionSchema],
      directory: dir.path,
      name: 'cardblaze',
    );
  }

  // ── Decks ────────────────────────────────────────────────────────────────

  Future<List<Deck>> getAllDecks() async {
    final decks = await _isar.decks.where().findAll();
    for (final deck in decks) {
      deck.cardCount = await _isar.flashCards
          .filter()
          .deckIdEqualTo(deck.id)
          .count();
    }
    return decks;
  }

  Future<Deck?> getDeckById(int id) async {
    final deck = await _isar.decks.get(id);
    if (deck != null) {
      deck.cardCount = await _isar.flashCards
          .filter()
          .deckIdEqualTo(id)
          .count();
    }
    return deck;
  }

  Future<void> saveDeck(Deck deck) async {
    await _isar.writeTxn(() => _isar.decks.put(deck));
  }

  Future<void> deleteDeck(int id) async {
    await _isar.writeTxn(() async {
      await _isar.decks.delete(id);
      // Cascade — delete all cards belonging to this deck
      final cardIds = await _isar.flashCards
          .filter()
          .deckIdEqualTo(id)
          .idProperty()
          .findAll();
      await _isar.flashCards.deleteAll(cardIds);
      // Sessions are kept intentionally — deleting a deck must not affect stats history
    });
  }

  // ── FlashCards ───────────────────────────────────────────────────────────

  Future<List<FlashCard>> getCardsForDeck(int deckId) {
    return _isar.flashCards
        .filter()
        .deckIdEqualTo(deckId)
        .findAll();
  }

  Future<int> getAnsweredCountForDeck(int deckId) {
    return _isar.flashCards
        .filter()
        .deckIdEqualTo(deckId)
        .repetitionsGreaterThan(0)
        .count();
  }

  Future<int> getMasteredCount() {
    return _isar.flashCards
        .filter()
        .repetitionsGreaterThan(2)
        .count();
  }

  Future<int> getTotalDueCount() {
    final now = DateTime.now();
    return _isar.flashCards
        .filter()
        .dueDateLessThan(now, include: true)
        .count();
  }

  Future<List<FlashCard>> getDueCards(int deckId) {
    final now = DateTime.now();
    return _isar.flashCards
        .filter()
        .deckIdEqualTo(deckId)
        .dueDateLessThan(now, include: true)
        .findAll();
  }

  Future<void> saveCard(FlashCard card) async {
    await _isar.writeTxn(() => _isar.flashCards.put(card));
  }

  Future<void> resetCardsForDeck(int deckId) async {
    final cards = await _isar.flashCards.filter().deckIdEqualTo(deckId).findAll();
    final now = DateTime.now();
    for (final c in cards) {
      c.repetitions = 0;
      c.interval = 1;
      c.easeFactor = 2.5;
      c.dueDate = now;
      c.lastReviewed = null;
    }
    await _isar.writeTxn(() => _isar.flashCards.putAll(cards));
  }

  Future<void> deleteCard(int id) async {
    await _isar.writeTxn(() => _isar.flashCards.delete(id));
  }

  // ── StudySessions ────────────────────────────────────────────────────────

  Future<void> saveSession(StudySession session) async {
    await _isar.writeTxn(() => _isar.studySessions.put(session));
  }

  Future<bool> deckHasSession(int deckId) async {
    final count = await _isar.studySessions.filter().deckIdEqualTo(deckId).count();
    return count > 0;
  }

  Future<List<StudySession>> getRecentSessions(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _isar.studySessions
        .filter()
        .dateGreaterThan(cutoff)
        .sortByDateDesc()
        .findAll();
  }

  // ── Live streams (Isar watchers) ─────────────────────────────────────────

  Stream<Deck?> watchDeckById(int id) {
    return _isar.decks.watchObject(id, fireImmediately: true).asyncMap((deck) async {
      if (deck != null) {
        deck.cardCount = await _isar.flashCards.filter().deckIdEqualTo(id).count();
      }
      return deck;
    });
  }

  Stream<List<FlashCard>> watchCardsForDeck(int deckId) {
    return _isar.flashCards
        .filter()
        .deckIdEqualTo(deckId)
        .watch(fireImmediately: true);
  }

  Stream<List<FlashCard>> watchAllCards() {
    return _isar.flashCards.where().watch(fireImmediately: true);
  }

  Stream<List<Deck>> watchAllDecks() {
    return _isar.decks.where().watch(fireImmediately: true).asyncMap((decks) async {
      for (final deck in decks) {
        deck.cardCount = await _isar.flashCards
            .filter()
            .deckIdEqualTo(deck.id)
            .count();
      }
      return decks;
    });
  }

  Stream<int> watchTotalDueCount() {
    final now = DateTime.now();
    return _isar.flashCards
        .filter()
        .dueDateLessThan(now, include: true)
        .watch(fireImmediately: true)
        .map((cards) => cards.length);
  }

  Stream<int> watchDueCountForDeck(int deckId) {
    final now = DateTime.now();
    return _isar.flashCards
        .filter()
        .deckIdEqualTo(deckId)
        .and()
        .dueDateLessThan(now, include: true)
        .watch(fireImmediately: true)
        .map((cards) => cards.length);
  }
}

// ── Riverpod providers ───────────────────────────────────────────────────────

final isarServiceProvider = Provider<IsarService>((ref) {
  throw UnimplementedError('Call IsarService.init() before accessing this provider');
});
