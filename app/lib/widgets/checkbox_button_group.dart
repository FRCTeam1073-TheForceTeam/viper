import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../providers/locale_provider.dart';
import '../services/localization.dart';

class CheckboxButtonOption {
	final String translationKey;

	const CheckboxButtonOption({
		required this.translationKey,
	});
}

/// Checkbox button group that displays checkboxes in a wrap layout
/// When there are no descriptions, buttons appear on one line and wrap as needed
class CheckboxButtonGroup extends ConsumerWidget {
	final List<CheckboxButtonOption> options;
	final List<bool> selectedValues;
	final ValueChanged<int> onChanged;

	const CheckboxButtonGroup({
		Key? key,
		required this.options,
		required this.selectedValues,
		required this.onChanged,
	}) : super(key: key);

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		ref.watch(selectedLocaleProvider);
		final locale = ref.read(selectedLocaleProvider);

		return Wrap(
			spacing: 12,
			runSpacing: 12,
			children: List.generate(options.length, (index) {
				final option = options[index];
				final isChecked = selectedValues[index];
				final label = AppLocalizations.translate(option.translationKey, locale: locale);

				return FilledButton(
					style: FilledButton.styleFrom(
						backgroundColor: isChecked
							? AppColors.buttonSelectedBgColor
							: AppColors.buttonBgColor,
						foregroundColor: AppColors.buttonFgColor,
						padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
						shape: RoundedRectangleBorder(
							borderRadius: BorderRadius.circular(8),
						),
					),
					onPressed: () => onChanged(index),
					child: Text(
						label,
						style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
					),
				);
			}),
		);
	}
}
