import 'package:isar/isar.dart';

part 'flash_card.g.dart';

@collection
class FlashCard {
  Id id = Isar.autoIncrement;

  @Index()
  late int deckId;

  late String front;
  late String back;

  late DateTime createdAt;

  // ── SM-2 scheduling fields ───────────────────────────────────────────────
  int interval = 1;       // days until next review
  int repetitions = 0;    // consecutive correct answers
  double easeFactor = 2.5;

  @Index()
  late DateTime dueDate;

  DateTime? lastReviewed;
}
