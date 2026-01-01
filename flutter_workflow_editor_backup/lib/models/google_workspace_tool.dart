/// Google Workspace tool models
library;

import 'package:json_annotation/json_annotation.dart';

part 'google_workspace_tool.g.dart';

/// Google Workspace service types
enum GoogleWorkspaceService {
  gmail,
  calendar,
  drive,
}

@JsonSerializable()
class GoogleWorkspaceTool {
  final String id;
  final String name;
  final GoogleWorkspaceService service;
  final String? description;
  final String? icon;
  final List<GoogleWorkspaceAction> actions;
  final bool authenticated;

  GoogleWorkspaceTool({
    required this.id,
    required this.name,
    required this.service,
    this.description,
    this.icon,
    this.actions = const [],
    this.authenticated = false,
  });

  factory GoogleWorkspaceTool.fromJson(Map<String, dynamic> json) =>
      _$GoogleWorkspaceToolFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleWorkspaceToolToJson(this);
}

@JsonSerializable()
class GoogleWorkspaceAction {
  final String name;
  final String displayName;
  final String? description;
  final List<GoogleWorkspaceParameter> parameters;
  final Map<String, dynamic>? responseSchema;

  GoogleWorkspaceAction({
    required this.name,
    required this.displayName,
    this.description,
    this.parameters = const [],
    this.responseSchema,
  });

  factory GoogleWorkspaceAction.fromJson(Map<String, dynamic> json) =>
      _$GoogleWorkspaceActionFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleWorkspaceActionToJson(this);
}

@JsonSerializable()
class GoogleWorkspaceParameter {
  final String name;
  final String type;
  final String? description;
  final bool required;
  final dynamic defaultValue;
  final List<String>? enumValues;

  GoogleWorkspaceParameter({
    required this.name,
    required this.type,
    this.description,
    this.required = false,
    this.defaultValue,
    this.enumValues,
  });

  factory GoogleWorkspaceParameter.fromJson(Map<String, dynamic> json) =>
      _$GoogleWorkspaceParameterFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleWorkspaceParameterToJson(this);
}

/// Predefined Google Workspace tools
class GoogleWorkspaceTools {
  static GoogleWorkspaceTool gmail() {
    return GoogleWorkspaceTool(
      id: 'gmail',
      name: 'Gmail',
      service: GoogleWorkspaceService.gmail,
      description: 'Send, read, and manage emails',
      icon: 'email',
      actions: [
        GoogleWorkspaceAction(
          name: 'send_email',
          displayName: 'Send Email',
          description: 'Send an email',
          parameters: [
            GoogleWorkspaceParameter(
              name: 'to',
              type: 'string',
              description: 'Recipient email address',
              required: true,
            ),
            GoogleWorkspaceParameter(
              name: 'subject',
              type: 'string',
              description: 'Email subject',
              required: true,
            ),
            GoogleWorkspaceParameter(
              name: 'body',
              type: 'string',
              description: 'Email body',
              required: true,
            ),
            GoogleWorkspaceParameter(
              name: 'cc',
              type: 'string',
              description: 'CC recipients (comma-separated)',
              required: false,
            ),
            GoogleWorkspaceParameter(
              name: 'bcc',
              type: 'string',
              description: 'BCC recipients (comma-separated)',
              required: false,
            ),
          ],
        ),
        GoogleWorkspaceAction(
          name: 'read_emails',
          displayName: 'Read Emails',
          description: 'Read emails from inbox',
          parameters: [
            GoogleWorkspaceParameter(
              name: 'max_results',
              type: 'number',
              description: 'Maximum number of emails',
              defaultValue: 10,
            ),
            GoogleWorkspaceParameter(
              name: 'query',
              type: 'string',
              description: 'Search query (Gmail syntax)',
              required: false,
            ),
          ],
        ),
        GoogleWorkspaceAction(
          name: 'search_emails',
          displayName: 'Search Emails',
          description: 'Search emails with query',
          parameters: [
            GoogleWorkspaceParameter(
              name: 'query',
              type: 'string',
              description: 'Search query',
              required: true,
            ),
            GoogleWorkspaceParameter(
              name: 'max_results',
              type: 'number',
              description: 'Maximum results',
              defaultValue: 10,
            ),
          ],
        ),
      ],
    );
  }

