import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../constants/colors.dart';
import '../../data/database/scout_database.dart';
import '../../providers/app_providers.dart';
import '../../providers/auto_tab_controller.dart';
import '../../providers/field_side_provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/scout_data_helper.dart';
import '../../services/localization.dart';
import '../../widgets/auto_field_overlay.dart';
import '../../widgets/auto_values_table.dart';
import '../../widgets/auto_timeline_table.dart';
import '../../l10n/auto_tab.dart';

class AutoTab extends ConsumerStatefulWidget {
	final String eventId;
	final String? matchNumber;
	final String? teamNumber;
	final DateTime? matchStartTime;
	final Function(DateTime)? onStartMatch;

	const AutoTab({
		Key? key,
		required this.eventId,
		required this.matchNumber,
		required this.teamNumber,
		this.matchStartTime,
		this.onStartMatch,
	}) : super(key: key);

	@override
	ConsumerState<AutoTab> createState() => _AutoTabState();
}

class _AutoTabState extends ConsumerState<AutoTab> {
	ScoutData? _currentScout;
	bool _valuesExpanded = false;
	bool _timelineExpanded = false;

	String _translate(String key, {Map<String, String>? variables}) {
		final locale = ref.read(selectedLocaleProvider);
		return AppLocalizations.translate(key, locale: locale, variables: variables);
	}

	/// Get team color based on bot position (red vs blue team)
	Color _getTeamColor(String? botPosition) {
		if (botPosition == null) return AppColors.blueTeamColor;
		// Red team positions start with 'R', Blue with 'B'
		return botPosition.startsWith('R') ? AppColors.redTeamColor : AppColors.blueTeamColor;
	}

	/// Get responsive font size based on screen width
	double _getResponsiveFontSize(double baseSize) {
		final screenWidth = MediaQuery.of(context).size.width;
		if (screenWidth < 400) return baseSize * 0.85; // Mobile
		return baseSize;
	}

	/// Get responsive padding based on screen width
	EdgeInsets _getResponsivePadding() {
		final screenWidth = MediaQuery.of(context).size.width;
		if (screenWidth < 400) return const EdgeInsets.all(8);
		return const EdgeInsets.all(12);
	}

	/// Start the match timer if not already started
	void _startMatchIfNeeded() {
		if (widget.matchStartTime == null) {
			final now = DateTime.now();
			widget.onStartMatch?.call(now);
			// Sync provider's autoStartTime with UI timer start
			ref.read(autoTabControllerProvider.notifier).syncStartTime(now);
		}
	}

	@override
	void initState() {
		super.initState();
		// Initialize i18n for auto tab
		initAutoTabTranslations();
		_loadScout();
	}

	Future<void> _loadScout() async {
		if (widget.matchNumber != null && widget.teamNumber != null) {
			final db = await ref.read(databaseProvider.future);
			final scout = await db.getScout(
				widget.eventId,
				widget.matchNumber!,
				widget.teamNumber!,
			);
			if (scout != null && mounted) {
				setState(() {
					_currentScout = scout;
				});

				// Load auto data into controller
				final controller = ref.read(autoTabControllerProvider.notifier);
				final autoData = {
					'auto_trench_depot_alliance_to_neutral': scout.autoTrenchDepotAllianceToNeutral ?? 0,
					'auto_bump_depot_alliance_to_neutral': scout.autoBumpDepotAllianceToNeutral ?? 0,
					'auto_bump_outpost_alliance_to_neutral': scout.autoBumpOutpostAllianceToNeutral ?? 0,
					'auto_trench_outpost_alliance_to_neutral': scout.autoTrenchOutpostAllianceToNeutral ?? 0,
					'auto_trench_depot_neutral_to_alliance': scout.autoTrenchDepotNeutralToAlliance ?? 0,
					'auto_bump_depot_neutral_to_alliance': scout.autoBumpDepotNeutralToAlliance ?? 0,
					'auto_bump_outpost_neutral_to_alliance': scout.autoBumpOutpostNeutralToAlliance ?? 0,
					'auto_trench_outpost_neutral_to_alliance': scout.autoTrenchOutpostNeutralToAlliance ?? 0,
					'auto_fuel_score': scout.autoFuelScore ?? 0,
					'auto_fuel_neutral_alliance_pass': scout.autoFuelNeutralAlliancePass ?? 0,
					'auto_collect_outpost': scout.autoCollectOutpost ?? false,
					'auto_collect_depot': scout.autoCollectDepot ?? false,
					'auto_alliance_time': scout.autoAllianceTime ?? 0,
					'auto_neutral_time': scout.autoNeutralTime ?? 0,
					'auto_climb_level': scout.autoClimbLevel ?? 0,
					'auto_timeline_events': scout.autoTimelineEvents,
				};
				controller.loadFromData(autoData);
			}
		}
	}

