import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'active_zone_provider.dart';
import 'auto_tab_controller.dart' show TimelineEvent;
import 'timeline_provider.dart';
import 'match_timer_provider.dart';


/// State for tele tab - tracks all counters and timeline
class TeleTabState {
	// Movement counters (alliance ↔ neutral)
	final int trenchDepotAllianceToNeutral;
	final int bumpDepotAllianceToNeutral;
	final int bumpOutpostAllianceToNeutral;
	final int trenchOutpostAllianceToNeutral;
	final int trenchDepotNeutralToAlliance;
	final int bumpDepotNeutralToAlliance;
	final int bumpOutpostNeutralToAlliance;
	final int trenchOutpostNeutralToAlliance;

	// Movement counters (neutral ↔ opponent)
	final int trenchOutpostNeutralToOpponent;
	final int bumpOutpostNeutralToOpponent;
	final int bumpDepotNeutralToOpponent;
	final int trenchDepotNeutralToOpponent;
	final int trenchOutpostOpponentToNeutral;
	final int bumpOutpostOpponentToNeutral;
	final int bumpDepotOpponentToNeutral;
	final int trenchDepotOpponentToNeutral;

	// Fuel scoring
	final int fuelScore;
	final int fuelAllianceDump;
	final int fuelOutpost;
	final int fuelNeutralAlliancePass;
	final int fuelOpponentNeutralPass;
	final int fuelOpponentAlliancePass;

	// Zone times
	final int allianceTime;
	final int neutralTime;
	final int opponentTime;

	// Climb level
	final int climbLevel;

	// Active zone for button filtering ('alliance', 'neutral', or 'opponent')
	final String activeZone;

	// Active fuel target
	final String activeFuelTarget;

	// Last zone change time (to calculate time spent in zone)
	final DateTime? lastZoneChangeTime;

	TeleTabState({
		this.trenchDepotAllianceToNeutral = 0,
		this.bumpDepotAllianceToNeutral = 0,
		this.bumpOutpostAllianceToNeutral = 0,
		this.trenchOutpostAllianceToNeutral = 0,
		this.trenchDepotNeutralToAlliance = 0,
		this.bumpDepotNeutralToAlliance = 0,
		this.bumpOutpostNeutralToAlliance = 0,
		this.trenchOutpostNeutralToAlliance = 0,
		this.trenchOutpostNeutralToOpponent = 0,
		this.bumpOutpostNeutralToOpponent = 0,
		this.bumpDepotNeutralToOpponent = 0,
		this.trenchDepotNeutralToOpponent = 0,
		this.trenchOutpostOpponentToNeutral = 0,
		this.bumpOutpostOpponentToNeutral = 0,
		this.bumpDepotOpponentToNeutral = 0,
		this.trenchDepotOpponentToNeutral = 0,
		this.fuelScore = 0,
		this.fuelAllianceDump = 0,
		this.fuelOutpost = 0,
		this.fuelNeutralAlliancePass = 0,
		this.fuelOpponentNeutralPass = 0,
		this.fuelOpponentAlliancePass = 0,
		this.allianceTime = 0,
		this.neutralTime = 0,
		this.opponentTime = 0,
		this.climbLevel = 0,
		this.activeZone = 'alliance',
		this.activeFuelTarget = 'hub',
		this.lastZoneChangeTime,
	});

