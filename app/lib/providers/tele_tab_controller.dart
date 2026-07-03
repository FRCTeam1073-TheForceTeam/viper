import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/field_descriptor.dart';
import '../models/map_data_model.dart';
import '../models/serialization_helper.dart';
import 'active_zone_provider.dart';
import 'auto_tab_controller.dart' show TimelineEvent;
import 'timeline_provider.dart';
import 'match_timer_provider.dart';


/// State for tele tab - map-based data with UI state
class TeleTabState extends MapDataModel {
	// UI state (not serialized)
	final String activeZone;
	final String activeFuelTarget;
	final DateTime? lastZoneChangeTime;

	TeleTabState([Map<String, dynamic>? initialValues, this.activeZone = 'alliance', this.activeFuelTarget = 'hub', this.lastZoneChangeTime])
		: super(initialValues ?? {});

	TeleTabState.empty()
		: activeZone = 'alliance',
			activeFuelTarget = 'hub',
			lastZoneChangeTime = null,
			super.empty();

	@override
	List<FieldDescriptor> get descriptors => _descriptors;

	static const List<FieldDescriptor> _descriptors = [
		FieldDescriptor(name: 'tele_trench_depot_alliance_to_neutral'),
		FieldDescriptor(name: 'tele_bump_depot_alliance_to_neutral'),
		FieldDescriptor(name: 'tele_bump_outpost_alliance_to_neutral'),
		FieldDescriptor(name: 'tele_trench_outpost_alliance_to_neutral'),
		FieldDescriptor(name: 'tele_trench_depot_neutral_to_alliance'),
		FieldDescriptor(name: 'tele_bump_depot_neutral_to_alliance'),
		FieldDescriptor(name: 'tele_bump_outpost_neutral_to_alliance'),
		FieldDescriptor(name: 'tele_trench_outpost_neutral_to_alliance'),
		FieldDescriptor(name: 'tele_trench_outpost_neutral_to_opponent'),
		FieldDescriptor(name: 'tele_bump_outpost_neutral_to_opponent'),
		FieldDescriptor(name: 'tele_bump_depot_neutral_to_opponent'),
		FieldDescriptor(name: 'tele_trench_depot_neutral_to_opponent'),
		FieldDescriptor(name: 'tele_trench_outpost_opponent_to_neutral'),
		FieldDescriptor(name: 'tele_bump_outpost_opponent_to_neutral'),
		FieldDescriptor(name: 'tele_bump_depot_opponent_to_neutral'),
		FieldDescriptor(name: 'tele_trench_depot_opponent_to_neutral'),
		FieldDescriptor(name: 'tele_fuel_score'),
		FieldDescriptor(name: 'tele_fuel_alliance_dump'),
		FieldDescriptor(name: 'tele_fuel_outpost'),
		FieldDescriptor(name: 'tele_fuel_neutral_alliance_pass'),
		FieldDescriptor(name: 'tele_fuel_opponent_neutral_pass'),
		FieldDescriptor(name: 'tele_fuel_opponent_alliance_pass'),
		FieldDescriptor(name: 'tele_alliance_time'),
		FieldDescriptor(name: 'tele_neutral_time'),
		FieldDescriptor(name: 'tele_opponent_time'),
		FieldDescriptor(name: 'tele_climb_level'),
	];


	/// Create a copy with updated fields (preserves UI state)
	TeleTabState copyWith({
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

		return TeleTabState(
			result,
			activeZone ?? this.activeZone,
			activeFuelTarget ?? this.activeFuelTarget,
			lastZoneChangeTime ?? this.lastZoneChangeTime,
		);
	}

	@override
	TeleTabState updateField(String fieldName, dynamic value) {
		return TeleTabState(updateFieldValues(fieldName, value), activeZone, activeFuelTarget, lastZoneChangeTime);
	}
}

/// Controller for tele tab state
class TeleTabNotifier extends StateNotifier<TeleTabState> {
	final Ref _ref;

	TeleTabNotifier(this._ref) : super(TeleTabState.empty()) {
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
				final currentTime = newState.getFieldValue('tele_alliance_time').asInt();
				newState = newState.copyWith(
					data: {'tele_alliance_time': (currentTime + zoneElapsedSeconds).toString()},
				);
			} else if (state.activeZone == 'neutral' && zoneElapsedSeconds > 0) {
				final currentTime = newState.getFieldValue('tele_neutral_time').asInt();
				newState = newState.copyWith(
					data: {'tele_neutral_time': (currentTime + zoneElapsedSeconds).toString()},
				);
			} else if (state.activeZone == 'opponent' && zoneElapsedSeconds > 0) {
				final currentTime = newState.getFieldValue('tele_opponent_time').asInt();
				newState = newState.copyWith(
					data: {'tele_opponent_time': (currentTime + zoneElapsedSeconds).toString()},
				);
			}
			// Update shared active zone provider
			_ref.read(activeZoneProvider.notifier).state = newZone;
		}

