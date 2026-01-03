import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document.g.dart';

/// Represents a document in the AI-Native Text Editor.
/// 
/// This model stores document metadata and content using Quill Delta format.
/// The content is stored as a JSON-serializable list of operations.
@JsonSerializable()
class EditorDocument {
  /// Unique identifier for the document
  final String id;
  
  /// Document title
  String title;
  
  /// Quill Delta content (stored as JSON)
  final List<dynamic> content;
  
  /// Timestamp when document was created
  final DateTime createdAt;
  
  /// Timestamp when document was last modified
  DateTime updatedAt;
  
  /// Tags for organization
  final List<String> tags;
  
  /// Whether this document is a template
  final bool isTemplate;
  
  /// Template category (e.g., "blog", "email", "essay")
  final String? templateCategory;
  
  /// Pro feature flag - some templates or features may be Pro-only
  final bool requiresPro;

  EditorDocument({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.isTemplate = false,
    this.templateCategory,
    this.requiresPro = false,
  });

  /// Create a new empty document
  factory EditorDocument.empty({String? title}) {
    final now = DateTime.now();
    return EditorDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title ?? 'Untitled Document',
      content: [
        {'insert': '\n'}
      ],
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create from Quill Delta
  factory EditorDocument.fromDelta({
    required String id,
    required String title,
    required Delta delta,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String> tags = const [],
  }) {
    final now = DateTime.now();
    return EditorDocument(
      id: id,
      title: title,
      content: delta.toJson(),
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      tags: tags,
    );
  }

  /// Convert to Delta for Quill editor
  Delta toDelta() {
    return Delta.fromJson(content);
  }

  /// Update document content from controller
  EditorDocument copyWithDelta(Delta delta) {
    return EditorDocument(
      id: id,
      title: title,
      content: delta.toJson(),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      tags: tags,
      isTemplate: isTemplate,
      templateCategory: templateCategory,
      requiresPro: requiresPro,
    );
  }

  /// Copy with modifications
  EditorDocument copyWith({
    String? title,
    List<dynamic>? content,
    DateTime? updatedAt,
    List<String>? tags,
    bool? isTemplate,
    String? templateCategory,
    bool? requiresPro,
  }) {
    return EditorDocument(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      tags: tags ?? this.tags,
      isTemplate: isTemplate ?? this.isTemplate,
      templateCategory: templateCategory ?? this.templateCategory,
      requiresPro: requiresPro ?? this.requiresPro,
    );
  }

  /// Get plain text content
  String getPlainText() {
    final delta = toDelta();
    return delta.toPlainText();
  }

  /// Get word count
  int getWordCount() {
    final text = getPlainText().trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  /// JSON serialization
  factory EditorDocument.fromJson(Map<String, dynamic> json) =>
      _$EditorDocumentFromJson(json);
  
  Map<String, dynamic> toJson() => _$EditorDocumentToJson(this);

  @override
  String toString() {
    return 'EditorDocument(id: $id, title: $title, words: ${getWordCount()})';
  }
}

/// Predefined document templates
class DocumentTemplates {
  static final List<EditorDocument> templates = [
    _createTemplate(
      id: 'template_blog',
      title: 'Blog Post',
      category: 'blog',
      content: '''
# Your Blog Post Title

## Introduction
Write an engaging introduction that hooks your readers...

## Main Content
Share your insights, stories, or information here...

## Conclusion
Wrap up with key takeaways and a call to action...

---
*Published on ${DateTime.now().toString().split(' ')[0]}*
''',
    ),
    _createTemplate(
      id: 'template_email',
      title: 'Professional Email',
      category: 'email',
      content: '''
Subject: 

Dear [Recipient Name],

I hope this email finds you well.

[Your message here]

Best regards,
[Your Name]
''',
    ),
    _createTemplate(
      id: 'template_essay',
      title: 'Essay',
      category: 'essay',
      content: '''
# Essay Title

## Thesis Statement
State your main argument or thesis here...

## Body Paragraph 1
First supporting argument with evidence...

## Body Paragraph 2
Second supporting argument with evidence...

## Body Paragraph 3
Third supporting argument with evidence...

## Conclusion
Summarize your arguments and restate your thesis...

## References
1. 
2. 
''',
    ),
    _createTemplate(
      id: 'template_report',
      title: 'Business Report',
      category: 'report',
      content: '''
# Report Title

**Date:** ${DateTime.now().toString().split(' ')[0]}
**Prepared by:** [Your Name]

## Executive Summary
Brief overview of key findings and recommendations...

## Background
Context and background information...

## Findings
1. **Key Finding 1**
   - Details and analysis

2. **Key Finding 2**
   - Details and analysis

## Recommendations
- Recommendation 1
- Recommendation 2

## Conclusion
Final thoughts and next steps...
''',
    ),
    _createTemplate(
      id: 'template_meeting_notes',
      title: 'Meeting Notes',
      category: 'notes',
      content: '''
# Meeting Notes

**Date:** ${DateTime.now().toString().split(' ')[0]}
**Attendees:** 
**Purpose:** 

## Agenda
1. 
2. 
3. 

## Discussion Points
- 

## Action Items
- [ ] Task 1 - Assigned to:
- [ ] Task 2 - Assigned to:

## Next Steps
''',
      requiresPro: false,
    ),
    _createTemplate(
      id: 'template_creative',
      title: 'Creative Writing',
      category: 'creative',
      content: '''
# Story Title

*Genre: [Your Genre]*

## Chapter 1

The story begins...

---

**Notes:**
- Characters:
- Setting:
- Plot points:
''',
      requiresPro: true,
    ),
  ];

  static EditorDocument _createTemplate({
    required String id,
    required String title,
    required String category,
    required String content,
    bool requiresPro = false,
  }) {
    final delta = Delta();
    delta.insert(content);
    final now = DateTime.now();
    
    return EditorDocument(
      id: id,
      title: title,
      content: delta.toJson(),
      createdAt: now,
      updatedAt: now,
      isTemplate: true,
      templateCategory: category,
      requiresPro: requiresPro,
      tags: [category, 'template'],
    );
  }

  /// Get templates by category
  static List<EditorDocument> getByCategory(String category) {
    return templates.where((t) => t.templateCategory == category).toList();
  }

  /// Get free templates
  static List<EditorDocument> getFreeTemplates() {
    return templates.where((t) => !t.requiresPro).toList();
  }

  /// Get Pro templates
  static List<EditorDocument> getProTemplates() {
    return templates.where((t) => t.requiresPro).toList();
  }
}
