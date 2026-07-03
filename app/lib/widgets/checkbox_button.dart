import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../providers/locale_provider.dart';
import '../services/localization.dart';
import '../models/field_descriptor.dart';
import '../models/map_data_model.dart';

/// Reusable checkbox button widget that uses AppColors and localization
/// Takes the current state and a callback to update it
/// Returns 0/1 instead of bool for database compatibility
class CheckboxButton extends ConsumerWidget {
	final bool isChecked;
	final String translationKey;
	final ValueChanged<int> onChanged; // Returns 0 or 1 instead of bool
	final EdgeInsets padding;
	final EdgeInsets margin;

	const CheckboxButton({
		Key? key,
		required this.isChecked,
		required this.translationKey,
		required this.onChanged,
		this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
		this.margin = const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
	}) : super(key: key);

	/// Create checkbox button for a field - pass descriptor with field definition
	/// Automatically registers descriptor with model
	static Widget forField({
		Key? key,
		required FieldDescriptor descriptor,
		required MapDataModel model,
		required WidgetRef ref,
		required dynamic provider,
		EdgeInsets padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
		EdgeInsets margin = const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
	}) {
		// Auto-register descriptor if model supports it
		_tryRegisterDescriptor(model, descriptor);

		return _CheckboxButtonDescriptor(
			key: key,
			descriptor: descriptor,
			model: model,
			provider: provider,
			padding: padding,
			margin: margin,
		);
	}

	static void _tryRegisterDescriptor(MapDataModel model, FieldDescriptor descriptor) {
		try {
			// Use reflection to call registerDescriptor on the model's class
			final type = model.runtimeType;
			final registerMethod = type.toString();
			// Try to register if supported by this model type
			if (registerMethod.contains('EndGameData') || registerMethod.contains('Data')) {
				(type as dynamic).registerDescriptor(descriptor);
			}
		} catch (e) {
			// If registration fails, the descriptor will be created on-demand in the widget
		}
	}

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		// Watch locale to trigger rebuild when language changes
		ref.watch(selectedLocaleProvider);
		final locale = ref.read(selectedLocaleProvider);
		final label = AppLocalizations.translate(translationKey, locale: locale);

		return Padding(
			padding: margin,
			child: Center(
				child: FilledButton(
					style: FilledButton.styleFrom(
						backgroundColor: isChecked
							? AppColors.buttonSelectedBgColor
							: AppColors.buttonBgColor,
						foregroundColor: AppColors.buttonFgColor,
						padding: padding,
						shape: RoundedRectangleBorder(
							borderRadius: BorderRadius.circular(8),
						),
					),
					onPressed: () => onChanged(isChecked ? 0 : 1), // Return 0 or 1 instead of bool
					child: Text(
						label,
						style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
					),
				),
			),
		);
	}
}

/// Internal widget for descriptor-based checkbox with Riverpod integration
class _CheckboxButtonDescriptor extends ConsumerStatefulWidget {
	final FieldDescriptor descriptor;
	final MapDataModel model;
	final dynamic provider;
	final EdgeInsets padding;
	final EdgeInsets margin;

	const _CheckboxButtonDescriptor({
		Key? key,
		required this.descriptor,
		required this.model,
		required this.provider,
		required this.padding,
		required this.margin,
	}) : super(key: key);

	@override
	ConsumerState<_CheckboxButtonDescriptor> createState() => _CheckboxButtonDescriptorState();
}

class _CheckboxButtonDescriptorState extends ConsumerState<_CheckboxButtonDescriptor> {
	late bool _localChecked;

	@override
	void initState() {
		super.initState();
		// Initialize local state from model
		final storageValue = widget.model.values[widget.descriptor.name] as String?;
		_localChecked = widget.descriptor.withValue(storageValue).asBool();
	}

	@override
	Widget build(BuildContext context) {
		final label = AppLocalizations.translate(
			widget.descriptor.uiLabel,
			locale: ref.read(selectedLocaleProvider),
		);

		return Padding(
			padding: widget.margin,
			child: Center(
				child: FilledButton(
					style: FilledButton.styleFrom(
						backgroundColor: _localChecked
							? AppColors.buttonSelectedBgColor
							: AppColors.buttonBgColor,
						foregroundColor: AppColors.buttonFgColor,
						padding: widget.padding,
						shape: RoundedRectangleBorder(
							borderRadius: BorderRadius.circular(8),
						),
					),
					onPressed: () {
						// Update local state immediately for UI feedback
						setState(() {
							_localChecked = !_localChecked;
						});
						// Update provider without triggering parent rebuild
						final updated = widget.model.updateField(
							widget.descriptor.name,
							_localChecked ? 1 : 0,
						);
						ref.read(widget.provider.notifier).update(updated);
					},
					child: Text(
						label,
						style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
					),
				),
			),
		);
	}
}
