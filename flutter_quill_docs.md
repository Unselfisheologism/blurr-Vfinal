Directory structure:
└── doc/
    ├── attribute_introduction.md
    ├── code_introduction.md
    ├── custom_embed_blocks.md
    ├── custom_toolbar.md
    ├── customizing_shortcuts.md
    ├── delta_introduction.md
    ├── rules_introduction.md
    ├── translation.md
    ├── configurations/
    │   ├── custom_buttons.md
    │   ├── font_size.md
    │   ├── localizations_setup.md
    │   ├── search.md
    │   └── using_custom_app_widget.md
    ├── migration/
    │   └── 10_to_11.md
    └── readme/
        └── cn.md


Files Content:

================================================
FILE: doc/attribute_introduction.md
================================================
# What is an `Attribute`

An `attribute` is a property or characteristic that can be applied to text or a section of text within the editor to
change its appearance or behavior.
Attributes allow the user to style the text in various ways.

# How do attributes work?

An Attribute is applied to selected segments of text in the editor. Each attribute has an identifier and a value that
determines how it should be applied to the text. For example, to apply bold to a text, an attribute with the
identifier "bold" is used. When a text is selected and an attribute is applied, the editor updates the visual
representation of the text in real time.

# Scope of an `Attribute`

The attributes have a Scope that limit where start and end the `Attribute`.
The Scope is called as `AttributeScope`.
It has these options to be selected:

```dart
enum AttributeScope {
  inline, // just the selected text will apply the attribute (like: bold, italic or strike)
  block, // all the paragraph will apply the attribute (like: Header, Alignment or CodeBlock)
  embeds, // the attr will be taked as a different part of any paragraph or line, working as a block (By now not works as an inline)
  ignore, // the attribute can be applied, but on Retain operations will be ignored
}
```

# How looks a `Attribute`

The original `Attribute` class that you need to extend from if you want to create any custom attribute looks like:

```dart
class Attribute<T> {
  const Attribute(
    this.key,
    this.scope,
    this.value,
  );

  /// Unique key of this attribute.
  final String key;
  final AttributeScope scope;
  final T value;
}
```

The key of any `Attribute` must be **unique** to avoid any conflict with the default implementations.

#### Why `Attribute` class contains a **Generic** as a value

This is the same reason why we can create `Block` styles, `Inline` styles and `Custom` styles. Having a **Generic** type
value let us define any value as we want to recognize them later and apply it.

### Example of an default attribute

##### Inline Scope:

```dart
class BoldAttribute extends Attribute<bool> {
  const BoldAttribute() : super('bold', AttributeScope.inline, true);
}
```

##### Block Scope:

```dart
class HeaderAttribute extends Attribute<int?> {
  const HeaderAttribute({int? level})
      : super('header', AttributeScope.block, level);
}
```

