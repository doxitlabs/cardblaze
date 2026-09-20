import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class FileNotFoundException implements Exception {
  final String message;
  const FileNotFoundException(this.message);
  @override
  String toString() => message;
}

class PdfExtractionException implements Exception {
  final String message;
  const PdfExtractionException(this.message);
  @override
  String toString() => message;
}

class PdfService {
  static const int _maxChars = 5000;

  Future<String> extractText(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileNotFoundException('PDF fajl nije pronađen: $filePath');
    }

    late PdfDocument document;
    try {
      final bytes = await file.readAsBytes();
      document = PdfDocument(inputBytes: bytes);
    } catch (e) {
      throw PdfExtractionException('Nije moguće otvoriti PDF: $e');
    }

    try {
      final extractor = PdfTextExtractor(document);
      final buffer = StringBuffer();

      for (int i = 0; i < document.pages.count; i++) {
        final pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
        if (pageText.isNotEmpty) {
          if (buffer.isNotEmpty) buffer.write('\n\n');
          buffer.write(pageText);
        }
        if (buffer.length >= _maxChars) break;
      }

      final result = buffer.toString();
      return result.length > _maxChars ? result.substring(0, _maxChars) : result;
    } catch (e) {
      throw PdfExtractionException('Greška pri ekstrakciji teksta: $e');
    } finally {
      document.dispose();
    }
  }

  Future<String?> pickAndExtractPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final path = result.files.single.path;
    if (path == null) return null;

    return extractText(path);
  }
}
