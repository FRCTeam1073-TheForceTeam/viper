import 'field_descriptor.dart';

/// Generic serialization helpers using field descriptors.
/// Convert between objects and CSV-compatible maps without repetition.

class SerializationHelper {
	/// Convert object to CSV map using descriptors and getters.
	/// Eliminates the need to pass a values map - uses descriptor getters.
	/// Example: toMapFromObject(descriptors, endGameData) extracts all fields automatically
	static Map<String, dynamic> toMapFromObject(
		List<FieldDescriptor> descriptors,
		dynamic object,
	) {
		final result = <String, dynamic>{};
		for (final desc in descriptors) {
			if (desc.getter == null) {
				throw ArgumentError(
					'Descriptor for ${desc.fieldName} has no getter. '
					'Add getter: (obj) => obj.${desc.fieldName}',
				);
			}
			final value = desc.getter!(object);
			final csvValue = desc.toCsv(value);
			if (csvValue != null) {
				result[desc.csvKey] = csvValue;
			}
		}
		return result;
	}

	/// Convert object field values to a CSV map using descriptors.
	/// Kept for backwards compatibility. Prefer toMapFromObject.
	/// Example: endGameData.shootOnMove (bool) → {'shoot_move': 1}
	static Map<String, dynamic> toMap(
		List<FieldDescriptor> descriptors,
		Map<String, dynamic> values,
	) {
		final result = <String, dynamic>{};
		for (final desc in descriptors) {
			final value = values[desc.fieldName];
			final csvValue = desc.toCsv(value);
			if (csvValue != null) {
				result[desc.csvKey] = csvValue;
			}
		}
		return result;
	}

	/// Convert a CSV map to object field values using descriptors.
	/// Example: {'shoot_move': 1} -> shootOnMove (bool true)
	static Map<String, dynamic> fromMap(
		List<FieldDescriptor> descriptors,
		Map<String, dynamic> csvData,
	) {
		final result = <String, dynamic>{};
		for (final desc in descriptors) {
			final csvValue = csvData[desc.csvKey];
			result[desc.fieldName] = desc.fromCsv(csvValue);
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
			final value = values[desc.fieldName];
			final csvValue = desc.toCsv(value);
			if (csvValue != null) {
				result[desc.csvKey] = csvValue;
			}
		}
		return result;
	}
}