	Future<void> _saveTab() async {
		if (widget.matchNumber == null || widget.teamNumber == null) return;

		final db = await ref.read(databaseProvider.future);
		final autoState = ref.read(autoTabControllerProvider);

		final existing = _currentScout ?? await db.getScout(
			widget.eventId,
			widget.matchNumber!,
			widget.teamNumber!,
		);

		final now = DateTime.now();
		final countersMap = autoState.toJson();
		final timelineJson = countersMap['auto_timeline_events'] as String?;

		final scout = existing != null
				? existing.copyWith(
					autoTrenchDepotAllianceToNeutral: autoState.trenchDepotAllianceToNeutral,
					autoBumpDepotAllianceToNeutral: autoState.bumpDepotAllianceToNeutral,
					autoBumpOutpostAllianceToNeutral: autoState.bumpOutpostAllianceToNeutral,
					autoTrenchOutpostAllianceToNeutral: autoState.trenchOutpostAllianceToNeutral,
					autoTrenchDepotNeutralToAlliance: autoState.trenchDepotNeutralToAlliance,
					autoBumpDepotNeutralToAlliance: autoState.bumpDepotNeutralToAlliance,
					autoBumpOutpostNeutralToAlliance: autoState.bumpOutpostNeutralToAlliance,
					autoTrenchOutpostNeutralToAlliance: autoState.trenchOutpostNeutralToAlliance,
					autoFuelScore: autoState.fuelScore,
					autoFuelNeutralAlliancePass: autoState.fuelNeutralAlliancePass,
					autoCollectOutpost: autoState.collectOutpost,
					autoCollectDepot: autoState.collectDepot,
					autoAllianceTime: autoState.allianceTime,
					autoNeutralTime: autoState.neutralTime,
					autoClimbLevel: Value(autoState.climbLevel),
					autoTimelineEvents: Value(timelineJson),
					updatedAt: now,
				)
				: ScoutDataHelper.createNewScout(
					event: widget.eventId,
					match: widget.matchNumber!,
					team: widget.teamNumber!,
				);

		await db.upsertScout(scout);
		setState(() => _currentScout = scout);

		if (mounted) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text(_translate('pre_match_data_saved')),
					duration: const Duration(seconds: 2),
				),
			);
		}
	}

	@override
	Widget build(BuildContext context) {
		final fieldSide = ref.watch(selectedFieldSideProvider);
		final autoState = ref.watch(autoTabControllerProvider);
		final botPosition = ref.watch(selectedBotPositionProvider);
		final teamColor = _getTeamColor(botPosition);

		return SingleChildScrollView(
			padding: const EdgeInsets.symmetric(vertical: 8),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [
					// Field Overlay with all integrated controls
					// (movement buttons, fuel overlays, zone toggles, climb selector)
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 16),
						child: AutoFieldOverlay(
							fieldSide: fieldSide,
							activeZone: autoState.activeZone,
							collectDepot: autoState.collectDepot,
							collectOutpost: autoState.collectOutpost,
							climbLevel: autoState.climbLevel,
							botPosition: botPosition,
							showStartButton: widget.matchStartTime == null,
							onMovementTapped: (field, action) {
								// Start match timer if not already started
								_startMatchIfNeeded();

								// Record the action (zone change is implicit in field name)
								ref.read(autoTabControllerProvider.notifier).recordAction(
									type: 'movement',
									field: field,
									value: 1,
									actionLabel: action,
									valueLabel: '+1',
								);
							},
							onCollectionToggled: (type) {							// Start match timer if not already started
							_startMatchIfNeeded();
								final field = type == 'depot' ? 'auto_collect_depot' : 'auto_collect_outpost';
								ref.read(autoTabControllerProvider.notifier).recordAction(
									type: 'collection',
									field: field,
									value: 1,
									actionLabel: 'Collect: $type',
									valueLabel: 'toggle',
								);
							},
							onClimbToggled: () {
								// Start match timer if not already started
								_startMatchIfNeeded();

								ref.read(autoTabControllerProvider.notifier).recordAction(
									type: 'climb',
									field: 'auto_climb_level',
									value: autoState.climbLevel == 0 ? 1 : 0,
									actionLabel: 'Climb',
									valueLabel: '${autoState.climbLevel == 0 ? 1 : 0}',
								);
							},
							onStartAutoTapped: () {
								_startMatchIfNeeded();
							},						activeFuelTarget: autoState.activeFuelTarget,
						onFuelTargetTapped: (targetName) {
							ref.read(autoTabControllerProvider.notifier).changeFuelTarget(targetName);
						},						startAutoButtonLabel: _translate('start_auto_button'),
					),
				),

				const SizedBox(height: 16),

				// Two-column layout: fuel and info
				Padding(
					padding: const EdgeInsets.symmetric(horizontal: 16),
					child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					// LEFT COLUMN: Fuel and Table Toggles
					Expanded(
					flex: 3,
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.center,
							children: [
								// Fuel buttons row
								Row(
								mainAxisAlignment: MainAxisAlignment.center,
									children: [
										_buildFuelButton('1', 1, autoState, ref),
										const SizedBox(width: 8),
										_buildFuelButton('5', 5, autoState, ref),
										const SizedBox(width: 8),
										_buildFuelButton('10', 10, autoState, ref),
									],
								),
								const SizedBox(height: 8),
								// Values and timeline toggle buttons row
								Row(
								mainAxisAlignment: MainAxisAlignment.center,
									children: [
										TextButton(
											onPressed: () {
												setState(() => _valuesExpanded = !_valuesExpanded);
											},
											child: Text(_translate('values')),
										),
										const SizedBox(width: 8),
										TextButton(
											onPressed: () {
												setState(() => _timelineExpanded = !_timelineExpanded);
											},
											child: Text(_translate('timeline')),
										),
									],
								),
								const SizedBox(height: 12),
								// Values Table (readonly counters)
								if (_valuesExpanded) ...[
									AutoValuesTable(
										key: const ValueKey('auto_values_table'),
										trenchDepotAllianceToNeutral: autoState.trenchDepotAllianceToNeutral,
										bumpDepotAllianceToNeutral: autoState.bumpDepotAllianceToNeutral,
										bumpOutpostAllianceToNeutral: autoState.bumpOutpostAllianceToNeutral,
										trenchOutpostAllianceToNeutral: autoState.trenchOutpostAllianceToNeutral,
										trenchDepotNeutralToAlliance: autoState.trenchDepotNeutralToAlliance,
										bumpDepotNeutralToAlliance: autoState.bumpDepotNeutralToAlliance,
										bumpOutpostNeutralToAlliance: autoState.bumpOutpostNeutralToAlliance,
										trenchOutpostNeutralToAlliance: autoState.trenchOutpostNeutralToAlliance,
										fuelScore: autoState.fuelScore,
										fuelNeutralAlliancePass: autoState.fuelNeutralAlliancePass,
										allianceTime: autoState.allianceTime,
										neutralTime: autoState.neutralTime,
									),
									const SizedBox(height: 12),
								],
								// Timeline Table
								if (_timelineExpanded)
									AutoTimelineTable(
										key: const ValueKey('auto_timeline_table'),
										events: autoState.timeline,
									),
							],
						),
					),
					const SizedBox(width: 16),
					// RIGHT COLUMN: Info Section (vertically stacked)
					Expanded(
						flex: 1,
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.stretch,
							children: [
								// Undo button
								FilledButton(
									style: FilledButton.styleFrom(
										backgroundColor: autoState.timeline.isNotEmpty
											? AppColors.buttonBgColor
											: Colors.grey.shade700,
										foregroundColor: autoState.timeline.isNotEmpty
											? AppColors.buttonFgColor
											: Colors.grey.shade500,
										padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(8),
										),
									),
									onPressed: autoState.timeline.isNotEmpty
										? () {
											ref.read(autoTabControllerProvider.notifier).undo();
										}
										: null,
									child: Text(
										_translate('undo'),
										style: TextStyle(fontSize: _getResponsiveFontSize(12)),
									),
								),
								const SizedBox(height: 8),
								// Robot/Team indicator - team color background with contrasting text
								Container(
									padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
									decoration: BoxDecoration(
										color: teamColor,
										borderRadius: BorderRadius.circular(4),
									),
									child: Center(
										child: Text(
											'$botPosition ${widget.teamNumber ?? ''}',
											style: TextStyle(
												fontSize: _getResponsiveFontSize(12),
												fontWeight: FontWeight.bold,
												color: AppColors.mainFgColor,
											),
										),
									),
								),
								const SizedBox(height: 8),
								// Tele button
								FilledButton(
									style: FilledButton.styleFrom(
										backgroundColor: AppColors.buttonBgColor,
										foregroundColor: AppColors.buttonFgColor,
										padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(8),
										),
									),
									onPressed: _saveTab,
									child: Text(
										_translate('proceed_tele_button'),
										style: TextStyle(fontSize: _getResponsiveFontSize(12)),
									),
								),
							],
						),
					),
				],
			),
		),

		const SizedBox(height: 16),
		],
		),
	);
	}

	/// Build a fuel quick-add button
	Widget _buildFuelButton(
		String label,
		int amount,
		AutoTabState autoState,
		WidgetRef ref,
	) {
		return SizedBox(
			width: 70,
			height: 70,
			child: ElevatedButton(
				onPressed: () {
					// Use the correct fuel counter based on active target
					final fuelField = autoState.activeFuelTarget == 'hub'
						? 'auto_fuel_score'
						: 'auto_fuel_neutral_alliance_pass';

					ref.read(autoTabControllerProvider.notifier).recordAction(
						type: 'fuel',
						field: fuelField,
						value: amount,
						actionLabel: 'Fuel',
						valueLabel: '+$amount',
					);
				},
				style: ElevatedButton.styleFrom(
					backgroundColor: const Color(0xFFF1CE03),
					foregroundColor: Colors.black87,
					padding: EdgeInsets.zero,
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(50),
					),
				),
				child: Text(
					label,
					style: TextStyle(
						fontSize: _getResponsiveFontSize(18),
						fontWeight: FontWeight.bold,
					),
				),
			),
		);
	}
}
