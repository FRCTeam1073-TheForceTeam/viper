import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'active_zone_provider.dart';

/// Timeline event entry: tracks when an action happened and its value
/// Format matches web app: time:field:value
class TeleTimelineEvent {
	final int timeSeconds; // Time since tele start
	final String action; // Field name (e.g., 'tele_fuel_score')
	final String value; // Numeric value as string (e.g., "1", "5", "-1")

	TeleTimelineEvent({
		required this.timeSeconds,
		required this.action,
		required this.value,
	});

	/// Convert to JSON for storage (matches web app format)
	Map<String, dynamic> toJson() => {
		'time': timeSeconds,
		'action': action,
		'value': value,
	};

	/// Create from JSON
	factory TeleTimelineEvent.fromJson(Map<String, dynamic> json) => TeleTimelineEvent(
		timeSeconds: json['time'] as int,
		action: json['action'] as String,
		value: json['value'] as String? ?? '1',
	);

	/// Format timeline list to string (time:action or time:action:value, space-separated)
	/// Value is omitted if it equals "1" for parity with web app
	static String formatTimeline(List<TeleTimelineEvent> events) {
		return events.map((e) => e.value == '1' ? '${e.timeSeconds}:${e.action}' : '${e.timeSeconds}:${e.action}:${e.value}').join(' ');
	}

	/// Parse timeline string to list of events (time:action or time:action:value, space-separated)
	/// Value defaults to "1" if not specified for parity with web app
	static List<TeleTimelineEvent> parseTimeline(String timelineStr) {
		final events = <TeleTimelineEvent>[];
		if (timelineStr.isEmpty) return events;

		final entries = timelineStr.split(' ');
		for (final entry in entries) {
			final parts = entry.split(':');
			if (parts.length == 2) {
				// Format: time:action (value defaults to "1")
				events.add(TeleTimelineEvent(
					timeSeconds: int.parse(parts[0]),
					action: parts[1],
					value: '1',
				));
			} else if (parts.length == 3) {
				// Format: time:action:value
				events.add(TeleTimelineEvent(
					timeSeconds: int.parse(parts[0]),
					action: parts[1],
					value: parts[2],
				));
			}
		}
		return events;
	}

