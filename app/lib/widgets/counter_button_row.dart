import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../services/localization.dart';
import '../constants/colors.dart';

/// Reusable counter button row: label + tappable amount buttons + numeric readout
/// Each button reports its own global tap position via callback for the caller's floating-popup math
class CounterButtonRow extends ConsumerWidget {
	final String labelKey;
	final int value;
	final List<int> amounts; // e.g. const [1,2,3] or const [1]
	final void Function(int amount, Offset globalPosition) onAmountTapped;
	final EdgeInsets padding;

	const CounterButtonRow({
		super.key,
		required this.labelKey,
		required this.value,
		required this.onAmountTapped,
		this.amounts = const [1, 2, 3],
		this.padding = const EdgeInsets.symmetric(vertical: 8),
	});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		ref.watch(selectedLocaleProvider);
		final locale = ref.read(selectedLocaleProvider);
		final label = AppLocalizations.translate(labelKey, locale: locale);

		return Padding(
			padding: padding,
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: [
					// Label
					Expanded(
						flex: 2,
						child: Text(
							label,
							style: Theme.of(context).textTheme.bodyMedium,
						),
					),
					const SizedBox(width: 8),
					// Amount buttons
					Expanded(
						flex: 3,
						child: Wrap(
							spacing: 8,
							children: amounts.map((amount) {
								return SizedBox(
									width: 50,
									child: FilledButton(
										style: FilledButton.styleFrom(
											backgroundColor: AppColors.buttonBgColor,
											foregroundColor: AppColors.buttonFgColor,
											padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
											shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(8),
											),
										),
										onPressed: () {
											final renderBox = context.findRenderObject() as RenderBox?;
											if (renderBox != null) {
												final globalPos = renderBox.localToGlobal(Offset.zero);
												onAmountTapped(amount, globalPos);
											}
										},
										child: Text(
											'+$amount',
											style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
										),
									),
								);
							}).toList(),
						),
					),
					const SizedBox(width: 8),
					// Numeric readout
					SizedBox(
						width: 40,
						child: Text(
							value.toString(),
							textAlign: TextAlign.right,
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
