// GENERATED CODE - DO NOT MODIFY BY HAND
// This is a placeholder for the generated JSON serialization code
// Run: flutter pub run build_runner build

part of 'spreadsheet_document.dart';

SpreadsheetDocument _$SpreadsheetDocumentFromJson(Map<String, dynamic> json) => SpreadsheetDocument(
      id: json['id'] as String,
      name: json['name'] as String,
      sheets: (json['sheets'] as List<dynamic>)
          .map((e) => SpreadsheetSheet.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SpreadsheetDocumentToJson(SpreadsheetDocument instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sheets': instance.sheets.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

SpreadsheetSheet _$SpreadsheetSheetFromJson(Map<String, dynamic> json) => SpreadsheetSheet(
      id: json['id'] as String,
      name: json['name'] as String,
      rowCount: json['rowCount'] as int? ?? 100,
      columnCount: json['columnCount'] as int? ?? 26,
      cells: (json['cells'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, SpreadsheetCell.fromJson(e as Map<String, dynamic>)),
          ) ??
          {},
    );

Map<String, dynamic> _$SpreadsheetSheetToJson(SpreadsheetSheet instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'rowCount': instance.rowCount,
      'columnCount': instance.columnCount,
      'cells': instance.cells.map((k, e) => MapEntry(k, e.toJson())),
    };
