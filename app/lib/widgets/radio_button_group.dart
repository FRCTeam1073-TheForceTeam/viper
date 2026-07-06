import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../providers/locale_provider.dart';
import '../services/localization.dart';
import '../models/field_descriptor.dart';

class RadioButtonOption {
	final String? value;
	final String labelKey;
	final String? descKey;

	const RadioButtonOption({
		required this.value,
		required this.labelKey,
		this.descKey,
	});
}

/// Reusable radio button group widget that matches CheckboxButton's look-and-feel
/// Each option renders as: [FilledButton] [Description Text]
/// Only one option can be selected at a time
class RadioButtonGroup extends ConsumerWidget {
	final List<RadioButtonOption> options;
	final String? selectedValue;
	final ValueChanged<String?> onChanged;
	final EdgeInsets padding;

	const RadioButtonGroup({
		Key? key,
		required this.options,
		required this.selectedValue,
		required this.onChanged,
		this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
	}) : super(key: key);

	/// Create a radio button group for a model field with automatic state binding
	static Widget forField({
		Key? key,
		required FieldDescriptor descriptor,
		required WidgetRef ref,
		required dynamic provider,
		required List<RadioButtonOption> options,
		EdgeInsets padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
	}) {
		final model = ref.watch(provider);
		final currentValue = model.getFieldValue(descriptor.name).asString();

		return RadioButtonGroup(
			key: key,
			options: options,
			selectedValue: currentValue,
			onChanged: (value) {
				final currentModel = ref.read(provider);
				final updated = currentModel.updateField(descriptor.name, value ?? '');
				ref.read(provider.notifier).update(updated);
			},
			padding: padding,
		);
	}

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		ref.watch(selectedLocaleProvider);
		final locale = ref.read(selectedLocaleProvider);

		// Check if any option has a description
		final hasDescriptions = options.any((option) => option.descKey != null);

		if (hasDescriptions) {
			// Use Column layout when there are descriptions
			return Column(
				children: options.map((option) {
					final isSelected = selectedValue == option.value;
					final label = AppLocalizations.translate(option.labelKey, locale: locale);
					final desc = option.descKey != null
						? AppLocalizations.translate(option.descKey!, locale: locale)
						: null;

					return Padding(
						padding: padding,
						child: Row(
							children: [
								FilledButton(
									style: FilledButton.styleFrom(
										backgroundColor: isSelected
											? AppColors.buttonSelectedBgColor
											: AppColors.buttonBgColor,
										foregroundColor: AppColors.buttonFgColor,
										padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(8),
										),
									),
									onPressed: () => onChanged(isSelected ? null : option.value),
									child: Text(
										label,
										style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
									),
								),
								if (desc != null) ...[
									const SizedBox(width: 12),
									Expanded(
										flex: 2,
										child: Text(
											desc,
											style: TextStyle(
												fontSize: 14,
												color: Theme.of(context).textTheme.bodyMedium?.color,
											),
										),
									),
								],
							],
						),
					);
				}).toList(),
			);
		} else {
			// Use Wrap layout when there are no descriptions
			return Wrap(
				spacing: 12,
				runSpacing: 12,
				children: options.map((option) {
					final isSelected = selectedValue == option.value;
					final label = AppLocalizations.translate(option.labelKey, locale: locale);

					return FilledButton(
						style: FilledButton.styleFrom(
							backgroundColor: isSelected
								? AppColors.buttonSelectedBgColor
								: AppColors.buttonBgColor,
							foregroundColor: AppColors.buttonFgColor,
							padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(8),
							),
						),
						onPressed: () => onChanged(isSelected ? null : option.value),
						child: Text(
							label,
							style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
						),
					);
				}).toList(),
			);
		}
	}
}
