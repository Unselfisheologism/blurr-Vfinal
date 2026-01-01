# Spreadsheet Editor Quick Start Guide

## Setup Instructions

### 1. Generate JSON Serialization Code
The spreadsheet models use JSON serialization which requires code generation:

```bash
cd flutter_workflow_editor
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- `lib/spreadsheet_editor/models/spreadsheet_cell.g.dart`
- `lib/spreadsheet_editor/models/spreadsheet_document.g.dart`

### 2. Update AndroidManifest.xml
Add the SpreadsheetEditorActivity to your manifest:

```xml
<application>
    <!-- Existing activities... -->
    
    <activity
        android:name=".SpreadsheetEditorActivity"
        android:exported="false"
        android:theme="@style/Theme.Blurr"
        android:configChanges="orientation|screenSize|keyboard|keyboardHidden"
        android:windowSoftInputMode="adjustResize" />
</application>
```

### 3. Register SpreadsheetTool (Optional - for AI Agent)
In your ToolExecutor or agent initialization code:

```kotlin
// In ToolExecutor.kt or similar
val spreadsheetTool = SpreadsheetTool(context)
registerTool(spreadsheetTool)
```

### 4. Initialize Hive (if not already done)
In your Flutter app initialization:

```dart
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const WorkflowEditorApp());
}
```

## Launch Methods

### From Kotlin/Android

#### Method 1: Create Blank Spreadsheet
```kotlin
val intent = Intent(context, SpreadsheetEditorActivity::class.java)
context.startActivity(intent)
```

#### Method 2: Open Existing Document
```kotlin
val intent = Intent(context, SpreadsheetEditorActivity::class.java).apply {
    putExtra(SpreadsheetEditorActivity.EXTRA_DOCUMENT_ID, "doc_12345")
}
context.startActivity(intent)
```

#### Method 3: Generate from AI Prompt
```kotlin
val intent = Intent(context, SpreadsheetEditorActivity::class.java).apply {
    putExtra(SpreadsheetEditorActivity.EXTRA_INITIAL_PROMPT, 
             "create a monthly budget tracker with income and expenses")
}
context.startActivity(intent)
```

### From Flutter

#### Method 1: Named Route
```dart
Navigator.pushNamed(context, '/spreadsheet_editor');
```

#### Method 2: Open Specific Document
```dart
Navigator.pushNamed(context, '/spreadsheet_editor/doc_12345');
```

#### Method 3: Direct Navigation
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SpreadsheetEditorScreen(
      initialPrompt: 'create sales tracker',
    ),
  ),
);
```

## Basic Usage

### Creating a Spreadsheet
1. Launch the app → Blank spreadsheet appears
2. Click cells to edit values
3. Use toolbar for formatting (bold, colors, alignment)
4. Click "+" to add rows/columns
5. Click save icon to persist

### Using AI Features
1. **Generate Data**:
   - Click "Generate Data" in AI toolbar
   - Enter prompt: "monthly sales data for 2024"
   - AI populates cells

2. **Fill Column**:
   - Select column cells
   - Click "Fill Column"
   - Enter pattern: "sequential dates starting today"

3. **Analyze Selection**:
   - Select data cells
   - Click "Analyze"
   - View AI insights

4. **Write Formula**:
   - Select result cell
   - Click "Write Formula"
   - Describe: "sum of column A"
   - AI generates: `=SUM(A1:A10)`

5. **Create Chart**:
   - Select data range
   - Click "Create Chart"
   - Choose chart type
   - View visualization

6. **Summarize Sheet**:
   - Click "Summarize"
   - AI provides overview of all data

### Importing/Exporting Excel

#### Import
1. Click folder icon (Open)
2. Select .xlsx file
3. Data and formatting imported

#### Export
1. Click download icon
2. File saved to device storage as .xlsx
3. Open with Excel/Sheets/LibreOffice

### Multi-Sheet Operations
1. Click "+" at bottom to add sheet
2. Click sheet tab to switch
3. Each sheet has independent data

## Keyboard Shortcuts (Desktop/Web)

