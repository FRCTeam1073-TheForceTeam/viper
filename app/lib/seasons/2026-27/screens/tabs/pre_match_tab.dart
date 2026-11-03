import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../strings.dart';
import '../../widgets/piece_counter.dart';
import '../../../../providers/locale_provider.dart';
import '../../../../services/localization.dart';
import '../../../../constants/colors.dart';

class PreMatchTab extends ConsumerStatefulWidget {
	final String eventId;
	final String? matchNumber;
	final String? teamNumber;
	final String eventName;
	final String? botPosition;
	final VoidCallback? onProceedToAuto;

	const PreMatchTab({
		super.key,
		required this.eventId,
		required this.matchNumber,
		required this.teamNumber,
		required this.eventName,
		this.botPosition,
		this.onProceedToAuto,
	});

	@override
	ConsumerState<PreMatchTab> createState() => _PreMatchTabState();
}

class _PreMatchTabState extends ConsumerState<PreMatchTab> {
	String _t(String key) => AppLocalizations.translate(key, locale: ref.read(selectedLocaleProvider));

	@override
	void initState() {
		super.initState();
		registerSeasonStrings();
	}

	@override
	Widget build(BuildContext context) {
		ref.watch(selectedLocaleProvider);

		return SingleChildScrollView(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [
					Align(
						alignment: Alignment.centerLeft,
						child: TimelineCheckbox(
							field: 'no_show',
							labelKey: 'no_show',
						),
					),
					const SizedBox(height: 24),
					Row(
						mainAxisAlignment: MainAxisAlignment.end,
						children: [
							FilledButton(
								style: FilledButton.styleFrom(
									backgroundColor: AppColors.buttonBgColor,
									foregroundColor: AppColors.buttonFgColor,
									shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
								),
								onPressed: widget.onProceedToAuto,
								child: Text(_t('proceed_auto_button')),
							),
						],
					),
				],
			),
		);
	}
}
