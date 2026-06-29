import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

/// Timeline event entry: tracks when an action happened and its value
class TimelineEvent {
	final int timeSeconds; // Time since auto start (MM:SS)
	final String action; // Description of action
	final String value; // Value associated with action (e.g., "+5 fuel")

	TimelineEvent({
		required this.timeSeconds,
		required this.action,
		required this.value,
	});

	/// Convert to JSON for storage
	Map<String, dynamic> toJson() => {
		'time': timeSeconds,
		'action': action,
		'value': value,
	};

	/// Create from JSON
	factory TimelineEvent.fromJson(Map<String, dynamic> json) => TimelineEvent(
		timeSeconds: json['time'] as int,
		action: json['action'] as String,
		value: json['value'] as String,
	);

	@override
	String toString() => '[$timeSeconds] $action ($value)';
}

/// Represents a single action that was performed
class AutoAction {
	final String type; // 'movement', 'fuel', 'collect', 'climb'
	final String field; // Field name (e.g., 'auto_trench_depot_alliance_to_neutral')
	final int value; // Value to add/set
	final int timeSeconds; // When the action happened

	AutoAction({
		required this.type,
		required this.field,
		required this.value,
		required this.timeSeconds,
	});
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

	// Timeline of all events
	final List<TimelineEvent> timeline;

	// Action history for undo (stores last N actions)
	final List<AutoAction> actionHistory;

	// Auto start time (to calculate relative timestamps)
	final DateTime? autoStartTime;

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
		this.timeline = const [],
		this.actionHistory = const [],
		this.autoStartTime,
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
		List<TimelineEvent>? timeline,
		List<AutoAction>? actionHistory,
		DateTime? autoStartTime,
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
			timeline: timeline ?? this.timeline,
			actionHistory: actionHistory ?? this.actionHistory,
			autoStartTime: autoStartTime ?? this.autoStartTime,
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
			timeline: timeline,
		);
	}
}

/// Controller for auto tab state
class AutoTabNotifier extends StateNotifier<AutoTabState> {
	static const int maxHistorySize = 50;

	AutoTabNotifier() : super(AutoTabState());

