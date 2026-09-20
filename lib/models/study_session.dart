import 'package:isar/isar.dart';

part 'study_session.g.dart';

@collection
class StudySession {
  Id id = Isar.autoIncrement;

  @Index()
  late int deckId;

  @Index()
  late DateTime date;

  late int cardsStudied;
  late int correctCount;
  late int incorrectCount;
}
