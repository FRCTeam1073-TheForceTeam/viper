import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

/// Timeline event entry: tracks when an action happened and its value
/// Format matches web app: time:field:value
class TimelineEvent {
	final int timeSeconds; // Time since auto start
	final String action; // Field name (e.g., 'auto_trench_depot_alliance_to_neutral')
	final String value; // Numeric value as string (e.g., "1", "5", "-1")

	TimelineEvent({
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
	factory TimelineEvent.fromJson(Map<String, dynamic> json) => TimelineEvent(
		timeSeconds: json['time'] as int,
		action: json['action'] as String,
		value: json['value'] as String? ?? '1',
	);

	@override
	String toString() => '[$timeSeconds] $action ($value)';
}

/// State for auto tab - tracks all counters and timeline
class AutoTabState {
	// Movement counters (field interactions)
	final int trenchDepotAllianceToNeutral;
	final int bumpDepotAllianceToNeutral;
	final int bumpOutpostAllianceToNeutral;
	final int trenchOutpostAllianceToNeutral;
	final int trenchDepotNeutralToAlliance;
	final int bumpDepotNeutralToAlliance;
	final int bumpOutpostNeutralToAlliance;
	final int trenchOutpostNeutralToAlliance;

	// Fuel and collection
	final int fuelScore; // Fuel shot in hub
	final int fuelNeutralAlliancePass; // Fuel passed from neutral
	final bool collectOutpost;
	final bool collectDepot;

	// Zone times
	final int allianceTime;
	final int neutralTime;

	// Climb level
	final int climbLevel;

	// Active zone for button filtering ('alliance' or 'neutral')
	final String activeZone;

	// Active fuel target ('hub' or 'alliancePass')
	final String activeFuelTarget;

	// Timeline of all events
	final List<TimelineEvent> timeline;

	// Auto start time (to calculate relative timestamps)
	final DateTime? autoStartTime;

	// Last zone change time (to calculate time spent in zone)
	final DateTime? lastZoneChangeTime;

	AutoTabState({
		this.trenchDepotAllianceToNeutral = 0,
		this.bumpDepotAllianceToNeutral = 0,
		this.bumpOutpostAllianceToNeutral = 0,
		this.trenchOutpostAllianceToNeutral = 0,
		this.trenchDepotNeutralToAlliance = 0,
		this.bumpDepotNeutralToAlliance = 0,
		this.bumpOutpostNeutralToAlliance = 0,
		this.trenchOutpostNeutralToAlliance = 0,
		this.fuelScore = 0,
		this.fuelNeutralAlliancePass = 0,
		this.collectOutpost = false,
		this.collectDepot = false,
		this.allianceTime = 0,
		this.neutralTime = 0,
		this.climbLevel = 0,
		this.activeZone = 'alliance',
		this.activeFuelTarget = 'hub',
		this.timeline = const [],
		this.autoStartTime,
		this.lastZoneChangeTime,
	});

	/// Create a copy with updated fields
	AutoTabState copyWith({
		int? trenchDepotAllianceToNeutral,
		int? bumpDepotAllianceToNeutral,
		int? bumpOutpostAllianceToNeutral,
		int? trenchOutpostAllianceToNeutral,
		int? trenchDepotNeutralToAlliance,
		int? bumpDepotNeutralToAlliance,
		int? bumpOutpostNeutralToAlliance,
		int? trenchOutpostNeutralToAlliance,
		int? fuelScore,
		int? fuelNeutralAlliancePass,
		bool? collectOutpost,
		bool? collectDepot,
		int? allianceTime,
		int? neutralTime,
		int? climbLevel,
		String? activeZone,
		String? activeFuelTarget,
		List<TimelineEvent>? timeline,
		DateTime? autoStartTime,
		DateTime? lastZoneChangeTime,
	}) {
		return AutoTabState(
			trenchDepotAllianceToNeutral: trenchDepotAllianceToNeutral ?? this.trenchDepotAllianceToNeutral,
			bumpDepotAllianceToNeutral: bumpDepotAllianceToNeutral ?? this.bumpDepotAllianceToNeutral,
			bumpOutpostAllianceToNeutral: bumpOutpostAllianceToNeutral ?? this.bumpOutpostAllianceToNeutral,
			trenchOutpostAllianceToNeutral: trenchOutpostAllianceToNeutral ?? this.trenchOutpostAllianceToNeutral,
			trenchDepotNeutralToAlliance: trenchDepotNeutralToAlliance ?? this.trenchDepotNeutralToAlliance,
			bumpDepotNeutralToAlliance: bumpDepotNeutralToAlliance ?? this.bumpDepotNeutralToAlliance,
			bumpOutpostNeutralToAlliance: bumpOutpostNeutralToAlliance ?? this.bumpOutpostNeutralToAlliance,
			trenchOutpostNeutralToAlliance: trenchOutpostNeutralToAlliance ?? this.trenchOutpostNeutralToAlliance,
			fuelScore: fuelScore ?? this.fuelScore,
			fuelNeutralAlliancePass: fuelNeutralAlliancePass ?? this.fuelNeutralAlliancePass,
			collectOutpost: collectOutpost ?? this.collectOutpost,
			collectDepot: collectDepot ?? this.collectDepot,
			allianceTime: allianceTime ?? this.allianceTime,
			neutralTime: neutralTime ?? this.neutralTime,
			climbLevel: climbLevel ?? this.climbLevel,
			activeZone: activeZone ?? this.activeZone,
			activeFuelTarget: activeFuelTarget ?? this.activeFuelTarget,
			timeline: timeline ?? this.timeline,
			autoStartTime: autoStartTime ?? this.autoStartTime,
			lastZoneChangeTime: lastZoneChangeTime ?? this.lastZoneChangeTime,
		);
	}

	/// Convert state to map for database storage
	Map<String, dynamic> toJson() {
		return {
			'auto_trench_depot_alliance_to_neutral': trenchDepotAllianceToNeutral,
			'auto_bump_depot_alliance_to_neutral': bumpDepotAllianceToNeutral,
			'auto_bump_outpost_alliance_to_neutral': bumpOutpostAllianceToNeutral,
			'auto_trench_outpost_alliance_to_neutral': trenchOutpostAllianceToNeutral,
			'auto_trench_depot_neutral_to_alliance': trenchDepotNeutralToAlliance,
			'auto_bump_depot_neutral_to_alliance': bumpDepotNeutralToAlliance,
			'auto_bump_outpost_neutral_to_alliance': bumpOutpostNeutralToAlliance,
			'auto_trench_outpost_neutral_to_alliance': trenchOutpostNeutralToAlliance,
			'auto_fuel_score': fuelScore,
			'auto_fuel_neutral_alliance_pass': fuelNeutralAlliancePass,
			'auto_collect_outpost': collectOutpost,
			'auto_collect_depot': collectDepot,
			'auto_alliance_time': allianceTime,
			'auto_neutral_time': neutralTime,
			'auto_climb_level': climbLevel,
			'auto_active_zone': activeZone,
			'auto_active_fuel_target': activeFuelTarget,
			'auto_timeline_events': jsonEncode(timeline.map((e) => e.toJson()).toList()),
		};
	}

	/// Load state from map (database)
	factory AutoTabState.fromJson(Map<String, dynamic> json) {
		List<TimelineEvent> timeline = [];
		if (json['auto_timeline_events'] != null) {
			try {
				final decoded = jsonDecode(json['auto_timeline_events'] as String) as List;
				timeline = decoded.map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>)).toList();
			} catch (e) {
				// Failed to parse timeline, continue with empty
			}
		}

		return AutoTabState(
			trenchDepotAllianceToNeutral: json['auto_trench_depot_alliance_to_neutral'] as int? ?? 0,
			bumpDepotAllianceToNeutral: json['auto_bump_depot_alliance_to_neutral'] as int? ?? 0,
			bumpOutpostAllianceToNeutral: json['auto_bump_outpost_alliance_to_neutral'] as int? ?? 0,
			trenchOutpostAllianceToNeutral: json['auto_trench_outpost_alliance_to_neutral'] as int? ?? 0,
			trenchDepotNeutralToAlliance: json['auto_trench_depot_neutral_to_alliance'] as int? ?? 0,
			bumpDepotNeutralToAlliance: json['auto_bump_depot_neutral_to_alliance'] as int? ?? 0,
			bumpOutpostNeutralToAlliance: json['auto_bump_outpost_neutral_to_alliance'] as int? ?? 0,
			trenchOutpostNeutralToAlliance: json['auto_trench_outpost_neutral_to_alliance'] as int? ?? 0,
			fuelScore: json['auto_fuel_score'] as int? ?? 0,
			fuelNeutralAlliancePass: json['auto_fuel_neutral_alliance_pass'] as int? ?? 0,
			collectOutpost: json['auto_collect_outpost'] as bool? ?? false,
			collectDepot: json['auto_collect_depot'] as bool? ?? false,
			allianceTime: json['auto_alliance_time'] as int? ?? 0,
			neutralTime: json['auto_neutral_time'] as int? ?? 0,
			climbLevel: json['auto_climb_level'] as int? ?? 0,
			activeZone: json['auto_active_zone'] as String? ?? 'alliance',
			activeFuelTarget: json['auto_active_fuel_target'] as String? ?? 'hub',
			timeline: timeline,
		);
	}
}