	/// Record an action (button click, fuel add, etc.)
	void recordAction({
		required String type, // 'movement', 'fuel', 'collect', 'climb'
		required String field, // Field name
		required int value, // Value to add
		required String actionLabel, // Label for timeline
		required String valueLabel, // Value label for timeline
	}) {
		final now = DateTime.now();
		final startTime = state.autoStartTime ?? now;
		final elapsed = now.difference(startTime).inSeconds;

		// Create new timeline event
		final event = TimelineEvent(
			timeSeconds: elapsed,
			action: actionLabel,
			value: valueLabel,
		);

		// Create action for undo
		final action = AutoAction(
			type: type,
			field: field,
			value: value,
			timeSeconds: elapsed,
		);

		// Update appropriate counter based on field
		AutoTabState newState = state;

		switch (field) {
			case 'auto_trench_depot_alliance_to_neutral':
				newState = newState.copyWith(
					trenchDepotAllianceToNeutral: newState.trenchDepotAllianceToNeutral + value,
				);
			case 'auto_bump_depot_alliance_to_neutral':
				newState = newState.copyWith(
					bumpDepotAllianceToNeutral: newState.bumpDepotAllianceToNeutral + value,
				);
			case 'auto_bump_outpost_alliance_to_neutral':
				newState = newState.copyWith(
					bumpOutpostAllianceToNeutral: newState.bumpOutpostAllianceToNeutral + value,
				);
			case 'auto_trench_outpost_alliance_to_neutral':
				newState = newState.copyWith(
					trenchOutpostAllianceToNeutral: newState.trenchOutpostAllianceToNeutral + value,
				);
			case 'auto_trench_depot_neutral_to_alliance':
				newState = newState.copyWith(
					trenchDepotNeutralToAlliance: newState.trenchDepotNeutralToAlliance + value,
				);
			case 'auto_bump_depot_neutral_to_alliance':
				newState = newState.copyWith(
					bumpDepotNeutralToAlliance: newState.bumpDepotNeutralToAlliance + value,
				);
			case 'auto_bump_outpost_neutral_to_alliance':
				newState = newState.copyWith(
					bumpOutpostNeutralToAlliance: newState.bumpOutpostNeutralToAlliance + value,
				);
			case 'auto_trench_outpost_neutral_to_alliance':
				newState = newState.copyWith(
					trenchOutpostNeutralToAlliance: newState.trenchOutpostNeutralToAlliance + value,
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
		}

		// Add event to timeline
		final newTimeline = [...newState.timeline, event];

		// Add action to history (maintain max size)
		final newHistory = [...newState.actionHistory, action];
		if (newHistory.length > maxHistorySize) {
			newHistory.removeAt(0);
		}

		// Update state with start time if not set
		state = newState.copyWith(
			timeline: newTimeline,
			actionHistory: newHistory,
			autoStartTime: state.autoStartTime ?? now,
		);
	}

	/// Undo the last action
	void undo() {
		if (state.actionHistory.isEmpty) return;

		final lastAction = state.actionHistory.last;
		final newHistory = state.actionHistory.toList()..removeLast();

		// Remove last timeline event
		final newTimeline = state.timeline.toList();
		if (newTimeline.isNotEmpty) {
			newTimeline.removeLast();
		}

		// Reverse the action
		AutoTabState newState = state;
		switch (lastAction.field) {
			case 'auto_trench_depot_alliance_to_neutral':
				newState = newState.copyWith(
					trenchDepotAllianceToNeutral:
						(newState.trenchDepotAllianceToNeutral - lastAction.value).clamp(0, 999),
				);
			case 'auto_bump_depot_alliance_to_neutral':
				newState = newState.copyWith(
					bumpDepotAllianceToNeutral:
						(newState.bumpDepotAllianceToNeutral - lastAction.value).clamp(0, 999),
				);
			case 'auto_bump_outpost_alliance_to_neutral':
				newState = newState.copyWith(
					bumpOutpostAllianceToNeutral:
						(newState.bumpOutpostAllianceToNeutral - lastAction.value).clamp(0, 999),
				);
			case 'auto_trench_outpost_alliance_to_neutral':
				newState = newState.copyWith(
					trenchOutpostAllianceToNeutral:
						(newState.trenchOutpostAllianceToNeutral - lastAction.value).clamp(0, 999),
				);
			case 'auto_trench_depot_neutral_to_alliance':
				newState = newState.copyWith(
					trenchDepotNeutralToAlliance:
						(newState.trenchDepotNeutralToAlliance - lastAction.value).clamp(0, 999),
				);
			case 'auto_bump_depot_neutral_to_alliance':
				newState = newState.copyWith(
					bumpDepotNeutralToAlliance:
						(newState.bumpDepotNeutralToAlliance - lastAction.value).clamp(0, 999),
				);
			case 'auto_bump_outpost_neutral_to_alliance':
				newState = newState.copyWith(
					bumpOutpostNeutralToAlliance:
						(newState.bumpOutpostNeutralToAlliance - lastAction.value).clamp(0, 999),
				);
			case 'auto_trench_outpost_neutral_to_alliance':
				newState = newState.copyWith(
					trenchOutpostNeutralToAlliance:
						(newState.trenchOutpostNeutralToAlliance - lastAction.value).clamp(0, 999),
				);
			case 'auto_fuel_score':
				newState = newState.copyWith(
					fuelScore: (newState.fuelScore - lastAction.value).clamp(0, 999),
				);
			case 'auto_fuel_neutral_alliance_pass':
				newState = newState.copyWith(
					fuelNeutralAlliancePass:
						(newState.fuelNeutralAlliancePass - lastAction.value).clamp(0, 999),
				);
			case 'auto_collect_outpost':
				newState = newState.copyWith(collectOutpost: !newState.collectOutpost);
			case 'auto_collect_depot':
				newState = newState.copyWith(collectDepot: !newState.collectDepot);
			case 'auto_climb_level':
				newState = newState.copyWith(climbLevel: lastAction.value);
		}

		state = newState.copyWith(
			timeline: newTimeline,
			actionHistory: newHistory,
		);
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
	/// Simply updates the active zone without recording a separate action
	void changeZone(String targetZone) {
		if (state.activeZone == targetZone) {
			return; // Already in target zone
		}

		// Update active zone
		state = state.copyWith(activeZone: targetZone);
	}

	/// Start auto (initialize start time)
	void startAuto() {
		state = state.copyWith(autoStartTime: DateTime.now());
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