	/// Create a copy with updated fields
	TeleTabState copyWith({
		int? trenchDepotAllianceToNeutral,
		int? bumpDepotAllianceToNeutral,
		int? bumpOutpostAllianceToNeutral,
		int? trenchOutpostAllianceToNeutral,
		int? trenchDepotNeutralToAlliance,
		int? bumpDepotNeutralToAlliance,
		int? bumpOutpostNeutralToAlliance,
		int? trenchOutpostNeutralToAlliance,
		int? trenchOutpostNeutralToOpponent,
		int? bumpOutpostNeutralToOpponent,
		int? bumpDepotNeutralToOpponent,
		int? trenchDepotNeutralToOpponent,
		int? trenchOutpostOpponentToNeutral,
		int? bumpOutpostOpponentToNeutral,
		int? bumpDepotOpponentToNeutral,
		int? trenchDepotOpponentToNeutral,
		int? fuelScore,
		int? fuelAllianceDump,
		int? fuelOutpost,
		int? fuelNeutralAlliancePass,
		int? fuelOpponentNeutralPass,
		int? fuelOpponentAlliancePass,
		int? allianceTime,
		int? neutralTime,
		int? opponentTime,
		int? climbLevel,
		String? activeZone,
		String? activeFuelTarget,
		DateTime? lastZoneChangeTime,
	}) {
		return TeleTabState(
			trenchDepotAllianceToNeutral: trenchDepotAllianceToNeutral ?? this.trenchDepotAllianceToNeutral,
			bumpDepotAllianceToNeutral: bumpDepotAllianceToNeutral ?? this.bumpDepotAllianceToNeutral,
			bumpOutpostAllianceToNeutral: bumpOutpostAllianceToNeutral ?? this.bumpOutpostAllianceToNeutral,
			trenchOutpostAllianceToNeutral: trenchOutpostAllianceToNeutral ?? this.trenchOutpostAllianceToNeutral,
			trenchDepotNeutralToAlliance: trenchDepotNeutralToAlliance ?? this.trenchDepotNeutralToAlliance,
			bumpDepotNeutralToAlliance: bumpDepotNeutralToAlliance ?? this.bumpDepotNeutralToAlliance,
			bumpOutpostNeutralToAlliance: bumpOutpostNeutralToAlliance ?? this.bumpOutpostNeutralToAlliance,
			trenchOutpostNeutralToAlliance: trenchOutpostNeutralToAlliance ?? this.trenchOutpostNeutralToAlliance,
			trenchOutpostNeutralToOpponent: trenchOutpostNeutralToOpponent ?? this.trenchOutpostNeutralToOpponent,
			bumpOutpostNeutralToOpponent: bumpOutpostNeutralToOpponent ?? this.bumpOutpostNeutralToOpponent,
			bumpDepotNeutralToOpponent: bumpDepotNeutralToOpponent ?? this.bumpDepotNeutralToOpponent,
			trenchDepotNeutralToOpponent: trenchDepotNeutralToOpponent ?? this.trenchDepotNeutralToOpponent,
			trenchOutpostOpponentToNeutral: trenchOutpostOpponentToNeutral ?? this.trenchOutpostOpponentToNeutral,
			bumpOutpostOpponentToNeutral: bumpOutpostOpponentToNeutral ?? this.bumpOutpostOpponentToNeutral,
			bumpDepotOpponentToNeutral: bumpDepotOpponentToNeutral ?? this.bumpDepotOpponentToNeutral,
			trenchDepotOpponentToNeutral: trenchDepotOpponentToNeutral ?? this.trenchDepotOpponentToNeutral,
			fuelScore: fuelScore ?? this.fuelScore,
			fuelAllianceDump: fuelAllianceDump ?? this.fuelAllianceDump,
			fuelOutpost: fuelOutpost ?? this.fuelOutpost,
			fuelNeutralAlliancePass: fuelNeutralAlliancePass ?? this.fuelNeutralAlliancePass,
			fuelOpponentNeutralPass: fuelOpponentNeutralPass ?? this.fuelOpponentNeutralPass,
			fuelOpponentAlliancePass: fuelOpponentAlliancePass ?? this.fuelOpponentAlliancePass,
			allianceTime: allianceTime ?? this.allianceTime,
			neutralTime: neutralTime ?? this.neutralTime,
			opponentTime: opponentTime ?? this.opponentTime,
			climbLevel: climbLevel ?? this.climbLevel,
			activeZone: activeZone ?? this.activeZone,
			activeFuelTarget: activeFuelTarget ?? this.activeFuelTarget,
			lastZoneChangeTime: lastZoneChangeTime ?? this.lastZoneChangeTime,
		);
	}

