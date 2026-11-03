import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/colors.dart';
import '../../../providers/floating_popup_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../services/localization.dart';
import '../../../widgets/popup_floater.dart';
import '../providers/scouting_data_provider.dart';

/// One tappable counter: an icon button with its count beside it.
/// When [enabled] is false the button is dimmed and does not respond (web: the disabledOverlay).
class PieceCounter extends StatelessWidget {
	final GlobalKey buttonKey;
	final Widget icon;
	final int value;
	final bool enabled;
	final VoidCallback onTap;

	const PieceCounter({
		super.key,
		required this.buttonKey,
		required this.icon,
		required this.value,
		required this.enabled,
		required this.onTap,
	});

	@override
	Widget build(BuildContext context) {
		return Opacity(
			opacity: enabled ? 1 : 0.35,
			child: Row(
				mainAxisSize: MainAxisSize.min,
				children: [
					FilledButton(
						key: buttonKey,
						onPressed: enabled ? onTap : null,
						style: FilledButton.styleFrom(
							backgroundColor: AppColors.buttonBgColor,
							foregroundColor: AppColors.buttonFgColor,
							minimumSize: const Size(56, 48),
							padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
						),
						child: icon,
					),
					SizedBox(
						width: 36,
						child: Text(
							value.toString(),
							textAlign: TextAlign.center,
							style: Theme.of(context).textTheme.bodyLarge?.copyWith(
								fontWeight: FontWeight.bold,
							),
						),
					),
				],
			),
		);
	}
}

/// A table row: a counter on the left, a label in the middle, and a counter on the right.
/// Either side can be empty.
class PieceCounterRow extends StatelessWidget {
	final String label;
	final Widget? left;
	final Widget? right;

	const PieceCounterRow({
		super.key,
		required this.label,
		this.left,
		this.right,
	});

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 6),
			child: Row(
				children: [
					Expanded(child: Align(alignment: Alignment.centerLeft, child: left ?? const SizedBox())),
					Expanded(
						child: Text(
							label,
							textAlign: TextAlign.center,
							style: Theme.of(context).textTheme.bodyMedium,
						),
					),
					Expanded(child: Align(alignment: Alignment.centerRight, child: right ?? const SizedBox())),
				],
			),
		);
	}
}

/// Checkbox that is recorded on the timeline (or removed from it when unchecked).
/// Reads its value from the provider, so an undo updates it.
class TimelineCheckbox extends ConsumerWidget {
	final String field;
	final String labelKey;
	final VoidCallback? onBeforeToggle;

	const TimelineCheckbox({
		super.key,
		required this.field,
		required this.labelKey,
		this.onBeforeToggle,
	});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final locale = ref.watch(selectedLocaleProvider);
		final checked = ref.watch(scoutingDataProvider).getFieldValue(field).asBool();
		final label = AppLocalizations.translate(labelKey, locale: locale);

		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 8),
			child: FilledButton(
				style: FilledButton.styleFrom(
					backgroundColor: checked ? AppColors.buttonSelectedBgColor : AppColors.buttonBgColor,
					foregroundColor: AppColors.buttonFgColor,
					padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
				),
				onPressed: () {
					onBeforeToggle?.call();
					ref.read(scoutingDataProvider.notifier).toggleCheckbox(
						field: field,
						checked: !checked,
					);
				},
				child: Text(
					label,
					style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
				),
			),
		);
	}
}

/// Draws the "+1" and "-1" floaters. Place it last in a Stack so it sits on top of the tab.
class PopupFloaterLayer extends ConsumerWidget {
	const PopupFloaterLayer({super.key});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final floatingPopups = ref.watch(floatingPopupProvider);

		return Stack(
			children: floatingPopups.map((popup) {
				return PopupFloater(
					text: popup.text,
					initialX: popup.initialX,
					initialY: popup.initialY,
					onAnimationComplete: () {
						ref.read(floatingPopupProvider.notifier).removePopup(popup.id);
					},
				);
			}).toList(),
		);
	}
}
