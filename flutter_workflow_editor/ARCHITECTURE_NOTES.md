# Architecture & Best Practices - Flutter Workflow Editor

## 🏛️ Architectural Decisions

### Why FL Nodes?

**Selected**: fl_nodes by William Karol DiCioccio  
**Reasoning**:
- Mature, production-ready node rendering engine
- Built-in support for touch interactions
- Extensible prototype system
- Active development and community
- Proper separation of concerns (rendering vs logic)

**Alternative Considered**: Building from scratch with CustomPainter  
**Why Not**: Would require 10x development time for similar features

---

### Why Vertical Layout?

**Decision**: Top-to-bottom flow instead of left-to-right

**Mobile Considerations**:
1. **Screen Real Estate**: Mobile screens are tall, not wide
2. **Natural Scrolling**: Users scroll vertically naturally
3. **One-Handed Use**: Vertical scrolling easier with thumb
4. **Readability**: Top-to-bottom matches natural reading flow
5. **Connection Clarity**: Downward flow is intuitive (cause → effect)

**Implementation**:
```dart
class VerticalLayoutAdapter {
  // Enforces Y-position increases for connected nodes
  // Calculates optimal spacing based on node depth
  // Auto-arranges using topological sort
}
```

---

### Why Provider + Riverpod?

**State Management Strategy**:
- **Provider**: Simple, built into Flutter, good for basic state
- **Riverpod**: More powerful, better for complex state and testing

**Usage Pattern**:
- `WorkflowState` (Provider): UI-driven state with ChangeNotifier
- `AppState` (Provider): Global app state
- Future: Consider migrating to full Riverpod for better testability

**Alternative Considered**: BLoC pattern  
**Why Not**: Overkill for this use case, more boilerplate

---

### Why Platform Channels Instead of FFI?

**Decision**: Method Channel communication with Kotlin

**Reasoning**:
1. **Simplicity**: Easy to implement and maintain
2. **Type Safety**: JSON encoding provides clear contracts
3. **Async Support**: Built-in async/await pattern
4. **Error Handling**: Native exception propagation
5. **Flutter Standard**: Well-documented, community support

**Trade-off**: Slightly slower than FFI, but negligible for workflow operations

---

### Why JSON Serialization?

**Decision**: json_annotation + build_runner code generation

**Reasoning**:
1. **Type Safety**: Generated code is compile-time safe
2. **Maintainability**: Schema changes caught at build time
3. **Performance**: No runtime reflection
4. **Standard**: Industry standard for Flutter apps

**Implementation**:
```dart
@JsonSerializable()
class Workflow {
  // Auto-generated fromJson/toJson
}
```

---

## 🎯 Design Patterns Used

### 1. Factory Pattern (Node Creation)

```dart
class FlNodePrototypeFactory {
  static NodePrototype createPrototype(NodeDefinition definition) {
    // Creates FL Node prototypes from definitions
    // Centralizes node creation logic
  }
}
```

**Why**: Decouples node definition from FL Nodes implementation

---

### 2. Strategy Pattern (Node Execution)

```dart
class WorkflowExecutionEngine {
  Future<NodeExecutionResult> _executeNodeByType(WorkflowNode node) {
    switch (node.type) {
      case 'unified_shell': return _executeUnifiedShell(node);
      case 'http_request': return _executeHttpRequest(node);
      // ... strategies for each node type
    }
  }
}
```

**Why**: Keeps execution logic organized and extensible

---

### 3. Observer Pattern (State Updates)

```dart
class WorkflowState extends ChangeNotifier {
  void addNode(...) {
    // Modify state
    notifyListeners(); // Observers react
  }
}
```

**Why**: Reactive UI updates without manual refresh

---

### 4. Command Pattern (Undo/Redo)

```dart
class WorkflowState {
  final List<Workflow> _undoStack = [];
  final List<Workflow> _redoStack = [];
  
  void _saveToUndoStack() {
    _undoStack.add(_currentWorkflow!);
  }
  
  void undo() {
    _redoStack.add(_currentWorkflow!);
    _currentWorkflow = _undoStack.removeLast();
  }
}
```

**Why**: Immutable state snapshots enable perfect undo/redo

---

### 5. Repository Pattern (Platform Bridge)

```dart
class PlatformBridge {
  Future<Map<String, dynamic>> executeUnifiedShell(...) async {
    // Abstract platform-specific implementation
  }
}
```

**Why**: Separates business logic from platform concerns

---

## 🔧 Key Technical Decisions

### 1. Immutable Data Structures

**Decision**: Use `copyWith` methods, no direct mutation

```dart
class WorkflowNode {
  WorkflowNode copyWith({
    String? id,
    Offset? position,
    // ... other fields
  }) {
    return WorkflowNode(
      id: id ?? this.id,
      position: position ?? this.position,
      // ...
    );
  }
}
```

**Benefits**:
- Enables undo/redo by storing snapshots
- Prevents accidental mutations
- Makes state changes explicit
- Easier to reason about data flow

