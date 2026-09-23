import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:xml/xml.dart';

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
      throw FileNotFoundException('File not found: $filePath');
    }

    if (filePath.toLowerCase().endsWith('.docx')) {
      return _extractDocx(file);
    }
    return _extractPdf(file);
  }

  Future<String> _extractPdf(File file) async {
    late PdfDocument document;
    try {
      final bytes = await file.readAsBytes();
      document = PdfDocument(inputBytes: bytes);
    } catch (e) {
      throw PdfExtractionException('Cannot open PDF: $e');
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
      throw PdfExtractionException('Error extracting text: $e');
    } finally {
      document.dispose();
    }
  }

  Future<String> _extractDocx(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final entry = archive.findFile('word/document.xml');
      if (entry == null) throw PdfExtractionException('Invalid DOCX file.');

      final xmlContent = String.fromCharCodes(entry.content as List<int>);
      final doc = XmlDocument.parse(xmlContent);

      final buffer = StringBuffer();
      for (final node in doc.findAllElements('w:t')) {
        final text = node.innerText;
        if (text.isNotEmpty) buffer.write('$text ');
        if (buffer.length >= _maxChars) break;
      }

      final result = buffer.toString().trim();
      return result.length > _maxChars ? result.substring(0, _maxChars) : result;
    } catch (e) {
      if (e is PdfExtractionException) rethrow;
      throw PdfExtractionException('Error reading DOCX: $e');
    }
  }

  Future<String?> pickAndExtract() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );

    if (files.isEmpty) return null;

    final path = files.single.path;
    if (path == null) return null;

    return extractText(path);
  }

  // Keep old name for compatibility
  Future<String?> pickAndExtractPdf() => pickAndExtract();
}
