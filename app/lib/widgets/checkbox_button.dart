import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../providers/locale_provider.dart';
import '../services/localization.dart';
import '../models/field_descriptor.dart';

/// Checkbox button widget that manages its own state
class CheckboxButton extends ConsumerStatefulWidget {
	final FieldDescriptor descriptor;
	final dynamic provider;
	final EdgeInsets padding;
	final EdgeInsets margin;

	const CheckboxButton({
		Key? key,
		required this.descriptor,
		required this.provider,
		this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
		this.margin = const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
	}) : super(key: key);

	@override
	ConsumerState<CheckboxButton> createState() => _CheckboxButtonState();
}

class _CheckboxButtonState extends ConsumerState<CheckboxButton> {
	late bool _isChecked;

	@override
	void initState() {
		super.initState();
		final model = ref.read(widget.provider);
		final storageValue = model.values[widget.descriptor.name] as String?;
		_isChecked = widget.descriptor.withValue(storageValue).asBool();
	}

	void _onPressed() {
		setState(() {
			_isChecked = !_isChecked;
		});
		final model = ref.read(widget.provider);
		final updated = model.updateField(widget.descriptor.name, _isChecked ? 1 : 0);
		ref.read(widget.provider.notifier).update(updated);
	}

	@override
	Widget build(BuildContext context) {
		final locale = ref.read(selectedLocaleProvider);
		final label = AppLocalizations.translate(
			widget.descriptor.uiLabel,
			locale: locale,
		);

		return Padding(
			padding: widget.margin,
			child: Center(
				child: _buildButtonContent(
					locale: locale,
					label: label,
					isChecked: _isChecked,
					descriptor: widget.descriptor,
					onPressed: _onPressed,
					padding: widget.padding,
				),
			),
		);
	}

	Widget _buildButtonContent({
		required Locale locale,
		required String label,
		required bool isChecked,
		required FieldDescriptor descriptor,
		required VoidCallback onPressed,
		required EdgeInsets padding,
	}) {
		// Handle image-based checkbox
		if (descriptor.imagePath != null) {
			final btnWidth = descriptor.width ?? 80.0;
			final btnHeight = descriptor.height ?? 80.0;

			return GestureDetector(
				onTap: onPressed,
				child: Container(
					width: btnWidth,
					height: btnHeight,
					decoration: BoxDecoration(
						borderRadius: BorderRadius.circular(8),
						color: isChecked
							? AppColors.buttonSelectedBgColor
							: AppColors.buttonBgColor,
						boxShadow: [
							BoxShadow(
								color: Colors.black.withValues(alpha: 0.3),
								blurRadius: 4,
								offset: const Offset(0, 2),
							),
						],
					),
					child: Image.asset(
						descriptor.imagePath!,
						fit: BoxFit.contain,
					),
				),
			);
		}

		// Handle text-based checkbox
		return FilledButton(
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
			onPressed: onPressed,
			child: Text(
				label,
				style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
			),
		);
	}
}
