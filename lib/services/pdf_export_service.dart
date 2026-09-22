import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:cardblaze/models/flash_card.dart';

class PdfExportException implements Exception {
  final String message;
  const PdfExportException(this.message);
  @override
  String toString() => 'PdfExportException: $message';
}

class PdfExportService {
  // Cached raw font bytes — loaded once, reused across exports/instances.
  static Uint8List? _regularBytes;
  static Uint8List? _boldBytes;

  Future<Uint8List> _loadFontBytes(String asset) async {
    final data = await rootBundle.load(asset);
    return data.buffer.asUint8List();
  }

  static final _format = PdfLayoutFormat(layoutType: PdfLayoutType.paginate);

  // Builds a PDF for [deckName]'s [cards] (question + answer, numbered),
  // writes it to a temp file and returns the file path, ready to share.
  Future<String> exportDeck(String deckName, List<FlashCard> cards) async {
    if (cards.isEmpty) {
      throw const PdfExportException('Deck nema kartica za export.');
    }

    _regularBytes ??= await _loadFontBytes('assets/fonts/roboto-regular.ttf');
    _boldBytes ??= await _loadFontBytes('assets/fonts/roboto-bold.ttf');

    final titleFont = PdfTrueTypeFont(_boldBytes!, 18);
    final questionFont = PdfTrueTypeFont(_regularBytes!, 12, style: PdfFontStyle.bold);
    final answerFont = PdfTrueTypeFont(_regularBytes!, 12);

    final document = PdfDocument();
    document.pageSettings.margins.all = 40;

    PdfPage page = document.pages.add();
    var y = 0.0;

    PdfLayoutResult? result = PdfTextElement(text: deckName, font: titleFont).draw(
      page: page,
      bounds: Rect.fromLTWH(0, y, page.getClientSize().width, page.getClientSize().height - y),
      format: _format,
    );
    page = result?.page ?? page;
    y = (result?.bounds.bottom ?? y) + 20;

    for (var i = 0; i < cards.length; i++) {
      final card = cards[i];
      var size = page.getClientSize();

      result = PdfTextElement(text: '${i + 1}. ${card.front}', font: questionFont).draw(
        page: page,
        bounds: Rect.fromLTWH(0, y, size.width, size.height - y),
        format: _format,
      );
      page = result?.page ?? page;
      y = (result?.bounds.bottom ?? y) + 4;

      size = page.getClientSize();
      result = PdfTextElement(text: card.back, font: answerFont).draw(
        page: page,
        bounds: Rect.fromLTWH(16, y, size.width - 16, size.height - y),
        format: _format,
      );
      page = result?.page ?? page;
      y = (result?.bounds.bottom ?? y) + 16;
    }

    final bytes = Uint8List.fromList(await document.save());
    document.dispose();

    final dir = await getTemporaryDirectory();
    final safeName = deckName.replaceAll(RegExp(r'[^\w\-]+'), '_');
    final file = File('${dir.path}/cardblaze_${safeName}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