---

### 2. Async/Await Throughout

**Decision**: All platform operations are async

```dart
Future<void> executeWorkflow() async {
  await _executionEngine!.executeWorkflow(_currentWorkflow!);
}
```

**Benefits**:
- Non-blocking UI
- Natural error handling with try/catch
- Composable async operations
- Future-proof for concurrent execution

---

### 3. Null Safety

**Decision**: Full null safety enabled

```dart
Workflow? _currentWorkflow; // Can be null
WorkflowNode? _selectedNode; // Can be null

void addNode(...) {
  if (_currentWorkflow == null) return; // Guard clause
}
```

**Benefits**:
- Prevents null reference errors at compile time
- Forces explicit null handling
- Safer, more robust code

---

### 4. Single Source of Truth

**Decision**: WorkflowState owns all workflow data

```dart
class WorkflowState extends ChangeNotifier {
  Workflow? _currentWorkflow; // Single source
  
  // All mutations go through state methods
  void addNode(...) { /* ... */ }
  void removeNode(...) { /* ... */ }
}
```

**Benefits**:
- Predictable state updates
- Easy to debug state changes
- Single place to add logging/analytics
- Simplifies testing

---

### 5. Error Boundaries

**Decision**: Try/catch at every async boundary

```dart
Future<void> saveWorkflow() async {
  try {
    await platformBridge.saveWorkflow(...);
  } catch (e) {
    debugPrint('Failed to save: $e');
    rethrow; // Let UI handle user-facing error
  }
}
```

**Benefits**:
- Prevents app crashes
- Clear error context
- User-friendly error messages
- Enables error recovery

---

## 🎨 UI/UX Design Principles

### 1. Mobile-First Design

**Principle**: Design for touch, not mouse

**Implementation**:
- Larger touch targets (48x48 minimum)
- Gesture-based controls (pinch, pan, drag)
- Bottom sheet execution panel (thumb-reachable)
- Sidebar palettes (not floating windows)
- Vertical flow (natural scrolling)

---

### 2. Progressive Disclosure

**Principle**: Show complexity only when needed

**Implementation**:
- Collapsible panels (palette, inspector, execution)
- Expandable node properties
- Tabbed execution panel (logs/output/variables)
- Category filtering in palette
- Search to find specific nodes

---

### 3. Immediate Feedback

**Principle**: User actions have instant visual response

**Implementation**:
- Real-time log streaming
- Execution state indicators
- Node highlighting during execution
- Undo/redo button state
- Save confirmation snackbars

---

### 4. Forgiving Interactions

**Principle**: Easy to correct mistakes

**Implementation**:
- 50-level undo/redo
- Confirmation for destructive actions
- Auto-save workflows
- Draft mode for experiments
- Error recovery suggestions

---

### 5. Consistent Visual Language

**Principle**: Similar things look similar

**Implementation**:
- Color-coded node categories
- Consistent icon usage
- Standard Material Design components
- Unified spacing and padding
- Theme-aware colors

---

## 📦 Code Organization Best Practices

### File Structure Convention

```
lib/
  core/          # Framework-level code (layout, algorithms)
  models/        # Data structures (workflow, node, connection)
  nodes/         # Node-specific implementations
  services/      # Business logic (execution, storage, bridge)
  state/         # State management (providers)
  widgets/       # UI components (canvas, palette, inspector)
```

**Rule**: Each directory has a single responsibility

---

### Naming Conventions

**Classes**: PascalCase
```dart
class WorkflowExecutionEngine { }
class NodePalette { }
```

**Files**: snake_case
```dart
workflow_execution_engine.dart
node_palette.dart
```

**Private Members**: _leadingUnderscore
```dart
Workflow? _currentWorkflow;
void _saveToUndoStack() { }
```

**Constants**: SCREAMING_SNAKE_CASE
```dart
static const int MAX_UNDO_STACK_SIZE = 50;
```

---

### Documentation Standards

**Every Public Method**:
```dart
/// Execute a workflow from start to finish.
/// 
/// Returns the final [ExecutionContext] with logs and outputs.
/// Throws [StateError] if workflow is already running.
Future<ExecutionContext> executeWorkflow(Workflow workflow) async {
  // ...
}
```

**Every Class**:
```dart
/// Main workflow execution engine with async support and data flow.
/// 
/// Orchestrates node execution with state management and error handling.
class WorkflowExecutionEngine extends ChangeNotifier {
  // ...
}
```

---

### Testing Strategy (Recommended)

**Unit Tests**: Test each service/model in isolation
```dart
test('WorkflowState adds node correctly', () {
  final state = WorkflowState(platformBridge: mockBridge);
  state.addNode(type: 'manual_trigger', name: 'Test', data: {});
  expect(state.currentWorkflow!.nodes.length, 1);
});
```

**Widget Tests**: Test UI components
```dart
testWidgets('NodePalette displays all categories', (tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('Triggers'), findsOneWidget);
  expect(find.text('Actions'), findsOneWidget);
});
```

