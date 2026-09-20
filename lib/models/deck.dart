import 'package:isar/isar.dart';

part 'deck.g.dart';

@collection
class Deck {
  Id id = Isar.autoIncrement;

  late String name;

  @Index()
  late String colorHex;

  late DateTime createdAt;

  // Computed — not stored; populated manually from card count queries.
  @ignore
  int cardCount = 0;
}