- **Arrow Keys**: Navigate cells
- **Enter**: Edit cell / Move down
- **Tab**: Move right
- **Shift+Tab**: Move left
- **Escape**: Cancel editing
- **Space**: Toggle selection (multi-select mode)

## Troubleshooting

### Issue: "No spreadsheet loaded"
**Solution**: Ensure SpreadsheetState is provided in the widget tree:
```dart
ChangeNotifierProvider(create: (_) => SpreadsheetState())
```

### Issue: JSON serialization errors
**Solution**: Run build_runner:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: AI features not working
**Solution**: 
1. Check SpreadsheetEditorBridge is initialized in Activity
2. Verify ToolExecutor is accessible
3. Check platform channel name matches: `com.blurr.spreadsheet_editor/bridge`

### Issue: Excel export fails
**Solution**: 
1. Ensure storage permissions granted
2. Check `getApplicationDocumentsDirectory()` is accessible
3. Verify Syncfusion XLSIO package is imported

### Issue: Charts not displaying
**Solution**:
1. Ensure `syncfusion_flutter_charts` is in dependencies
2. Check data format: `List<ChartDataPoint>`
3. Verify chart type is supported

## Architecture Overview

```
User Interaction
     ↓
SpreadsheetEditorScreen (UI)
     ↓
SpreadsheetState (State Management)
     ↓
SpreadsheetDataSource (Syncfusion DataGrid)
     ↓
SpreadsheetStorageService (Hive) ←→ ExcelService (XLSIO)
     ↓
PlatformBridge ←→ SpreadsheetEditorBridge (Kotlin)
     ↓
ToolExecutor (AI Agent)
```

## Pro Features (Gating)

Currently, AI features show Pro badge but are accessible. To enable Pro gating:

1. Update `checkProStatus()` in SpreadsheetEditorBridge.kt:
```kotlin
private fun checkProStatus(result: MethodChannel.Result) {
    val freemiumManager = FreemiumManager(context)
    val isPro = freemiumManager.hasActiveSubscription()
    
    result.success(mapOf(
        "isPro" to isPro,
        "features" to mapOf(
            "aiGeneration" to isPro,
            "advancedFormulas" to isPro,
            "charts" to isPro
        )
    ))
}
```

2. In SpreadsheetEditorScreen, check Pro status before AI actions:
```dart
Future<void> _handleGenerateData() async {
  final proStatus = await _platformBridge.checkProStatus();
  if (proStatus['isPro'] != true) {
    _showProUpgradeDialog();
    return;
  }
  // Continue with AI generation...
}
```

## Testing Checklist

- [ ] Create new spreadsheet
- [ ] Edit cells (text, numbers, dates)
- [ ] Apply formatting (bold, italic, colors)
- [ ] Add/delete rows
- [ ] Add/delete columns
- [ ] Switch between sheets
- [ ] Add new sheet
- [ ] Save spreadsheet
- [ ] Load saved spreadsheet
- [ ] Export to Excel
- [ ] Import from Excel
- [ ] Generate data via AI
- [ ] Fill column via AI
- [ ] Analyze selection via AI
- [ ] Write formula via AI
- [ ] Create chart (column)
- [ ] Create chart (pie)
- [ ] Summarize sheet via AI
- [ ] Launch from AI agent with prompt
- [ ] Pro feature gating

## Support

For issues or questions:
1. Check implementation guide: `EPIC_3_SPREADSHEET_IMPLEMENTATION.md`
2. Review Syncfusion docs: `syncfusion_flutter_datagrid_docs.md` (specific sections)
3. Check Flutter logs: `flutter logs`
4. Check Android logs: `adb logcat | grep SpreadsheetEditor`

## Next Steps

After completing this quick start:
1. Run the testing checklist above
2. Customize themes/colors to match app design
3. Add additional AI prompts/templates
4. Implement Pro feature gating
5. Add undo/redo functionality
6. Enhance formula engine
7. Add more chart types
8. Implement cell validation
9. Add conditional formatting
10. Build spreadsheet templates library

Enjoy your AI-Native Spreadsheets! 🎉📊
