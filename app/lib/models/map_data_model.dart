import 'field_descriptor.dart';
import 'serialization_helper.dart';

/// Base class for untyped, map-based data models.
/// Stores all fields in a `Map<String, dynamic>` and uses descriptors for:
/// - Type safety (through generated getters)
/// - CSV serialization
/// - UI metadata
abstract class MapDataModel {
	final Map<String, dynamic> values;

	MapDataModel(this.values);

	MapDataModel.empty() : values = {};

	/// Get descriptor list - override in subclass
	List<FieldDescriptor> get descriptors;

	/// Generic field update: replaces copyWith entirely
	/// Returns a new instance with the field updated
	MapDataModel updateField(String fieldName, dynamic value);

	/// Helper for updateField implementation - converts value to string and updates map
	Map<String, dynamic> updateFieldValues(String fieldName, dynamic value) {
		if (value == null) return values;
		final newValues = {...values};
		newValues[fieldName] = value.toString();
		return newValues;
	}

	/// Serialize to CSV map - uses descriptors
	Map<String, dynamic> toMap() {
		return SerializationHelper.toMapFromMapObject(descriptors, values);
	}

	/// Deserialize from CSV map - uses descriptors
	void loadFromMap(Map<String, dynamic> csvData) {
		final parsed = SerializationHelper.fromMap(descriptors, csvData);
		values.clear();
		values.addAll(parsed);
	}

	/// Helper: get descriptor by name
	FieldDescriptor? getDescriptor(String name) {
		try {
			final descs = descriptors;
			if (descs.isEmpty) return null;
			return descs.firstWhere((d) => d.name == name);
		} catch (e) {
			return null;
		}
	}

	/// Get typed field value by binding descriptor to storage value
	FieldDescriptor getFieldValue(String name) {
		final desc = getDescriptor(name);
		if (desc == null) return FieldDescriptor(name: name);
		return desc.withValue(values[name] as String?);
	}

	/// Helper to build field update map with automatic string conversion
	static Map<String, String> fieldValue(String name, dynamic value) {
		return {name: value.toString()};
	}

	/// Update multiple fields at once
	MapDataModel updateFields(Map<String, dynamic> updates) {
		var result = this;
		for (final entry in updates.entries) {
			result = result.updateField(entry.key, entry.value);
		}
		return result;
	}

	/// Register a field descriptor with this model
	/// Override in subclasses that support dynamic descriptor registration
	void registerDescriptor(FieldDescriptor descriptor) {
		// Default implementation - do nothing
		// Subclasses override if they support registration
	}
}
