# Field Descriptor + Map-Based Data Model Guide

This guide explains the DRY pattern for scouting data fields. It eliminates repetition across data classes, CSV serialization, and UI code by combining field descriptors with a map-based data model.

## The Problem

Before: A field like `shootOnMove` appeared in ~10 places:
- Property declaration
- Constructor parameter
- Constructor default value
- copyWith parameter
- copyWith body (2 mentions)
- toMap() field mapping
- loadFromData() constructor call
- UI selectedValues array
- UI switch statement

## The Solution: Map-Based Data Model + Field Descriptors

### Core Pattern

Instead of strongly-typed properties, store all fields in a `Map<String, dynamic>` and use descriptors to define them once:

#### 1. Define Fields Via Descriptors

```dart
class EndGameData extends MapDataModel {
  static final _descriptors = [
    BoolFieldDescriptor(
      fieldName: 'shootOnMove',
      csvKey: 'shoot_move',
      uiLabelKey: 'shoot_move_desc',
    ),
    // ... rest of fields (one line per field)
  ];
  
  @override
  List<FieldDescriptor> get descriptors => _descriptors;
}
```

That's it. You've defined:
- Field name
- CSV key
- UI label (optional)
- Type (via descriptor class)
- Default (built-in: bool=false, string=null)

#### 2. Add Typed Getters

Provide type-safe access to the underlying map:

```dart
bool get shootOnMove => values['shootOnMove'] as bool? ?? false;
bool get shootWhileCollecting => values['shootWhileCollecting'] as bool? ?? false;
// ... one getter per field
```

#### 3. Implement updateField

Replaces copyWith entirely:

```dart
@override
EndGameData updateField(String fieldName, dynamic value) {
  final newValues = {...values};
  newValues[fieldName] = value;
  return EndGameData(newValues);
}
```

#### 4. CSV Serialization (Automatic)

```dart
Map<String, dynamic> toMap() {
  return SerializationHelper.toMapFromMapObject(descriptors, values);
}

void loadFromData(Map<String, dynamic> data) {
  final parsed = SerializationHelper.fromMap(descriptors, data);
  values.clear();
  values.addAll(parsed);
}
```

Type conversion (bool→1, string→null) is automatic via descriptors.

#### 5. UI with DescriptorCheckboxGroup

No hardcoded arrays or switch statements:

```dart
DescriptorCheckboxGroup(
  object: endGame,
  onChanged: (fieldName, newValue) {
    ref.read(endGameProvider.notifier).update(
      endGame.updateField(fieldName, newValue),
    );
  },
)
```

The widget automatically:
- Extracts checkbox values from the object
- Gets translation keys from descriptors
- Wires up field name callbacks

---

## How to Apply to Other Models

### Step 1: Extend MapDataModel

```dart
class PreMatchData extends MapDataModel {
  PreMatchData([Map<String, dynamic>? initialValues]) 
    : super(initialValues ?? {});
  
  PreMatchData.empty() : super.empty();
  
  @override
  List<FieldDescriptor> get descriptors => _descriptors;
  
  static final _descriptors = [
    StringFieldDescriptor(
      fieldName: 'startingPosition',
      csvKey: 'starting_position',
    ),
    BoolFieldDescriptor(
      fieldName: 'noShow',
      csvKey: 'no_show',
    ),
  ];
  
  // Typed getters
  String? get startingPosition => values['startingPosition'] as String?;
  bool get noShow => values['noShow'] as bool? ?? false;
  
  @override
  PreMatchData updateField(String fieldName, dynamic value) {
    final newValues = {...values};
    newValues[fieldName] = value;
    return PreMatchData(newValues);
  }
}
```

### Step 2: Update the Provider

```dart
class PreMatchNotifier extends StateNotifier<PreMatchData> {
  PreMatchNotifier() : super(PreMatchData.empty());

  void update(PreMatchData data) => state = data;
  
  void reset() => state = PreMatchData.empty();
  
  void loadFromData(Map<String, dynamic> data) {
    final parsed = SerializationHelper.fromMap(PreMatchData._descriptors, data);
    state = PreMatchData(parsed);
  }
}
```

### Step 3: Use in UI

```dart
// For checkboxes:
DescriptorCheckboxGroup(
  object: preMatch,
  onChanged: (fieldName, newValue) {
    ref.read(preMatchProvider.notifier).update(
      preMatch.updateField(fieldName, newValue),
    );
  },
)
```

---

## Key Classes

| Class | Purpose |
|-------|---------|
| `MapDataModel` | Base class for map-based data (replaces copyWith) |
| `FieldDescriptor` | Describes a field: name, CSV key, type, UI metadata |
| `BoolFieldDescriptor` | Bool fields (default false) |
| `StringFieldDescriptor` | String fields (default null) |
| `SerializationHelper` | CSV serialization/deserialization with type conversion |
| `DescriptorCheckboxGroup` | Generates checkbox UI from object descriptors |
| `UiHelper` | Extracts checkbox values from descriptors |

---

## Adding a New Field: Complete Example

**Cost before:** 10+ changes across 3 files  
**Cost now:** 2 changes in 1 file

### Before
```dart
// provider
final bool newField;
// constructor
this.newField = false,
// copyWith param
bool? newField,
// copyWith body
newField: newField ?? this.newField,
// toMap
'newField': newField ? 1 : 0,
// loadFromData
newField: (data['new_field'] as int?) == 1,

// ui
selectedValues: [..., endGame.newField],
switch(index) {
  case N:
    ref.read(...).update(endGame.copyWith(newField: !endGame.newField));
}
```

### After
```dart
// provider ONLY:

// 1. Add to descriptors:
BoolFieldDescriptor(fieldName: 'newField', csvKey: 'new_field'),

// 2. Add getter:
bool get newField => values['newField'] as bool? ?? false;

// 3. No UI changes needed — DescriptorCheckboxGroup handles it automatically
```

Done. CSV serialization, type conversion, defaults, and UI all work automatically.

---

## Tradeoffs

**Pros:**
- Minimal boilerplate (2 lines per field instead of 10+)
- Adding fields is trivial
- CSV serialization automatic
- UI generation automatic
- Type-safe getters

**Cons:**
- Fields stored dynamically (but getters provide type safety)
- No IDE autocomplete for field names in `updateField('fieldName', ...)`
- Requires MapDataModel base class

The tradeoff heavily favors DRY—adding a field is now so cheap that refactoring is fast.
