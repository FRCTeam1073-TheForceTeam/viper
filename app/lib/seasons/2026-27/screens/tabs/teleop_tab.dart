import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/scouting_data_provider.dart';
import '../../providers/undo_coordinator.dart';
import '../../strings.dart';
import '../../widgets/piece_counter.dart';
import '../../../../providers/app_providers.dart';
import '../../../../providers/floating_popup_provider.dart';
import '../../../../providers/locale_provider.dart';
import '../../../../providers/timeline_provider.dart';
import '../../../../services/localization.dart';
import '../../../../constants/colors.dart';

class TeleopTab extends ConsumerStatefulWidget {
	final String eventId;
	final String? matchNumber;
	final String? teamNumber;
	final VoidCallback onProceedToEndGame;

	const TeleopTab({
		super.key,
		required this.eventId,
		required this.matchNumber,
		required this.teamNumber,
		required this.onProceedToEndGame,
	});

	@override
	ConsumerState<TeleopTab> createState() => _TeleopTabState();
}

class _TeleopTabState extends ConsumerState<TeleopTab> {
	final GlobalKey _undoButtonKey = GlobalKey();
	final GlobalKey _stackKey = GlobalKey();
	final Map<String, GlobalKey> _fieldKeys = {};

	GlobalKey _keyFor(String field) => _fieldKeys.putIfAbsent(field, () => GlobalKey());

	String _t(String key) => AppLocalizations.translate(key, locale: ref.read(selectedLocaleProvider));

	@override
	void initState() {
		super.initState();
		registerSeasonStrings();
	}

	/// Stack-relative position of a counter's button, used for its floater
	Offset? _positionOf(String field) {
		final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
		final fieldBox = _fieldKeys[field]?.currentContext?.findRenderObject() as RenderBox?;
		if (stackBox == null || fieldBox == null) return null;
		return fieldBox.localToGlobal(Offset.zero) - stackBox.localToGlobal(Offset.zero);
	}

	void _tap(String field) {
		ref.read(scoutingDataProvider.notifier).recordAction(field: field);
		final pos = _positionOf(field);
		if (pos != null) {
			ref.read(floatingPopupProvider.notifier).addPopup('+1', pos.dx, pos.dy);
		}
	}

	@override
	Widget build(BuildContext context) {
		ref.watch(selectedLocaleProvider);
		final scoutingData = ref.watch(scoutingDataProvider);
		final timeline = ref.watch(timelineProvider);
		final botPosition = ref.watch(selectedBotPositionProvider);
		final isBlueTeam = botPosition?.startsWith('B') ?? false;
		final nectarIcon = Image.asset(
			isBlueTeam ? 'assets/2026-27/images/nectar-blue.png' : 'assets/2026-27/images/nectar-red.png',
			height: 28,
		);
		final pollenIcon = Image.asset('assets/2026-27/images/pollen.png', height: 28);

		final held = computeHeld(scoutingData);
		int v(String field) => scoutingData.getFieldValue(field).asInt();

		return Stack(
			key: _stackKey,
			children: [
				SingleChildScrollView(
					padding: const EdgeInsets.all(16),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							Align(
								alignment: Alignment.centerLeft,
								child: FilledButton(
									key: _undoButtonKey,
									onPressed: () => undoLastAction(
										ref,
										context,
										_undoButtonKey,
										getUndoPosition: _positionOf,
									),
									style: FilledButton.styleFrom(
										backgroundColor: AppColors.buttonBgColor,
										foregroundColor: AppColors.buttonFgColor,
									),
									child: Text(_t('undo')),
								),
							),
							const SizedBox(height: 8),
							Row(
								children: [
									Expanded(child: Center(child: Text(_t('pollen'), style: Theme.of(context).textTheme.titleSmall))),
									const Expanded(child: SizedBox()),
									Expanded(child: Center(child: Text(_t('nectar'), style: Theme.of(context).textTheme.titleSmall))),
								],
							),
							Row(
								children: [
									Expanded(
										child: Center(
											child: Text(
												'${held.pollen}',
												style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
											),
										),
									),
									Expanded(
										child: Center(
											child: Text(
												_t('held'),
												style: Theme.of(context).textTheme.bodySmall,
											),
										),
									),
									Expanded(
										child: Center(
											child: Text(
												'${held.nectar}',
												style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
											),
										),
									),
								],
							),
							PieceCounterRow(
								label: _t('collected'),
								left: PieceCounter(
									buttonKey: _keyFor('tele_collect_pollen'),
									icon: pollenIcon,
									value: v('tele_collect_pollen'),
									enabled: !held.collectBlocked,
									onTap: () => _tap('tele_collect_pollen'),
								),
								right: PieceCounter(
									buttonKey: _keyFor('tele_collect_nectar'),
									icon: nectarIcon,
									value: v('tele_collect_nectar'),
									enabled: !held.collectBlocked,
									onTap: () => _tap('tele_collect_nectar'),
								),
							),
							PieceCounterRow(
								label: _t('cell'),
								left: PieceCounter(
									buttonKey: _keyFor('tele_cell_pollen'),
									icon: pollenIcon,
									value: v('tele_cell_pollen'),
									enabled: !held.pollenPlaceBlocked,
									onTap: () => _tap('tele_cell_pollen'),
								),
								right: PieceCounter(
									buttonKey: _keyFor('tele_cell_nectar'),
									icon: nectarIcon,
									value: v('tele_cell_nectar'),
									enabled: !held.nectarPlaceBlocked,
									onTap: () => _tap('tele_cell_nectar'),
								),
							),
							PieceCounterRow(
								label: _t('hive_tip'),
								right: PieceCounter(
									buttonKey: _keyFor('tele_hive_tip'),
									icon: const Text('+1'),
									value: v('tele_hive_tip'),
									enabled: hiveTipEnabled(timeline),
									onTap: () => _tap('tele_hive_tip'),
								),
							),
							for (var i = 1; i <= 4; i++)
								PieceCounterRow(
									label: '${_t('flower')} $i',
									left: PieceCounter(
										buttonKey: _keyFor('tele_flower${i}_pollen'),
										icon: pollenIcon,
										value: v('tele_flower${i}_pollen'),
										enabled: !held.pollenPlaceBlocked,
										onTap: () => _tap('tele_flower${i}_pollen'),
									),
									right: PieceCounter(
										buttonKey: _keyFor('tele_flower${i}_nectar'),
										icon: nectarIcon,
										value: v('tele_flower${i}_nectar'),
										enabled: !held.nectarPlaceBlocked,
										onTap: () => _tap('tele_flower${i}_nectar'),
									),
								),
							PieceCounterRow(
								label: _t('garden'),
								left: PieceCounter(
									buttonKey: _keyFor('tele_garden_pollen'),
									icon: pollenIcon,
									value: v('tele_garden_pollen'),
									enabled: !held.pollenPlaceBlocked,
									onTap: () => _tap('tele_garden_pollen'),
								),
								right: PieceCounter(
									buttonKey: _keyFor('tele_garden_nectar'),
									icon: nectarIcon,
									value: v('tele_garden_nectar'),
									enabled: !held.nectarPlaceBlocked,
									onTap: () => _tap('tele_garden_nectar'),
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
										onPressed: widget.onProceedToEndGame,
										child: Text(_t('proceed_end_button')),
									),
								],
							),
						],
					),
				),
				// Floaters draw above the tab
				const PopupFloaterLayer(),
			],
		);
	}
}