  static GoogleWorkspaceTool calendar() {
    return GoogleWorkspaceTool(
      id: 'calendar',
      name: 'Google Calendar',
      service: GoogleWorkspaceService.calendar,
      description: 'Create and manage calendar events',
      icon: 'calendar_today',
      actions: [
        GoogleWorkspaceAction(
          name: 'create_event',
          displayName: 'Create Event',
          description: 'Create a calendar event',
          parameters: [
            GoogleWorkspaceParameter(
              name: 'summary',
              type: 'string',
              description: 'Event title',
              required: true,
            ),
            GoogleWorkspaceParameter(
              name: 'start_time',
              type: 'string',
              description: 'Start time (ISO 8601)',
              required: true,
            ),
            GoogleWorkspaceParameter(
              name: 'end_time',
              type: 'string',
              description: 'End time (ISO 8601)',
              required: true,
            ),
            GoogleWorkspaceParameter(
              name: 'description',
              type: 'string',
              description: 'Event description',
              required: false,
            ),
            GoogleWorkspaceParameter(
              name: 'location',
              type: 'string',
              description: 'Event location',
              required: false,
            ),
            GoogleWorkspaceParameter(
              name: 'attendees',
              type: 'string',
              description: 'Attendee emails (comma-separated)',
              required: false,
            ),
          ],
        ),
        GoogleWorkspaceAction(
          name: 'list_events',
          displayName: 'List Events',
          description: 'List upcoming events',
          parameters: [
            GoogleWorkspaceParameter(
              name: 'max_results',
              type: 'number',
              description: 'Maximum events',
              defaultValue: 10,
            ),
            GoogleWorkspaceParameter(
              name: 'time_min',
              type: 'string',
              description: 'Start time filter',
              required: false,
            ),
          ],
        ),
      ],
    );
  }

  static GoogleWorkspaceTool drive() {
    return GoogleWorkspaceTool(
      id: 'drive',
      name: 'Google Drive',
      service: GoogleWorkspaceService.drive,
      description: 'Manage files and folders',
      icon: 'folder',
      actions: [
        GoogleWorkspaceAction(
          name: 'upload_file',
          displayName: 'Upload File',
          description: 'Upload a file to Drive',
          parameters: [
            GoogleWorkspaceParameter(
              name: 'file_path',
              type: 'string',
              description: 'Local file path',
              required: true,
            ),
            GoogleWorkspaceParameter(
              name: 'name',
              type: 'string',
              description: 'File name in Drive',
              required: false,
            ),
            GoogleWorkspaceParameter(
              name: 'folder_id',
              type: 'string',
              description: 'Parent folder ID',
              required: false,
            ),
          ],
        ),
        GoogleWorkspaceAction(
          name: 'list_files',
          displayName: 'List Files',
          description: 'List files in Drive',
          parameters: [
            GoogleWorkspaceParameter(
              name: 'max_results',
              type: 'number',
              description: 'Maximum files',
              defaultValue: 10,
            ),
            GoogleWorkspaceParameter(
              name: 'query',
              type: 'string',
              description: 'Search query',
              required: false,
            ),
          ],
        ),
        GoogleWorkspaceAction(
          name: 'share_file',
          displayName: 'Share File',
          description: 'Share a file with someone',
          parameters: [
            GoogleWorkspaceParameter(
              name: 'file_id',
              type: 'string',
              description: 'File ID',
              required: true,
            ),
            GoogleWorkspaceParameter(
              name: 'email',
              type: 'string',
              description: 'Email to share with',
              required: true,
            ),
            GoogleWorkspaceParameter(
              name: 'role',
              type: 'string',
              description: 'Permission role',
              defaultValue: 'reader',
              enumValues: ['reader', 'writer', 'commenter'],
            ),
          ],
        ),
      ],
    );
  }

  static List<GoogleWorkspaceTool> all() {
    return [gmail(), calendar(), drive()];
  }
}
