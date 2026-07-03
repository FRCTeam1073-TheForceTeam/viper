enum FieldType { string, bool, integer }

class FieldDescriptor {
	final String fieldName;        // Property name in the class (e.g., 'shootOnMove')
	final String csvKey;           // CSV column name (e.g., 'shoot_move')
	final FieldType type;
	final dynamic defaultValue;
	final String? uiLabelKey;      // Translation key for checkbox/radio label (optional)
	final dynamic Function(dynamic)? getter;  // Extract value from object (e.g., (obj) => obj.shootOnMove)

	FieldDescriptor({
		required this.fieldName,
		required this.csvKey,
		required this.type,
		required this.defaultValue,
		this.uiLabelKey,
		this.getter,
	});

	/// Parse a value from CSV (handles type conversion)
	dynamic fromCsv(dynamic value) {
		if (value == null) return defaultValue;
		switch (type) {
			case FieldType.bool:
				if (value is bool) return value;
				if (value is int) return value == 1;
				if (value is String) return value == '1';
				return defaultValue;
			case FieldType.integer:
				if (value is int) return value;
				if (value is String) return int.tryParse(value) ?? defaultValue;
				return defaultValue;
			case FieldType.string:
				if (value is String) return value.isEmpty ? null : value;
				return value?.toString();
		}
	}

	/// Serialize a value to CSV format
	dynamic toCsv(dynamic value) {
		if (value == null) return null;
		switch (type) {
			case FieldType.bool:
				return (value as bool) ? 1 : 0;
			case FieldType.integer:
				return value;
			case FieldType.string:
				return value;
		}
	}
}

/// Helper to bulk-define bool fields with the same defaults
class BoolFieldDescriptor extends FieldDescriptor {
	BoolFieldDescriptor({
		required super.fieldName,
		required super.csvKey,
		super.uiLabelKey,
		super.getter,
		bool defaultValue = false,
	}) : super(
		type: FieldType.bool,
		defaultValue: defaultValue,
	);
}

class StringFieldDescriptor extends FieldDescriptor {
	StringFieldDescriptor({
		required super.fieldName,
		required super.csvKey,
		super.uiLabelKey,
		super.getter,
	}) : super(
		type: FieldType.string,
		defaultValue: null,
	);
}
