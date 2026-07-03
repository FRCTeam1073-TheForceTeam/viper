import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/colors.dart';
import '../../providers/app_providers.dart';
import '../../providers/scouting_data_provider.dart';
import '../../providers/field_side_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/timeline_provider.dart';
import '../../providers/match_timer_provider.dart';
import '../../providers/undo_coordinator.dart';
import '../../services/localization.dart';
import '../../widgets/tele_field_overlay.dart';
import '../../widgets/tele_values_table.dart';
import '../../widgets/timeline_table.dart';

typedef TeleTabRecord = ({
	String activeZone,
	String activeFuelTarget,
	int trenchDepotAllianceToNeutral,
	int bumpDepotAllianceToNeutral,
	int bumpOutpostAllianceToNeutral,
	int trenchOutpostAllianceToNeutral,
	int trenchDepotNeutralToAlliance,
	int bumpDepotNeutralToAlliance,
	int bumpOutpostNeutralToAlliance,
	int trenchOutpostNeutralToAlliance,
	int trenchOutpostNeutralToOpponent,
	int bumpOutpostNeutralToOpponent,
	int bumpDepotNeutralToOpponent,
	int trenchDepotNeutralToOpponent,
	int trenchOutpostOpponentToNeutral,
	int bumpOutpostOpponentToNeutral,
	int bumpDepotOpponentToNeutral,
	int trenchDepotOpponentToNeutral,
	int fuelScore,
	int fuelAllianceDump,
	int fuelOutpost,
	int fuelNeutralAlliancePass,
	int fuelOpponentNeutralPass,
	int fuelOpponentAlliancePass,
	int allianceTime,
	int neutralTime,
	int opponentTime,
	int climbLevel,
});

