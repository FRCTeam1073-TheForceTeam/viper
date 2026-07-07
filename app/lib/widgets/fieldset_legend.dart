import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../services/localization.dart';
import '../constants/colors.dart';

class FieldsetLegend extends ConsumerWidget {
	final Widget child;
	final String legendKey;

	const FieldsetLegend({
		super.key,
		required this.child,
		required this.legendKey,
	});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final locale = ref.watch(selectedLocaleProvider);
		final legendText = AppLocalizations.translate(legendKey, locale: locale);

		return Stack(
			clipBehavior: Clip.none,
			children: [
				Container(
					width: double.infinity,
					decoration: BoxDecoration(
						border: Border.all(color: AppColors.mainBorderColor, width: 1),
						borderRadius: BorderRadius.circular(8),
					),
					padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
					child: child,
				),
				Positioned(
					top: -7,
					left: 16,
					child: Container(
						color: AppColors.mainBgColor,
						padding: const EdgeInsets.symmetric(horizontal: 8),
						child: Text(
							legendText,
							style: const TextStyle(fontSize: 14, color: AppColors.mainFgColor),
						),
					),
				),
			],
		);
	}
}
