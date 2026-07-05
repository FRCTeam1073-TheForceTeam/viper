import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/scouting_data_provider.dart';
import '../../providers/undo_coordinator.dart';
import '../../../../providers/locale_provider.dart';
import '../../../../providers/floating_popup_provider.dart';
import '../../../../services/localization.dart';
import '../../../../constants/colors.dart';
import '../../../../widgets/counter_button_row.dart';

class TeleopTab extends ConsumerStatefulWidget {
	final String eventId;
	final String? matchNumber;
	final String? teamNumber;

	const TeleopTab({
		Key? key,
		required this.eventId,
		required this.matchNumber,
		required this.teamNumber,
	}) : super(key: key);

	@override
	ConsumerState<TeleopTab> createState() => _TeleopTabState();
}

class _TeleopTabState extends ConsumerState<TeleopTab> {
	late GlobalKey<State<StatefulWidget>> _undoButtonKey;

	String _translate(String key) {
		final locale = ref.read(selectedLocaleProvider);
		return AppLocalizations.translate(key, locale: locale);
	}

	@override
	void initState() {
		super.initState();
		_undoButtonKey = GlobalKey();

		// Register translations for this tab (reuse in_goal, in_depot, opened_gate, undo from auto)
		// Only add proceed_end_button
		AppLocalizations.addI18n({
			'proceed_end_button': {
				'en': 'End Game »',
				'es': 'Fin del juego »',
				'pt': 'Fim do jogo »',
				'fr': 'Fin de jeu »',
				'zh_tw': '遊戲結束 »',
				'he': 'סוף משחק »',
				'tr': 'Oyun Sonu »',
			},
		});
	}

	@override
	Widget build(BuildContext context) {
		ref.watch(selectedLocaleProvider);
		final scoutingData = ref.watch(scoutingDataProvider);

		return Stack(
			children: [
				SingleChildScrollView(
					padding: const EdgeInsets.all(16),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							FilledButton(
								key: _undoButtonKey,
								onPressed: () => undoLastAction(ref, context, _undoButtonKey),
								style: FilledButton.styleFrom(
									backgroundColor: AppColors.buttonBgColor,
									foregroundColor: AppColors.buttonFgColor,
								),
								child: Text(_translate('undo')),
							),
							const SizedBox(height: 16),
							CounterButtonRow(
								labelKey: 'in_goal',
								value: scoutingData.getFieldValue('tele_goal').asInt(),
								amounts: const [1, 2, 3],
								onAmountTapped: (amount, globalPos) {
									ref.read(scoutingDataProvider.notifier).recordTeleAction(field: 'tele_goal', value: amount);
									final stackBox = context.findRenderObject() as RenderBox?;
									if (stackBox != null) {
										final rel = globalPos - stackBox.localToGlobal(Offset.zero);
										ref.read(floatingPopupProvider.notifier).addPopup('+$amount', rel.dx, rel.dy);
									}
								},
							),
							CounterButtonRow(
								labelKey: 'in_depot',
								value: scoutingData.getFieldValue('tele_depot').asInt(),
								amounts: const [1, 2, 3],
								onAmountTapped: (amount, globalPos) {
									ref.read(scoutingDataProvider.notifier).recordTeleAction(field: 'tele_depot', value: amount);
									final stackBox = context.findRenderObject() as RenderBox?;
									if (stackBox != null) {
										final rel = globalPos - stackBox.localToGlobal(Offset.zero);
										ref.read(floatingPopupProvider.notifier).addPopup('+$amount', rel.dx, rel.dy);
									}
								},
							),
							CounterButtonRow(
								labelKey: 'opened_gate',
								value: scoutingData.getFieldValue('tele_gate').asInt(),
								amounts: const [1],
								onAmountTapped: (amount, globalPos) {
									ref.read(scoutingDataProvider.notifier).recordTeleAction(field: 'tele_gate', value: amount);
									final stackBox = context.findRenderObject() as RenderBox?;
									if (stackBox != null) {
										final rel = globalPos - stackBox.localToGlobal(Offset.zero);
										ref.read(floatingPopupProvider.notifier).addPopup('+$amount', rel.dx, rel.dy);
									}
								},
							),
							const SizedBox(height: 24),
							FilledButton(
								style: FilledButton.styleFrom(
									backgroundColor: AppColors.buttonBgColor,
									foregroundColor: AppColors.buttonFgColor,
								),
								onPressed: () {}, // wired by scouting_app_screen.dart
								child: Text(_translate('proceed_end_button')),
							),
						],
					),
				),
				// PopupFloater stack
				PopupFloaterWidget(),
			],
		);
	}
}

/// Simple popup floater for the +N animations
class PopupFloaterWidget extends ConsumerWidget {
	const PopupFloaterWidget({super.key});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final floatingPopups = ref.watch(floatingPopupProvider);

		return Stack(
			children: floatingPopups.map((popup) {
				return Positioned(
					left: popup.initialX,
					top: popup.initialY,
					child: Text(
						popup.text,
						style: const TextStyle(
							fontSize: 20,
							fontWeight: FontWeight.bold,
							color: Colors.green,
						),
					),
				);
			}).toList(),
		);
	}
}