If you want to see an example of an embed implementation you can see
it [here](https://github.com/singerdmx/flutter-quill/blob/master/doc/custom_embed_blocks.md)

### Example of a Custom Inline `Attribute`

##### The Attribute

```dart
import 'package:flutter_quill/flutter_quill.dart';

const String highlightKey = 'highlight';
const AttributeScope highlightScope = AttributeScope.inline;

class HighlightAttr extends Attribute<bool?> {
  HighlightAttr(bool? value) : super(highlightKey, highlightScope, value);
}
```

##### Where should we add this `HighlightAttr`?

On `QuillEditor` or `QuillEditorConfig` **doesn't exist** a param that let us pass our `Attribute`
implementations. To make this more easy, we can use just `customStyleBuilder` param from `QuillEditorConfig`,
that let us define a function to return a `TextStyle`. With this, we can define now our `HighlightAttr`

##### The editor

```dart
QuillEditor.basic(
      controller: controller,
      config: QuillEditorConfig(
        customStyleBuilder: (Attribute<dynamic> attribute) {
          if (attribute.key.equals(highlightKey)) {
            return TextStyle(color: Colors.black, backgroundColor: Colors.yellow);
          }
          //default paragraph style
          return TextStyle();
        },
      ),
);
```

Then, it should look as:

![HighlightAttr applied on the Quill Editor](https://github.com/user-attachments/assets/89c7bda5-f0de-4832-bcaa-8e0ccbe9be18)



================================================
FILE: doc/code_introduction.md
================================================
# Quill Overview
This document describes the most important files and classes in Quill.

## QUILL EDITOR, RENDER EDITOR, HANDLERS

**editor.dart**

`abstract EditorState extends State<RawEditor>`
- RawEditorState can be reference from QuillEditorState. This interface details several methods that are available from the mixins added to the RawEditor class.
- These methods are defined in the inherited classes from Flutter. So this Class helps us keep in mind several useful methods such as:
- showToolbar()
  - Triggers the mobile OS text selection toolbar.
- requestKeyboard()
  - Triggers the mobile OS keyboard
- getSelectionOverlay()

**abstract RenderAbstractEditor**
- Base interface for editable render objects
- Defines which methods the RenderEditor must implement
- Defined for the sake of documenting the most important operations
  Useful:
- selectWordAtPosition() selectLineAtPosition();
- getLocalRectForCaret() - Useful to enforce visibility of full caret at given position
- getPositionForOffset() getEndpointsForSelection()
- selectWordsInRange()
  - selectPositionAt()
- Selects text between coordinates
- selectWord()

**defaultEmbedBuilder()**

`BlockEmbed` &rarr; `Image, video or CustomEmbedBlock`
- It could be replaced with a custom implementation that supports all sorts of embeds (VS data types)
- Provided as argument in the QuillEditor instance

**QuillEditor**

- Gets the init params
  - Almost all the props that QuillEditor receives are passed to RawEditor
  - Basically QuillEditor is a wrapper that handles gestures and styling for the RawEditor
- Controller has the document, Controller will be passed to the RawEditor
- customStyleBuilder - Can override the styles of each attribute type.


`_QuillEditorState` &rarr; `EditorTextSelectionGestureDetectorBuilderDelegate`

`QuillEditorState` has a build method. This build method handles the assignment of styling depending on the current platform ios/android/web
QuillEditorState initialises a child named RawEditor

- `init()` it inits EditorTextSelectionGestureDetectorBuilder

  Keeps the delegate as a reference to _QuillEditorState
  From a global key we can get the current state (to read the state values, somewhat a counterpattern)
  EditorState? get editor => delegate.editableTextKey.currentState;

  Get the render editor from the state
  RenderEditor? get renderEditor => editor?.renderEditor;

- `build()`
  - `selectionColor` &rarr; Controls the color of the selection
- The local theme controls the selectionColor and the CursorColor
- In the end it returns the RawEditor wrapped in the gestureDetector
  - `getEditableTextKey()` - Reference to the editor widget key

`_QuillEditorSelectionGestureDetectorBuilder`
- `_onTapping()` - Searches for the Line. Attempts to update the selection. 
If not possible it fallbacks to a few platform dependent scenarios. Invoked by `onSingleTapUp()`
- `onSingleTapUp()` - override


TextSelectionChangedHandler



**RenderEditor**

Contains some extremely useful methods for handling the coordinates of words inside of the rendered document.
There methods are pivotal for synchronising the position of inline reactions to the quill editor

	class RenderEditor extends RenderEditableContainerBox
	with RelayoutWhenSystemFontsChangeMixin
	implements RenderAbstractEditor {


- onSelectionChanged()
- ViewportOffset? offset
- _updateSelectionExtentsVisibility()
  - React to selection changes
- startOffset, endOffset, _getOffsetForCaret()
  - Selection coordinates
- _getOffsetForCaret()
- size - Dimensions of the render box from Flutter.
- setDocument()
- setSelection()
  - getEndpointsForSelection() - Selection coordinates
- handleDragStart() handleDragEnd()
  - selectWordsInRange() &rarr; _handleSelectionChange()
- _paintHandleLayers - text selection handles on mobile
  - getPositionForOffset() - Gets us the text position (chars) from offset
- getOffsetToRevealCursor() - Used to reveal the cursor if scrolled
  - getWordBoundary() - Word boundary from click

**RenderEditableContainerBox** &rarr; RenderBox (dimensions) &rarr; RenderBoxContainerDefaultsMixin (HitTest) &rarr; RenderBoxContainerDefaultsMixin (add remove children)
- performLayout() - builds the layout dimensions for the widget &rarr; Called in many places
- childAtPosition() - Gets the child at TextPosition.


**controller.dart**

Embeds can be introduced as Embedabble via the controller, not only Quill. This method can be tracked to understand how to add topic from state store.

### QuillController
- updateSelection()
- addListener() - START UPDATE
- These methods are used to inform many parts of Quill that the controller state has changed
- This means we don't use ChangeNotifierProvider
- 15 listeners in total
- 12 for the buttons, stuff outside of Quill
- 1 for scroll arrows (if to show them)
- RawEditorState init and update listen _didChangeTextEditingValue &rarr; _onChangeTextEditingValue
- updateRemoteValueIfNeeded - When apps are sent into the background, the view ref is lost, when restoring the java code loses the state of the input.
- _showCaretOnScreen - Scrolls to show the carpet on screen
- start timer for blinking caret
- addPostFrameCallback - To be able to account for new lines of text when rendering the selection overlay
  - _updateOrDisposeSelectionOverlayIfNeeded - Updates the mobile context menu. We can show here the text selection menu as well (ideally with middleware override).
  EditorTextSelectionOverlay - An object that manages a pair of text selection handles.
- setState &rarr; Build &rarr; _Editor

### notifyListeners
- history change
- replace text
- format text
- update selection

- addListener, removeListener


**toolbar.dart**

Quill editors can have a Toolbar connected. The toolbar commands the controller which in turn commands the Document which commands the Renderer.
The toolbar can be customized to show all or part of the editing controls/buttons.
The Toolbar offers callbacks for reacting to adding images or videos.
For our own custom embeds we don't have to define extra callback here on the Toolbar context. We can host the logic in our own custom embeds (they are part of our own codebase).


**quill_icon_button.dart**

If we want to create more similar buttons for the Toolbar

**delegate.dart**

`EditorTextSelectionGestureDetectorBuilderDelegate` - Signatures for the methods that the EditableText (QuillEditor) must define to be able to run gesture detector
- `getEditableTextKey()`
  - EditableText is the delegate.
  - EditableText comes from Flutter
  - The key is the editor widget key.
  - The key is used to get the state.
  - In the state we have RenderEditor.


###  RAW EDITOR

**raw_editor.dart**
- Displays a document as a vertical list of document segments (lines and blocks)
  **RawEditorState** extends **EditorState**
    - Defines overrides and listener for all the exposed internal that were added by the mixing
    - Clipboard management, Keyboard management, Document changes management, Gestures Management
    - RawEditorState can be referenced from QuillEditorState.
    - EditorState interface details several methods that are available from the mixins added to the RawEditor class.

with `AutomaticKeepAliveClientMixin<RawEditor>`
- Indicates that the subtree through which this notification bubbles must be kept alive even if it would normally be discarded as an optimization.
- For example, a focused text field might fire this notification to indicate that it should not be disposed even if the user scrolls the field off screen.

WidgetsBindingObserver
- Notifies when new routes are pushed or poped such that the app can react accordingly (for ex if the app exits)

TickerProviderStateMixin<RawEditor>
- Synchronizes the animations of the widget with all other animations so that they can all complete before the new frame is to be rendered

RawEditorStateTextInputClientMixin
- Connector that links the editor to the Mobile keyboard

`RawEditorStateSelectionDelegateMixin`
- A mixin that controls text insertion operations. It is a delegate for Flutter's TextSelection.
- it can override the setter for `textEditingValue()`
  - It intercepts copy paste ops from the system, it commands the QuillEditor controller to run the necessary changes. 
  - In other words, that's how Quill knows how to react to text editing ops coming from the system (user input). 
 
`_getOffsetToRevealCaret()`
 - Finds the closest scroll offset to the current scroll offset that fully reveals the given caret rect. 
 - If the given rect's main axis extent is too large to be fully revealed in `renderEditable`, it will be centered along the main axis.



- build()
    - If no delta document is available an empty one will be created
    - If expanded true it builds an _Editor wrapped with Semantics and CompositedTransformTarget
        - Semantics is used for screen readers
        - CompositedTransformTarget - Hooks the custom widget into the mechanics of layout rendering and calculation of dimensions (Flutter).
        - Why CompositedTransformTarget? - Because Quill uses a custom renderer to render the document (for performance reasons)

    - If not expanded (meaning scrollable) it wraps the _editor with BaselineProxy, SingleChildScrollView and CompositedTransformTarget. 
      [CompositedTransformTarget] is needed to allow selection handle overlays to track the selected text.
      Since [SingleChildScrollView] does not implement `computeDistanceToActualBaseline` it prevents the editor from providing its baseline metrics.
      To address this issue we wrap the scroll view with [BaselineProxy] which mimics the editor's baseline.
      This implies that the first line has no styles applied to it.
      Why is computeDistanceToActualBaseline needed?
      If my intuition is right this is needed to scroll the page the right amount to offset the scroll to match the off screen selected text line when the carpet is moved.
      It computes the distance from top to the baseline of the first text. First text out of first editable text. I'll explain bellow, there are more lines of text in a Quill doc.

    - Nested in the _Editor we have the _buildChildren(_doc, context)
      This method loops trough the delta breaks it into text lines and text blocks and renders the corresponding children
      From here on the works of rendering the text starts

    - Finally the whole thing is wrapped in QuillStyles, Actions, Focus, QuillKeyboardListener and returned for the build()
        - Actions are callbacks registered to respond on Intents (Flutter alternative to callbacks)
          - _updateOrDisposeSelectionOverlayIfNeeded()
- Triggers the selection context menu on mobiles
- _selectionOverlay = EditorTextSelectionOverlay()
- _handleSelectionChanged()
  &rarr; widget.controller.updateSelection() Updates the state of the selection in memory (no visual change)
  &rarr; _selectionOverlay?.handlesVisible
- _buildChildren()
- compiles the list of nodes to be render as TextLine or TextBlock from the controller.document
- This is where we pass the embedBuilder to the block

**_Editor** extends **MultiChildRenderObjectWidget**
After all these layers: Gesture detectors, mixins, scrolls, actions, etc we finally arrive at the layer that handles the edit operations.
_Render creates and updates the RenderEditor which is basically the custom RenderBox that handles the coordination between multiple line models.
For example the RenderEditor knows how to coordinate multiple lines to draw a selection of text between them. It commands their widgets to render the correct selections.
This is where we need to add our own code for rendering multiple highlights. It queries and coordinates both the models and the render boxes.
MultiChildRenderObjectWidget takes the duty of rendering the line and block widgets that were created by the _buildChildren()



### Intents to Actions map

Flutter has a system of dispatching Intents when hotkeys are pressed and then Actions that react to these intents.
Actions can decide if they are enabled or not. This system is an alternative to callbacks.
https://docs.flutter.dev/development/ui/advanced/actions_and_shortcuts

Earlier it is mentioned that the `_Editor` is wrapped in Actions. Well this is the map it uses.
All these actions receive TextSelection and react to it by commanding the Controller.
```
DoNothingAndStopPropagationTextIntent
ReplaceTextIntent
UpdateSelectionIntent
DirectionalFocusIntent

// Delete
DeleteCharacterIntent
DeleteToNextWordBoundaryIntent
DeleteToLineBreakIntent

// Extend/Move Selection
ExtendSelectionByCharacterIntent
ExtendSelectionToNextWordBoundaryIntent
ExtendSelectionToLineBreakIntent
ExtendSelectionVerticallyToAdjacentLineIntent
ExtendSelectionToDocumentBoundaryIntent
ExtendSelectionToNextWordBoundaryOrCaretLocationIntent

// Copy Paste
SelectAllTextIntent
CopySelectionTextIntent
PasteTextIntent
```

**quill_single_child_scroll_view.dart**

`QuillSingleChildScrollView`

Very similar to `SingleChildView` but with a `ViewportBuilder` argument instead of a `Widget` &rarr; Meaning it can scroll over the CompositedTransformTarget instead of Widgets
A `ScrollController` serves several purposes.
It can be used to control the initial scroll position (see `ScrollController.initialScrollOffset`).
It can be used to control whether the scroll view should automatically save and restore its scroll position in the `PageStorage` (see `ScrollController.keepScrollOffset`).
It can be used to read the current scroll position (see `ScrollController.offset`), or change it (see `ScrollController.animateTo`)

showOnScreen() &rarr; The most important method here. It is invoked in several scenarios to expose the selected text on screen of off-page.
Now since our ArticlePage uses several stacked expanded editors (due to post topics) we don't use at all the scrolling behaviour.
If we wanted to use the scroll behaviour from Quill that means we would have to make the entire post topic together with the article topic.
It means one could copy paste the post topics to the bottom of the article which makes absolutely no sense. So therefore we have to handle this part ourselves.
And since the Article and topics are scrolled together by a greater scroll controller we are force to render the article editor as well in the expanded mode.
That make our situation a bit harder because we might have to redo some of the work needed to bring the selected text back into view when moving the carpet.
This is a luxury item for the moment, we don't care of this feature missing in the MVP. So no panic if we don't use the QuillEditorScroll.


`_Editor`
- A container with lifecycle calls create and update for RenderBoxes (RenderEditor)
- createRenderObject() updateRenderObject() &rarr; RenderEditor


**text_line.dart**

Callstack: `RawEditorState()` &rarr; `_buildChildren()` &rarr; `_getEditableTextLineFromNode()`
&rarr; `EditableTextLine()` &rarr; `_TextLineElement()` &rarr; `RenderEditableTextLine()` &rarr; `TextLine()` &rarr; `RichTextProxy()` &rarr; `RenderParagraphProxy` extends `RenderProxyBox` (we will talk proxy boxes separately)

When the rawEditor builds the children it uses 2 types of widgets: lines and blocks.
Bellow we will discuss how lines are renders. Blocks reuse lines.
Blocks are rendered for special graphical elements such as bullet lists.

`TextLine`

This is the actual line of text being rendered on screen. It uses editable text from flutter to render a basic text input.
Renders the proper text styling based on the delta text styling attributes. Contains lost of methods to accomplish this job.
This widget is rendered inside of an EditableTextLine as a child by the _getEditableTextLineFromNode() from RawEditor.
The widget itself renders a proxBox.
The EditableTextLine uses RenderEditableTextLine to render the highlight and caret on top of the raw text field.

`EditableTextLine`
- Creates and updates render objects base on the instructions received from the delta document.
- Passes the props to RenderEditableTextLine
  createRenderObject() &rarr; RenderEditableTextLine

`RenderEditableTextLine`

Creates new editable paragraph render box.
It contains many methods needed to coordinate imperatively how the text selection and caret sync with the document controller state.
This is where the hardwork of rendering and simulating the text interactions mechanics is happening.

Here's a list of methods to get a feeling of what happens in `RenderEditableTextLine`:

Most of these methods are wrappers over the TextLine (body) &rarr; They get their coordinates by querying the underlying text input.

setCursorCont()
setDevicePixelRatio()
setEnableInteractiveSelection()
setColor()
setTextSelection()
setLine() - The actual delta text content
setPadding()
containsTextSelection()
containsCursor()
getLineBoundary()
getOffsetForCaret()
getPositionForOffset()
getWordBoundary()
attach(), detach() &rarr; _onFloatingCursorChange
compute Min/Max Intrinsic Height/Width()
computeDistanceToActualBaseline()
performLayout() &rarr; Flutter layouting

#### Drawing text selection

For rendering custom highlights we are most interested in these methods:
- paint()
    - Draws the one of text and it's decorations. Custom decorations can be added.
    - It uses the offset of the parent (based on layout constraints) and the ofset of the text selection
- _paintSelection()
  - Handles the rendering of the selection
- Selection is rendered as new boxes in the paint area (RenderBox)- They can even have an offset
- Paints the _selectedRects
- draw cursor (above and bellow)
- By default, the cursor should be painted on top for iOS platforms and underneath for Android platforms.
- _selectedRects - The individual render boxes that compose a multiline selection
- getBoxesForSelection() &rarr; local TextSelection - Converts TextSelection to boxes coordinates
- list of TextBox.fromLTRBD (Flutter class)
- localSelection() does some sort of a conversion
  - setTextSelection() - Updates the text selection and clears the rect boxes
- if _attachedToCursorController it is marked for markNeedsLayout markNeedsPaint
- The cursor controller is defined for text fields, it is a change notifier and can be listened to
- When the text cursor changes position also the text selection will need to be repainted

`_TextLineElement` extends `enderObjectElement`
contains methods needed to sync the renderObject in the widget tree


**proxy.dart**

All sorts of rendering proxies for the items that can be rendered in Quill.
A proxy box isn't useful on its own because you might as well just replace the proxy box with its child.
However, RenderProxyBox is a useful base class for render objects that wish to mimic most, but not all, of the properties of their child.

For render objects with children, there are four possible scenarios:
* A single [RenderBox] child. In this scenario, consider inheriting from
  [RenderProxyBox] (if the render object sizes itself to match the child) or
  [RenderShiftedBox] (if the child will be smaller than the box and the box
  will align the child inside itself).
* A single child, but it isn't a [RenderBox]. Use the
  [RenderObjectWithChildMixin] mixin.
* A single list of children. Use the [ContainerRenderObjectMixin] mixin.
* A more complicated child model.
  https://programmer.group/the-operation-instruction-of-flutter-s-renderbox-principle-analysis.html

`RenderBaselineProxy` - Renders the scrollable input
`RenderEmbedProxy` - Renders embeds
`RichTextProxy` - rich text
`RenderParagraphProxy` - RenderProxyBox - Mimics it's children
`getBoxesForSelection()` - This code is used from Flutter


**models/quill_delta.dart**
- Container various utils for handling delta text
  - insert
- skip
- retain
  - slice - This might be super useful for splitting docs
- concat
  - diff
- delta.insert('\n' - used to add new character &rarr; Could be used to split our deltas
- DeltaIterator(document)..skip(index) - Skips [length] characters in source delta.
- Delta()..retain - Retain [count] of characters from current position.
- _trimNewLine() - Removes trailing '\n'

**text_selection.dart**

`EditorTextSelectionOverlay`
- Represents the selection overlay object (the highlight)
- It also renders the mobile actions menu and handles. This is from the system.


**document.dart**

The Document contains the Delta which contains all the operations. Inside operations we can find attributes. The attributes are useful for examining the text.

- These methods are extremely useful
  - insert &rarr; Can insert embeddable, Can replace selected text
  - delete
- replace
- format
- undo, hasUndo
- redo, hasRedo
- toPlainText
- isEmpty
- toDelta
- setCustomRules -&rarr; Could be extremely useful because we can edit the text editor each time something outstanding happens

**/rules**
- Contain business logic for handling operations and delta modifications
  - PreserveLineStyleOnSplitRule - Preserves the style to the split line

**node.dart**

An abstract node in a document tree.
Represents a segment of a Quill document with specified offset and length. The offset property is relative to parent.
See also documentOffset which provides absolute offset of this node within the document.


================================================
FILE: doc/custom_embed_blocks.md
================================================
# 📦 Custom Embed Blocks

Sometimes you want to add some custom content inside your text, custom widgets inside them.
An example is adding
notes to the text, or anything custom that you want to add in your text editor.

The only thing that you need is to add a `CustomBlockEmbed` and provide a builder for it to the `embedBuilders`
parameter, to transform the data inside the Custom Block into a widget!

Here is an example:

Starting with the `CustomBlockEmbed`, here we extend it and add the methods that are useful for the 'Note' widget, which
will be the `Document`, used by the `flutter_quill` to render the rich text.

```dart
class NotesBlockEmbed extends CustomBlockEmbed {
  const NotesBlockEmbed(String value) : super(noteType, value);

  static const String noteType = 'notes';

  static NotesBlockEmbed fromDocument(Document document) =>
      NotesBlockEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}
```

After that, we need to map this "notes" type into a widget. In that case, I used a `ListTile` with a text to show the
plain text resume of the note, and the `onTap` function to edit the note.
Don't forget to add this method to the `QuillEditor` after that!

```dart
class NotesEmbedBuilder extends EmbedBuilder {
  NotesEmbedBuilder({required this.addEditNote});

  Future<void> Function(BuildContext context, {Document? document}) addEditNote;

  @override
  String get key => 'notes';

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    final notes = NotesBlockEmbed(embedContext.node.value.data).document;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        title: Text(
          notes.toPlainText().replaceAll('\n', ' '),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        leading: const Icon(Icons.notes),
        onTap: () => addEditNote(context, document: notes),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
```

And finally, we write the function to add/edit this note.
The `showDialog` function shows the QuillEditor to edit the
note after the user ends the edition, we check if the document has something, and if it has, we add or edit
the `NotesBlockEmbed` inside of a `BlockEmbed.custom` (this is a little detail that will not work if you don't pass
the `CustomBlockEmbed` inside of a `BlockEmbed.custom`).

```dart
Future<void> _addEditNote(BuildContext context, {Document? document}) async {
  final isEditing = document != null;
  final controller = QuillController(
    document: document ?? Document(),
    selection: const TextSelection.collapsed(offset: 0),
  );

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      titlePadding: const EdgeInsets.only(left: 16, top: 8),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${isEditing ? 'Edit' : 'Add'} note'),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          )
        ],
      ),
      content: QuillEditor.basic(
        controller: controller,
        config: const QuillEditorConfig(),
      ),
    ),
  );

  if (controller.document.isEmpty()) return;

  final block = BlockEmbed.custom(
    NotesBlockEmbed.fromDocument(controller.document),
  );
  final controller = _controller!;
  final index = controller.selection.baseOffset;
  final length = controller.selection.extentOffset - index;

  if (isEditing) {
    final offset = getEmbedNode(controller, controller.selection.start).offset;
    controller.replaceText(
        offset, 1, block, TextSelection.collapsed(offset: offset));
  } else {
    controller.replaceText(index, length, block, null);
  }
}
```

And voilà, we have a custom widget inside the rich text editor!

<p float="left">
  <img width="400" alt="1" src="https://i.imgur.com/yBTPYeS.png">
</p>

> 1. For more info and a video example, see
     the [PR of this feature](https://github.com/singerdmx/flutter-quill/pull/877)
> 2. For more details, check out [this YouTube video](https://youtu.be/pI5p5j7cfHc)



================================================
FILE: doc/custom_toolbar.md
================================================
# 🎨 Custom Toolbar

You can use the `QuillController` in your custom toolbar or use the button widgets of the `QuillSimpleToolbar`:

```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Wrap(
    children: [
      IconButton(
        onPressed: () => context.read<SettingsCubit>().updateSettings(
            state.copyWith(useCustomQuillToolbar: false)),
        icon: const Icon(
          Icons.width_normal,
        ),
      ),
      QuillToolbarHistoryButton(
        isUndo: true,
        controller: controller,
      ),
      QuillToolbarHistoryButton(
        isUndo: false,
        controller: controller,
      ),
      QuillToolbarToggleStyleButton(
        options: const QuillToolbarToggleStyleButtonOptions(),
        controller: controller,
        attribute: Attribute.bold,
      ),
      QuillToolbarToggleStyleButton(
        options: const QuillToolbarToggleStyleButtonOptions(),
        controller: controller,
        attribute: Attribute.italic,
      ),
      QuillToolbarToggleStyleButton(
        controller: controller,
        attribute: Attribute.underline,
      ),
      QuillToolbarClearFormatButton(
        controller: controller,
      ),
      const VerticalDivider(),
      QuillToolbarImageButton(
        controller: controller,
      ),
      QuillToolbarCameraButton(
        controller: controller,
      ),
      QuillToolbarVideoButton(
        controller: controller,
      ),
      const VerticalDivider(),
      QuillToolbarColorButton(
        controller: controller,
        isBackground: false,
      ),
      QuillToolbarColorButton(
        controller: controller,
        isBackground: true,
      ),
      const VerticalDivider(),
      QuillToolbarSelectHeaderStyleDropdownButton(
        controller: controller,
      ),
      const VerticalDivider(),
      QuillToolbarSelectLineHeightStyleDropdownButton(
        controller: controller,
      ),
      const VerticalDivider(),
      QuillToolbarToggleCheckListButton(
        controller: controller,
      ),
      QuillToolbarToggleStyleButton(
        controller: controller,
        attribute: Attribute.ol,
      ),
      QuillToolbarToggleStyleButton(
        controller: controller,
        attribute: Attribute.ul,
      ),
      QuillToolbarToggleStyleButton(
        controller: controller,
        attribute: Attribute.inlineCode,
      ),
      QuillToolbarToggleStyleButton(
        controller: controller,
        attribute: Attribute.blockQuote,
      ),
      QuillToolbarIndentButton(
        controller: controller,
        isIncrease: true,
      ),
      QuillToolbarIndentButton(
        controller: controller,
        isIncrease: false,
      ),
      const VerticalDivider(),
      QuillToolbarLinkStyleButton(controller: controller),
    ],
  ),
)
```




================================================
FILE: doc/customizing_shortcuts.md
================================================
# Shortcut events

> [!NOTE]
> This feature is supported **only on desktop devices**.

We will use a simple example to illustrate how to quickly add a `CharacterShortcutEvent` event.

In this example, text that starts and ends with an asterisk ( * ) character will be rendered in italics for emphasis. So typing `*xxx*` will automatically be converted into _`xxx`_.

Let's start with a empty document:

```dart
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter/material.dart';

class AsteriskToItalicStyle extends StatelessWidget {
  const AsteriskToItalicStyle({super.key});

  @override
  Widget build(BuildContext context) {
    return QuillEditor.basic(
      controller: <your_controller>,
      config: QuillEditorConfig(
        characterShortcutEvents: [],
      ),
    );
  }
}
```

At this point, nothing magic will happen after typing `*xxx*`.

<p align="center">
   <img src="https://github.com/user-attachments/assets/c9ab15ec-2ada-4a84-96e8-55e6145e7925" width="800px" alt="Editor without shortcuts gif">
</p>

To implement our shortcut event we will create a `CharacterShortcutEvent` instance to handle an asterisk input.

We need to define key and character in a `CharacterShortcutEvent` object to customize hotkeys. We recommend using the description of your event as a key. For example, if the asterisk `*` is defined to make text italic, the key can be 'Asterisk to italic'.

```dart
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter/material.dart';

// [handleFormatByWrappingWithSingleCharacter] is a example function that contains 
// the necessary logic to replace asterisk characters and apply correctly the 
// style to the text around them 

enum SingleCharacterFormatStyle {
  code,
  italic,
  strikethrough,
}

CharacterShortcutEvent asteriskToItalicStyleEvent = CharacterShortcutEvent(
  key: 'Asterisk to italic',
  character: '*',
  handler: (QuillController controller) => handleFormatByWrappingWithSingleCharacter(
    controller: controller,
    character: '*',
    formatStyle: SingleCharacterFormatStyle.italic,
  ),
);
```

Now our 'asterisk handler' function is done and the only task left is to inject it into the `QuillEditorConfig`.

```dart
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter/material.dart';

class AsteriskToItalicStyle extends StatelessWidget {
  const AsteriskToItalicStyle({super.key});

  @override
  Widget build(BuildContext context) {
    return QuillEditor.basic(
      controller: <your_controller>,
      config: QuillEditorConfig(
        characterShortcutEvents: [
           asteriskToItalicStyleEvent,
        ],
      ),
    );
  }
}

CharacterShortcutEvent asteriskToItalicStyleEvent = CharacterShortcutEvent(
  key: 'Asterisk to italic',
  character: '*',
  handler: (QuillController controller) => handleFormatByWrappingWithSingleCharacter(
    controller: controller,
    character: '*',
    formatStyle: SingleCharacterFormatStyle.italic,
  ),
);
```
<p align="center">
   <img src="https://github.com/user-attachments/assets/35e74cbf-1bd8-462d-bb90-50d712012c90" width="800px" alt="Editor with shortcuts gif">
</p>



================================================
FILE: doc/delta_introduction.md
================================================
# What is Delta?

`Delta` is a structured format used to represent text editing operations consistently and efficiently.
It is especially useful in collaborative editors where multiple users may be editing the same document simultaneously.

## How does Delta work?

`Delta` consists of a list of operations.
Each operation describes a change in the document's content.
The operations can be of three types: insertion (`insert`), deletion (`delete`), and retention (`retain`).
These operations are combined to describe any change in the document's state.

You can import `Delta` and `Operation` class using:

```dart
import 'package:flutter_quill/quill_delta.dart';
```

# What is a `Operation`?

Operations are the actions performed on the document to modify its content.
Each operation can be an insertion,
deletion, or retention, and is executed sequentially to transform the document's state.

## How Do `Operations` Work?

`Operations` are applied in the order they are defined in the `Delta`.
Starting with the initial state of the
`Document`, the operations are applied one by one, updating the document's state at each step.

Example of a `Operation` Code:

```dart
[
    // Adds the text "Hello" to the editor's content
    { "insert": "Hello" },
    // Retains the first 5 characters of the existing content,
    // and applies the "bold" attribute to those characters.
    { "retain": 5, "attributes": { "bold": true } },
    // Deletes 2 characters starting from the current position in the editor's content.
    { "delete": 2 }
]
```

# Types of Operations in Delta

## 1. Insertion (`Insert`)

An insertion adds new content to the document. The `Insert` operation contains the text or data being added.

Example of `Insert` operation:

```dart
import 'package:flutter_quill/quill_delta.dart';

void main() {
  // Create a Delta with a text insertion
  final delta = Delta()
    ..insert('Hello, world!\n')
    ..insert('This is an example.\n', {'bold': true})
    ..delete(10); // Remove the first 10 characters

  print(delta); // Output: [{insert: "Hello, world!\n"}, {insert: "This is an example.\n", attributes: {bold: true}}, {delete: 10}]
}
```

## 2. Deletion (`Delete`)

In Quill, operations are a way to represent changes to the editor's content. Each operation has a type and a set of
properties that indicate what has changed and how.`Delete` operations are a specific type of operation that is used to
remove content from the editor.

## Delete Operations

A Delete operation is used to remove a portion of the editor's content. The Delete operation has the following format:

```dart
Delta()
 ..retain(<number>)
 ..delete(<number>);
```

Where:

- **retain**: (Optional) The number of characters to retain before deletion is performed.
- **delete**: The number of characters to delete.

Basic example

Let's say you have the following content in the editor:

```Arduino
"Hello, world!"
```

And you want to remove the word "world". The corresponding to Delete operation could be:

```dart
Delta()
 ..retain(6)
 ..delete(7);
```

Here the first **7** characters are being retained ("Hello, ") and then 6 characters are being removed ("world!").

### Behavior of Delete Operations

**Text Deletion**: The `Delete` operation removes text in the editor document. The characters removed are those that are
in the range specified by the operation.

**Combination with retain**: The `Delete` operation is often combined with the retain operation to specify which part of
the content should remain intact and which part should be removed. For example, if you want to delete a specific section
of a text, you can use retaining to keep the text before and after the section to be deleted.

**Range Calculation**: When a `Delete` operation is applied, the range of text to be deleted is calculated based on the
value of retaining and delete. It is important to understand how retain and delete are combined to perform correct
deletion.

Example of `Delete` operation using `QuillController`

```dart
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

QuillController _quillController = QuillController(
    document: Document.fromJson([{'insert': 'Hello, world!'}]),
    selection: TextSelection.collapsed(offset: 0),
);

// Create a delta with the retain and delete operations
final delta = Delta()
  ..retain(6) // Retain "Hello, "
  ..delete(7); // Delete "world!"

// Apply the delta to update the content of the editor
_quillController.compose(delta, ChangeSource.local);
```

In this example, the current content of the editor is updated to reflect the removal of the word "world."

## 3. Retention (`Retain`)

`Retain` operations are particularly important because they allow you to apply attributes to specific parts of the
content without modifying the content itself. A Retain operation consists of two parts:

- **Index**: The length of the content to retain unchanged.
- **Attributes**: An optional object containing the attributes to apply.

Example of a `Retain` Operation

Suppose we have the following content in an editor:

```arduino
"Hello world"
```

And we want to apply bold formatting to the word "world."
The `Retain` operation would be represented in a `Delta` as
follows:

```dart
[
    { "insert": "Hello, " },
    { "retain": 7 },
    { "retain": 5, "attributes": { "bold": true } }
]
```

This Delta is interpreted as follows:

- `{ "retain": 7 }`: Retains the first **7** characters ("Hello, ").
- `{ "retain": 5, "attributes": { "bold": true } }`: Retains the next **5** characters ("world") and applies the bold
  attribute.

### Applications of Retain

Retain operations are useful for various tasks in document editing, such as:

- **Text Formatting**: Applying styles (bold, italic, underline, etc.) to specific segments without altering the
  content.
- **Annotations**: Adding metadata or annotations to specific sections of text.
- **Content Preservation**: Ensuring that certain parts of the document remain unchanged during complex editing
  operations.

Using Directly `Delta` class:

```dart
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

void main() {
  // Create a Delta that retains 10 characters
 QuillController _quillController = QuillController(
    document: Document.fromJson([{'insert': 'Hello, world!'}]),
    selection: TextSelection.collapsed(offset: 0),
 );

 // Create a delta with the retain and delete operations
 final delta = Delta()
    ..retain(6) // Retain "Hello, "

 // Apply the delta to update the content of the editor
 _quillController.compose(delta, ChangeSource.local);
}
```

# Transformations

Transformations are used to combine two Deltas and produce a third Delta that represents the combination of both
operations.

Example 1: Transformation with Deletions

Deltas to combine:

- **Delta A**: `[{insert: "Flutter"}, {retain: 3}, {insert: "Quill"}]`
- **Delta B**: `[{retain: 6}, {delete: 4}, {insert: "Editor"}]`

```dart

import 'package:flutter_quill/quill_delta.dart' as quill;

void main() {
 // Defining Delta A
 final deltaA = quill.Delta()
 ..insert('Flutter')
 ..retain(3)
 ..insert('Quill');

 // Defining Delta B
 final deltaB = quill.Delta()
 ..retain(7) // retain: Flutter
 ..delete(5) // delete: Quill
 ..insert('Editor');

 // applying transformation
 final result = deltaA.transform(deltaB);

 print(result.toJson()); // output: [{insert: "FlutterEditor"}]
}
```

Example 2: Complex Transformation

Deltas to combine:

- **Delta A**: `[{insert: "Hello World"}]`
- **Delta B**: `[{retain: 6}, {delete: 5}, {insert: "Flutter"}]`

```dart
import 'package:flutter_quill/quill_delta.dart' as quill;

void main() {

 // Defining Delta A
 final deltaA = quill.Delta()
 ..insert('Hello World');

 // Defining Delta B
 final deltaB = quill.Delta()
 ..retain(6) // retain: 'Hello '
 ..delete(5) // delete: 'World'
 ..insert('Flutter');

 // Applying transformations
 final result = deltaA.transform(deltaB);

 print(result.toJson()); // output: [{insert: "Hello Flutter"}]
}
```

# Why Use Delta Instead of Another Format?

Delta offers a structured and efficient way to represent changes in text documents, especially in collaborative
environments.
Its operation-based design allows for easy synchronization, transformation, and conflict handling, which
is essential for real-time text editing applications.
Other formats may not provide the same level of granularity and
control over edits and transformations.



================================================
FILE: doc/rules_introduction.md
================================================
## Rule

`Rule` in `flutter_quill` is a handler for specific operations within the editor. They define how to apply, modify, or delete content based on user actions. Each Rule corresponds to a type of operation that the editor can perform.

### RuleType

There are three main `RuleTypes` supported in `flutter_quill`, each serving a distinct purpose:

- **insert**: Handles operations related to inserting new content into the editor. This includes inserting text, images, or any other supported media.

- **delete**: Manages operations that involve deleting content from the editor. This can include deleting characters, lines, or entire blocks of content.

- **format**: Deals with operations that apply formatting changes to the content in the editor. This could involve applying styles such as bold, italic, underline, or changing text alignment, among others.

### How Rules Work

When a user interacts with the editor in `flutter_quill`, their actions are translated into one of the predefined `RuleType`. For instance:

- When the user types a new character, an **insert** Rule is triggered to handle the insertion of that character into the editor's content.
- When the user selects and deletes a block of text, a **delete** Rule is used to remove that selection from the editor.
- Applying formatting, such as making text bold or italic, triggers a **format** Rule to update the style of the selected text.

`Rule` is designed to be modular and configurable, allowing developers to extend or customize editor behavior as needed. By defining how each RuleType operates, `flutter_quill` ensures consistent and predictable behavior across different editing operations.


### Example of a custom `Rule`

In this case, we will use a simple example. We will create a `Rule` that is responsible for detecting any word that is surrounded by "*" just as any `Markdown` editor would do for italics.

In order for it to be detected while the user writes character by character, what we will do is extend the `InsertRule` class that is responsible for being called while the user writes a word character by character.

```dart
/// Applies italic format to text segment (which is surrounded by *)
/// when user inserts space character after it.
class AutoFormatItalicRule extends InsertRule {
  const AutoFormatItalicRule();

  static const _italicPattern = r'\*(.+)\*';

  RegExp get italicRegExp => RegExp(
        _italicPattern,
        caseSensitive: false,
      );

  @override
  Delta? applyRule(
    Document document,
    int index, {
    int? len,
    Object? data,
    Attribute? attribute,
    Object? extraData,
  }) {
    // Only format when inserting text.
    if (data is! String) return null;

    // Get current text.
    final entireText = document.toPlainText();

    // Get word before insertion.
    final leftWordPart = entireText
        // Keep all text before insertion.
        .substring(0, index)
        // Keep last paragraph.
        .split('\n')
        .last
        // Keep last word.
        .split(' ')
        .last
        .trimLeft();

    // Get word after insertion.
    final rightWordPart = entireText
        // Keep all text after insertion.
        .substring(index)
        // Keep first paragraph.
        .split('\n')
        .first
        // Keep first word.
        .split(' ')
        .first
        .trimRight();

    // Build the segment of affected words.
    final affectedWords = '$leftWordPart$data$rightWordPart';

    // Check for italic patterns.
    final italicMatches = italicRegExp.allMatches(affectedWords);

    // If there are no matches, do not apply any format.
    if (italicMatches.isEmpty) return null;

    // Build base delta.
    // The base delta is a simple insertion delta.
    final baseDelta = Delta()
      ..retain(index)
      ..insert(data);

    // Get unchanged text length.
    final unmodifiedLength = index - leftWordPart.length;

    // Create formatter delta.
    // The formatter delta will include italic formatting when needed.
    final formatterDelta = Delta()..retain(unmodifiedLength);

    var previousEndRelativeIndex = 0;

    void retainWithAttributes(int start, int end, Map<String, dynamic> attributes) {
      final separationLength = start - previousEndRelativeIndex;
      final segment = affectedWords.substring(start, end);
      formatterDelta
        ..retain(separationLength)
        ..retain(segment.length, attributes);
      previousEndRelativeIndex = end;
    }

    for (final match in italicMatches) {
      final matchStart = match.start;
      final matchEnd = match.end;

      retainWithAttributes(matchStart + 1, matchEnd - 1, const ItalicAttribute().toJson());
    }

    // Get remaining text length.
    final remainingLength = affectedWords.length - previousEndRelativeIndex;

    // Remove italic from remaining non-italic text.
    formatterDelta.retain(remainingLength);

    // Build resulting change delta.
    return baseDelta.compose(formatterDelta);
  }
}
```

To apply any custom `Rule` you can use `setCustomRules` that is exposed on `Document`

```dart
quillController.document.setCustomRules([const AutoFormatItalicRule()]);
```

You can see a example video [here](https://e.pcloud.link/publink/show?code=XZ2NzgZrb888sWjuxFjzWoBpe7HlLymKp3V)



================================================
FILE: doc/translation.md
================================================
# 🌍 Translation

The package offers translations for the quill toolbar and editor, it will follow the locale that is defined in
your `WidgetsApp` for example `MaterialApp` which usually follows the system locally unless you set your own locale.

## 🌐 Supported Locales

Currently, translations are available for these 49 locales:

* `ar`, `bg`, `bn`, `ca`, `cs`, `da`, `de`
* `en`, `en_US`, `es`, `fa`, `fr`, `he`
* `hi`, `id`, `it`, `ja`, `ko`, `km`, `ku`
* `mn`, `ms`, `ne`, `nl`, `no`, `pl`, `pt`
* `pt_BR`, `ro`, `ro_RO`, `ru`, `sk`, `sr`
* `sv`, `sw`, `th`, `tk`, `tr`, `uk`, `ur`
* `vi`, `zh`, `zh_CN`, `zh_HK`, `hr`
* `bs`, `mk`, `gu`, `fi`

## 📌 Contributing to translations

The translation files are located in the [l10n](../lib/src/l10n/) folder. Feel free to contribute your own translations.

You can take a look at the [untranslated.json](../lib/src/l10n/untranslated.json) file, which is a generated file that
tells you which keys with which locales haven't been translated so you can find the missing easily.

<details>
<summary>Add new local</summary>

1. Create a new file in [l10n](../lib/src/l10n/) folder, with the following name`quill_${localName}.arb` for
   example `quill_de.arb`. See [locale codes](https://saimana.com/list-of-country-locale-code/).

2. Copy the [Arb Template](../lib/src/l10n/quill_en.arb) file and paste it into your new file, replace the values with
   your translations

3. Update the [Supported Locales](#supported-locales) section on this page to update the supported translations for both the
   number and the list

</details>

<details>
<summary>Update existing local</summary>

1. Navigate to [l10n](../lib/src/l10n/) folder

2. Find the existing local, let's say you want to update the Korean translations, it will be `quill_ko.arb`

3. Use [untranslated.json](../lib/src/l10n/untranslated.json) as a reference to find missing, update, or add what you
   want
   to translate.

</details>
<br>

> We usually avoid **updating the existing value of a key in the template file without updating the key or creating a new
one**.
> This will not update the [untranslated.json](../lib/src/l10n/untranslated.json) correctly and will make it harder
for contributors to find missing or incomplete.

Once you finish, run the following script:

```bash
dart ./scripts/regenerate_translations.dart
```

Or (if you can't run the script for some reason):

```bash
flutter gen-l10n
dart fix --apply ./lib/src/l10n/generated
dart format ./lib/src/l10n/generated
```

The script above will generate Dart files from the Arb files to test the changes and take effect, otherwise you
won't notice a difference.

> 🔧 If you added or removed translations in the template file, make sure to update `_expectedTranslationKeysLength`
> variable in [scripts/translations_check.dart](../scripts/translations_check.dart) <br>
> Otherwise you don't need to update it.

Then open a pull request so everyone can benefit from your translations!



================================================
FILE: doc/configurations/custom_buttons.md
================================================
# 🔘 Custom `QuillSimpleToolbar` Buttons

You may add custom buttons to the _end_ of the toolbar, via the `customButtons` option, which is a `List`
of `QuillToolbarCustomButtonOptions`.

## Adding an Icon 🖌️

To add an Icon:

```dart
    QuillToolbarCustomButtonOptions(
        icon: const Icon(Icons.ac_unit),
        tooltip: 'Tooltip',
        onPressed: () {},
      ),
```

## Example Usage 📚

Each `QuillCustomButton` is used as part of the `customButtons` option as follows:

```dart
QuillSimpleToolbar(
  controller: _controller,
  config: QuillSimpleToolbarConfig(
    customButtons: [
      QuillToolbarCustomButtonOptions(
        icon: const Icon(Icons.ac_unit),
        onPressed: () {
          debugPrint('snowflake1');
        },
      ),
      QuillToolbarCustomButtonOptions(
        icon: const Icon(Icons.ac_unit),
        onPressed: () {
          debugPrint('snowflake2');
        },
      ),
      QuillToolbarCustomButtonOptions(
        icon: const Icon(Icons.ac_unit),
        onPressed: () {
          debugPrint('snowflake3');
        },
      ),
    ],
  ),
),
```


================================================
FILE: doc/configurations/font_size.md
================================================
# 🔠 Font Size

Within the editor toolbar, a drop-down with font-sizing capabilities is available.
This can be enabled or disabled with `showFontSize`.

When enabled, the default font-size values can be modified via _optional_ `rawItemsMap`.
Accepts a `Map<String, String>` consisting of a `String` title for the font size and a `String` value for the font size.
Example:

```dart
QuillSimpleToolbar(
    config: const QuillSimpleToolbarConfig(
      buttonOptions: QuillSimpleToolbarButtonOptions(
        fontSize: QuillToolbarFontSizeButtonOptions(
          items: {'Small': '8', 'Medium': '24.5', 'Large': '46'},
        ),
      ),
    ),
  );
```

Font size can be cleared with a value of `0`, for example:

```dart
QuillSimpleToolbar(
    config: const QuillSimpleToolbarConfig(
      buttonOptions: QuillSimpleToolbarButtonOptions(
        fontSize: QuillToolbarFontSizeButtonOptions(
          items: {'Small': '8', 'Medium': '24.5', 'Large': '46', 'Clear': '0'},
        ),
      ),
    ),
  );
```


================================================
FILE: doc/configurations/localizations_setup.md
================================================
# 🌍 Localizations Setup

The required localization delegates:

```dart
localizationsDelegates: const [
    DefaultCupertinoLocalizations.delegate,
    DefaultMaterialLocalizations.delegate,
    DefaultWidgetsLocalizations.delegate,
    FlutterQuillLocalizations.delegate,
]
```

📄 For additional notes, refer to the [Translation](../translation.md) section.



================================================
FILE: doc/configurations/search.md
================================================
# Search

You can search the text of your document using the search toolbar button.
Enter the text and use the up/down buttons to move to the previous/next selection.
Use the 3 vertical dots icon to turn on case-sensitivity or whole word constraints.

## Search configuration options

By default, the content of Embed objects are not searched.
You can enable search by setting the [searchEmbedMode] in `searchConfig`:

```dart
    QuillEditor.basic(
      controller: _controller,
      config: QuillEditorConfig(
        searchConfig: const QuillSearchConfig(
          searchEmbedMode: SearchEmbedMode.plainText,
        ),
      ),
      ...
    ),
```

### SearchEmbedMode.none (default option)

Embed objects will not be included in searches.

### SearchEmbedMode.rawData

This is the simplest search option when your Embed objects use simple text that is also displayed to the user.
This option allows searching within custom Embed objects using the node's raw data [Embeddable.data].

### SearchEmbedMode.plainText

This option is best for complex Embeds where the raw data contains text that is not visible to the user and/or contains textual data that is not suitable for searching.
For example, searching for '2024' would not be meaningful if the raw data is the full path of an image object (such as /user/temp/20240125/myimage.png).
In this case the image would be shown as a search hit but the user would not know why.

This option allows searching within custom Embed objects using an override to the [toPlainText] method.

```dart
  class MyEmbedBuilder extends EmbedBuilder {

    @override
    String toPlainText(Embed node) {
      /// Convert [node] to the text that can be searched.
      /// For example: convert to MyEmbeddable and use the
      ///   properties to return the searchable text.
      final m = MyEmbeddable(node.value.data);
      return  '${m.property1}\t${m.property2}';
    }
    ...
```
If [toPlainText] is not overridden, the base class implementation returns [Embed.kObjectReplacementCharacter] which is not searchable.

### Strategy for mixed complex and simple Embed objects

Select option [SearchEmbedMode.plainText] and override [toPlainText] to provide the searchable text. For your simple Embed objects provide the following override:

```dart
  class MySimpleEmbedBuilder extends EmbedBuilder {

    @override
    String toPlainText(Embed node) {
      return node.value.data;
    }
    ...
```



================================================
FILE: doc/configurations/using_custom_app_widget.md
================================================
# 🛠️ Using Custom App Widget

The project uses some adaptive widgets like `AdaptiveTextSelectionToolbar` which require the following delegates:

1. Default Material Localizations delegate
2. Default Cupertino Localizations delegate
3. Default Widgets Localizations delegate

You don't need to include these since they are defined by default. However, if you are using a custom app or overriding the `localizationsDelegates` in the App widget, ensure it includes the following:

```dart
localizationsDelegates: const [
    DefaultCupertinoLocalizations.delegate,
    DefaultMaterialLocalizations.delegate,
    DefaultWidgetsLocalizations.delegate,
],
```

📄 For additional notes, see the [localizations setup](./localizations_setup.md) page.




================================================
FILE: doc/migration/10_to_11.md
================================================
# 🔄 Migration from 10.x.x to 11.x.x

If you're using version `10.x.x`, we recommend fixing all the deprecations before migrating to `11.x.x` for a smoother migration.

> [!IMPORTANT]
> Once you're able to build and run the app successfully, ensure to read [breaking behavior](#-breaking-behavior).
> See if any changes affect your usage and update the existing code.

## 📋 1. Clipboard

The `super_clipboard` plugin has been removed from `flutter_quill` and `flutter_quill_extensions`.

Remove the following if used:

```diff
- FlutterQuillExtensions.useSuperClipboardPlugin();
```

You can either use our default implementation or continue using `super_clipboard`, if you're unsure, try with **option A** unless you have a reason to use **option B**.

### ⚙️ A. Using the new default implementation

> [!NOTE]
> You only need to remove the `super_clipboard` configuration if you're not using [super_clipboard](https://pub.dev/packages/super_clipboard) which was introduced in your app as a transitive dependency.

The [configuration of `super_clipboard`](https://pub.dev/packages/super_clipboard#getting-started) is no longer required.

The following snippet in your `android/app/src/main/AndroidManifest.xml` **should be removed** otherwise you will be unable to launch the **Android app**:

```xml
<provider
    android:name="com.superlist.super_native_extensions.DataProvider"
    android:authorities="<your-package-name>.SuperClipboardDataProvider"
    android:exported="true"
    android:grantUriPermissions="true" >
</provider>
```

It can be found inside the `<application>` tag if you have [added it](https://pub.dev/packages/super_clipboard#android-support).

See the [`quill_native_bridge` platform configuration](https://pub.dev/packages/quill_native_bridge#-platform-configuration) (**optional** for copying images on **Android**).

#### 🔧 Other Optional changes

The `super_clipboard` is no longer a dependency of `flutter_quill_extensions`.

As such it's no longer required to set the `minSdkVersion` to `23` on **Android**. If the main reason you updated
the version was `flutter_quill_extensions` then you can restore the Flutter default now (currently `21`).

Open the `android/app/build.gradle` file:

- Use the Flutter default `minSdkVersion`:

```kotlin
android {
  defaultConfig {
   minSdk = flutter.minSdkVersion
 }
}
```

- Use the Flutter default `ndkVersion`:

```kotlin
android {
  ndkVersion = flutter.ndkVersion
}
```

> [!NOTE]
> You should only apply this optional change if you're not using
> [`super_clipboard`](https://pub.dev/packages/super_clipboard) or you don't have a reason to change the Flutter default.

### ⚙️ B. Continue using the `super_clipboard` implementation

Use the new default implementation or if you want to continue using `super_clipboard`, use the package [quill_super_clipboard](https://pub.dev/packages/quill_super_clipboard) (**support might be discontinued in future releases**).

> [!WARNING]
> The support of [quill_super_clipboard](https://pub.dev/packages/quill_super_clipboard) might be discontinued. It's still possible to
> override the default implementation manually.

See [#2229](https://github.com/singerdmx/flutter-quill/issues/2229). 

## 📝 2. Quill Controller

The `QuillController` should now be passed to the `QuillEditor` and `QuillSimpleToolbar` constructors instead of the configuration class.

**Before**:

```dart
QuillEditor.basic(
    config: QuillEditorConfig(
      controller: _controller,
    ),
  )
```

**After**:

```dart
QuillEditor.basic(
    controller: _controller,
)
```

<details>
<summary>The change</summary>

```diff
QuillEditor.basic(
+   controller: _controller,
    config: QuillEditorConfig(
-      controller: _controller,
    ),
  )
```

</details>

> [!NOTE]
> The class `QuillEditorConfigurations` has been renamed to `QuillEditorConfig`. See [renames to configuration classes](#5-renames-to-configuration-classes) section.

See [#2037](https://github.com/singerdmx/flutter-quill/discussions/2037) for discussion. Thanks to [#2078](https://github.com/singerdmx/flutter-quill/pull/2078).

> [!TIP]
> The `QuillToolbar` widget has been removed and is no longer
required for custom toolbars, see [removal of the `QuillToolbar`](#️-8-removal-of-the-quilltoolbar) section.

## 🧹 3. Removal of the `QuillEditorProvider` and `QuillToolbarProvider` inherited widgets

It's no longer possible to access the `QuillController`, the `QuillEditorConfiugrations`, and `QuillSimpleToolbarConfigurations` using the `BuildContext`.
Instead, you will have to pass them through constructors (revert to the old behavior).

The extension methods on `BuildContext` like `requireQuillEditorConfigurations`, `quillEditorConfigurations`, and `quillEditorElementOptions` have been removed.

See [#2301](https://github.com/singerdmx/flutter-quill/issues/2301).

## 🌐 4. Required localization delegate

This project uses the [Flutter Localizations library](https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html), requiring `FlutterQuillLocalizations.delegate` to be included in your app widget (e.g., `MaterialApp`, `WidgetsApp`, `CupertinoApp`).

Previously, we used a helper widget (`FlutterQuillLocalizationsWidget`) to manually provide localization delegates, but this approach was inefficient and error-prone, causing unexpected bugs. It has been removed.

To use the `QuillEditor` and `QuillSimpleToolbar` widgets, add the required delegates as shown:

```dart
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

MaterialApp(
  localizationsDelegates: const [
    // Your other delegates...
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    FlutterQuillLocalizations.delegate,
  ],
);
```

<p align="center">OR (less code with less control)</p>

```dart
import 'package:flutter_quill/flutter_quill.dart';

MaterialApp(
  localizationsDelegates: FlutterQuillLocalizations.localizationsDelegates,
);
```

The widget `FlutterQuillLocalizationsWidget` has been removed.

The library `package:flutter_quill/translations.dart` has been removed and the replacement is `package:flutter_quill/flutter_quill.dart`

## 🔧 5. Renames to configuration classes

- **Renames `QuillEditorConfigurations` to `QuillEditorConfig` and `QuillEditor.configurations` to `QuillEditor.config`.**
- **Renames `QuillRawEditorConfigurations` to `QuillRawEditorConfig` and `QuillRawEditor.configurations` to `QuillRawEditor.config`.**
- **Renames `QuillSimpleToolbarConfigurations` to `QuillSimpleToolbarConfig` and `QuillSimpleToolbar.configurations` to `QuillSimpleToolbar.config`.**
- **Renames `QuillSearchConfigurations` to `QuillSearchConfig` and `QuillEditorConfig.searchConfigurations` to `QuillEditorConfig.searchConfig`.**
- **Renames `QuillControllerConfigurations` to `QuillControllerConfig` and `QuillController.configurations` to `QuillController.config`.** The `configurations` parameter in the `QuillController.basic()` factory constructor was also renamed to `config`.
- **Renames `QuillToolbarImageConfigurations` to `QuillToolbarImageConfig` and `QuillToolbarImageButtonOptions.imageButtonConfigurations` to `QuillToolbarImageButtonOptions.imageButtonConfig`.**

All class names have been updated to replace `Configurations` with `Config`, and the related parameter name has been changed from `configurations` to `config`.

## 🧩 6. Refactoring of the Embed block interface

The `EmbedBuilder.build()` and `EmbedButtonBuilder` have both been changed.

### 📥 The `EmbedBuilder.build()` method

All the properties (except `context`) have been encapsulated into one class `EmbedContext`.

```diff
  Widget build(
    BuildContext context,
-    QuillController controller,
-    Embed node,
-    bool readOnly,
-    bool inline,
-    TextStyle textStyle,
+    EmbedContext embedContext,
  ) {
-   controller.replaceText();
+   embedContext.controller.replaceText();
 }
```

### 🔘 The `EmbedButtonBuilder` function

All the properties have been encapsulated into one class `EmbedButtonContext` and the `BuildContext` property has been added.

```diff
- (controller, toolbarIconSize, iconTheme, dialogTheme) =>
-  QuillToolbarImageButton(
-    controller: controller,
-    options: imageButtonOptions,
-  )
+ (context, embedContext) => QuillToolbarImageButton(
+  controller: embedContext.controller,
+  options: imageButtonOptions,
+ ),
```

The `flutter_quill_extensions` has been updated.

> [!TIP]
> For more details, see [custom embed blocks](https://github.com/singerdmx/flutter-quill/blob/master/doc/custom_embed_blocks.md).

## 🔄 7. The `flutter_quill_extensions`

- Removes `ImagePickerService` from `OnRequestPickVideo` and `OnRequestPickImage`.
- Removes `ImageSaverService` from `ImageOptionsMenu`.
- Removes `QuillSharedExtensionsConfigurations`.
- The return type (`ImageProvider`) of `ImageEmbedBuilderProviderBuilder` has been made `null` so you can return `null` and fallback to our default handling. See [#2317](https://github.com/singerdmx/flutter-quill/pull/2317).
- Removes `QuillSharedExtensionsConfigurations.assetsPrefix`. Use `imageProviderBuilder` to support image assets. See [Image assets support](https://pub.dev/packages/flutter_quill_extensions#-image-assets).
- Removes YouTube video support. To migrate see [CHANGELOG of 10.8.0](https://github.com/singerdmx/flutter-quill/releases/tag/v10.8.0). See [#2284](https://github.com/singerdmx/flutter-quill/issues/2284).
- Removes the deprecated class `FlutterQuillExtensions`.
- Removes the deprecated and experimental table embed support.
- Avoid exporting `flutter_quill_extensions/utils.dart`.

## ✒️ 8. Removal of the `QuillToolbar`

The `QuillToolbar` widget has been removed as it's no longer necessary for `QuillSimpleToolbar` or **custom toolbars**.

Previously, `QuillToolbar` was required to provide a toolbar provider and localization delegate. Additionally, the `QuillToolbarConfigurations` class has been removed.

To migrate, add the [required localization delegate](#-4-required-localization-delegate) in your app widget
and remove the `QuillToolbar`.

```diff
- QuillToolbar(
-  configurations: const QuillToolbarConfigurations(),
-  child: YourCustomToolbar(),
- );
+ YourCustomToolbar();
```

See the [custom toolbar](https://github.com/singerdmx/flutter-quill/blob/master/doc/custom_toolbar.md) page for an example.

Customizing the buttons (that are from `flutter_quill`) within `QuillToolbarConfigurations` in a custom toolbar is **no longer supported**.
Instead, you can use the constructor of each button widget, an example:

```dart
final QuillController _controller = QuillController.basic();
final QuillToolbarBaseButtonOptions _baseOptions = QuillToolbarBaseButtonOptions(
  afterButtonPressed: () {
    // Do something
  }
);

YourCustomToolbar(
  buttons: [
    // Example of using buttons of the `QuillSimpleToolbar` in your custom toolbar.
    // Those buttons are from the flutter_quill library.
    // Pass the _baseOptions to all buttons.
    QuillToolbarToggleStyleButton(
      controller: _controller,
      baseOptions: _baseOptions,
      attribute: Attribute.bold,
    ),
    QuillToolbarClearFormatButton(
      controller: _controller,
      baseOptions: _baseOptions,
    ),
    QuillToolbarFontSizeButton(
      controller: _controller,
      baseOptions: _baseOptions,
      // Override the base button options within options, also allow button-specific options
      options: const QuillToolbarFontSizeButtonOptions(
        items: {'Small': '8', 'Medium': '24.5', 'Large': '46'},
      )
    )
  ]
);
```

> [!NOTE]
> This might be confusing: `QuillToolbar` is **not a visual toolbar** on its own like `QuillSimpleToolbar`. It's a non-visual widget that only 
ensures to provide the localization delegate and the toolbar provider.

<details>

<summary>Expand to see explanation about QuillToolbar vs QuillSimpleToolbar</summary>

This section explains the main difference between `QuillSimpleToolbar` and `QuillToolbar`.

- The `QuillSimpleToolbar` widget is a basic, straightforward toolbar provided by the library, which uses `QuillToolbar` internally.
- The non-visual `QuillToolbar` widget is utilized within `QuillSimpleToolbar` and can also be used to build a custom toolbar.
Before version `11.0.0`, it provided the toolbar provider and localization delegate, 
which supported the buttons provided by the library used in `QuillSimpleToolbar`. For custom toolbars, `QuillToolbar` 
is only needed if you use the library’s toolbar buttons from `flutter_quill`. Those buttons are used in `QuillSimpleToolbar`.

The `QuillToolbar` is different depending on the release you're using:

* On `7.x.x` and older versions, the `QuillToolbar.basic()` was the equivalent of `QuillSimpleToolbar`. The widget `QuillSimpleToolbar` didn't exist.
* On `9.x.x` and newer versions, the `QuillToolbar` has been changed to be a non-visual widget and `QuillSimpleToolbar` was added (the visual widget).
* On `11.0.0` and newer versions, the `QuillToolbar` is no longer needed and has been removed, and the `QuillSimpleToolbar` works without. It is no longer
required for **custom toolbars**.

</details>

## 📎 Minor changes

- `QuillEditorConfig.readOnly` has been removed and is accessible in `QuillController.readOnly`.
- `QuillController.editorFocusNode` has been removed, and is accessible in the `QuillEditor` widget.
- `QuillController.editorConfig` has been removed, and is accessible in the `QuillEditor` widget.
- `QuillEditorBuilderWidget` and `QuillEditorConfig.builder` have been removed as there's no valid use-case and this can be confusing.
- `QuillToolbarLegacySearchDialog` and `QuillToolbarLegacySearchButton` have been removed and replaced with `QuillToolbarSearchDialog` and `QuillToolbarSearchButton` which has been introduced in [9.4.0](https://github.com/singerdmx/flutter-quill/releases/tag/v9.4.0). `QuillSimpleToolbarConfigu.searchButtonType` is removed too.
- The property `dialogBarrierColor` has been removed from all buttons, use the `DialogTheme` in your `ThemeData` instead to customize it. See [Override a theme](https://docs.flutter.dev/cookbook/design/themes#override-a-theme).
- The deprecated members `QuillRawEditorConfig.enableMarkdownStyleConversion` and `QuillEditorConfig.enableMarkdownStyleConversion` has been removed. See [#2214](https://github.com/singerdmx/flutter-quill/issues/2214).
- Removes `QuillSharedConfigurations.extraConfigurations`. The optional configuration of `flutter_quill_extensions` should be separated.
- Renames the classes:
  - `QuillEditorBulletPoint` to `QuillBulletPoint`
  - `QuillEditorCheckboxPoint` to `QuillCheckbox`
  - `QuillEditorNumberPoint` to `QuillNumberPoint`.
- Removes `QuillEditorElementOptions` and `QuillEditorConfig.elementOptions`. To customize the leading, see [#2146](https://github.com/singerdmx/flutter-quill/pull/2146) as an example. The classes related to `QuillEditorElementOptions` such as `QuillEditorCodeBlockElementOptions` has been removed.
- Removes `QuillController.toolbarConfigurations` to not store anything specific to the `QuillSimpleToolbar` in the `QuillController`.
- Removes `QuillToolbarBaseButtonOptions.globalIconSize` and `QuillToolbarBaseButtonOptions.globalIconButtonFactor`. Both are deprecated for at least 10 months.
- Removes `QuillToolbarFontSizeButton.defaultDisplayText` (deprecated for more than 10 months).
- Removes `fontSizesValues` and `fontFamilyValues` from `QuillSimpleToolbarConfig` since those were used only in `QuillToolbarFontSizeButton` and `QuillToolbarFontFamilyButton`. Pass them to `items` (which exist in each button configuration) directly.
- Removes the deprecated library `flutter_quill/extensions.dart` since the name was confusing, it's for `flutter_quill_extensions`.
- Removes the deprecated library `flutter_quill/markdown_quill.dart`. Suggested alternatives: [markdown_quill](https://pub.dev/packages/markdown_quill) or [quill_markdown](https://pub.dev/packages/quill_markdown).
- Removes `Document.fromHtml`. Use an alternative such as [flutter_quill_delta_from_html](https://pub.dev/packages/flutter_quill_delta_from_html).
- Removes `QuillControllerConfig.editorConfig` (not being used and invalid).
- Remove `QuillSharedConfigurations` (it's no longer used). It was previously used to set the `Local` for both `QuillEditor` and `QuillToolbar` simultaneously.
- Removes the experimental method `QuillController.setContents`.
- Renames `isOnTapOutsideEnabled` from `QuillRawEditorConfig` and `QuillEditorConfig` to `onTapOutsideEnabled`.
- Removes editor configuration from `Document`. Instead, only require the needed parameters as internal members. Updates `Line.getPlainText()`.
- The class `OptionalSize` are no longer exported as part of `package:flutter_quill/flutter_quill.dart`.
- Renames `QuillToolbarToggleCheckListButtonOptions.isShouldRequestKeyboard` to `QuillToolbarToggleCheckListButtonOptions.shouldRequestKeyboard`.
- Moved `onClipboardPaste` from `QuillControllerConfig` to `QuillClipboardConfig`. Added `clipboardConfig` property to `QuillControllerConfig`.
- Moved `onImagePaste` and `onGifPaste` from the editor's config (`QuillEditorConfig` or `QuillRawEditorConfig`) to the clipboard's config (`QuillClipboardConfig`), which is part of the controller's config (`QuillControllerConfig`).
- Changed the options type from `QuillToolbarToggleStyleButtonOptions` to `QuillToolbarClipboardButtonOptions` in `QuillToolbarClipboardButton`, use the new options class.
- Change the `onTapDown` to accept `TapDownDetails` instead of `TapDragDownDetails` (revert [#2128](https://github.com/singerdmx/flutter-quill/pull/2128/files#diff-49ca9b0fdd0d380a06b34d5aed7674bbfb27fede500831b3e1279615a9edd06dL259-L261) due to regressions).
- Change the `onTapUp` to accept `TapUpDetails` instead of `TapDragUpDetails` (revert [#2128](https://github.com/singerdmx/flutter-quill/pull/2128/files#diff-49ca9b0fdd0d380a06b34d5aed7674bbfb27fede500831b3e1279615a9edd06dL263-L265) due to regressions).

## 💥 Breaking behavior

The existing code works and compiles but the functionality has changed in a non-backward-compatible way:

### 1. The `QuillClipboardConfig.onClipboardPaste` is not a fallback anymore when couldn't handle the paste operation by default

The `QuillClipboardConfig.onClipboardPaste` has been updated to allow to override of the default clipboard paste handling instead of only handling the clipboard paste if the default logic didn't paste. See the updated docs comment of [`QuillClipboardConfig.onClipboardPaste`](https://github.com/singerdmx/flutter-quill/blob/master/lib/src/controller/clipboard/quill_clipboard_config.dart#L18-L47) for an example.

Previously it was a fallback function that will be called when the default paste is not handled successfully.

To migrate, use the [`QuillClipboardConfig.onUnprocessedPaste`](https://github.com/singerdmx/flutter-quill/blob/master/lib/src/controller/clipboard/quill_clipboard_config.dart#L49-L53) callback instead.

```diff
- QuillControllerConfig(
-   onClipboardPaste: () {}
- )
+  QuillControllerConfig(
+   clipboardConfig: QuillClipboardConfig(
+     onUnprocessedPaste: () {}
+   )
+ )
```

### 2. No longer handle asset images by default in `flutter_quill_extensions`

The **flutter_quill_extensions** does not handle `AssetImage` anymore by default when loading images, instead use `imageProviderBuilder` to override the default handling. 

To support loading image assets (images bundled within your app):

```dart
FlutterQuillEmbeds.editorBuilders(
    imageEmbedConfig:
        QuillEditorImageEmbedConfig(
      imageProviderBuilder: (context, imageUrl) {
        if (imageUrl.startsWith('assets/')) {
          return AssetImage(imageUrl);
        }
        // Fallback to default handling
        return null;
      },
    ),  
)
```

Ensures to replace `assets` with your assets directory name or change the logic to fit your needs.

### 3. No longer request editor focus by default after pressing a `QuillSimpleToolbar`'s button

The `QuillSimpleToolbar` and related toolbar buttons no longer request focus from the editor after pressing a button (**revert to the old behavior**).

Here is a minimal example to use to the old behavior using `QuillSimpleToolbar`:

```dart
final QuillController _controller = QuillController.basic();
final _editorFocusNode = FocusNode();
final _editorScrollController = ScrollController();

QuillSimpleToolbar(
  controller: _controller,
  config: QuillSimpleToolbarConfig(
    buttonOptions: QuillSimpleToolbarButtonOptions(
      base: QuillToolbarBaseButtonOptions(
        afterButtonPressed: _editorFocusNode.requestFocus
      )
    )
  )
),
Expanded(
  child: QuillEditor(controller: _controller, focusNode: _editorFocusNode, scrollController: _editorScrollController)
)
```

With a custom toolbar:

```dart
final QuillController _controller = QuillController.basic();
final _editorFocusNode = FocusNode();
final _editorScrollController = ScrollController();

final QuillToolbarBaseButtonOptions _baseOptions = QuillToolbarBaseButtonOptions(
  afterButtonPressed: _editorFocusNode.requestFocus
);

YourCustomToolbar(
  buttons: [
    // Pass the _baseOptions to all buttons.
    QuillToolbarClearFormatButton(
      controller: _controller,
      baseOptions: _baseOptions,
    ),
    QuillToolbarFontSizeButton(
      controller: _controller,
      baseOptions: _baseOptions,
    ),
    // all the other buttons
  ]
),
Expanded(
  child: QuillEditor(controller: _controller, focusNode: _editorFocusNode, scrollController: _editorScrollController)
)
```

Don't forgot to dispose the `QuillController`, `FocusNode` and `ScrollController` in the `dispose()` method:

```dart
@override
void dispose() {
  _controller.dispose();
  _editorFocusNode.dispose();
  _editorScrollController.dispose();
  super.dispose();
}
```

### 4. Clipboard action buttons in `QuillSimpleToolbar` are now disabled by default

This change was made due to a performance issue ([#2421](https://github.com/singerdmx/flutter-quill/issues/2421)) and reverts a minor update ([9.3.10](https://pub.dev/packages/flutter_quill/changelog#9310)) that unexpectedly enabled these buttons by default, increasing UI space usage.

To show them again, set `showClipboardCut`, `showClipboardCopy`, and `showClipboardPaste` to `true` in `QuillSimpleToolbarConfig`:

```dart
QuillSimpleToolbar(
  config: QuillSimpleToolbarConfig(
    showClipboardCut: true,
    showClipboardCopy: true,
    showClipboardPaste: true,
  )
)
```

### 5. Removal of the magnifier feature

Unfortunately, **due to the high volume of issues and bugs introduced by the magnifier**, this feature has been removed to ensure stability.

This feature was introduced in [9.6.0](https://pub.dev/packages/flutter_quill/versions/9.6.0/changelog#960) which supports Android and iOS only.

For more details, refer to [#2406](https://github.com/singerdmx/flutter-quill/issues/2406).

```diff
QuillEditorConfig(
-   magnifierConfiguration: TextMagnifierConfiguration()
)
// No longer supported, subscribe to https://github.com/singerdmx/flutter-quill/issues/1504 for updates
```

In the future, new features will be implemented with more caution to avoid possible issues.

> [!NOTE]
> **Update**: This feature has been added back in [11.3.0](https://github.com/singerdmx/flutter-quill/compare/v11.2.0...v11.3.0) ([#2529](https://github.com/singerdmx/flutter-quill/pull/2529/files#diff-3fd362bb7d8427c36545eac5cc1f18edc8137fbb866f1f52950b3a88823bc0d2R372-R378)) and is disabled by default.

## 🚧 Experimental

APIs that were indicated as stable but are now updated to indicate
that they are experimental, which means that they might be removed or changed
in non-major releases:

- The `QuillSearchConfig` and search within embed objects feature. Related [#2090](https://github.com/singerdmx/flutter-quill/pull/2090).
- The `QuillController.clipboardPaste()` and `QuillEditorConfig.onGifPaste`.
- The `QuillEditorConfig.characterShortcutEvents` and `QuillEditorConfig.spaceShortcutEvents`.
- The `QuillControllerConfig.onClipboardPaste`.
- The `QuillEditorConfig.customLeadingBlockBuilder`.
- The `shouldNotifyListeners` in `QuillController.replaceText()`, `QuillController.replaceText()`, `QuillController.formatSelection()`.
- The `QuillController.clipboardSelection()`.
- The `CopyCutServiceProvider`, `CopyCutService`, and `DefaultCopyCutService`.
- The clipboard action buttons in the `QuillSimpleToolbar` (`showClipboardCut`, `showClipboardCopy` and `showClipboardPaste`), including `QuillToolbarClipboardButton` and `ClipboardMonitor` due to a performance issue [#2421](https://github.com/singerdmx/flutter-quill/issues/2421).

The functionality itself has not changed and no experimental changes were introduced.



================================================
FILE: doc/readme/cn.md
================================================
<p align="center" style="background-color:#282C34">
  <img src="https://user-images.githubusercontent.com/10923085/119221946-2de89000-baf2-11eb-8285-68168a78c658.png" width="600px">
</p>
<h1 align="center">支持 Flutter 平台的富文本编辑器</h1>

[![MIT License][license-badge]][license-link]
[![PRs Welcome][prs-badge]][prs-link]
[![Watch on GitHub][github-watch-badge]][github-watch-link]
[![Star on GitHub][github-star-badge]][github-star-link]
[![Watch on GitHub][github-forks-badge]][github-forks-link]

[license-badge]: https://img.shields.io/github/license/singerdmx/flutter-quill.svg?style=for-the-badge
[license-link]: https://github.com/singerdmx/flutter-quill/blob/master/LICENSE
[prs-badge]: https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=for-the-badge
[prs-link]: https://github.com/singerdmx/flutter-quill/issues
[github-watch-badge]: https://img.shields.io/github/watchers/singerdmx/flutter-quill.svg?style=for-the-badge&logo=github&logoColor=ffffff
[github-watch-link]: https://github.com/singerdmx/flutter-quill/watchers
[github-star-badge]: https://img.shields.io/github/stars/singerdmx/flutter-quill.svg?style=for-the-badge&logo=github&logoColor=ffffff
[github-star-link]: https://github.com/singerdmx/flutter-quill/stargazers
[github-forks-badge]: https://img.shields.io/github/forks/singerdmx/flutter-quill.svg?style=for-the-badge&logo=github&logoColor=ffffff
[github-forks-link]: https://github.com/singerdmx/flutter-quill/network/members

[原文档](./README.md)

---

> This documentation is outdated. Please check the [English version](../../README.md).

`FlutterQuill` 是一个富文本编辑器，也是 [Quill](https://quilljs.com/docs/formats) 在 [Flutter](https://github.com/flutter/flutter) 的版本

该库是为 Android、iOS、Web、Desktop 多平台构建的『所见即所得』的富文本编辑器。查看我们的 [Youtube 播放列表](https://youtube.com/playlist?list=PLbhaS_83B97vONkOAWGJrSXWX58et9zZ2) 或 [代码介绍](https://github.com/singerdmx/flutter-quill/blob/master/CodeIntroduction.md) 以了解代码的详细内容。你可以加入我们的 [Slack Group](https://join.slack.com/t/bulletjournal1024/shared_invite/zt-fys7t9hi-ITVU5PGDen1rNRyCjdcQ2g) 来进行讨论

示例 `App` : [BULLET JOURNAL](https://bulletjournal.us/home/index.html)

`Pub` : [FlutterQuill](https://pub.dev/packages/flutter_quill)

## 效果展示

<p float="left">
  <img width="400" alt="1" src="https://user-images.githubusercontent.com/122956/103142422-9bb19c80-46b7-11eb-83e4-dd0538a9236e.png">
  <img width="400" alt="1" src="https://user-images.githubusercontent.com/122956/103142455-0531ab00-46b8-11eb-89f8-26a77de9227f.png">
</p>

<p float="left">
  <img width="400" alt="1" src="https://user-images.githubusercontent.com/122956/102963021-f28f5a00-449c-11eb-8f5f-6e9dd60844c4.png">
  <img width="400" alt="1" src="https://user-images.githubusercontent.com/122956/102977404-c9c88e00-44b7-11eb-9423-b68f3b30b0e0.png">
</p>

---

## 用法

查看  `示例` 目录来学习 `FlutterQuill` 最简单的使用方法，你通常只需要一个控制器实例：

```dart
QuillController _controller = QuillController.basic();
```

然后在你的 `App` 中嵌入工具栏 `QuillToolbar` 和编辑器 `QuillEditor` ，如：

```dart
Column(
  children: [
    QuillToolbar.basic(controller: _controller),
    Expanded(
      child: Container(
        child: QuillEditor.basic(
          controller: _controller,
          readOnly: false, // 为 true 时只读
        ),
      ),
    )
  ],
)
```

查看 [示例页面](https://github.com/singerdmx/flutter-quill/blob/master/example/lib/pages/home_page.dart) 查看高级用法

## 保存和读取

该库使用 [Quill 格式](https://quilljs.com/docs/formats) 作为内部数据格式

* 使用 `_controller.document.toDelta()` 获取 [Delta 格式](https://quilljs.com/docs/delta/)
* 使用 `_controller.document.toPlainText()` 获取纯文本

`FlutterQuill` 提供了一些 `JSON` 序列化支持，以便你保存和打开文档

要将文档转化为 `JSON` 类型，请执行以下操作：

```dart
var json = jsonEncode(_controller.document.toDelta().toJson());
```

要将 `FlutterQuill` 使用之前存储的 `JSON` 数据，请执行以下操作：

```dart
var myJSON = jsonDecode(r'{"insert":"hello\n"}');
_controller = QuillController(
          document: Document.fromJson(myJSON),
          selection: TextSelection.collapsed(offset: 0),
          );
```

## Web 端

对于 `Web` 开发，请执行 `flutter config --enable-web` 来获取 `Flutter` 的支持，或使用 [ReactQuill](https://github.com/zenoamaro/react-quill) 获取对 `React` 的支持

进行 `Web` 开发需要提供 `EmbedBuilder` ，参见 [defaultEmbedBuilderWeb](https://github.com/singerdmx/flutter-quill/blob/master/example/lib/universal_ui/universal_ui.dart#L29)

进行 `Web` 开发还需要提供 `webImagePickImpl` ，参见 [示例页面](https://github.com/singerdmx/flutter-quill/blob/master/example/lib/pages/home_page.dart#L225)

## 桌面端

进行桌面端工具栏按钮开发需要提供 `filePickImpl` ，参见 [示例页面](https://github.com/singerdmx/flutter-quill/blob/master/example/lib/pages/home_page.dart#L205)

## 配置

`QuillToolbar` 类允许你自定义可用的格式选项，参见 [示例页面](https://github.com/singerdmx/flutter-quill/blob/master/example/lib/pages/home_page.dart) 提供了高级使用和配置的示例代码

### 字号

在工具栏中提供了选择字号的下拉菜单，可通过 `showFontSize` 来启用或禁用

启用后，可以通过 *可选的* `fontSizeValues` 属性修改默认字号

`fontSizeValues` 接收一个 `Map<String, String>`，其中包含一个 `String` 类型的标题和一个 `String` 类型的字号，如：

```dart
fontSizeValues: const {'小字号': '8', '中字号': '24.5', '大字号': '46'}
```

字体大小可以使用 `0` 值清除，例如：

```dart
fontSizeValues: const {'小字号': '8', '中字号': '24.5', '大字号': '46', '清除': '0'}
```

### 字体

想要使用你自己的字体，请更新你的 [assets folder](https://github.com/singerdmx/flutter-quill/tree/master/example/assets/fonts) 并且传入 `fontFamilyValues`

详见 [这个 Commit](https://github.com/singerdmx/flutter-quill/commit/71d06f6b7be1b7b6dba2ea48e09fed0d7ff8bbaa) 和 [这篇文章](https://stackoverflow.com/questions/55075834/fontfamily-property-not-working-properly-in-flutter) 以及 [这个教程](https://www.flutterbeads.com/change-font-family-flutter/)

### 自定义按钮

你可以通过 `customButtons` 可选参数将自定义按钮添加到工具栏的 *末尾* ，该参数接收 `QuillCustomButton` 的 `List`

要添加一个 `Icon` ，我们应该实例化一个新的 `QuillCustomButton`

```dart
    QuillCustomButton(
        icon:Icons.ac_unit,
        onTap: () {
          debugPrint('snowflake');
        }
    ),
```

每个 `QuillCustomButton` 都是 `customButtons` 可选参数的一部分，如：

```dart
QuillToolbar.basic(
   (...),
    customButtons: [
        QuillCustomButton(
            icon:Icons.ac_unit,
            onTap: () {
              debugPrint('snowflake1');
            }
        ),
        QuillCustomButton(
            icon:Icons.ac_unit,
            onTap: () {
              debugPrint('snowflake2');
            }
        ),
        QuillCustomButton(
            icon:Icons.ac_unit,
            onTap: () {
              debugPrint('snowflake3');
            }
        ),
    ]
```

## 嵌入块

自 `6.0` 版本，本库不默认支持嵌入块，反之本库提供接口给所有用户来创建所需的嵌入块。

若需要图片、视频、公式块的支持，请查看独立库 [`flutter_quill_extensions`](https://pub.dev/packages/flutter_quill_extensions)

### 根据 `flutter_quill_extensions` 使用图片、视频、公式等自定义嵌入块

```dart
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

QuillEditor.basic(
  controller: controller,
  embedBuilders: FlutterQuillEmbeds.builders(),
);

QuillToolbar.basic(
  controller: controller,
  embedButtons: FlutterQuillEmbeds.buttons(),
);
```

### 移动端上自定义图片尺寸

定义`mobileWidth`、`mobileHeight`、`mobileMargin`、`mobileAlignment`如下：

```dart
{
      "insert": {
         "image": "https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png"
      },
      "attributes":{
         "style":"mobileWidth: 50; mobileHeight: 50; mobileMargin: 10; mobileAlignment: topLeft"
      }
}
```

### 自定义嵌入块

有时你想在文本中添加一些自定义内容或者是自定义小部件

比如向文本添加注释，或者在文本编辑器中添加的任何自定义内容

你唯一需要做的就是添加一个 `CustomBlockEmbed` 并将其映射到 `customElementsEmbedBuilder` 中，以将自定义块内的数据转换为一个 `Widget` ，如：

先从 `CustomBlockEmbed` `extent` 出一个 `NotesBlockEmbed` 类，并添加两个方法以返回 `Document` 用以 `flutter_quill` 渲染富文本

```dart
class NotesBlockEmbed extends CustomBlockEmbed {
  const NotesBlockEmbed(String value) : super(noteType, value);

  static const String noteType = 'notes';

  static NotesBlockEmbed fromDocument(Document document) =>
      NotesBlockEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}
```

然后，我们需要将这个 `notes` 类型映射到其想渲染出的 `Widget` 中

在这里我们使用 `ListTile` 来渲染它，并使用 `onTap` 方法来编辑内容，最后不要忘记将此方法添加到 `QuillEditor` 中

```dart
class NotesEmbedBuilder extends EmbedBuilder {
  NotesEmbedBuilder({required this.addEditNote});

  Future<void> Function(BuildContext context, {Document? document}) addEditNote;

  @override
  String get key => 'notes';

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    final notes = NotesBlockEmbed(node.value.data).document;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        title: Text(
          notes.toPlainText().replaceAll('\n', ' '),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        leading: const Icon(Icons.notes),
        onTap: () => addEditNote(context, document: notes),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
```

最后我们编写一个方法来添加或编辑内容

`showDialog` 方法先显示 `Quill` 编辑器以让用户编辑内容，编辑完成后，我们需要检查文档是否有内容，若有则在 `BlockEmbed.custom` 传入添加或编辑了的 `NotesBlockEmbed`

注意，如果我们没有在 `BlockEmbed.custom` 传如我们所自定义的 `CustomBlockEmbed` ，那么编辑将不会生效

```dart
Future<void> _addEditNote(BuildContext context, {Document? document}) async {
  final isEditing = document != null;
  final quillEditorController = QuillController(
    document: document ?? Document(),
    selection: const TextSelection.collapsed(offset: 0),
  );

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      titlePadding: const EdgeInsets.only(left: 16, top: 8),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${isEditing ? 'Edit' : 'Add'} note'),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          )
        ],
      ),
      content: QuillEditor.basic(
        controller: quillEditorController,
        readOnly: false,
      ),
    ),
  );

  if (quillEditorController.document.isEmpty()) return;

  final block = BlockEmbed.custom(
    NotesBlockEmbed.fromDocument(quillEditorController.document),
  );
  final controller = _controller!;
  final index = controller.selection.baseOffset;
  final length = controller.selection.extentOffset - index;

  if (isEditing) {
    final offset = getEmbedNode(controller, controller.selection.start).offset;
    controller.replaceText(
        offset, 1, block, TextSelection.collapsed(offset: offset));
  } else {
    controller.replaceText(index, length, block, null);
  }
}
```

这样我们就成功的在富文本编辑器中添加了一个自定义小组件

<p float="left">
  <img width="400" alt="1" src="https://i.imgur.com/yBTPYeS.png">
</p>

> 1. 更多信息和视频示例，请参阅 [这个特性的 PR](https://github.com/singerdmx/flutter-quill/pull/877)
> 2. 有关更多详细信息，请查看 [这个 Youtube 视频](https://youtu.be/pI5p5j7cfHc)

### 翻译

该库为 `QuillToolbar` 和 `QuillEditor` 提供了部分翻译，且若你未设置自己的语言环境，则它将使用系统语言环境：

```dart
QuillToolbar(locale: Locale('fr'), ...)
QuillEditor(locale: Locale('fr'), ...)
```

目前，可提供以下 27 种语言环境的翻译：

* `Locale('en')`
* `Locale('ar')`
* `Locale('cs')`
* `Locale('de')`
* `Locale('da')`
* `Locale('fr')`
* `Locale('he')`
* `Locale('zh', 'cn')`
* `Locale('zh', 'hk')`
* `Locale('ko')`
* `Locale('ru')`
* `Locale('es')`
* `Locale('tr')`
* `Locale('uk')`
* `Locale('ur')`
* `Locale('pt')`
* `Locale('pl')`
* `Locale('vi')`
* `Locale('id')`
* `Locale('it')`
* `Locale('ms')`
* `Locale('nl')`
* `Locale('no')`
* `Locale('fa')`
* `Locale('hi')`
* `Locale('sr')`
* `Locale('jp')`

#### 贡献翻译

翻译文件位于 [toolbar.i18n.dart](lib/src/translations/toolbar.i18n.dart)

随意贡献你自己的翻译，只需复制英文翻译映射并将值替换为你的翻译即可

然后打开一个拉取请求，这样每个人都可以从你的翻译中受益！

### 转化至 HTML

将你的文档转为 `Quill Delta` 格式有时还不够，通常你需要将其转化为其他如 `HTML` 格式来分发他，或作为邮件发出

一个方案是使用 [vsc_quill_delta_to_html](https://pub.dev/packages/vsc_quill_delta_to_html) `Flutter` 包来转化至 `HTML` 格式。此包支持所以的 `Quill` 操作，包含图片、视频、公式、表格和注释

转化过程可以在 `vanilla Dart` 如服务器端或 `CLI` 执行，也可在 `Flutter` 中执行

其是流行且成熟的 [quill-delta-to-html](https://www.npmjs.com/package/quill-delta-to-html) `Typescript/Javascript` 包的 `Dart` 部分

## 测试

为了能在测试文件里测试编辑器，我们给 flutter `WidgetTester` 提供了一个扩展，其中包括在测试文件中简化与编辑器交互的方法。

在测试文件内导入测试工具：

```dart
import 'package:flutter_quill/flutter_quill_test.dart';
```

然后使用 `quillEnterText` 输入文字：

```dart
await tester.quillEnterText(find.byType(QuillEditor), 'test\n');
```

---

## 赞助

<a href="https://bulletjournal.us/home/index.html">
<img src=
"https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png"
 width="150px" height="150px"></a>


