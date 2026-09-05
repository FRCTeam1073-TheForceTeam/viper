import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../providers/global_scouting_data.dart';
import '../services/localization.dart';
import '../models/field_descriptor.dart';

/// Reusable single-line text field widget that uses field descriptors
class DescriptorTextField extends ConsumerWidget {
	final String initialValue;
	final String labelTranslationKey;
	final ValueChanged<String> onChanged;
	final EdgeInsets padding;
	final int? maxLength;

	const DescriptorTextField({
		super.key,
		required this.initialValue,
		required this.labelTranslationKey,
		required this.onChanged,
		this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
		this.maxLength,
	});

	/// Create text field for a field - pass descriptor with field definition
	static Widget forField({
		Key? key,
		required FieldDescriptor descriptor,
		required WidgetRef ref,
		required dynamic provider,
		EdgeInsets padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
		int? maxLength,
	}) {
		return _DescriptorTextFieldDescriptor(
			key: key,
			descriptor: descriptor,
			provider: provider,
			padding: padding,
			maxLength: maxLength,
		);
	}

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		ref.watch(selectedLocaleProvider);
		final locale = ref.read(selectedLocaleProvider);
		final label = AppLocalizations.translate(labelTranslationKey, locale: locale);

		return Padding(
			padding: padding,
			child: TextField(
				decoration: InputDecoration(
					labelText: label,
					border: OutlineInputBorder(
						borderRadius: BorderRadius.circular(8),
					),
					contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
				),
				maxLength: maxLength,
				onChanged: onChanged,
			),
		);
	}
}

/// Internal widget for descriptor-based text field with Riverpod integration
class _DescriptorTextFieldDescriptor extends ConsumerStatefulWidget {
	final FieldDescriptor descriptor;
	final dynamic provider;
	final EdgeInsets padding;
	final int? maxLength;

	const _DescriptorTextFieldDescriptor({
		super.key,
		required this.descriptor,
		required this.provider,
		required this.padding,
		required this.maxLength,
	});

	@override
	ConsumerState<_DescriptorTextFieldDescriptor> createState() => _DescriptorTextFieldDescriptorState();
}

class _DescriptorTextFieldDescriptorState extends ConsumerState<_DescriptorTextFieldDescriptor> {
	late TextEditingController _controller;

	@override
	void initState() {
		super.initState();
		final model = getGlobalScoutingData();
		final storageValue = model?.values[widget.descriptor.name] as String?;
		_controller = TextEditingController(text: storageValue ?? '');
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final label = AppLocalizations.translate(
			widget.descriptor.uiLabel,
			locale: ref.read(selectedLocaleProvider),
		);

		return Padding(
			padding: widget.padding,
			child: TextField(
				controller: _controller,
				decoration: InputDecoration(
					labelText: label,
					border: OutlineInputBorder(
						borderRadius: BorderRadius.circular(8),
					),
					contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
				),
				maxLength: widget.maxLength,
				onChanged: (value) {
					final model = getGlobalScoutingData();
					if (model != null) {
						final updated = model.updateField(widget.descriptor.name, value);
						ref.read(widget.provider.notifier).update(updated);
					}
				},
			),
		);
	}
}
