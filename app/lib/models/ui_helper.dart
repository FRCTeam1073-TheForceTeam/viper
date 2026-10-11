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
			if (desc.uiLabelKey != null) {
				// Parse bool value from string storage
				final strValue = object.values[desc.name] as String?;
				values.add(desc.withValue(strValue).asBool());
			}
		}
		return values;
	}

	/// Extract checkbox fields (those with uiLabelKey) as a filtered list of descriptors.
	static List<FieldDescriptor> getCheckboxDescriptors(
		List<FieldDescriptor> descriptors,
	) {
		return descriptors
				.where((d) => d.uiLabelKey != null)
				.toList();
	}
}