	@override
	String toString() => '[$timeSeconds] $action ($value)';
}

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

	// Timeline of all events
	final List<TeleTimelineEvent> timeline;

	// Tele start time (to calculate relative timestamps)
	final DateTime? teleStartTime;

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
		this.timeline = const [],
		this.teleStartTime,
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
		List<TeleTimelineEvent>? timeline,
		DateTime? teleStartTime,
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
			timeline: timeline ?? this.timeline,
			teleStartTime: teleStartTime ?? this.teleStartTime,
			lastZoneChangeTime: lastZoneChangeTime ?? this.lastZoneChangeTime,
		);
	}

	/// Convert state to map for database storage
	Map<String, dynamic> toJson() {
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
			'tele_timeline': TeleTimelineEvent.formatTimeline(timeline),
		};
	}

	/// Load state from map (database)
	factory TeleTabState.fromJson(Map<String, dynamic> json) {
		final timeline = TeleTimelineEvent.parseTimeline(json['tele_timeline'] as String? ?? '');

		return TeleTabState(
			trenchDepotAllianceToNeutral: json['tele_trench_depot_alliance_to_neutral'] as int? ?? 0,
			bumpDepotAllianceToNeutral: json['tele_bump_depot_alliance_to_neutral'] as int? ?? 0,
			bumpOutpostAllianceToNeutral: json['tele_bump_outpost_alliance_to_neutral'] as int? ?? 0,
			trenchOutpostAllianceToNeutral: json['tele_trench_outpost_alliance_to_neutral'] as int? ?? 0,
			trenchDepotNeutralToAlliance: json['tele_trench_depot_neutral_to_alliance'] as int? ?? 0,
			bumpDepotNeutralToAlliance: json['tele_bump_depot_neutral_to_alliance'] as int? ?? 0,
			bumpOutpostNeutralToAlliance: json['tele_bump_outpost_neutral_to_alliance'] as int? ?? 0,
			trenchOutpostNeutralToAlliance: json['tele_trench_outpost_neutral_to_alliance'] as int? ?? 0,
			trenchOutpostNeutralToOpponent: json['tele_trench_outpost_neutral_to_opponent'] as int? ?? 0,
			bumpOutpostNeutralToOpponent: json['tele_bump_outpost_neutral_to_opponent'] as int? ?? 0,
			bumpDepotNeutralToOpponent: json['tele_bump_depot_neutral_to_opponent'] as int? ?? 0,
			trenchDepotNeutralToOpponent: json['tele_trench_depot_neutral_to_opponent'] as int? ?? 0,
			trenchOutpostOpponentToNeutral: json['tele_trench_outpost_opponent_to_neutral'] as int? ?? 0,
			bumpOutpostOpponentToNeutral: json['tele_bump_outpost_opponent_to_neutral'] as int? ?? 0,
			bumpDepotOpponentToNeutral: json['tele_bump_depot_opponent_to_neutral'] as int? ?? 0,
			trenchDepotOpponentToNeutral: json['tele_trench_depot_opponent_to_neutral'] as int? ?? 0,
			fuelScore: json['tele_fuel_score'] as int? ?? 0,
			fuelAllianceDump: json['tele_fuel_alliance_dump'] as int? ?? 0,
			fuelOutpost: json['tele_fuel_outpost'] as int? ?? 0,
			fuelNeutralAlliancePass: json['tele_fuel_neutral_alliance_pass'] as int? ?? 0,
			fuelOpponentNeutralPass: json['tele_fuel_opponent_neutral_pass'] as int? ?? 0,
			fuelOpponentAlliancePass: json['tele_fuel_opponent_alliance_pass'] as int? ?? 0,
			allianceTime: json['tele_alliance_time'] as int? ?? 0,
			neutralTime: json['tele_neutral_time'] as int? ?? 0,
			opponentTime: json['tele_opponent_time'] as int? ?? 0,
			climbLevel: json['tele_climb_level'] as int? ?? 0,
			activeZone: json['tele_active_zone'] as String? ?? 'alliance',
			activeFuelTarget: json['tele_active_fuel_target'] as String? ?? 'hub',
			timeline: timeline,
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
		final startTime = state.teleStartTime ?? now;
		final elapsed = now.difference(startTime).inSeconds;

		// Create timeline event
		final event = TeleTimelineEvent(
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

		// Add event to timeline
		final newTimeline = [...newState.timeline, event];

		// Update state - set teleStartTime only on first action if not already set
		state = newState.copyWith(
			timeline: newTimeline,
			teleStartTime: state.teleStartTime ?? now,
			lastZoneChangeTime: newState.lastZoneChangeTime ?? state.lastZoneChangeTime ?? now,
		);
	}

	/// Undo the last action
	void undo() {
		if (state.timeline.isEmpty) return;

		final lastEvent = state.timeline.last;
		final newTimeline = state.timeline.toList()..removeLast();

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

		// Update timeline and reset timer if empty
		if (newTimeline.isEmpty) {
			state = TeleTabState(
				trenchDepotAllianceToNeutral: newState.trenchDepotAllianceToNeutral,
				bumpDepotAllianceToNeutral: newState.bumpDepotAllianceToNeutral,
				bumpOutpostAllianceToNeutral: newState.bumpOutpostAllianceToNeutral,
				trenchOutpostAllianceToNeutral: newState.trenchOutpostAllianceToNeutral,
				trenchDepotNeutralToAlliance: newState.trenchDepotNeutralToAlliance,
				bumpDepotNeutralToAlliance: newState.bumpDepotNeutralToAlliance,
				bumpOutpostNeutralToAlliance: newState.bumpOutpostNeutralToAlliance,
				trenchOutpostNeutralToAlliance: newState.trenchOutpostNeutralToAlliance,
				trenchOutpostNeutralToOpponent: newState.trenchOutpostNeutralToOpponent,
				bumpOutpostNeutralToOpponent: newState.bumpOutpostNeutralToOpponent,
				bumpDepotNeutralToOpponent: newState.bumpDepotNeutralToOpponent,
				trenchDepotNeutralToOpponent: newState.trenchDepotNeutralToOpponent,
				trenchOutpostOpponentToNeutral: newState.trenchOutpostOpponentToNeutral,
				bumpOutpostOpponentToNeutral: newState.bumpOutpostOpponentToNeutral,
				bumpDepotOpponentToNeutral: newState.bumpDepotOpponentToNeutral,
				trenchDepotOpponentToNeutral: newState.trenchDepotOpponentToNeutral,
				fuelScore: newState.fuelScore,
				fuelAllianceDump: newState.fuelAllianceDump,
				fuelOutpost: newState.fuelOutpost,
				fuelNeutralAlliancePass: newState.fuelNeutralAlliancePass,
				fuelOpponentNeutralPass: newState.fuelOpponentNeutralPass,
				fuelOpponentAlliancePass: newState.fuelOpponentAlliancePass,
				allianceTime: newState.allianceTime,
				neutralTime: newState.neutralTime,
				opponentTime: newState.opponentTime,
				climbLevel: newState.climbLevel,
				activeZone: newState.activeZone,
				activeFuelTarget: newState.activeFuelTarget,
				timeline: newTimeline,
				teleStartTime: null,
			);
		} else {
			state = newState.copyWith(timeline: newTimeline);
		}
	}

	/// Change fuel target to specific target
	void changeFuelTarget(String targetName) {
		if (state.activeFuelTarget == targetName) {
			return; // Already on target
		}
		state = state.copyWith(activeFuelTarget: targetName);
	}

	/// Load state from data map
	void loadFromData(Map<String, dynamic> data) {
		state = TeleTabState.fromJson(data);
		// Sync active zone with shared provider
		final sharedZone = _ref.read(activeZoneProvider);
		state = state.copyWith(activeZone: sharedZone);
	}

	/// Get all counters as map for database save
	Map<String, dynamic> getCountersForSave() => state.toJson();
}

/// Riverpod provider for tele tab controller
final teleTabControllerProvider = StateNotifierProvider<TeleTabNotifier, TeleTabState>((ref) {
	return TeleTabNotifier(ref);
});
