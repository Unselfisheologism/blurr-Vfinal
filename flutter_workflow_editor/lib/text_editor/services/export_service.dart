import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import '../models/document.dart';

/// Service for exporting documents in various formats
/// 
/// Handles PDF generation, Markdown conversion, HTML export, and sharing.
class ExportService {
  static const MethodChannel _exportChannel = MethodChannel('document_export');

  /// Export document as PDF
  /// 
  /// Converts Quill Delta to formatted PDF with proper styling.
  Future<ExportResult> exportAsPDF({
    required EditorDocument document,
    required Delta delta,
  }) async {
    try {
      final pdf = pw.Document();

      // Convert Delta to plain text and parse for formatting
      final content = _deltaToFormattedText(delta);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Title
              pw.Header(
                level: 0,
                child: pw.Text(
                  document.title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Document info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Created: ${_formatDate(document.createdAt)}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    '${document.getWordCount()} words',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // Content
              ...content,
            ];
          },
        ),
      );

      // Save to temporary file
      final output = await getTemporaryDirectory();
      final fileName = '${document.title.replaceAll(' ', '_')}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      return ExportResult.success(
        filePath: file.path,
        fileName: fileName,
        mimeType: 'application/pdf',
      );
    } catch (e) {
      return ExportResult.error('Failed to export PDF: $e');
    }
  }

  /// Export document as Markdown
  Future<ExportResult> exportAsMarkdown({
    required EditorDocument document,
    required Delta delta,
  }) async {
    try {
      final markdown = _deltaToMarkdown(delta);
      
      // Save to temporary file
      final output = await getTemporaryDirectory();
      final fileName = '${document.title.replaceAll(' ', '_')}.md';
      final file = File('${output.path}/$fileName');
      await file.writeAsString(markdown);

      return ExportResult.success(
        filePath: file.path,
        fileName: fileName,
        mimeType: 'text/markdown',
      );
    } catch (e) {
      return ExportResult.error('Failed to export Markdown: $e');
    }
  }

  /// Export document as HTML
  Future<ExportResult> exportAsHTML({
    required EditorDocument document,
    required Delta delta,
  }) async {
    try {
      final converter = QuillDeltaToHtmlConverter(
        delta.toJson(),
        ConverterOptions.forEmail(),
      );
      
      final html = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${document.title}</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            max-width: 800px;
            margin: 40px auto;
            padding: 20px;
            line-height: 1.6;
        }
        h1 { font-size: 2em; margin-bottom: 0.5em; }
        h2 { font-size: 1.5em; margin-top: 1em; }
        h3 { font-size: 1.2em; margin-top: 0.8em; }
        code { 
            background: #f4f4f4; 
            padding: 2px 6px; 
            border-radius: 3px; 
            font-family: monospace;
        }
        pre {
            background: #f4f4f4;
            padding: 12px;
            border-radius: 4px;
            overflow-x: auto;
        }
        blockquote {
            border-left: 4px solid #ddd;
            margin-left: 0;
            padding-left: 16px;
            color: #666;
        }
        .metadata {
            color: #666;
            font-size: 0.9em;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #ddd;
        }
    </style>
</head>
<body>
    <h1>${document.title}</h1>
    <div class="metadata">
        Created: ${_formatDate(document.createdAt)} | 
        ${document.getWordCount()} words
    </div>
    ${converter.convert()}
</body>
</html>
''';

      // Save to temporary file
      final output = await getTemporaryDirectory();
      final fileName = '${document.title.replaceAll(' ', '_')}.html';
      final file = File('${output.path}/$fileName');
      await file.writeAsString(html);

      return ExportResult.success(
        filePath: file.path,
        fileName: fileName,
        mimeType: 'text/html',
      );
    } catch (e) {
      return ExportResult.error('Failed to export HTML: $e');
    }
  }

  /// Export as plain text
  Future<ExportResult> exportAsPlainText({
    required EditorDocument document,
    required Delta delta,
  }) async {
    try {
      final plainText = delta.toPlainText();
      
      // Save to temporary file
      final output = await getTemporaryDirectory();
      final fileName = '${document.title.replaceAll(' ', '_')}.txt';
      final file = File('${output.path}/$fileName');
      await file.writeAsString(plainText);

      return ExportResult.success(
        filePath: file.path,
        fileName: fileName,
        mimeType: 'text/plain',
      );
    } catch (e) {
      return ExportResult.error('Failed to export plain text: $e');
    }
  }

  /// Share document
  /// 
  /// Uses platform share sheet to share document in specified format.
  Future<ShareResult> shareDocument({
    required EditorDocument document,
    required Delta delta,
    required ShareFormat format,
  }) async {
    try {
      ExportResult exportResult;

      switch (format) {
        case ShareFormat.pdf:
          exportResult = await exportAsPDF(document: document, delta: delta);
          break;
        case ShareFormat.markdown:
          exportResult = await exportAsMarkdown(document: document, delta: delta);
          break;
        case ShareFormat.html:
          exportResult = await exportAsHTML(document: document, delta: delta);
          break;
        case ShareFormat.plainText:
          exportResult = await exportAsPlainText(document: document, delta: delta);
          break;
      }

      if (!exportResult.success) {
        return ShareResult.error(exportResult.error ?? 'Export failed');
      }

      // Share using share_plus
      final result = await Share.shareXFiles(
        [XFile(exportResult.filePath!, mimeType: exportResult.mimeType)],
        subject: document.title,
        text: 'Sharing: ${document.title}',
      );

      return ShareResult.success(result.status);
    } catch (e) {
      return ShareResult.error('Failed to share: $e');
    }
  }

  /// Print document
  Future<void> printDocument({
    required EditorDocument document,
    required Delta delta,
  }) async {
    try {
      final pdf = pw.Document();

      final content = _deltaToFormattedText(delta);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  document.title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              ...content,
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      throw Exception('Failed to print: $e');
    }
  }

  /// Export via Kotlin side (for Google Docs, etc.)
  Future<ExportResult> exportViaKotlin({
    required EditorDocument document,
    required String format,
    required Map<String, dynamic> options,
  }) async {
    try {
      final result = await _exportChannel.invokeMethod('exportDocument', {
        'documentId': document.id,
        'title': document.title,
        'content': document.content,
        'format': format,
        'options': options,
      });

      if (result is Map) {
        final success = result['success'] as bool? ?? false;
        if (success) {
          return ExportResult.success(
            filePath: result['filePath'] as String?,
            fileName: result['fileName'] as String?,
            cloudUrl: result['cloudUrl'] as String?,
          );
        } else {
          return ExportResult.error(result['error'] as String? ?? 'Unknown error');
        }
      }
      return ExportResult.error('Invalid response from native side');
    } catch (e) {
      return ExportResult.error('Failed to export via Kotlin: $e');
    }
  }

  /// Convert Delta to formatted PDF widgets
  List<pw.Widget> _deltaToFormattedText(Delta delta) {
    final widgets = <pw.Widget>[];
    final operations = delta.toList();

    for (final op in operations) {
      if (op.data is String) {
        final text = op.data as String;
        final attributes = op.attributes;

        if (text.trim().isEmpty && text != '\n') continue;

        // Determine styling
        pw.TextStyle style = const pw.TextStyle(fontSize: 12);
        
        if (attributes != null) {
          if (attributes['bold'] == true) {
            style = style.copyWith(fontWeight: pw.FontWeight.bold);
          }
          if (attributes['italic'] == true) {
            style = style.copyWith(fontStyle: pw.FontStyle.italic);
          }
          if (attributes['underline'] == true) {
            style = style.copyWith(decoration: pw.TextDecoration.underline);
          }
          if (attributes['header'] != null) {
            final level = attributes['header'] as int;
            final fontSize = level == 1 ? 20.0 : level == 2 ? 16.0 : 14.0;
            style = style.copyWith(
              fontSize: fontSize,
              fontWeight: pw.FontWeight.bold,
            );
          }
          if (attributes['code-block'] == true) {
            widgets.add(
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(text, style: pw.TextStyle(font: pw.Font.courier())),
              ),
            );
            continue;
          }
          if (attributes['blockquote'] == true) {
            widgets.add(
              pw.Container(
                padding: const pw.EdgeInsets.only(left: 12),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    left: pw.BorderSide(color: PdfColors.grey, width: 4),
                  ),
                ),
                child: pw.Text(text, style: style.copyWith(color: PdfColors.grey700)),
              ),
            );
            continue;
          }
        }

        widgets.add(pw.Paragraph(text: text, style: style));
      }
    }

    return widgets;
  }

  /// Convert Delta to Markdown
  String _deltaToMarkdown(Delta delta) {
    final buffer = StringBuffer();
    final operations = delta.toList();

    for (final op in operations) {
      if (op.data is String) {
        String text = op.data as String;
        final attributes = op.attributes;

        if (attributes != null) {
          if (attributes['bold'] == true) {
            text = '**$text**';
          }
          if (attributes['italic'] == true) {
            text = '*$text*';
          }
          if (attributes['code'] == true) {
            text = '`$text`';
          }
          if (attributes['link'] != null) {
            final url = attributes['link'] as String;
            text = '[$text]($url)';
          }
          if (attributes['header'] != null) {
            final level = attributes['header'] as int;
            text = '${'#' * level} $text';
          }
          if (attributes['list'] == 'bullet') {
            text = '- $text';
          }
          if (attributes['list'] == 'ordered') {
            text = '1. $text';
          }
          if (attributes['list'] == 'checked') {
            text = '- [x] $text';
          }
          if (attributes['list'] == 'unchecked') {
            text = '- [ ] $text';
          }
          if (attributes['code-block'] == true) {
            text = '```\n$text\n```';
          }
          if (attributes['blockquote'] == true) {
            text = '> $text';
          }
        }

        buffer.write(text);
      }
    }

    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Result of an export operation
class ExportResult {
  final bool success;
  final String? filePath;
  final String? fileName;
  final String? mimeType;
  final String? cloudUrl;
  final String? error;

  ExportResult({
    required this.success,
    this.filePath,
    this.fileName,
    this.mimeType,
    this.cloudUrl,
    this.error,
  });

  factory ExportResult.success({
    String? filePath,
    String? fileName,
    String? mimeType,
    String? cloudUrl,
  }) {
    return ExportResult(
      success: true,
      filePath: filePath,
      fileName: fileName,
      mimeType: mimeType,
      cloudUrl: cloudUrl,
    );
  }

  factory ExportResult.error(String error) {
    return ExportResult(
      success: false,
      error: error,
    );
  }
}

/// Result of a share operation
class ShareResult {
  final bool success;
  final ShareResultStatus? status;
  final String? error;

  ShareResult({
    required this.success,
    this.status,
    this.error,
  });

  factory ShareResult.success(ShareResultStatus status) {
    return ShareResult(success: true, status: status);
  }

  factory ShareResult.error(String error) {
    return ShareResult(success: false, error: error);
  }
}

/// Share format options
enum ShareFormat {
  pdf,
  markdown,
  html,
  plainText,
}
