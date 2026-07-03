import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../services/localization.dart';
import '../models/field_descriptor.dart';
import '../models/map_data_model.dart';

/// Reusable single-line text field widget that uses field descriptors
class DescriptorTextField extends ConsumerWidget {
	final String initialValue;
	final String labelTranslationKey;
	final ValueChanged<String> onChanged;
	final EdgeInsets padding;
	final int? maxLength;

	const DescriptorTextField({
		Key? key,
		required this.initialValue,
		required this.labelTranslationKey,
		required this.onChanged,
		this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
		this.maxLength,
	}) : super(key: key);

	/// Create text field for a field - pass descriptor with field definition
	static Widget forField({
		Key? key,
		required FieldDescriptor descriptor,
		required MapDataModel model,
		required WidgetRef ref,
		required dynamic provider,
		EdgeInsets padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
		int? maxLength,
	}) {
		_tryRegisterDescriptor(model, descriptor);

		return _DescriptorTextFieldDescriptor(
			key: key,
			descriptor: descriptor,
			model: model,
			provider: provider,
			padding: padding,
			maxLength: maxLength,
		);
	}

	static void _tryRegisterDescriptor(MapDataModel model, FieldDescriptor descriptor) {
		model.registerDescriptor(descriptor);
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
	final MapDataModel model;
	final dynamic provider;
	final EdgeInsets padding;
	final int? maxLength;

	const _DescriptorTextFieldDescriptor({
		Key? key,
		required this.descriptor,
		required this.model,
		required this.provider,
		required this.padding,
		required this.maxLength,
	}) : super(key: key);

	@override
	ConsumerState<_DescriptorTextFieldDescriptor> createState() => _DescriptorTextFieldDescriptorState();
}

class _DescriptorTextFieldDescriptorState extends ConsumerState<_DescriptorTextFieldDescriptor> {
	late TextEditingController _controller;

	@override
	void initState() {
		super.initState();
		final storageValue = widget.model.values[widget.descriptor.name] as String?;
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
					final updated = widget.model.updateField(widget.descriptor.name, value);
					ref.read(widget.provider.notifier).update(updated);
				},
			),
		);
	}
}
