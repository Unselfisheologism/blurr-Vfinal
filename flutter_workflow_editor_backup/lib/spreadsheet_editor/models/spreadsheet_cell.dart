/// Spreadsheet cell model with formatting and value
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'spreadsheet_cell.g.dart';

/// Cell data type
enum CellDataType {
  text,
  number,
  formula,
  date,
  boolean,
}

/// Cell formatting options
@JsonSerializable()
class CellFormat {
  final bool bold;
  final bool italic;
  final bool underline;
  final String? fontFamily;
  final double? fontSize;
  final String? textColor; // Color as hex string
  final String? backgroundColor;
  final TextAlign? alignment;
  final String? numberFormat; // e.g., "0.00", "$#,##0.00"

  const CellFormat({
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.fontFamily,
    this.fontSize,
    this.textColor,
    this.backgroundColor,
    this.alignment,
    this.numberFormat,
  });

  factory CellFormat.fromJson(Map<String, dynamic> json) => _$CellFormatFromJson(json);
  Map<String, dynamic> toJson() => _$CellFormatToJson(this);

  CellFormat copyWith({
    bool? bold,
    bool? italic,
    bool? underline,
    String? fontFamily,
    double? fontSize,
    String? textColor,
    String? backgroundColor,
    TextAlign? alignment,
    String? numberFormat,
  }) {
    return CellFormat(
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      alignment: alignment ?? this.alignment,
      numberFormat: numberFormat ?? this.numberFormat,
    );
  }

  /// Convert hex color string to Color object
  Color? get textColorValue {
    if (textColor == null) return null;
    return Color(int.parse(textColor!.replaceFirst('#', '0xFF')));
  }

  /// Convert hex color string to Color object
  Color? get backgroundColorValue {
    if (backgroundColor == null) return null;
    return Color(int.parse(backgroundColor!.replaceFirst('#', '0xFF')));
  }
}

/// Spreadsheet cell with value, type, and formatting
@JsonSerializable()
class SpreadsheetCell {
  final String id; // e.g., "A1", "B5"
  final dynamic value; // Can be String, num, bool, DateTime, or formula
  final CellDataType dataType;
  final CellFormat format;
  final String? formula; // If dataType is formula, this contains the formula string

  const SpreadsheetCell({
    required this.id,
    this.value,
    this.dataType = CellDataType.text,
    this.format = const CellFormat(),
    this.formula,
  });

  factory SpreadsheetCell.fromJson(Map<String, dynamic> json) => _$SpreadsheetCellFromJson(json);
  Map<String, dynamic> toJson() => _$SpreadsheetCellToJson(this);

  SpreadsheetCell copyWith({
    String? id,
    dynamic value,
    CellDataType? dataType,
    CellFormat? format,
    String? formula,
  }) {
    return SpreadsheetCell(
      id: id ?? this.id,
      value: value ?? this.value,
      dataType: dataType ?? this.dataType,
      format: format ?? this.format,
      formula: formula ?? this.formula,
    );
  }

  /// Get display value (formatted)
  String get displayValue {
    if (value == null) return '';
    
    switch (dataType) {
      case CellDataType.formula:
        return value?.toString() ?? '';
      case CellDataType.number:
        if (format.numberFormat != null && value is num) {
          // Simple number formatting (can be enhanced with intl package)
          return value.toStringAsFixed(2);
        }
        return value.toString();
      case CellDataType.date:
        if (value is DateTime) {
          return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
        }
        return value.toString();
      case CellDataType.boolean:
        return value.toString().toUpperCase();
      default:
        return value.toString();
    }
  }

  /// Empty cell factory
  factory SpreadsheetCell.empty(String id) {
    return SpreadsheetCell(id: id, value: null);
  }
}