/// Controller for auto tab state
class AutoTabNotifier extends StateNotifier<AutoTabState> {
	AutoTabNotifier() : super(AutoTabState());

	/// Record an action (button click, fuel add, etc.)
	void recordAction({
		required String type, // 'movement', 'fuel', 'collect', 'climb'
		required String field, // Field name
		required int value, // Value to add
		required String actionLabel, // Label for timeline (currently unused - field name is stored)
		required String valueLabel, // Value label for timeline (currently unused - numeric value is stored)
	}) {
		final now = DateTime.now();
		final startTime = state.autoStartTime ?? now;
		final elapsed = now.difference(startTime).inSeconds;

		// Create timeline event with field name and numeric value (matching web app format)
		final event = TimelineEvent(
			timeSeconds: elapsed,
			action: field,
			value: value.toString(),
		);

		// Update appropriate counter based on field
		AutoTabState newState = state;

		// Determine if this is a zone transition and calculate elapsed time in current zone
		String? newZone;
		if (field.endsWith('_to_neutral')) {
			newZone = 'neutral';
		} else if (field.endsWith('_to_alliance')) {
			newZone = 'alliance';
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
			}
		}

		switch (field) {
			case 'auto_trench_depot_alliance_to_neutral':
				newState = newState.copyWith(
					trenchDepotAllianceToNeutral: newState.trenchDepotAllianceToNeutral + value,
					activeZone: 'neutral',
					activeFuelTarget: 'alliancePass',
					lastZoneChangeTime: now,
				);
			case 'auto_bump_depot_alliance_to_neutral':
				newState = newState.copyWith(
					bumpDepotAllianceToNeutral: newState.bumpDepotAllianceToNeutral + value,
					activeZone: 'neutral',
					activeFuelTarget: 'alliancePass',
					lastZoneChangeTime: now,
				);
			case 'auto_bump_outpost_alliance_to_neutral':
				newState = newState.copyWith(
					bumpOutpostAllianceToNeutral: newState.bumpOutpostAllianceToNeutral + value,
					activeZone: 'neutral',
					activeFuelTarget: 'alliancePass',
					lastZoneChangeTime: now,
				);
			case 'auto_trench_outpost_alliance_to_neutral':
				newState = newState.copyWith(
					trenchOutpostAllianceToNeutral: newState.trenchOutpostAllianceToNeutral + value,
					activeZone: 'neutral',
					activeFuelTarget: 'alliancePass',
					lastZoneChangeTime: now,
				);
			case 'auto_trench_depot_neutral_to_alliance':
				newState = newState.copyWith(
					trenchDepotNeutralToAlliance: newState.trenchDepotNeutralToAlliance + value,
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: now,
				);
			case 'auto_bump_depot_neutral_to_alliance':
				newState = newState.copyWith(
					bumpDepotNeutralToAlliance: newState.bumpDepotNeutralToAlliance + value,
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: now,
				);
			case 'auto_bump_outpost_neutral_to_alliance':
				newState = newState.copyWith(
					bumpOutpostNeutralToAlliance: newState.bumpOutpostNeutralToAlliance + value,
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: now,
				);
			case 'auto_trench_outpost_neutral_to_alliance':
				newState = newState.copyWith(
					trenchOutpostNeutralToAlliance: newState.trenchOutpostNeutralToAlliance + value,
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: now,
				);
			case 'auto_fuel_score':
				newState = newState.copyWith(fuelScore: newState.fuelScore + value);
			case 'auto_fuel_neutral_alliance_pass':
				newState = newState.copyWith(
					fuelNeutralAlliancePass: newState.fuelNeutralAlliancePass + value,
				);
			case 'auto_collect_outpost':
				newState = newState.copyWith(collectOutpost: !newState.collectOutpost);
			case 'auto_collect_depot':
				newState = newState.copyWith(collectDepot: !newState.collectDepot);
			case 'auto_climb_level':
				newState = newState.copyWith(climbLevel: value);
			case 'auto_zone_change':
				// Zone change: toggle zone
				newState = newState.copyWith(
					activeZone: state.activeZone == 'alliance' ? 'neutral' : 'alliance',
					lastZoneChangeTime: now,
				);
		}

