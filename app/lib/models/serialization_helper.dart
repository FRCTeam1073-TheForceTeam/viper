import 'field_descriptor.dart';

/// Generic serialization helpers using field descriptors.
/// Convert between objects and CSV-compatible maps without repetition.

class SerializationHelper {
	/// Convert object field values to a CSV map using descriptors.
	/// Example: data value → {'shoot_move': value}
	static Map<String, dynamic> toMap(
		List<FieldDescriptor> descriptors,
		Map<String, dynamic> values,
	) {
		final result = <String, dynamic>{};
		for (final desc in descriptors) {
			final value = values[desc.name];
			if (value != null) {
				result[desc.name] = value;
			}
		}
		return result;
	}

	/// Convert a CSV map to object field values using descriptors.
	/// Example: {'shoot_move': '1'} -> 'shoot_move': '1' (stored as string)
	static Map<String, dynamic> fromMap(
		List<FieldDescriptor> descriptors,
		Map<String, dynamic> csvData,
	) {
		final result = <String, dynamic>{};
		for (final desc in descriptors) {
			final csvValue = csvData[desc.name];
			if (csvValue != null) {
				result[desc.name] = csvValue.toString();
			}
		}
		return result;
	}

	/// Helper: extract typed values from a Map<String, dynamic>.
	static T? getFieldValue<T>(Map<String, dynamic> map, String key) {
		final value = map[key];
		if (value is T) return value;
		return null;
	}

	/// Convert a values map directly to CSV map (for MapDataModel).
	/// Used when the object's fields are already stored in a map.
	static Map<String, dynamic> toMapFromMapObject(
		List<FieldDescriptor> descriptors,
		Map<String, dynamic> values,
	) {
		final result = <String, dynamic>{};
		for (final desc in descriptors) {
			final value = values[desc.name];
			if (value != null) {
				result[desc.name] = value;
			}
		}
		return result;
	}
}
