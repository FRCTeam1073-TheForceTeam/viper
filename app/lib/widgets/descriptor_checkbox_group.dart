import 'package:flutter/material.dart';
import '../models/field_descriptor.dart';
import '../models/map_data_model.dart';
import '../models/ui_helper.dart';
import 'checkbox_button_group.dart';

/// Builds a checkbox group from a MapDataModel instance.
/// Automatically extracts checkbox values and translation keys from descriptors.
/// Eliminates hardcoded selectedValues arrays and switch statements.
class DescriptorCheckboxGroup extends StatelessWidget {
	final MapDataModel object;
	final Function(String fieldName, bool newValue) onChanged;
	final List<FieldDescriptor> _descriptors;

	const DescriptorCheckboxGroup({
		super.key,
		required this.object,
		required this.onChanged,
	}) : _descriptors = const [];

	// Private constructor for forFields factory
	const DescriptorCheckboxGroup._({
		super.key,
		required this.object,
		required this.onChanged,
		required List<FieldDescriptor> descriptors,
	}) : _descriptors = descriptors;

	/// Create a checkbox group with inline descriptors
	/// Automatically registers descriptors with the model
	static Widget forFields({
		Key? key,
		required MapDataModel object,
		required List<FieldDescriptor> descriptors,
		required Function(String fieldName, bool newValue) onChanged,
	}) {
		// Auto-register all descriptors
		_registerDescriptors(object, descriptors);

		return DescriptorCheckboxGroup._(
			key: key,
			object: object,
			onChanged: onChanged,
			descriptors: descriptors,
		);
	}

	static void _registerDescriptors(MapDataModel object, List<FieldDescriptor> descriptors) {
		// Register descriptors with the model instance
		for (final descriptor in descriptors) {
			object.registerDescriptor(descriptor);
		}
	}

	@override
	Widget build(BuildContext context) {
		// Use provided descriptors or filter from object
		final checkboxFields = _descriptors.isNotEmpty
			? _descriptors
			: UiHelper.getCheckboxDescriptors(object.descriptors);

		if (checkboxFields.isEmpty) {
			return const SizedBox.shrink();
		}

		// Build options from descriptors
		final options = checkboxFields.map((desc) {
			return CheckboxButtonOption(
				labelKey: desc.uiLabelKey ?? desc.name,
				descKey: desc.descriptionLabelKey,
			);
		}).toList();

		// Extract values automatically from object
		final selectedValues = checkboxFields.map((desc) {
			final strValue = object.values[desc.name] as String?;
			return desc.withValue(strValue).asBool();
		}).toList();

		return CheckboxButtonGroup(
			options: options,
			selectedValues: selectedValues,
			onChanged: (index) {
				if (index >= 0 && index < checkboxFields.length) {
					final field = checkboxFields[index];
					final currentValue = selectedValues[index];
					onChanged(field.name, !currentValue);
				}
			},
		);
	}
}
