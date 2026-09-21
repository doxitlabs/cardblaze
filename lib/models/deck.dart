import 'package:isar/isar.dart';

part 'deck.g.dart';

@collection
class Deck {
  Id id = Isar.autoIncrement;

  late String name;

  @Index()
  late String colorHex;

  late DateTime createdAt;

  // null = visible in all languages (legacy decks)
  String? language;

  // Computed — not stored; populated manually from card count queries.
  @ignore
  int cardCount = 0;
}
