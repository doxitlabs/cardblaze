import 'dart:math';
import 'package:cardblaze/models/flash_card.dart';

class Sm2Service {
  FlashCard applyRating(FlashCard card, int rating) {
    assert(rating >= 0 && rating <= 2);

    if (rating == 0) {
      card.repetitions = 0;
      card.interval = 1;
    } else {
      final ef = card.easeFactor + (0.1 - (2 - rating) * (0.08 + (2 - rating) * 0.02));
      card.easeFactor = max(1.3, ef);

      if (card.repetitions == 0) {
        card.interval = 1;
      } else if (card.repetitions == 1) {
        card.interval = 6;
      } else {
        card.interval = (card.interval * card.easeFactor).round();
      }
      card.repetitions += 1;
    }

    card.lastReviewed = DateTime.now();
    card.dueDate = rating == 0 ? DateTime.now() : DateTime.now().add(Duration(days: card.interval));
    return card;
  }
}

final sm2Service = Sm2Service();