/// Initialize Tele Tab translations
void _initTeleTabTranslations() {
	AppLocalizations.addI18n({
		// Tab header
		'tele_heading': {
			'en': 'Teleop Period',
			'es': 'Período de Teleoperación',
			'pt': 'Período de Teleoperação',
			'fr': 'Période Téléopérée',
			'zh_tw': '遙控操作期間',
			'he': 'תקופת טלאופ',
			'tr': 'Teleop Dönemi',
		},

		// Section headers
		'field_interactions': {
			'en': 'Field Interactions',
			'es': 'Interacciones de Campo',
			'pt': 'Interações de Campo',
			'fr': 'Interactions sur le Terrain',
			'zh_tw': '場地交互',
			'he': 'אינטראקציות שדה',
			'tr': 'Saha Etkileşimleri',
		},
		'fuel_scoring': {
			'en': 'Fuel Scoring',
			'es': 'Puntuación de Combustible',
			'pt': 'Pontuação de Combustível',
			'fr': 'Marquage de Carburant',
			'zh_tw': '燃料評分',
			'he': 'ניקוד דלק',
			'tr': 'Yakıt Puanlaması',
		},
		'climb': {
			'en': 'Climb',
			'es': 'Escalada',
			'pt': 'Escalada',
			'fr': 'Escalade',
			'zh_tw': '攀爬',
			'he': 'טיפוס',
			'tr': 'Tırmanış',
		},
		'timeline': {
			'en': 'Timeline',
			'es': 'Cronograma',
			'pt': 'Cronograma',
			'fr': 'Chronologie',
			'zh_tw': '時間表',
			'he': 'ציר הזמן',
			'tr': 'Zaman Çizelgesi',
		},
		'values': {
			'en': 'Values',
			'es': 'Valores',
			'pt': 'Valores',
			'fr': 'Valeurs',
			'zh_tw': '值',
			'he': 'ערכים',
			'tr': 'Değerler',
		},

		// Movement labels
		'trench_outpost_neutral_to_opponent': {
			'en': 'Trench Outpost → Opponent',
			'es': 'Trinchera Puesto Avanzado → Oponente',
			'pt': 'Trincheira Avanço → Oponente',
			'fr': 'Tranchée Avant-Poste → Opposant',
			'zh_tw': '壕溝哨站 → 對手',
			'he': 'משק עמוק צפוי → יריב',
			'tr': 'Hendek Karakol → Rakip',
		},
		'bump_outpost_neutral_to_opponent': {
			'en': 'Bump Outpost → Opponent',
			'es': 'Golpe Puesto Avanzado → Oponente',
			'pt': 'Bump Avanço → Oponente',
			'fr': 'Bump Avant-Poste → Opposant',
			'zh_tw': '碰撞哨站 → 對手',
			'he': 'דחיפה אחסון צפוי → יריב',
			'tr': 'Bump Karakol → Rakip',
		},
		'bump_depot_neutral_to_opponent': {
			'en': 'Bump Depot → Opponent',
			'es': 'Golpe Depósito → Oponente',
			'pt': 'Bump Depósito → Oponente',
			'fr': 'Bump Dépôt → Opposant',
			'zh_tw': '碰撞倉庫 → 對手',
			'he': 'דחיפה אחסון → יריב',
			'tr': 'Bump Depo → Rakip',
		},
		'trench_depot_neutral_to_opponent': {
			'en': 'Trench Depot → Opponent',
			'es': 'Trinchera Depósito → Oponente',
			'pt': 'Trincheira Depósito → Oponente',
			'fr': 'Tranchée Dépôt → Opposant',
			'zh_tw': '壕溝倉庫 → 對手',
			'he': 'משק אחסון עמוק → יריב',
			'tr': 'Hendek Depo → Rakip',
		},
		'trench_outpost_opponent_to_neutral': {
			'en': 'Trench Outpost ← Opponent',
			'es': 'Trinchera Puesto Avanzado ← Oponente',
			'pt': 'Trincheira Avanço ← Oponente',
			'fr': 'Tranchée Avant-Poste ← Opposant',
			'zh_tw': '壕溝哨站 ← 對手',
			'he': 'משק עמוק צפוי ← יריב',
			'tr': 'Hendek Karakol ← Rakip',
		},
		'bump_outpost_opponent_to_neutral': {
			'en': 'Bump Outpost ← Opponent',
			'es': 'Golpe Puesto Avanzado ← Oponente',
			'pt': 'Bump Avanço ← Oponente',
			'fr': 'Bump Avant-Poste ← Opposant',
			'zh_tw': '碰撞哨站 ← 對手',
			'he': 'דחיפה אחסון צפוי ← יריב',
			'tr': 'Bump Karakol ← Rakip',
		},
		'bump_depot_opponent_to_neutral': {
			'en': 'Bump Depot ← Opponent',
			'es': 'Golpe Depósito ← Oponente',
			'pt': 'Bump Depósito ← Oponente',
			'fr': 'Bump Dépôt ← Opposant',
			'zh_tw': '碰撞倉庫 ← 對手',
			'he': 'דחיפה אחסון ← יריב',
			'tr': 'Bump Depo ← Rakip',
		},
		'trench_depot_opponent_to_neutral': {
			'en': 'Trench Depot ← Opponent',
			'es': 'Trinchera Depósito ← Oponente',
			'pt': 'Trincheira Depósito ← Oponente',
			'fr': 'Tranchée Dépôt ← Opposant',
			'zh_tw': '壕溝倉庫 ← 對手',
			'he': 'משק אחסון עמוק ← יריב',
			'tr': 'Hendek Depo ← Rakip',
		},

		// Fuel labels
		'fuel_alliance_dump': {
			'en': 'Fuel Alliance Dump',
			'es': 'Descarga de Alianza',
			'pt': 'Descarga de Aliança',
			'fr': 'Vidage Alliance',
			'zh_tw': '聯盟傾倒',
			'he': 'זריקת ברית',
			'tr': 'İttifak Boşaltma',
		},
		'fuel_outpost': {
			'en': 'Fuel Outpost',
			'es': 'Combustible Puesto Avanzado',
			'pt': 'Combustível Avanço',
			'fr': 'Carburant Avant-Poste',
			'zh_tw': '燃料前哨',
			'he': 'דלק אחסון צפוי',
			'tr': 'Yakıt Karakolu',
		},
		'fuel_opponent_alliance_pass': {
			'en': 'Opponent Alliance Pass',
			'es': 'Pase de Alianza del Oponente',
			'pt': 'Passe de Aliança do Oponente',
			'fr': 'Passe Alliance Adversaire',
			'zh_tw': '對手聯盟通道',
			'he': 'מעבר ברית של היריב',
			'tr': 'Rakip İttifak Geçiti',
		},
		'fuel_opponent_neutral_pass': {
			'en': 'Opponent Neutral Pass',
			'es': 'Pase Neutral del Oponente',
			'pt': 'Passe Neutra do Oponente',
			'fr': 'Passe Neutre Adversaire',
			'zh_tw': '對手中立通道',
			'he': 'מעבר ניטראלי של היריב',
			'tr': 'Rakip Nötr Geçiti',
		},

		// Zone time labels
		'opponent_time': {
			'en': 'Opponent Time',
			'es': 'Tiempo del Oponente',
			'pt': 'Tempo do Oponente',
			'fr': 'Temps Adversaire',
			'zh_tw': '對手時間',
			'he': 'זמן יריב',
			'tr': 'Rakip Süresi',
		},

		// Action buttons
		'undo': {
			'en': 'Undo',
			'es': 'Deshacer',
			'pt': 'Desfazer',
			'fr': 'Annuler',
			'zh_tw': '撤銷',
			'he': 'בטל',
			'tr': 'Geri Al',
		},
		'reset': {
			'en': 'Reset',
			'es': 'Reiniciar',
			'pt': 'Redefinir',
			'fr': 'Réinitialiser',
			'zh_tw': '重置',
			'he': 'אתחול',
			'tr': 'Sıfırla',
		},

		// Max fuel label
		'fuel_capacity_label': {
			'en': 'Max fuel:',
			'es': 'Capacidad de combustible:',
			'pt': 'Combustível máximo:',
			'fr': 'Carburant max :',
			'zh_tw': '最大燃料：',
			'he': 'דלק מקסימלי:',
			'tr': 'Maksimum yakıt:',
		},

		// Shared tele labels (from web app analysis)
		'fuel_score': {
			'en': 'Fuel Score',
			'es': 'Puntuación de Combustible',
			'pt': 'Pontuação de Combustível',
			'fr': 'Score de Carburant',
			'zh_tw': '燃料評分',
			'he': 'ניקוד דלק',
			'tr': 'Yakıt Puanı',
		},
		'fuel_neutral_pass': {
			'en': 'Neutral Pass',
			'es': 'Pase Neutral',
			'pt': 'Passagem Neutra',
			'fr': 'Passe Neutre',
			'zh_tw': '中立通行',
			'he': 'מעבר ניטראלי',
			'tr': 'Tarafsız Geçiş',
		},
		'alliance_time': {
			'en': 'Alliance Time',
			'es': 'Tiempo de Alianza',
			'pt': 'Tempo da Aliança',
			'fr': 'Temps d\'Alliance',
			'zh_tw': '聯盟時間',
			'he': 'זמן הברית',
			'tr': 'İttifak Süresi',
		},
		'neutral_time': {
			'en': 'Neutral Time',
			'es': 'Tiempo Neutral',
			'pt': 'Tempo Neutro',
			'fr': 'Temps Neutre',
			'zh_tw': '中立時間',
			'he': 'זמן ניטראלי',
			'tr': 'Tarafsız Süresi',
		},

		// Movement labels for tele (reuse shared ones where available)
		'trench_depot_alliance_to_neutral': {
			'en': 'Trench Depot → Neutral',
			'es': 'Trinchera Depósito → Neutral',
			'pt': 'Trincheira Depósito → Neutro',
			'fr': 'Tranchée Dépôt → Neutre',
			'zh_tw': '壕溝倉庫 → 中立',
			'he': 'משק אחסון עמוק → ניטראלי',
			'tr': 'Hendek Depo → Tarafsız',
		},
		'bump_depot_alliance_to_neutral': {
			'en': 'Bump Depot → Neutral',
			'es': 'Golpe Depósito → Neutral',
			'pt': 'Bump Depósito → Neutro',
			'fr': 'Bump Dépôt → Neutre',
			'zh_tw': '碰撞倉庫 → 中立',
			'he': 'דחיפה אחסון → ניטראלי',
			'tr': 'Bump Depo → Tarafsız',
		},
		'bump_outpost_alliance_to_neutral': {
			'en': 'Bump Outpost → Neutral',
			'es': 'Golpe Puesto Avanzado → Neutral',
			'pt': 'Bump Avanço → Neutro',
			'fr': 'Bump Avant-Poste → Neutre',
			'zh_tw': '碰撞哨站 → 中立',
			'he': 'דחיפה אחסון צפוי → ניטראלי',
			'tr': 'Bump Karakol → Tarafsız',
		},
		'trench_outpost_alliance_to_neutral': {
			'en': 'Trench Outpost → Neutral',
			'es': 'Trinchera Puesto Avanzado → Neutral',
			'pt': 'Trincheira Avanço → Neutro',
			'fr': 'Tranchée Avant-Poste → Neutre',
			'zh_tw': '壕溝哨站 → 中立',
			'he': 'משק עמוק צפוי → ניטראלי',
			'tr': 'Hendek Karakol → Tarafsız',
		},
		'trench_depot_neutral_to_alliance': {
			'en': 'Trench Depot ← Neutral',
			'es': 'Trinchera Depósito ← Neutral',
			'pt': 'Trincheira Depósito ← Neutro',
			'fr': 'Tranchée Dépôt ← Neutre',
			'zh_tw': '壕溝倉庫 ← 中立',
			'he': 'משק אחסון עמוק ← ניטראלי',
			'tr': 'Hendek Depo ← Tarafsız',
		},
		'bump_depot_neutral_to_alliance': {
			'en': 'Bump Depot ← Neutral',
			'es': 'Golpe Depósito ← Neutral',
			'pt': 'Bump Depósito ← Neutro',
			'fr': 'Bump Dépôt ← Neutre',
			'zh_tw': '碰撞倉庫 ← 中立',
			'he': 'דחיפה אחסון ← ניטראלי',
			'tr': 'Bump Depo ← Tarafsız',
		},
		'bump_outpost_neutral_to_alliance': {
			'en': 'Bump Outpost ← Neutral',
			'es': 'Golpe Puesto Avanzado ← Neutral',
			'pt': 'Bump Avanço ← Neutro',
			'fr': 'Bump Avant-Poste ← Neutre',
			'zh_tw': '碰撞哨站 ← 中立',
			'he': 'דחיפה אחסון צפוי ← ניטראלי',
			'tr': 'Bump Karakol ← Tarafsız',
		},
		'trench_outpost_neutral_to_alliance': {
			'en': 'Trench Outpost ← Neutral',
			'es': 'Trinchera Puesto Avanzado ← Neutral',
			'pt': 'Trincheira Avanço ← Neutro',
			'fr': 'Tranchée Avant-Poste ← Neutre',
			'zh_tw': '壕溝哨站 ← 中立',
			'he': 'משק עמוק צפוי ← ניטראלי',
			'tr': 'Hendek Karakol ← Tarafsız',
		},
	});
}

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
	bool _valuesExpanded = false;
	bool _timelineExpanded = false;
	bool _listenerRegistered = false;
	late FocusNode _focusNode;

	String _translate(String key, {Map<String, String>? variables}) {
		final locale = ref.read(selectedLocaleProvider);
		return AppLocalizations.translate(key, locale: locale, variables: variables);
	}

	/// Get team color based on bot position
	Color _getTeamColor(String? botPosition) {
		if (botPosition == null) return AppColors.blueTeamColor;
		return botPosition.startsWith('R') ? AppColors.redTeamColor : AppColors.blueTeamColor;
	}

	/// Get responsive font size based on screen width
	double _getResponsiveFontSize(double baseSize) {
		final screenWidth = MediaQuery.of(context).size.width;
		if (screenWidth < 400) return baseSize * 0.85;
		return baseSize;
	}

	@override
	void initState() {
		super.initState();
		_initTeleTabTranslations();
		_focusNode = FocusNode();
		_focusNode.addListener(_onFocusChanged);
	}

	void _onFocusChanged() {
	}

	@override
	void dispose() {
		_focusNode.removeListener(_onFocusChanged);
		_focusNode.dispose();
		super.dispose();
	}

	/// Start match timer with offset for auto period + gap (20s + 3s = 23s)
	/// Used when button is pressed before timer was started in auto
	void _startMatchIfNeeded() {
		final currentTime = ref.read(matchTimerProvider);
		if (currentTime == null) {
			// Set timer to 23 seconds ago so clock shows ~23 seconds
			final now = DateTime.now();
			final autoAndGapDuration = const Duration(seconds: 23);
			final startTime = now.subtract(autoAndGapDuration);
			ref.read(matchTimerProvider.notifier).setStartTime(startTime);
		}
	}



	@override
	Widget build(BuildContext context) {
		final fieldSide = ref.watch(selectedFieldSideProvider);
		final teleState = ref.watch(scoutingDataProvider.select((data) => (
			activeZone: data.teleActiveZone,
			activeFuelTarget: data.teleActiveFuelTarget,
			trenchDepotAllianceToNeutral: data.getFieldValue('tele_trench_depot_alliance_to_neutral').asInt(),
			bumpDepotAllianceToNeutral: data.getFieldValue('tele_bump_depot_alliance_to_neutral').asInt(),
			bumpOutpostAllianceToNeutral: data.getFieldValue('tele_bump_outpost_alliance_to_neutral').asInt(),
			trenchOutpostAllianceToNeutral: data.getFieldValue('tele_trench_outpost_alliance_to_neutral').asInt(),
			trenchDepotNeutralToAlliance: data.getFieldValue('tele_trench_depot_neutral_to_alliance').asInt(),
			bumpDepotNeutralToAlliance: data.getFieldValue('tele_bump_depot_neutral_to_alliance').asInt(),
			bumpOutpostNeutralToAlliance: data.getFieldValue('tele_bump_outpost_neutral_to_alliance').asInt(),
			trenchOutpostNeutralToAlliance: data.getFieldValue('tele_trench_outpost_neutral_to_alliance').asInt(),
			trenchOutpostNeutralToOpponent: data.getFieldValue('tele_trench_outpost_neutral_to_opponent').asInt(),
			bumpOutpostNeutralToOpponent: data.getFieldValue('tele_bump_outpost_neutral_to_opponent').asInt(),
			bumpDepotNeutralToOpponent: data.getFieldValue('tele_bump_depot_neutral_to_opponent').asInt(),
			trenchDepotNeutralToOpponent: data.getFieldValue('tele_trench_depot_neutral_to_opponent').asInt(),
			trenchOutpostOpponentToNeutral: data.getFieldValue('tele_trench_outpost_opponent_to_neutral').asInt(),
			bumpOutpostOpponentToNeutral: data.getFieldValue('tele_bump_outpost_opponent_to_neutral').asInt(),
			bumpDepotOpponentToNeutral: data.getFieldValue('tele_bump_depot_opponent_to_neutral').asInt(),
			trenchDepotOpponentToNeutral: data.getFieldValue('tele_trench_depot_opponent_to_neutral').asInt(),
			fuelScore: data.getFieldValue('tele_fuel_score').asInt(),
			fuelAllianceDump: data.getFieldValue('tele_fuel_alliance_dump').asInt(),
			fuelOutpost: data.getFieldValue('tele_fuel_outpost').asInt(),
			fuelNeutralAlliancePass: data.getFieldValue('tele_fuel_neutral_alliance_pass').asInt(),
			fuelOpponentNeutralPass: data.getFieldValue('tele_fuel_opponent_neutral_pass').asInt(),
			fuelOpponentAlliancePass: data.getFieldValue('tele_fuel_opponent_alliance_pass').asInt(),
			allianceTime: data.getFieldValue('tele_alliance_time').asInt(),
			neutralTime: data.getFieldValue('tele_neutral_time').asInt(),
			opponentTime: data.getFieldValue('tele_opponent_time').asInt(),
			climbLevel: data.getFieldValue('tele_climb_level').asInt(),
		)));
		final botPosition = ref.watch(selectedBotPositionProvider);
		final teamColor = _getTeamColor(botPosition);

		return Focus(
			focusNode: _focusNode,
			child: SingleChildScrollView(
				padding: const EdgeInsets.symmetric(vertical: 8),
				child: Column(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [
					// Field Overlay
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 16),
						child: TeleFieldOverlay(
							fieldSide: fieldSide,
							activeZone: teleState.activeZone,
							climbLevel: teleState.climbLevel,
							botPosition: botPosition,
							activeFuelTarget: teleState.activeFuelTarget,
							onMovementTapped: (field, action) {
								_startMatchIfNeeded();
								ref.read(scoutingDataProvider.notifier).recordTeleAction(
						field: field,
						value: 1,
					);
							},
							onClimbTapped: () {
								_startMatchIfNeeded();
								final currentClimbLevel = teleState.climbLevel;
								if (currentClimbLevel < 3) {
									ref.read(scoutingDataProvider.notifier).recordTeleAction(
						field: 'tele_climb_level',
						value: currentClimbLevel + 1,
					);
								}
							},
							onFuelTargetTapped: (targetName) {
								ref.read(scoutingDataProvider.notifier).changeTeleFuelTarget(targetName);
							},
						),
					),

					const SizedBox(height: 16),

					// Two-column layout: fuel and info
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 16),
						child: Row(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								// LEFT COLUMN: Fuel and Tables
								Expanded(
									flex: 3,
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.center,
										children: [
											// Fuel buttons row
											Row(
												mainAxisAlignment: MainAxisAlignment.center,
												children: [
													_buildFuelButton('1', 1, teleState, ref),
													const SizedBox(width: 8),
													_buildFuelButton('5', 5, teleState, ref),
													const SizedBox(width: 8),
													_buildFuelButton('10', 10, teleState, ref),
												],
											),
											const SizedBox(height: 8),
											// Max fuel display and toggle buttons
											Row(
												mainAxisAlignment: MainAxisAlignment.center,
												children: [
													_buildMaxFuelDisplay(ref),
													TextButton(
														onPressed: () {
															setState(() => _valuesExpanded = !_valuesExpanded);
														},
														child: Text('${_valuesExpanded ? '▼' : '▶'} ${_translate('values')}'),
													),
													const SizedBox(width: 8),
													TextButton(
														onPressed: () {
															setState(() => _timelineExpanded = !_timelineExpanded);
														},
														child: Text('${_timelineExpanded ? '▼' : '▶'} ${_translate('timeline')}'),
													),
												],
											),
											const SizedBox(height: 12),
											// Values Table
											if (_valuesExpanded) ...[
												TeleValuesTable(
													key: const ValueKey('tele_values_table'),
													trenchDepotAllianceToNeutral: teleState.trenchDepotAllianceToNeutral,
													bumpDepotAllianceToNeutral: teleState.bumpDepotAllianceToNeutral,
													bumpOutpostAllianceToNeutral: teleState.bumpOutpostAllianceToNeutral,
													trenchOutpostAllianceToNeutral: teleState.trenchOutpostAllianceToNeutral,
													trenchDepotNeutralToAlliance: teleState.trenchDepotNeutralToAlliance,
													bumpDepotNeutralToAlliance: teleState.bumpDepotNeutralToAlliance,
													bumpOutpostNeutralToAlliance: teleState.bumpOutpostNeutralToAlliance,
													trenchOutpostNeutralToAlliance: teleState.trenchOutpostNeutralToAlliance,
													trenchOutpostNeutralToOpponent: teleState.trenchOutpostNeutralToOpponent,
													bumpOutpostNeutralToOpponent: teleState.bumpOutpostNeutralToOpponent,
													bumpDepotNeutralToOpponent: teleState.bumpDepotNeutralToOpponent,
													trenchDepotNeutralToOpponent: teleState.trenchDepotNeutralToOpponent,
													trenchOutpostOpponentToNeutral: teleState.trenchOutpostOpponentToNeutral,
													bumpOutpostOpponentToNeutral: teleState.bumpOutpostOpponentToNeutral,
													bumpDepotOpponentToNeutral: teleState.bumpDepotOpponentToNeutral,
													trenchDepotOpponentToNeutral: teleState.trenchDepotOpponentToNeutral,
													fuelScore: teleState.fuelScore,
													fuelAllianceDump: teleState.fuelAllianceDump,
													fuelOutpost: teleState.fuelOutpost,
													fuelNeutralAlliancePass: teleState.fuelNeutralAlliancePass,
													fuelOpponentNeutralPass: teleState.fuelOpponentNeutralPass,
													fuelOpponentAlliancePass: teleState.fuelOpponentAlliancePass,
													allianceTime: teleState.allianceTime,
													neutralTime: teleState.neutralTime,
													opponentTime: teleState.opponentTime,
												),
												const SizedBox(height: 12),
											],
											// Timeline Table
											if (_timelineExpanded)
												TimelineTable(
													key: const ValueKey('tele_timeline_table'),
													events: ref.watch(timelineProvider),
												),
										],
									),
								),
								const SizedBox(width: 16),
								// RIGHT COLUMN: Info
								Expanded(
									flex: 1,
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.stretch,
										children: [
											// Undo button (always enabled to undo either timeline events or timer start)
											FilledButton(
												style: FilledButton.styleFrom(
													backgroundColor: AppColors.buttonBgColor,
													foregroundColor: AppColors.buttonFgColor,
													padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
													shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(8),
													),
												),
												onPressed: () {
													undoLastAction(ref);
												},
												child: Text(
													_translate('undo'),
													style: TextStyle(fontSize: _getResponsiveFontSize(12)),
												),
											),
											const SizedBox(height: 8),
											// Robot indicator
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
											// End game button
											FilledButton(
												style: FilledButton.styleFrom(
													backgroundColor: AppColors.buttonBgColor,
													foregroundColor: AppColors.buttonFgColor,
													padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
													shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(8),
													),
												),
												onPressed: () {},
												child: Text(
													'End Game »',
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
			),
		);
	}

	/// Build a fuel quick-add button
	Widget _buildFuelButton(
		String label,
		int amount,
		TeleTabRecord teleState,
		WidgetRef ref,
	) {
		// Map activeFuelTarget to field name
		String getFuelField() {
			switch (teleState.activeFuelTarget) {
				case 'hub':
					return 'tele_fuel_score';
				case 'allianceDump':
					return 'tele_fuel_alliance_dump';
				case 'outpost':
					return 'tele_fuel_outpost';
				case 'neutralAlliancePass':
					return 'tele_fuel_neutral_alliance_pass';
				case 'opponentAlliancePass':
					return 'tele_fuel_opponent_alliance_pass';
				case 'opponentNeutralPass':
					return 'tele_fuel_opponent_neutral_pass';
				default:
					return 'tele_fuel_score';
			}
		}

		return SizedBox(
			width: 70,
			height: 70,
			child: ElevatedButton(
				onPressed: () {
					_startMatchIfNeeded();
					ref.read(scoutingDataProvider.notifier).recordTeleAction(
						field: getFuelField(),
						value: amount,
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

	/// Build max fuel display widget
	Widget _buildMaxFuelDisplay(WidgetRef ref) {
		return ref.watch(pitScoutingDataProvider).when(
			data: (pitData) {
				final teamNumber = widget.teamNumber;
				if (teamNumber == null) {
					return const SizedBox.shrink();
				}

				final teamData = pitData[teamNumber] as Map<String, dynamic>?;
				final fuelCapacity = int.tryParse((teamData?['fuel_capacity'] ?? '0').toString()) ?? 0;

				if (fuelCapacity <= 0) {
					return const SizedBox.shrink();
				}

				return Padding(
					padding: const EdgeInsets.only(right: 8),
					child: Text(
						'${_translate('fuel_capacity_label')} $fuelCapacity',
						style: TextStyle(
							fontSize: _getResponsiveFontSize(12),
							fontWeight: FontWeight.w500,
						),
					),
				);
			},
			loading: () => const SizedBox.shrink(),
			error: (_, __) => const SizedBox.shrink(),
		);
	}
}
