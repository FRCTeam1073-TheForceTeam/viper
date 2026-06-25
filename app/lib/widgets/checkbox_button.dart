import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/localization.dart';

/// Reusable checkbox button widget that uses AppColors and localization
/// Takes the current state and a callback to update it
class CheckboxButton extends StatelessWidget {
	final bool isChecked;
	final String translationKey;
	final ValueChanged<bool> onChanged;
	final EdgeInsets padding;

	const CheckboxButton({
		Key? key,
		required this.isChecked,
		required this.translationKey,
		required this.onChanged,
		this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
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
				onPressed: () => onChanged(!isChecked),
				child: Text(
					context.t(translationKey),
					style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
				),
			),
		);
	}
}
