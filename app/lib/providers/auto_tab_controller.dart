import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/field_descriptor.dart';
import '../models/map_data_model.dart';
import '../models/serialization_helper.dart';
import 'active_zone_provider.dart';
import 'timeline_provider.dart';
import 'match_timer_provider.dart';

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

	/// Format timeline list to string (time:action or time:action:value, space-separated)
	/// Value is omitted if it equals "1" for parity with web app
	static String formatTimeline(List<TimelineEvent> events) {
		return events.map((e) => e.value == '1' ? '${e.timeSeconds}:${e.action}' : '${e.timeSeconds}:${e.action}:${e.value}').join(' ');
	}

	/// Parse timeline string to list of events (time:action or time:action:value, space-separated)
	/// Value defaults to "1" if not specified for parity with web app
	static List<TimelineEvent> parseTimeline(String timelineStr) {
		final events = <TimelineEvent>[];
		if (timelineStr.isEmpty) return events;

		final entries = timelineStr.split(' ');
		for (final entry in entries) {
			final parts = entry.split(':');
			if (parts.length == 2) {
				// Format: time:action (value defaults to "1")
				events.add(TimelineEvent(
					timeSeconds: int.parse(parts[0]),
					action: parts[1],
					value: '1',
				));
			} else if (parts.length == 3) {
				// Format: time:action:value
				events.add(TimelineEvent(
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

/// State for auto tab - map-based data with UI state
class AutoTabState extends MapDataModel {
	// UI state (not serialized)
	final String activeZone;
	final String activeFuelTarget;
	final DateTime? lastZoneChangeTime;

	AutoTabState([Map<String, dynamic>? initialValues, this.activeZone = 'alliance', this.activeFuelTarget = 'hub', this.lastZoneChangeTime])
		: super(initialValues ?? {});

	AutoTabState.empty()
		: activeZone = 'alliance',
			activeFuelTarget = 'hub',
			lastZoneChangeTime = null,
			super.empty();

	@override
	List<FieldDescriptor> get descriptors => _descriptors;

	static const List<FieldDescriptor> _descriptors = [
		FieldDescriptor(name: 'auto_trench_depot_alliance_to_neutral'),
		FieldDescriptor(name: 'auto_bump_depot_alliance_to_neutral'),
		FieldDescriptor(name: 'auto_bump_outpost_alliance_to_neutral'),
		FieldDescriptor(name: 'auto_trench_outpost_alliance_to_neutral'),
		FieldDescriptor(name: 'auto_trench_depot_neutral_to_alliance'),
		FieldDescriptor(name: 'auto_bump_depot_neutral_to_alliance'),
		FieldDescriptor(name: 'auto_bump_outpost_neutral_to_alliance'),
		FieldDescriptor(name: 'auto_trench_outpost_neutral_to_alliance'),
		FieldDescriptor(name: 'auto_fuel_score'),
		FieldDescriptor(name: 'auto_fuel_neutral_alliance_pass'),
		FieldDescriptor(name: 'auto_collect_outpost'),
		FieldDescriptor(name: 'auto_collect_depot'),
		FieldDescriptor(name: 'auto_alliance_time'),
		FieldDescriptor(name: 'auto_neutral_time'),
		FieldDescriptor(name: 'auto_climb_level'),
	];


	/// Create a copy with updated fields (preserves UI state)
	AutoTabState copyWith({
		Map<String, String>? data,
		String? activeZone,
		String? activeFuelTarget,
		DateTime? lastZoneChangeTime,
	}) {
		final result = {...this.values};
		if (data != null) {
			for (final desc in descriptors) {
				if (data.containsKey(desc.name)) {
					result[desc.name] = data[desc.name];
				}
			}
		}

		return AutoTabState(
			result,
			activeZone ?? this.activeZone,
			activeFuelTarget ?? this.activeFuelTarget,
			lastZoneChangeTime ?? this.lastZoneChangeTime,
		);
	}

	@override
	AutoTabState updateField(String fieldName, dynamic value) {
		return AutoTabState(updateFieldValues(fieldName, value), activeZone, activeFuelTarget, lastZoneChangeTime);
	}
}

/// Controller for auto tab state
class AutoTabNotifier extends StateNotifier<AutoTabState> {
	final Ref _ref;

	AutoTabNotifier(this._ref) : super(AutoTabState.empty());

	/// Record an action (button click, fuel add, etc.)
	void recordAction({
		required String type, // 'movement', 'fuel', 'collect', 'climb'
		required String field, // Field name
		required int value, // Value to add
		required String actionLabel, // Label for timeline (currently unused - field name is stored)
		required String valueLabel, // Value label for timeline (currently unused - numeric value is stored)
	}) {
		final now = DateTime.now();
		final matchStartTime = _ref.read(matchTimerProvider);
		final startTime = matchStartTime ?? now;
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
				final currentTime = newState.getFieldValue('auto_alliance_time').asInt();
				newState = newState.copyWith(
					data: MapDataModel.fieldValue('auto_alliance_time', currentTime + zoneElapsedSeconds),
				);
			} else if (state.activeZone == 'neutral' && zoneElapsedSeconds > 0) {
				final currentTime = newState.getFieldValue('auto_neutral_time').asInt();
				newState = newState.copyWith(
					data: {'auto_neutral_time': (currentTime + zoneElapsedSeconds).toString()},
				);
			}
			// Update shared active zone provider
			_ref.read(activeZoneProvider.notifier).state = newZone;
		}

		switch (field) {
			case 'auto_trench_depot_alliance_to_neutral':
			case 'auto_bump_depot_alliance_to_neutral':
			case 'auto_bump_outpost_alliance_to_neutral':
			case 'auto_trench_outpost_alliance_to_neutral':
			case 'auto_trench_depot_neutral_to_alliance':
			case 'auto_bump_depot_neutral_to_alliance':
			case 'auto_bump_outpost_neutral_to_alliance':
			case 'auto_trench_outpost_neutral_to_alliance':
				final currentValue = newState.getFieldValue(field).asInt();
				final newValue = currentValue + value;
				final isToNeutral = field.endsWith('_to_neutral');
				newState = newState.copyWith(
					data: {field: newValue.toString()},
					activeZone: isToNeutral ? 'neutral' : 'alliance',
					activeFuelTarget: isToNeutral ? 'alliancePass' : 'hub',
					lastZoneChangeTime: now,
				);
			case 'auto_fuel_score':
			case 'auto_fuel_neutral_alliance_pass':
				final currentValue = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(
					data: {field: (currentValue + value).toString()},
				);
			case 'auto_collect_outpost':
			case 'auto_collect_depot':
			case 'auto_climb_level':
				newState = newState.copyWith(
					data: {field: value.toString()},
				);
			case 'auto_zone_change':
				// Zone change: toggle zone
				newState = newState.copyWith(
					activeZone: state.activeZone == 'alliance' ? 'neutral' : 'alliance',
					lastZoneChangeTime: now,
				);
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
				// Update shared active zone provider
				_ref.read(activeZoneProvider.notifier).state = newZone;
			case 'auto_trench_depot_alliance_to_neutral':
			case 'auto_bump_depot_alliance_to_neutral':
			case 'auto_bump_outpost_alliance_to_neutral':
			case 'auto_trench_outpost_alliance_to_neutral':
				final currentValue = newState.getFieldValue(field).asInt();
				final newValue = (currentValue - actionValue).clamp(0, 999);
				newState = newState.copyWith(
					data: {field: newValue.toString()},
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'alliance';
			case 'auto_trench_depot_neutral_to_alliance':
			case 'auto_bump_depot_neutral_to_alliance':
			case 'auto_bump_outpost_neutral_to_alliance':
			case 'auto_trench_outpost_neutral_to_alliance':
				final currentValue = newState.getFieldValue(field).asInt();
				final newValue = (currentValue - actionValue).clamp(0, 999);
				newState = newState.copyWith(
					data: {field: newValue.toString()},
					activeZone: 'neutral',
					activeFuelTarget: 'alliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'neutral';
			case 'auto_fuel_score':
			case 'auto_fuel_neutral_alliance_pass':
				final currentValue = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(
					data: {field: ((currentValue - actionValue).clamp(0, 999)).toString()},
				);
			case 'auto_collect_outpost':
			case 'auto_collect_depot':
			case 'auto_climb_level':
				newState = newState.copyWith(
					data: {field: actionValue.toString()},
				);
		}

		// Remove event from shared timeline provider
		_ref.read(timelineProvider.notifier).undo();

		// Update state (no need to reset anything, match timer is shared)
		state = newState;
	}

	/// Reset all state
	void reset() {
		state = AutoTabState.empty();
		_ref.read(timelineProvider.notifier).clear();
		_ref.read(matchTimerProvider.notifier).clear();
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
		final now = DateTime.now();
		_ref.read(matchTimerProvider.notifier).setStartTime(now);
	}

	/// Sync auto start time with external match timer (called when UI timer starts)
	void syncStartTime(DateTime matchStartTime) {
		if (_ref.read(matchTimerProvider) == null) {
			_ref.read(matchTimerProvider.notifier).setStartTime(matchStartTime);
		}
	}

	/// Load state from data map and populate timeline provider
	void loadFromData(Map<String, dynamic> data, {bool isFirstLoad = false}) {
		if (isFirstLoad) {
			reset();
			final newState = AutoTabState.empty();
			newState.loadFromMap(data);
			state = newState;
			_ref.read(timelineProvider.notifier).clear();
		}
	}

	/// Get all counters and timeline as map for database save
	Map<String, dynamic> getCountersForSave() {
		final counters = state.values;
		// All field names are already in CSV format
		final result = <String, dynamic>{...counters};
		// Add timeline to the save data
		final timeline = _ref.read(timelineProvider);
		result['timeline'] = TimelineEvent.formatTimeline(timeline);
		return result;
	}
}

/// Riverpod provider for auto tab controller
final autoTabControllerProvider = StateNotifierProvider<AutoTabNotifier, AutoTabState>((ref) {
	return AutoTabNotifier(ref);
});
