/// System-level tool model for UI automation, notifications, and other Android system features
library;

import 'package:json_annotation/json_annotation.dart';

part 'system_tool.g.dart';

/// System tool categories matching Blurr's capabilities
enum SystemToolCategory {
  uiAutomation,
  notification,
  accessibility,
  systemControl,
  phoneControl,
}

/// UI automation action types
enum UIAutomationAction {
  tap,
  longPress,
  swipe,
  type,
  scroll,
  back,
  home,
  recents,
  notifications,
  quickSettings,
  powerDialog,
  screenshot,
  lockScreen,
  openApp,
  getScreenHierarchy,
  getCurrentActivity,
  findElement,
}

/// Notification action types
enum NotificationAction {
  getAll,
  getByApp,
  dismiss,
  dismissAll,
  click,
  expand,
}

/// System control action types
enum SystemControlAction {
  volumeUp,
  volumeDown,
  toggleWifi,
  toggleBluetooth,
  toggleFlashlight,
  openSettings,
  takeScreenshot,
  lockScreen,
}

@JsonSerializable()
class SystemTool {
  final String id;
  final String name;
  final String description;
  final SystemToolCategory category;
  final List<SystemToolParameter> parameters;
  final bool requiresPermission;
  final String? permissionName;

  SystemTool({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.parameters = const [],
    this.requiresPermission = false,
    this.permissionName,
  });

  factory SystemTool.fromJson(Map<String, dynamic> json) =>
      _$SystemToolFromJson(json);

  Map<String, dynamic> toJson() => _$SystemToolToJson(this);
}

@JsonSerializable()
class SystemToolParameter {
  final String name;
  final String type;
  final String description;
  final bool required;
  final dynamic defaultValue;
  final List<String>? allowedValues;

  SystemToolParameter({
    required this.name,
    required this.type,
    required this.description,
    this.required = true,
    this.defaultValue,
    this.allowedValues,
  });

  factory SystemToolParameter.fromJson(Map<String, dynamic> json) =>
      _$SystemToolParameterFromJson(json);

  Map<String, dynamic> toJson() => _$SystemToolParameterToJson(this);
}

/// Pre-defined system tools matching Blurr's PhoneControlTool capabilities
class SystemTools {
  // UI Automation Tools
  static final tapElement = SystemTool(
    id: 'ui_tap',
    name: 'Tap Element',
    description: 'Tap on a UI element by text, ID, or coordinates',
    category: SystemToolCategory.uiAutomation,
    requiresPermission: true,
    permissionName: 'Accessibility Service',
    parameters: [
      SystemToolParameter(
        name: 'text',
        type: 'string',
        description: 'Text of the element to tap',
        required: false,
      ),
      SystemToolParameter(
        name: 'resourceId',
        type: 'string',
        description: 'Resource ID of the element',
        required: false,
      ),
      SystemToolParameter(
        name: 'x',
        type: 'number',
        description: 'X coordinate',
        required: false,
      ),
      SystemToolParameter(
        name: 'y',
        type: 'number',
        description: 'Y coordinate',
        required: false,
      ),
    ],
  );

  static final typeText = SystemTool(
    id: 'ui_type',
    name: 'Type Text',
    description: 'Type text into the currently focused input field',
    category: SystemToolCategory.uiAutomation,
    requiresPermission: true,
    permissionName: 'Accessibility Service',
    parameters: [
      SystemToolParameter(
        name: 'text',
        type: 'string',
        description: 'Text to type',
        required: true,
      ),
    ],
  );

  static final swipe = SystemTool(
    id: 'ui_swipe',
    name: 'Swipe',
    description: 'Perform a swipe gesture',
    category: SystemToolCategory.uiAutomation,
    requiresPermission: true,
    permissionName: 'Accessibility Service',
    parameters: [
      SystemToolParameter(
        name: 'direction',
        type: 'string',
        description: 'Swipe direction',
        required: true,
        allowedValues: ['up', 'down', 'left', 'right'],
      ),
      SystemToolParameter(
        name: 'fromX',
        type: 'number',
        description: 'Starting X coordinate',
        required: false,
      ),
      SystemToolParameter(
        name: 'fromY',
        type: 'number',
        description: 'Starting Y coordinate',
        required: false,
      ),
      SystemToolParameter(
        name: 'toX',
        type: 'number',
        description: 'Ending X coordinate',
        required: false,
      ),
      SystemToolParameter(
        name: 'toY',
        type: 'number',
        description: 'Ending Y coordinate',
        required: false,
      ),
    ],
  );

  static final scroll = SystemTool(
    id: 'ui_scroll',
    name: 'Scroll',
    description: 'Scroll in a direction',
    category: SystemToolCategory.uiAutomation,
    requiresPermission: true,
    permissionName: 'Accessibility Service',
    parameters: [
      SystemToolParameter(
        name: 'direction',
        type: 'string',
        description: 'Scroll direction',
        required: true,
        allowedValues: ['up', 'down'],
      ),
    ],
  );

