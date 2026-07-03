import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../services/localization.dart';
import '../models/field_descriptor.dart';
import '../models/map_data_model.dart';

/// Reusable multi-line text area widget that uses field descriptors
class DescriptorTextArea extends ConsumerWidget {
	final String initialValue;
	final String labelTranslationKey;
	final ValueChanged<String> onChanged;
	final EdgeInsets padding;
	final int minLines;
	final int maxLines;

	const DescriptorTextArea({
		Key? key,
		required this.initialValue,
		required this.labelTranslationKey,
		required this.onChanged,
		this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
		this.minLines = 3,
		this.maxLines = 8,
	}) : super(key: key);

	/// Create text area for a field - pass descriptor with field definition
	static Widget forField({
		Key? key,
		required FieldDescriptor descriptor,
		required MapDataModel model,
		required WidgetRef ref,
		required dynamic provider,
		EdgeInsets padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
		int minLines = 3,
		int maxLines = 8,
	}) {
		_tryRegisterDescriptor(model, descriptor);

		return _DescriptorTextAreaDescriptor(
			key: key,
			descriptor: descriptor,
			model: model,
			provider: provider,
			padding: padding,
			minLines: minLines,
			maxLines: maxLines,
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
				minLines: minLines,
				maxLines: maxLines,
				onChanged: onChanged,
			),
		);
	}
}

/// Internal widget for descriptor-based text area with Riverpod integration
class _DescriptorTextAreaDescriptor extends ConsumerStatefulWidget {
	final FieldDescriptor descriptor;
	final MapDataModel model;
	final dynamic provider;
	final EdgeInsets padding;
	final int minLines;
	final int maxLines;

	const _DescriptorTextAreaDescriptor({
		Key? key,
		required this.descriptor,
		required this.model,
		required this.provider,
		required this.padding,
		required this.minLines,
		required this.maxLines,
	}) : super(key: key);

	@override
	ConsumerState<_DescriptorTextAreaDescriptor> createState() => _DescriptorTextAreaDescriptorState();
}

class _DescriptorTextAreaDescriptorState extends ConsumerState<_DescriptorTextAreaDescriptor> {
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
				minLines: widget.minLines,
				maxLines: widget.maxLines,
				onChanged: (value) {
					final updated = widget.model.updateField(widget.descriptor.name, value);
					ref.read(widget.provider.notifier).update(updated);
				},
			),
		);
	}
}