**Integration Tests**: Test full workflows
```dart
testWidgets('Complete workflow execution', (tester) async {
  // Add nodes, connect them, execute, verify output
});
```

---

## 🚀 Performance Optimization

### 1. Lazy Loading

**Principle**: Load data only when needed

**Implementation**:
```dart
// Don't load all workflows upfront
Future<void> _loadWorkflow(String id) async {
  // Load only when user opens
}

// Don't render off-screen nodes
CustomScrollView(
  slivers: [
    SliverList(delegate: SliverChildBuilderDelegate(...))
  ]
)
```

---

### 2. Debouncing

**Principle**: Limit rapid repeated operations

**Implementation**:
```dart
Timer? _debounceTimer;

void onSearchChanged(String query) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 300), () {
    _performSearch(query);
  });
}
```

---

### 3. Efficient State Updates

**Principle**: Only rebuild what changed

**Implementation**:
```dart
// Use Selector to rebuild only affected widgets
Selector<WorkflowState, WorkflowNode?>(
  selector: (_, state) => state.selectedNode,
  builder: (_, selectedNode, __) => NodeInspector(node: selectedNode),
)

// Use const constructors where possible
const Text('Static Label')
```

---

### 4. Memory Management

**Principle**: Clean up resources properly

**Implementation**:
```dart
@override
void dispose() {
  _scrollController.dispose();
  _textEditingController.dispose();
  _executionEngine?.dispose();
  super.dispose();
}
```

---

## 🔒 Security Considerations

### 1. Input Validation

**Always validate user input before execution**:
```dart
if (code.isEmpty) {
  return NodeExecutionResult.failure('No code provided');
}

if (!isValidUrl(url)) {
  return NodeExecutionResult.failure('Invalid URL');
}
```

---

### 2. Sandboxed Execution

**Code execution is isolated**:
- Unified Shell runs in separate process
- Limited file system access
- No direct system calls
- Timeout enforcement

---

### 3. Credential Storage

**Never store sensitive data in plain text**:
```kotlin
// Use Android Keystore for API keys
val keyStore = KeyStore.getInstance("AndroidKeyStore")

// Encrypt sensitive workflow data
val cipher = Cipher.getInstance("AES/GCM/NoPadding")
```

---

### 4. Permission Checks

**Always verify permissions before system actions**:
```kotlin
if (ContextCompat.checkSelfPermission(context, CALL_PHONE) 
    != PackageManager.PERMISSION_GRANTED) {
  return error("Permission denied")
}
```

---

## 🐛 Debugging Tips

### 1. Enable Debug Logging

```dart
// In development
if (kDebugMode) {
  debugPrint('Executing node: ${node.id}');
  debugPrint('Node data: ${node.data}');
}
```

---

### 2. Use Flutter DevTools

- **Widget Inspector**: Debug UI layout
- **Performance View**: Find frame drops
- **Memory View**: Track memory leaks
- **Network View**: Monitor platform channel calls

---

### 3. Platform Channel Debugging

```kotlin
// Add detailed logging
Log.d(TAG, "Executing shell: code=$code, language=$language")
Log.d(TAG, "Shell result: $result")
```

---

### 4. Execution Trace

```dart
// Add to execution engine
_log(nodeId, nodeName, ExecutionLogLevel.debug, 
     'Input data: ${jsonEncode(inputData)}');
```

---

## 📈 Future Extensibility

### Adding New Node Types

**Step-by-Step**:

1. **Define in node_definitions.dart**:
```dart
static const myCustomNode = NodeDefinition(
  id: 'my_custom_node',
  displayName: 'My Custom Node',
  // ...
);
```

2. **Create prototype** (if needed):
```dart
class MyCustomNodePrototype {
  static NodePrototype create() { /* ... */ }
}
```

3. **Add execution logic**:
```dart
// In workflow_execution_engine.dart
case 'my_custom_node':
  return await _executeMyCustomNode(node);
```

4. **Add platform method** (if needs native):
```kotlin
// In WorkflowEditorHandler.kt
"executeMyCustomNode" -> executeMyCustomNode(call, result)
```

---

### Adding New Features

**Example: Add workflow variables panel**

1. Create widget: `lib/widgets/variables_panel.dart`
2. Add to state: `WorkflowState.workflowVariables`
3. Update UI: Add to workflow_editor_screen.dart
4. Connect to execution: Pass to ExecutionContext
5. Test thoroughly

---

## 🎯 Conclusion

This architecture is designed for:
- ✅ **Maintainability**: Clear separation of concerns
- ✅ **Extensibility**: Easy to add new nodes and features
- ✅ **Performance**: Optimized for mobile constraints
- ✅ **Reliability**: Error handling at every layer
- ✅ **Testability**: Mockable dependencies
- ✅ **Scalability**: Can handle complex workflows

**Follow these patterns, and the codebase will remain clean and professional as it grows.**

---

**Questions?** Review the implementation files for detailed examples of each pattern in action.