  static final pressBack = SystemTool(
    id: 'ui_back',
    name: 'Press Back',
    description: 'Press the back button',
    category: SystemToolCategory.uiAutomation,
    requiresPermission: true,
    permissionName: 'Accessibility Service',
    parameters: [],
  );

  static final pressHome = SystemTool(
    id: 'ui_home',
    name: 'Press Home',
    description: 'Go to home screen',
    category: SystemToolCategory.uiAutomation,
    requiresPermission: true,
    permissionName: 'Accessibility Service',
    parameters: [],
  );

  static final openNotifications = SystemTool(
    id: 'ui_open_notifications',
    name: 'Open Notifications',
    description: 'Open the notification shade',
    category: SystemToolCategory.uiAutomation,
    requiresPermission: true,
    permissionName: 'Accessibility Service',
    parameters: [],
  );

  static final openApp = SystemTool(
    id: 'ui_open_app',
    name: 'Open App',
    description: 'Open an app by package name',
    category: SystemToolCategory.uiAutomation,
    requiresPermission: true,
    permissionName: 'Accessibility Service',
    parameters: [
      SystemToolParameter(
        name: 'packageName',
        type: 'string',
        description: 'Package name of the app to open',
        required: true,
      ),
    ],
  );

  static final getScreenHierarchy = SystemTool(
    id: 'ui_get_hierarchy',
    name: 'Get Screen Hierarchy',
    description: 'Get the current UI hierarchy as XML',
    category: SystemToolCategory.uiAutomation,
    requiresPermission: true,
    permissionName: 'Accessibility Service',
    parameters: [
      SystemToolParameter(
        name: 'format',
        type: 'string',
        description: 'Output format',
        required: false,
        defaultValue: 'xml',
        allowedValues: ['xml', 'markdown'],
      ),
    ],
  );

  static final screenshot = SystemTool(
    id: 'ui_screenshot',
    name: 'Take Screenshot',
    description: 'Capture a screenshot of the current screen',
    category: SystemToolCategory.uiAutomation,
    requiresPermission: true,
    permissionName: 'Accessibility Service',
    parameters: [],
  );

  // Notification Tools
  static final getAllNotifications = SystemTool(
    id: 'notif_get_all',
    name: 'Get All Notifications',
    description: 'Get all active notifications',
    category: SystemToolCategory.notification,
    requiresPermission: true,
    permissionName: 'Notification Listener',
    parameters: [],
  );

  static final getNotificationsByApp = SystemTool(
    id: 'notif_get_by_app',
    name: 'Get Notifications by App',
    description: 'Get notifications from a specific app',
    category: SystemToolCategory.notification,
    requiresPermission: true,
    permissionName: 'Notification Listener',
    parameters: [
      SystemToolParameter(
        name: 'packageName',
        type: 'string',
        description: 'Package name of the app',
        required: true,
      ),
    ],
  );

  static final dismissNotification = SystemTool(
    id: 'notif_dismiss',
    name: 'Dismiss Notification',
    description: 'Dismiss a specific notification',
    category: SystemToolCategory.notification,
    requiresPermission: true,
    permissionName: 'Notification Listener',
    parameters: [
      SystemToolParameter(
        name: 'notificationKey',
        type: 'string',
        description: 'Key of the notification to dismiss',
        required: true,
      ),
    ],
  );

  // System Control Tools
  static final getCurrentActivity = SystemTool(
    id: 'system_get_activity',
    name: 'Get Current Activity',
    description: 'Get the package name of the current foreground activity',
    category: SystemToolCategory.systemControl,
    requiresPermission: true,
    permissionName: 'Accessibility Service',
    parameters: [],
  );

  static final openSettings = SystemTool(
    id: 'system_open_settings',
    name: 'Open Settings',
    description: 'Open Android Settings',
    category: SystemToolCategory.systemControl,
    requiresPermission: false,
    parameters: [
      SystemToolParameter(
        name: 'settingsPage',
        type: 'string',
        description: 'Specific settings page to open',
        required: false,
        allowedValues: ['wifi', 'bluetooth', 'app', 'location', 'accessibility'],
      ),
    ],
  );

  static List<SystemTool> getAllTools() {
    return [
      // UI Automation
      tapElement,
      typeText,
      swipe,
      scroll,
      pressBack,
      pressHome,
      openNotifications,
      openApp,
      getScreenHierarchy,
      screenshot,
      
      // Notifications
      getAllNotifications,
      getNotificationsByApp,
      dismissNotification,
      
      // System Control
      getCurrentActivity,
      openSettings,
    ];
  }

  static List<SystemTool> getToolsByCategory(SystemToolCategory category) {
    return getAllTools().where((tool) => tool.category == category).toList();
  }

  static SystemTool? getToolById(String id) {
    try {
      return getAllTools().firstWhere((tool) => tool.id == id);
    } catch (e) {
      return null;
    }
  }
}
