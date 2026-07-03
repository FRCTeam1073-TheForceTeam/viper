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

	/// Helper: get typed value from map with default
	T getTyped<T>(String fieldName, T defaultValue) {
		final value = values[fieldName];
		if (value is T) return value;
		return defaultValue;
	}
}
