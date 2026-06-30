import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../providers/locale_provider.dart';
import '../services/localization.dart';

/// Reusable checkbox button widget that uses AppColors and localization
/// Takes the current state and a callback to update it
/// Returns 0/1 instead of bool for database compatibility
class CheckboxButton extends ConsumerWidget {
	final bool isChecked;
	final String translationKey;
	final ValueChanged<int> onChanged; // Returns 0 or 1 instead of bool
	final EdgeInsets padding;

	const CheckboxButton({
		Key? key,
		required this.isChecked,
		required this.translationKey,
		required this.onChanged,
		this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
	}) : super(key: key);

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		// Watch locale to trigger rebuild when language changes
		ref.watch(selectedLocaleProvider);
		final locale = ref.read(selectedLocaleProvider);
		final label = AppLocalizations.translate(translationKey, locale: locale);

		return Center(
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
		);
	}
}