		// Update counters based on field name
		switch (field) {
			case 'tele_trench_depot_alliance_to_neutral':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(
					data: {field: (val + value).toString()},
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_bump_depot_alliance_to_neutral':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(
					data: {field: (val + value).toString()},
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_bump_outpost_alliance_to_neutral':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(
					data: {field: (val + value).toString()},
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_trench_outpost_alliance_to_neutral':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(
					data: {field: (val + value).toString()},
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_trench_depot_neutral_to_alliance':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(
					data: {field: (val + value).toString()},
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: now,
				);
			case 'tele_bump_depot_neutral_to_alliance':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(
					data: {field: (val + value).toString()},
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: now,
				);
			case 'tele_bump_outpost_neutral_to_alliance':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(
					data: {field: (val + value).toString()},
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: now,
				);
			case 'tele_trench_outpost_neutral_to_alliance':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(
					data: {field: (val + value).toString()},
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: now,
				);
			case 'tele_trench_outpost_neutral_to_opponent':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(
					data: {field: (val + value).toString()},
					activeZone: 'opponent',
					activeFuelTarget: 'opponentAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_bump_outpost_neutral_to_opponent':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(
					data: {field: (val + value).toString()},
					activeZone: 'opponent',
					activeFuelTarget: 'opponentAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_bump_depot_neutral_to_opponent':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(
					data: {field: (val + value).toString()},
					activeZone: 'opponent',
					activeFuelTarget: 'opponentAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_trench_depot_neutral_to_opponent':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(
					data: {field: (val + value).toString()},
					activeZone: 'opponent',
					activeFuelTarget: 'opponentAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_trench_outpost_opponent_to_neutral':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(
					data: {field: (val + value).toString()},
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_bump_outpost_opponent_to_neutral':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(
					data: {field: (val + value).toString()},
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_bump_depot_opponent_to_neutral':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(
					data: {field: (val + value).toString()},
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_trench_depot_opponent_to_neutral':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(
					data: {field: (val + value).toString()},
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: now,
				);
			case 'tele_fuel_score':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(data: {field: (val + value).toString()});
			case 'tele_fuel_alliance_dump':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(data: {field: (val + value).toString()});
			case 'tele_fuel_outpost':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(data: {field: (val + value).toString()});
			case 'tele_fuel_neutral_alliance_pass':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(data: {field: (val + value).toString()});
			case 'tele_fuel_opponent_alliance_pass':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(data: {field: (val + value).toString()});
			case 'tele_fuel_opponent_neutral_pass':
				final val = newState.getFieldValue(field).asInt();
				newState = newState.copyWith(data: {field: (val + value).toString()});
			case 'tele_climb_level':
				newState = newState.copyWith(data: {field: value.toString()});
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
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(
					data: {field: val.toString()},
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'alliance';
			case 'tele_bump_depot_alliance_to_neutral':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(
					data: {field: val.toString()},
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'alliance';
			case 'tele_bump_outpost_alliance_to_neutral':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(
					data: {field: val.toString()},
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'alliance';
			case 'tele_trench_outpost_alliance_to_neutral':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(
					data: {field: val.toString()},
					activeZone: 'alliance',
					activeFuelTarget: 'hub',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'alliance';
			case 'tele_trench_depot_neutral_to_alliance':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(
					data: {field: val.toString()},
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'neutral';
			case 'tele_bump_depot_neutral_to_alliance':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(
					data: {field: val.toString()},
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'neutral';
			case 'tele_bump_outpost_neutral_to_alliance':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(
					data: {field: val.toString()},
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'neutral';
			case 'tele_trench_outpost_neutral_to_alliance':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(
					data: {field: val.toString()},
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'neutral';
			case 'tele_trench_outpost_neutral_to_opponent':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(
					data: {field: val.toString()},
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'neutral';
			case 'tele_bump_outpost_neutral_to_opponent':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(
					data: {field: val.toString()},
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'neutral';
			case 'tele_bump_depot_neutral_to_opponent':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(
					data: {field: val.toString()},
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'neutral';
			case 'tele_trench_depot_neutral_to_opponent':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(
					data: {field: val.toString()},
					activeZone: 'neutral',
					activeFuelTarget: 'neutralAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'neutral';
			case 'tele_trench_outpost_opponent_to_neutral':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(
					data: {field: val.toString()},
					activeZone: 'opponent',
					activeFuelTarget: 'opponentAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'opponent';
			case 'tele_bump_outpost_opponent_to_neutral':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(
					data: {field: val.toString()},
					activeZone: 'opponent',
					activeFuelTarget: 'opponentAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'opponent';
			case 'tele_bump_depot_opponent_to_neutral':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(
					data: {field: val.toString()},
					activeZone: 'opponent',
					activeFuelTarget: 'opponentAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'opponent';
			case 'tele_trench_depot_opponent_to_neutral':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(
					data: {field: val.toString()},
					activeZone: 'opponent',
					activeFuelTarget: 'opponentAlliancePass',
					lastZoneChangeTime: state.lastZoneChangeTime,
				);
				_ref.read(activeZoneProvider.notifier).state = 'opponent';
			case 'tele_fuel_score':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(data: {field: val.toString()});
			case 'tele_fuel_alliance_dump':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(data: {field: val.toString()});
			case 'tele_fuel_outpost':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(data: {field: val.toString()});
			case 'tele_fuel_neutral_alliance_pass':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(data: {field: val.toString()});
			case 'tele_fuel_opponent_alliance_pass':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(data: {field: val.toString()});
			case 'tele_fuel_opponent_neutral_pass':
				final val = (newState.getFieldValue(field).asInt() - actionValue).clamp(0, 999);
				newState = newState.copyWith(data: {field: val.toString()});
			case 'tele_climb_level':
				newState = newState.copyWith(data: {field: actionValue.toString()});
		}

		// Remove event from shared timeline provider
		_ref.read(timelineProvider.notifier).undo();

		// Update state (no need to reset anything, match timer is shared)
		state = newState;
	}

	/// Reset tele state for new match
	void reset() {
		state = TeleTabState.empty();
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
			reset();
			final newState = TeleTabState.empty();
			newState.loadFromMap(data);
			final sharedZone = _ref.read(activeZoneProvider);
			state = newState.updateField('activeZone', sharedZone) as TeleTabState;
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

/// Riverpod provider for tele tab controller
final teleTabControllerProvider = StateNotifierProvider<TeleTabNotifier, TeleTabState>((ref) {
	return TeleTabNotifier(ref);
});
