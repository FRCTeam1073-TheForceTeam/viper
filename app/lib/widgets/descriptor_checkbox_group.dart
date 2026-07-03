import 'package:flutter/material.dart';
import '../models/map_data_model.dart';
import '../models/ui_helper.dart';
import 'checkbox_button_group.dart';

/// Builds a checkbox group from a MapDataModel instance.
/// Automatically extracts checkbox values and translation keys from descriptors.
/// Eliminates hardcoded selectedValues arrays and switch statements.
class DescriptorCheckboxGroup extends StatelessWidget {
	final MapDataModel object;
	final Function(String fieldName, bool newValue) onChanged;

	const DescriptorCheckboxGroup({
		super.key,
		required this.object,
		required this.onChanged,
	});

	@override
	Widget build(BuildContext context) {
		// Filter to only checkbox-type boolean fields with UI labels
		final checkboxFields = UiHelper.getCheckboxDescriptors(object.descriptors);

		if (checkboxFields.isEmpty) {
			return const SizedBox.shrink();
		}

		// Build options from descriptors
		final options = checkboxFields.map((desc) {
			return CheckboxButtonOption(translationKey: desc.uiLabelKey!);
		}).toList();

		// Extract values automatically from object
		final selectedValues = UiHelper.getCheckboxValues(object);

		return CheckboxButtonGroup(
			options: options,
			selectedValues: selectedValues,
			onChanged: (index) {
				if (index >= 0 && index < checkboxFields.length) {
					final field = checkboxFields[index];
					final currentValue = selectedValues[index];
					onChanged(field.fieldName, !currentValue);
				}
			},
		);
	}
}
