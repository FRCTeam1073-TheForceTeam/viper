import 'field_descriptor.dart';
import 'map_data_model.dart';

/// Helper to generate UI-specific data from field descriptors.
class UiHelper {
	/// Extract checkbox values in the order of UI-checkable fields.
	/// Returns a list of boolean values corresponding to fields with uiLabelKey.
	/// Works with MapDataModel instances (uses typed getters).
	static List<bool> getCheckboxValues(
		MapDataModel object,
	) {
		final values = <bool>[];
		for (final desc in object.descriptors) {
			if (desc.uiLabelKey != null && desc.type == FieldType.bool) {
				final value = object.values[desc.fieldName] as bool? ?? false;
				values.add(value);
			}
		}
		return values;
	}

	/// Extract checkbox fields (those with uiLabelKey) as a filtered list of descriptors.
	static List<FieldDescriptor> getCheckboxDescriptors(
		List<FieldDescriptor> descriptors,
	) {
		return descriptors
				.where((d) => d.uiLabelKey != null && d.type == FieldType.bool)
				.toList();
	}
}