	/// Convert state to map for database storage (does not include timeline - handled separately)
	Map<String, dynamic> toMap() {
		return {
			'tele_trench_depot_alliance_to_neutral': trenchDepotAllianceToNeutral,
			'tele_bump_depot_alliance_to_neutral': bumpDepotAllianceToNeutral,
			'tele_bump_outpost_alliance_to_neutral': bumpOutpostAllianceToNeutral,
			'tele_trench_outpost_alliance_to_neutral': trenchOutpostAllianceToNeutral,
			'tele_trench_depot_neutral_to_alliance': trenchDepotNeutralToAlliance,
			'tele_bump_depot_neutral_to_alliance': bumpDepotNeutralToAlliance,
			'tele_bump_outpost_neutral_to_alliance': bumpOutpostNeutralToAlliance,
			'tele_trench_outpost_neutral_to_alliance': trenchOutpostNeutralToAlliance,
			'tele_trench_outpost_neutral_to_opponent': trenchOutpostNeutralToOpponent,
			'tele_bump_outpost_neutral_to_opponent': bumpOutpostNeutralToOpponent,
			'tele_bump_depot_neutral_to_opponent': bumpDepotNeutralToOpponent,
			'tele_trench_depot_neutral_to_opponent': trenchDepotNeutralToOpponent,
			'tele_trench_outpost_opponent_to_neutral': trenchOutpostOpponentToNeutral,
			'tele_bump_outpost_opponent_to_neutral': bumpOutpostOpponentToNeutral,
			'tele_bump_depot_opponent_to_neutral': bumpDepotOpponentToNeutral,
			'tele_trench_depot_opponent_to_neutral': trenchDepotOpponentToNeutral,
			'tele_fuel_score': fuelScore,
			'tele_fuel_alliance_dump': fuelAllianceDump,
			'tele_fuel_outpost': fuelOutpost,
			'tele_fuel_neutral_alliance_pass': fuelNeutralAlliancePass,
			'tele_fuel_opponent_neutral_pass': fuelOpponentNeutralPass,
			'tele_fuel_opponent_alliance_pass': fuelOpponentAlliancePass,
			'tele_alliance_time': allianceTime,
			'tele_neutral_time': neutralTime,
			'tele_opponent_time': opponentTime,
			'tele_climb_level': climbLevel,
		};
	}

	/// Load state from map (database) - does not include timeline, handled separately
	factory TeleTabState.fromMap(Map<String, dynamic> data) {
		return TeleTabState(
			trenchDepotAllianceToNeutral: data['tele_trench_depot_alliance_to_neutral'] as int? ?? 0,
			bumpDepotAllianceToNeutral: data['tele_bump_depot_alliance_to_neutral'] as int? ?? 0,
			bumpOutpostAllianceToNeutral: data['tele_bump_outpost_alliance_to_neutral'] as int? ?? 0,
			trenchOutpostAllianceToNeutral: data['tele_trench_outpost_alliance_to_neutral'] as int? ?? 0,
			trenchDepotNeutralToAlliance: data['tele_trench_depot_neutral_to_alliance'] as int? ?? 0,
			bumpDepotNeutralToAlliance: data['tele_bump_depot_neutral_to_alliance'] as int? ?? 0,
			bumpOutpostNeutralToAlliance: data['tele_bump_outpost_neutral_to_alliance'] as int? ?? 0,
			trenchOutpostNeutralToAlliance: data['tele_trench_outpost_neutral_to_alliance'] as int? ?? 0,
			trenchOutpostNeutralToOpponent: data['tele_trench_outpost_neutral_to_opponent'] as int? ?? 0,
			bumpOutpostNeutralToOpponent: data['tele_bump_outpost_neutral_to_opponent'] as int? ?? 0,
			bumpDepotNeutralToOpponent: data['tele_bump_depot_neutral_to_opponent'] as int? ?? 0,
			trenchDepotNeutralToOpponent: data['tele_trench_depot_neutral_to_opponent'] as int? ?? 0,
			trenchOutpostOpponentToNeutral: data['tele_trench_outpost_opponent_to_neutral'] as int? ?? 0,
			bumpOutpostOpponentToNeutral: data['tele_bump_outpost_opponent_to_neutral'] as int? ?? 0,
			bumpDepotOpponentToNeutral: data['tele_bump_depot_opponent_to_neutral'] as int? ?? 0,
			trenchDepotOpponentToNeutral: data['tele_trench_depot_opponent_to_neutral'] as int? ?? 0,
			fuelScore: data['tele_fuel_score'] as int? ?? 0,
			fuelAllianceDump: data['tele_fuel_alliance_dump'] as int? ?? 0,
			fuelOutpost: data['tele_fuel_outpost'] as int? ?? 0,
			fuelNeutralAlliancePass: data['tele_fuel_neutral_alliance_pass'] as int? ?? 0,
			fuelOpponentNeutralPass: data['tele_fuel_opponent_neutral_pass'] as int? ?? 0,
			fuelOpponentAlliancePass: data['tele_fuel_opponent_alliance_pass'] as int? ?? 0,
			allianceTime: data['tele_alliance_time'] as int? ?? 0,
			neutralTime: data['tele_neutral_time'] as int? ?? 0,
			opponentTime: data['tele_opponent_time'] as int? ?? 0,
			climbLevel: data['tele_climb_level'] as int? ?? 0,
			activeZone: data['tele_active_zone'] as String? ?? 'alliance',
			activeFuelTarget: data['tele_active_fuel_target'] as String? ?? 'hub',
		);
	}
}