		// Add event to timeline
		final newTimeline = [...newState.timeline, event];

		// Update state - set autoStartTime only on first action if not already set
		state = newState.copyWith(
			timeline: newTimeline,
			autoStartTime: state.autoStartTime ?? now,
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
		AutoTabState newState = state;
		switch (field) {
			case 'auto_zone_change':
				// Toggle zone back to previous zone and set appropriate fuel target
				final newZone = state.activeZone == 'alliance' ? 'neutral' : 'alliance';
				newState = newState.copyWith(
					activeZone: newZone,
					activeFuelTarget: newZone == 'neutral' ? 'alliancePass' : 'hub',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
			case 'auto_trench_depot_alliance_to_neutral':
				newState = newState.copyWith(
					trenchDepotAllianceToNeutral:
						(newState.trenchDepotAllianceToNeutral - actionValue).clamp(0, 999),
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
			case 'auto_bump_depot_alliance_to_neutral':
				newState = newState.copyWith(
					bumpDepotAllianceToNeutral:
						(newState.bumpDepotAllianceToNeutral - actionValue).clamp(0, 999),
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
			case 'auto_bump_outpost_alliance_to_neutral':
				newState = newState.copyWith(
					bumpOutpostAllianceToNeutral:
						(newState.bumpOutpostAllianceToNeutral - actionValue).clamp(0, 999),
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
			case 'auto_trench_outpost_alliance_to_neutral':
				newState = newState.copyWith(
					trenchOutpostAllianceToNeutral:
						(newState.trenchOutpostAllianceToNeutral - actionValue).clamp(0, 999),
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
			case 'auto_trench_depot_neutral_to_alliance':
				newState = newState.copyWith(
					trenchDepotNeutralToAlliance:
						(newState.trenchDepotNeutralToAlliance - actionValue).clamp(0, 999),
					activeZone: 'neutral',
					activeFuelTarget: 'alliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
			case 'auto_bump_depot_neutral_to_alliance':
				newState = newState.copyWith(
					bumpDepotNeutralToAlliance:
						(newState.bumpDepotNeutralToAlliance - actionValue).clamp(0, 999),
					activeZone: 'neutral',
					activeFuelTarget: 'alliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
			case 'auto_bump_outpost_neutral_to_alliance':
				newState = newState.copyWith(
					bumpOutpostNeutralToAlliance:
						(newState.bumpOutpostNeutralToAlliance - actionValue).clamp(0, 999),
					activeZone: 'neutral',
					activeFuelTarget: 'alliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
			case 'auto_trench_outpost_neutral_to_alliance':
				newState = newState.copyWith(
					trenchOutpostNeutralToAlliance:
						(newState.trenchOutpostNeutralToAlliance - actionValue).clamp(0, 999),
					activeZone: 'neutral',
					activeFuelTarget: 'alliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
			case 'auto_fuel_score':
				newState = newState.copyWith(
					fuelScore: (newState.fuelScore - actionValue).clamp(0, 999),
				);
			case 'auto_fuel_neutral_alliance_pass':
				newState = newState.copyWith(
					fuelNeutralAlliancePass:
						(newState.fuelNeutralAlliancePass - actionValue).clamp(0, 999),
				);
			case 'auto_collect_outpost':
				newState = newState.copyWith(collectOutpost: !newState.collectOutpost);
			case 'auto_collect_depot':
				newState = newState.copyWith(collectDepot: !newState.collectDepot);
			case 'auto_climb_level':
				newState = newState.copyWith(climbLevel: actionValue);
		}

		// Update timeline and reset timer if empty
		if (newTimeline.isEmpty) {
			// Directly create new state with autoStartTime set to null (can't use copyWith for this)
			state = AutoTabState(
				trenchDepotAllianceToNeutral: newState.trenchDepotAllianceToNeutral,
				bumpDepotAllianceToNeutral: newState.bumpDepotAllianceToNeutral,
				bumpOutpostAllianceToNeutral: newState.bumpOutpostAllianceToNeutral,
				trenchOutpostAllianceToNeutral: newState.trenchOutpostAllianceToNeutral,
				trenchDepotNeutralToAlliance: newState.trenchDepotNeutralToAlliance,
				bumpDepotNeutralToAlliance: newState.bumpDepotNeutralToAlliance,
				bumpOutpostNeutralToAlliance: newState.bumpOutpostNeutralToAlliance,
				trenchOutpostNeutralToAlliance: newState.trenchOutpostNeutralToAlliance,
				fuelScore: newState.fuelScore,
				fuelNeutralAlliancePass: newState.fuelNeutralAlliancePass,
				collectOutpost: newState.collectOutpost,
				collectDepot: newState.collectDepot,
				allianceTime: newState.allianceTime,
				neutralTime: newState.neutralTime,
				climbLevel: newState.climbLevel,
				activeZone: newState.activeZone,
				activeFuelTarget: newState.activeFuelTarget,
				timeline: newTimeline,
				autoStartTime: null,
			);
		} else {
			state = newState.copyWith(timeline: newTimeline);
		}
	}

	/// Reset all state
	void reset() {
		state = AutoTabState();
	}

	/// Toggle zone between alliance and neutral
	/// Records a "-1" action in timeline when exiting a zone
	void toggleZone() {
		final newZone = state.activeZone == 'alliance' ? 'neutral' : 'alliance';

		// Record zone change in timeline
		recordAction(
			type: 'zone_toggle',
			field: 'auto_zone_change',
			value: -1,
			actionLabel: 'Zone: ${state.activeZone} → $newZone',
			valueLabel: '-1',
		);

		// Update active zone
		state = state.copyWith(activeZone: newZone);
	}

	/// Change zone to specific zone (alliance or neutral)
	/// Zone changes are handled implicitly by movement actions
	void changeZone(String targetZone) {
		if (state.activeZone == targetZone) {
			return; // Already in target zone
		}
		state = state.copyWith(activeZone: targetZone);
	}

	/// Change fuel target to specific target ('hub' or 'alliancePass')
	void changeFuelTarget(String targetName) {
		if (state.activeFuelTarget == targetName) {
			return; // Already on target
		}
		state = state.copyWith(activeFuelTarget: targetName);
	}

	/// Start auto (initialize start time) - syncs with UI timer
	void startAuto() {
		state = state.copyWith(autoStartTime: DateTime.now());
	}

	/// Sync auto start time with external match timer (called when UI timer starts)
	void syncStartTime(DateTime matchStartTime) {
		if (state.autoStartTime == null) {
			state = state.copyWith(autoStartTime: matchStartTime);
		}
	}

	/// Load state from data map
	void loadFromData(Map<String, dynamic> data) {
		state = AutoTabState.fromJson(data);
	}

	/// Get all counters as map for database save
	Map<String, dynamic> getCountersForSave() => state.toJson();
}

/// Riverpod provider for auto tab controller
final autoTabControllerProvider = StateNotifierProvider<AutoTabNotifier, AutoTabState>((ref) {
	return AutoTabNotifier();
});
