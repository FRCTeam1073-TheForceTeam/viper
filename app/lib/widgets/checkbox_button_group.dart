import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../providers/locale_provider.dart';
import '../services/localization.dart';

class CheckboxButtonOption {
	final String labelKey;
	final String? descKey;

	const CheckboxButtonOption({
		required this.labelKey,
		this.descKey,
	});
}

/// Checkbox button group that displays checkboxes in a wrap layout
/// When there are no descriptions, buttons appear on one line and wrap as needed
class CheckboxButtonGroup extends ConsumerWidget {
	final List<CheckboxButtonOption> options;
	final List<bool> selectedValues;
	final ValueChanged<int> onChanged;

	const CheckboxButtonGroup({
		super.key,
		required this.options,
		required this.selectedValues,
		required this.onChanged,
	});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		ref.watch(selectedLocaleProvider);
		final locale = ref.read(selectedLocaleProvider);
		final hasDescriptions = options.any((o) => o.descKey != null);

		if (hasDescriptions) {
			// Use Column layout when there are descriptions
			return Column(
				children: List.generate(options.length, (index) {
					final option = options[index];
					final isChecked = selectedValues[index];
					final label = AppLocalizations.translate(option.labelKey, locale: locale);
					final desc = option.descKey != null
						? AppLocalizations.translate(option.descKey!, locale: locale)
						: null;

					return Padding(
						padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
						child: Row(
							children: [
								FilledButton(
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
				}),
			);
		} else {
			// Use Wrap layout when there are no descriptions
			return Wrap(
				spacing: 12,
				runSpacing: 12,
				children: List.generate(options.length, (index) {
					final option = options[index];
					final isChecked = selectedValues[index];
					final label = AppLocalizations.translate(option.labelKey, locale: locale);

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
}