/// Controller for tele tab state
class TeleTabNotifier extends StateNotifier<TeleTabState> {
	final Ref _ref;

	TeleTabNotifier(this._ref) : super(TeleTabState()) {
		// Initialize active zone from shared provider
		state = state.copyWith(activeZone: _ref.read(activeZoneProvider));
	}

	/// Record an action (button click, fuel add, etc.)
	void recordAction({
		required String type, // 'movement', 'fuel', 'climb'
		required String field, // Field name
		required int value, // Value to add
		required String actionLabel, // Label for timeline
		required String valueLabel, // Value label for timeline
	}) {
		final now = DateTime.now();
		final matchStartTime = _ref.read(matchTimerProvider);
		final startTime = matchStartTime ?? now;
		final elapsed = now.difference(startTime).inSeconds;

		// Create timeline event
		final event = TimelineEvent(
			timeSeconds: elapsed,
			action: field,
			value: value.toString(),
		);

		// Update appropriate counter based on field
		TeleTabState newState = state;

		// Determine if this is a zone transition and calculate elapsed time in current zone
		String? newZone;
		if (field.endsWith('_to_neutral')) {
			newZone = 'neutral';
		} else if (field.endsWith('_to_alliance')) {
			newZone = 'alliance';
		} else if (field.endsWith('_to_opponent')) {
			newZone = 'opponent';
		}

		// If zone is changing, calculate time spent in previous zone and update counter
		if (newZone != null && newZone != state.activeZone) {
			final lastZoneTime = state.lastZoneChangeTime ?? startTime;
			final zoneElapsedSeconds = now.difference(lastZoneTime).inSeconds;

			if (state.activeZone == 'alliance' && zoneElapsedSeconds > 0) {
				newState = newState.copyWith(
					allianceTime: newState.allianceTime + zoneElapsedSeconds,
				);
			} else if (state.activeZone == 'neutral' && zoneElapsedSeconds > 0) {
				newState = newState.copyWith(
					neutralTime: newState.neutralTime + zoneElapsedSeconds,
				);
			} else if (state.activeZone == 'opponent' && zoneElapsedSeconds > 0) {
				newState = newState.copyWith(
					opponentTime: newState.opponentTime + zoneElapsedSeconds,
				);
			}
			// Update shared active zone provider
			_ref.read(activeZoneProvider.notifier).state = newZone;
		}

		// Update counters based on field name
		switch (field) {
			case 'tele_trench_depot_alliance_to_neutral':
				newState = newState.copyWith(
					trenchDepotAllianceToNeutral: newState.trenchDepotAllianceToNeutral + value,
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_bump_depot_alliance_to_neutral':
				newState = newState.copyWith(
					bumpDepotAllianceToNeutral: newState.bumpDepotAllianceToNeutral + value,
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_bump_outpost_alliance_to_neutral':
				newState = newState.copyWith(
					bumpOutpostAllianceToNeutral: newState.bumpOutpostAllianceToNeutral + value,
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_trench_outpost_alliance_to_neutral':
				newState = newState.copyWith(
					trenchOutpostAllianceToNeutral: newState.trenchOutpostAllianceToNeutral + value,
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_trench_depot_neutral_to_alliance':
				newState = newState.copyWith(
					trenchDepotNeutralToAlliance: newState.trenchDepotNeutralToAlliance + value,
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: now,
				);
			case 'tele_bump_depot_neutral_to_alliance':
				newState = newState.copyWith(
					bumpDepotNeutralToAlliance: newState.bumpDepotNeutralToAlliance + value,
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: now,
				);
			case 'tele_bump_outpost_neutral_to_alliance':
				newState = newState.copyWith(
					bumpOutpostNeutralToAlliance: newState.bumpOutpostNeutralToAlliance + value,
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: now,
				);
			case 'tele_trench_outpost_neutral_to_alliance':
				newState = newState.copyWith(
					trenchOutpostNeutralToAlliance: newState.trenchOutpostNeutralToAlliance + value,
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: now,
				);
			case 'tele_trench_outpost_neutral_to_opponent':
				newState = newState.copyWith(
					trenchOutpostNeutralToOpponent: newState.trenchOutpostNeutralToOpponent + value,
					activeZone: 'opponent',
					activeFuelTarget: 'opponentAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_bump_outpost_neutral_to_opponent':
				newState = newState.copyWith(
					bumpOutpostNeutralToOpponent: newState.bumpOutpostNeutralToOpponent + value,
					activeZone: 'opponent',
					activeFuelTarget: 'opponentAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_bump_depot_neutral_to_opponent':
				newState = newState.copyWith(
					bumpDepotNeutralToOpponent: newState.bumpDepotNeutralToOpponent + value,
					activeZone: 'opponent',
					activeFuelTarget: 'opponentAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_trench_depot_neutral_to_opponent':
				newState = newState.copyWith(
					trenchDepotNeutralToOpponent: newState.trenchDepotNeutralToOpponent + value,
					activeZone: 'opponent',
					activeFuelTarget: 'opponentAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_trench_outpost_opponent_to_neutral':
				newState = newState.copyWith(
					trenchOutpostOpponentToNeutral: newState.trenchOutpostOpponentToNeutral + value,
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_bump_outpost_opponent_to_neutral':
				newState = newState.copyWith(
					bumpOutpostOpponentToNeutral: newState.bumpOutpostOpponentToNeutral + value,
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_bump_depot_opponent_to_neutral':
				newState = newState.copyWith(
					bumpDepotOpponentToNeutral: newState.bumpDepotOpponentToNeutral + value,
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_trench_depot_opponent_to_neutral':
				newState = newState.copyWith(
					trenchDepotOpponentToNeutral: newState.trenchDepotOpponentToNeutral + value,
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_fuel_score':
				newState = newState.copyWith(fuelScore: newState.fuelScore + value);
			case 'tele_fuel_alliance_dump':
				newState = newState.copyWith(fuelAllianceDump: newState.fuelAllianceDump + value);
			case 'tele_fuel_outpost':
				newState = newState.copyWith(fuelOutpost: newState.fuelOutpost + value);
			case 'tele_fuel_neutral_alliance_pass':
				newState = newState.copyWith(
					fuelNeutralAlliancePass: newState.fuelNeutralAlliancePass + value,
				);
			case 'tele_fuel_opponent_alliance_pass':
				newState = newState.copyWith(
					fuelOpponentAlliancePass: newState.fuelOpponentAlliancePass + value,
				);
			case 'tele_fuel_opponent_neutral_pass':
				newState = newState.copyWith(
					fuelOpponentNeutralPass: newState.fuelOpponentNeutralPass + value,
				);
			case 'tele_climb_level':
				newState = newState.copyWith(climbLevel: value);
		}

		// Add event to shared timeline provider
		_ref.read(timelineProvider.notifier).addEvent(event);

		// Update state
		state = newState.copyWith(
			lastZoneChangeTime: newState.lastZoneChangeTime ?? state.lastZoneChangeTime ?? now,
		);
	}

	/// Undo the last action
	void undo() {
		final currentTimeline = _ref.read(timelineProvider);
		if (currentTimeline.isEmpty) return;

		final lastEvent = currentTimeline.last;

		// Parse field name and value from timeline event
		final field = lastEvent.action;
		final actionValue = int.tryParse(lastEvent.value) ?? 1;

		// Reverse the action
		TeleTabState newState = state;
		switch (field) {
			case 'tele_trench_depot_alliance_to_neutral':
				newState = newState.copyWith(
					trenchDepotAllianceToNeutral:
						(newState.trenchDepotAllianceToNeutral - actionValue).clamp(0, 999),
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'alliance';
			case 'tele_bump_depot_alliance_to_neutral':
				newState = newState.copyWith(
					bumpDepotAllianceToNeutral:
						(newState.bumpDepotAllianceToNeutral - actionValue).clamp(0, 999),
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'alliance';
			case 'tele_bump_outpost_alliance_to_neutral':
				newState = newState.copyWith(
					bumpOutpostAllianceToNeutral:
						(newState.bumpOutpostAllianceToNeutral - actionValue).clamp(0, 999),
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'alliance';
			case 'tele_trench_outpost_alliance_to_neutral':
				newState = newState.copyWith(
					trenchOutpostAllianceToNeutral:
						(newState.trenchOutpostAllianceToNeutral - actionValue).clamp(0, 999),
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'alliance';
			case 'tele_trench_depot_neutral_to_alliance':
				newState = newState.copyWith(
					trenchDepotNeutralToAlliance:
						(newState.trenchDepotNeutralToAlliance - actionValue).clamp(0, 999),
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'neutral';
			case 'tele_bump_depot_neutral_to_alliance':
				newState = newState.copyWith(
					bumpDepotNeutralToAlliance:
						(newState.bumpDepotNeutralToAlliance - actionValue).clamp(0, 999),
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'neutral';
			case 'tele_bump_outpost_neutral_to_alliance':
				newState = newState.copyWith(
					bumpOutpostNeutralToAlliance:
						(newState.bumpOutpostNeutralToAlliance - actionValue).clamp(0, 999),
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'neutral';
			case 'tele_trench_outpost_neutral_to_alliance':
				newState = newState.copyWith(
					trenchOutpostNeutralToAlliance:
						(newState.trenchOutpostNeutralToAlliance - actionValue).clamp(0, 999),
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'neutral';
			case 'tele_trench_outpost_neutral_to_opponent':
				newState = newState.copyWith(
					trenchOutpostNeutralToOpponent:
						(newState.trenchOutpostNeutralToOpponent - actionValue).clamp(0, 999),
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'neutral';
			case 'tele_bump_outpost_neutral_to_opponent':
				newState = newState.copyWith(
					bumpOutpostNeutralToOpponent:
						(newState.bumpOutpostNeutralToOpponent - actionValue).clamp(0, 999),
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'neutral';
			case 'tele_bump_depot_neutral_to_opponent':
				newState = newState.copyWith(
					bumpDepotNeutralToOpponent:
						(newState.bumpDepotNeutralToOpponent - actionValue).clamp(0, 999),
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'neutral';
			case 'tele_trench_depot_neutral_to_opponent':
				newState = newState.copyWith(
					trenchDepotNeutralToOpponent:
						(newState.trenchDepotNeutralToOpponent - actionValue).clamp(0, 999),
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'neutral';
			case 'tele_trench_outpost_opponent_to_neutral':
				newState = newState.copyWith(
					trenchOutpostOpponentToNeutral:
						(newState.trenchOutpostOpponentToNeutral - actionValue).clamp(0, 999),
					activeZone: 'opponent',
					activeFuelTarget: 'opponentAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'opponent';
			case 'tele_bump_outpost_opponent_to_neutral':
				newState = newState.copyWith(
					bumpOutpostOpponentToNeutral:
						(newState.bumpOutpostOpponentToNeutral - actionValue).clamp(0, 999),
					activeZone: 'opponent',
					activeFuelTarget: 'opponentAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'opponent';
			case 'tele_bump_depot_opponent_to_neutral':
				newState = newState.copyWith(
					bumpDepotOpponentToNeutral:
						(newState.bumpDepotOpponentToNeutral - actionValue).clamp(0, 999),
					activeZone: 'opponent',
					activeFuelTarget: 'opponentAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'opponent';
			case 'tele_trench_depot_opponent_to_neutral':
				newState = newState.copyWith(
					trenchDepotOpponentToNeutral:
						(newState.trenchDepotOpponentToNeutral - actionValue).clamp(0, 999),
					activeZone: 'opponent',
					activeFuelTarget: 'opponentAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'opponent';
			case 'tele_fuel_score':
				newState = newState.copyWith(
					fuelScore: (newState.fuelScore - actionValue).clamp(0, 999),
				);
			case 'tele_fuel_alliance_dump':
				newState = newState.copyWith(
					fuelAllianceDump: (newState.fuelAllianceDump - actionValue).clamp(0, 999),
				);
			case 'tele_fuel_outpost':
				newState = newState.copyWith(
					fuelOutpost: (newState.fuelOutpost - actionValue).clamp(0, 999),
				);
			case 'tele_fuel_neutral_alliance_pass':
				newState = newState.copyWith(
					fuelNeutralAlliancePass:
						(newState.fuelNeutralAlliancePass - actionValue).clamp(0, 999),
				);
			case 'tele_fuel_opponent_alliance_pass':
				newState = newState.copyWith(
					fuelOpponentAlliancePass:
						(newState.fuelOpponentAlliancePass - actionValue).clamp(0, 999),
				);
			case 'tele_fuel_opponent_neutral_pass':
				newState = newState.copyWith(
					fuelOpponentNeutralPass:
						(newState.fuelOpponentNeutralPass - actionValue).clamp(0, 999),
				);
			case 'tele_climb_level':
				newState = newState.copyWith(climbLevel: actionValue);
		}

		// Remove event from shared timeline provider
		_ref.read(timelineProvider.notifier).undo();

		// Update state (no need to reset anything, match timer is shared)
		state = newState;
	}

	/// Reset tele state for new match
	void reset() {
		state = TeleTabState();
	}

	/// Start tele (initialize start time) - syncs with UI timer
	void startTele() {
		final now = DateTime.now();
		_ref.read(matchTimerProvider.notifier).setStartTime(now);
	}

	/// Sync tele start time with external match timer (called when UI timer starts)
	void syncStartTime(DateTime matchStartTime) {
		// Always sync the shared match timer
		if (_ref.read(matchTimerProvider) == null) {
			_ref.read(matchTimerProvider.notifier).setStartTime(matchStartTime);
		}
	}

	/// Change fuel target to specific target
	void changeFuelTarget(String targetName) {
		if (state.activeFuelTarget == targetName) {
			return; // Already on target
		}
		state = state.copyWith(activeFuelTarget: targetName);
	}

	/// Load state from data map and populate timeline provider
	void loadFromData(Map<String, dynamic> data, {bool isFirstLoad = false}) {
		if (isFirstLoad) {
			// Reset to start fresh before loading existing data
			reset();
			state = TeleTabState.fromMap(data);
			// Sync active zone with shared provider
			final sharedZone = _ref.read(activeZoneProvider);
			state = state.copyWith(activeZone: sharedZone);
			// Timeline is kept empty so new button clicks record fresh events
			_ref.read(timelineProvider.notifier).clear();
		}
	}

	/// Get all counters and timeline as map for database save
	Map<String, dynamic> getCountersForSave() {
		final counters = state.toMap();
		// Add timeline to the save data
		final timeline = _ref.read(timelineProvider);
		counters['timeline'] = TimelineEvent.formatTimeline(timeline);
		return counters;
	}
}

/// Riverpod provider for tele tab controller
final teleTabControllerProvider = StateNotifierProvider<TeleTabNotifier, TeleTabState>((ref) {
	return TeleTabNotifier(ref);
});
