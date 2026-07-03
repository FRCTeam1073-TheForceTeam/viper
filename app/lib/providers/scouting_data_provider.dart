import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/field_descriptor.dart';
import '../models/map_data_model.dart';
import 'timeline_provider.dart';
import 'match_timer_provider.dart';

/// Unified scouting data for an entire match
class ScoutingData extends MapDataModel {
	ScoutingData([Map<String, dynamic>? initialValues])
		: super(initialValues ?? {});

	ScoutingData.empty() : super.empty();

	@override
	ScoutingData updateField(String fieldName, dynamic value) {
		return ScoutingData(updateFieldValues(fieldName, value));
	}

	static final Map<String, FieldDescriptor> _registeredDescriptors = {};

	@override
	void registerDescriptor(FieldDescriptor descriptor) {
		_registeredDescriptors[descriptor.name] = descriptor;
	}

	@override
	List<FieldDescriptor> get descriptors {
		final baseDescriptors = _staticDescriptors.toList();
		final registered = _registeredDescriptors.values.where(
			(d) => !baseDescriptors.any((bd) => bd.name == d.name),
		);
		return [...baseDescriptors, ...registered];
	}

	static const List<FieldDescriptor> _staticDescriptors = [
		// Auto (15 fields)
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
		FieldDescriptor(name: 'auto_active_zone'),
		FieldDescriptor(name: 'auto_active_fuel_target'),
		// Tele (25 fields)
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
		FieldDescriptor(name: 'tele_active_zone'),
		FieldDescriptor(name: 'tele_active_fuel_target'),
		// End game
		FieldDescriptor(name: 'scouter'),
		FieldDescriptor(name: 'comments'),
	];

	// UI state getters - backed by descriptor fields, so they're serialized
	String get autoActiveZone => getFieldValue('auto_active_zone').asString();
	String get autoActiveFuelTarget => getFieldValue('auto_active_fuel_target').asString();
	String get teleActiveZone => getFieldValue('tele_active_zone').asString();
	String get teleActiveFuelTarget => getFieldValue('tele_active_fuel_target').asString();
}

class ScoutingDataNotifier extends StateNotifier<ScoutingData> {
	final Ref _ref;
	DateTime? _autoLastZoneChangeTime;
	DateTime? _teleLastZoneChangeTime;

	ScoutingDataNotifier(this._ref) : super(_initializeDefaults(ScoutingData.empty()));

	static ScoutingData _initializeDefaults(ScoutingData data) {
		var result = data;
		final autoZone = result.values['auto_active_zone'] as String?;
		if (autoZone == null || autoZone.isEmpty) {
			result = result.updateField('auto_active_zone', 'alliance');
		}
		final autoFuelTarget = result.values['auto_active_fuel_target'] as String?;
		if (autoFuelTarget == null || autoFuelTarget.isEmpty) {
			result = result.updateField('auto_active_fuel_target', 'hub');
		}
		final teleZone = result.values['tele_active_zone'] as String?;
		if (teleZone == null || teleZone.isEmpty) {
			result = result.updateField('tele_active_zone', 'alliance');
		}
		final teleFuelTarget = result.values['tele_active_fuel_target'] as String?;
		if (teleFuelTarget == null || teleFuelTarget.isEmpty) {
			result = result.updateField('tele_active_fuel_target', 'hub');
		}
		return result;
	}

	void update(ScoutingData data) {
		state = data;
	}

	void reset() {
		state = _initializeDefaults(ScoutingData.empty());
		_ref.read(timelineProvider.notifier).clear();
		_ref.read(matchTimerProvider.notifier).clear();
		_autoLastZoneChangeTime = null;
		_teleLastZoneChangeTime = null;
	}

	void loadFromServerData(Map<String, dynamic> data) {
		final newState = ScoutingData();
		newState.loadFromMap(data);

		// Initialize zone and fuel target defaults if not present
		var finalState = newState;
		final autoZone = finalState.values['auto_active_zone'] as String?;
		if (autoZone == null || autoZone.isEmpty) {
			finalState = finalState.updateField('auto_active_zone', 'alliance');
		}
		final autoFuelTarget = finalState.values['auto_active_fuel_target'] as String?;
		if (autoFuelTarget == null || autoFuelTarget.isEmpty) {
			finalState = finalState.updateField('auto_active_fuel_target', 'hub');
		}
		final teleZone = finalState.values['tele_active_zone'] as String?;
		if (teleZone == null || teleZone.isEmpty) {
			finalState = finalState.updateField('tele_active_zone', finalState.autoActiveZone);
		}
		final teleFuelTarget = finalState.values['tele_active_fuel_target'] as String?;
		if (teleFuelTarget == null || teleFuelTarget.isEmpty) {
			finalState = finalState.updateField('tele_active_fuel_target', 'hub');
		}

		state = finalState;
		_autoLastZoneChangeTime = null;
		_teleLastZoneChangeTime = null;
	}

	void syncStartTime(DateTime matchStartTime) {
		if (_ref.read(matchTimerProvider) == null) {
			_ref.read(matchTimerProvider.notifier).setStartTime(matchStartTime);
		}
	}

	// Parameterized action recording for both phases
	void _recordAction({
		required String phase, // 'auto' or 'tele'
		required String field,
		required int value,
	}) {
		final now = DateTime.now();
		final matchStartTime = _ref.read(matchTimerProvider);
		final startTime = matchStartTime ?? now;
		final elapsed = now.difference(startTime).inSeconds;

		final event = TimelineEvent(
			timeSeconds: elapsed,
			action: field,
			value: value.toString(),
		);

		ScoutingData newState = state;
		final activeZoneKey = '${phase}_active_zone';
		final activeFuelTargetKey = '${phase}_active_fuel_target';
		final allianceTimeKey = '${phase}_alliance_time';
		final neutralTimeKey = '${phase}_neutral_time';
		final opponentTimeKey = '${phase}_opponent_time';

		final currentActiveZone = (state.values[activeZoneKey] as String?) ?? (phase == 'auto' ? 'alliance' : 'alliance');
		final lastZoneChangeTime = phase == 'auto' ? _autoLastZoneChangeTime : _teleLastZoneChangeTime;

		// Determine zone transition
		String? newZone;
		if (field.endsWith('_to_neutral')) {
			newZone = 'neutral';
		} else if (field.endsWith('_to_alliance')) {
			newZone = 'alliance';
		} else if (field.endsWith('_to_opponent')) {
			newZone = 'opponent';
		}

		// Update time accumulators if zone is changing
		if (newZone != null && newZone != currentActiveZone) {
			final lastZoneTime = lastZoneChangeTime ?? startTime;
			final zoneElapsedSeconds = now.difference(lastZoneTime).inSeconds;

			if (currentActiveZone == 'alliance' && zoneElapsedSeconds > 0) {
				final currentTime = newState.getFieldValue(allianceTimeKey).asInt();
				newState = newState.updateField(allianceTimeKey, currentTime + zoneElapsedSeconds);
			} else if (currentActiveZone == 'neutral' && zoneElapsedSeconds > 0) {
				final currentTime = newState.getFieldValue(neutralTimeKey).asInt();
				newState = newState.updateField(neutralTimeKey, currentTime + zoneElapsedSeconds);
			} else if (currentActiveZone == 'opponent' && zoneElapsedSeconds > 0) {
				final currentTime = newState.getFieldValue(opponentTimeKey).asInt();
				newState = newState.updateField(opponentTimeKey, currentTime + zoneElapsedSeconds);
			}

			newState = newState.updateField(activeZoneKey, newZone);
			if (phase == 'auto') {
				_autoLastZoneChangeTime = now;
			} else {
				_teleLastZoneChangeTime = now;
			}
		}

		// Update field value based on field type
		if (field.contains('_to_')) {
			// Zone transition field
			final currentValue = newState.getFieldValue(field).asInt();
			final newValue = currentValue + value;
			final isToNeutral = field.endsWith('_to_neutral');
			final isToOpponent = field.endsWith('_to_opponent');

			newState = newState.updateField(field, newValue);

			if (isToNeutral) {
				newState = newState.updateField(activeFuelTargetKey, phase == 'auto' ? 'alliancePass' : 'neutralAlliancePass');
			} else if (isToOpponent) {
				newState = newState.updateField(activeFuelTargetKey, 'opponentAlliancePass');
			} else {
				newState = newState.updateField(activeFuelTargetKey, 'hub');
			}
		} else if (field.contains('_fuel_') || field.contains('_collect_')) {
			// Fuel or collect field
			final currentValue = newState.getFieldValue(field).asInt();
			newState = newState.updateField(field, currentValue + value);
		} else if (field.endsWith('_level')) {
			// Climb level (set directly)
			newState = newState.updateField(field, value);
		}

		_ref.read(timelineProvider.notifier).addEvent(event);
		state = newState;
	}

	// Parameterized undo for both phases
	void _undo({required String phase}) {
		final currentTimeline = _ref.read(timelineProvider);
		if (currentTimeline.isEmpty) return;

		final lastEvent = currentTimeline.last;
		final field = lastEvent.action;
		final actionValue = int.tryParse(lastEvent.value) ?? 1;

		ScoutingData newState = state;
		final activeZoneKey = '${phase}_active_zone';
		final activeFuelTargetKey = '${phase}_active_fuel_target';

		// Handle undo based on field type
		if (field.contains('_to_')) {
			// Zone transition field
			final currentValue = newState.getFieldValue(field).asInt();
			final newValue = (currentValue - actionValue).clamp(0, 999);
			newState = newState.updateField(field, newValue);

			if (field.endsWith('_to_neutral')) {
				newState = newState.updateField(activeZoneKey, phase == 'auto' ? 'alliance' : 'alliance');
				newState = newState.updateField(activeFuelTargetKey, 'hub');
			} else if (field.endsWith('_to_alliance')) {
				newState = newState.updateField(activeZoneKey, 'neutral');
				newState = newState.updateField(activeFuelTargetKey, phase == 'auto' ? 'alliancePass' : 'neutralAlliancePass');
			} else if (field.endsWith('_to_opponent')) {
				newState = newState.updateField(activeZoneKey, 'neutral');
				newState = newState.updateField(activeFuelTargetKey, 'neutralAlliancePass');
			}
		} else if (field.contains('_fuel_') || field.contains('_collect_')) {
			final currentValue = newState.getFieldValue(field).asInt();
			newState = newState.updateField(field, (currentValue - actionValue).clamp(0, 999));
		} else if (field.endsWith('_level')) {
			newState = newState.updateField(field, actionValue);
		}

		_ref.read(timelineProvider.notifier).undo();
		state = newState;
	}

	void recordAutoAction({
		required String field,
		required int value,
	}) {
		_recordAction(phase: 'auto', field: field, value: value);
	}

	void undoAuto() {
		_undo(phase: 'auto');
	}

	void changeAutoFuelTarget(String targetName) {
		if (state.autoActiveFuelTarget == targetName) {
			return;
		}
		state = state.updateField('auto_active_fuel_target', targetName);
	}

	void recordTeleAction({
		required String field,
		required int value,
	}) {
		_recordAction(phase: 'tele', field: field, value: value);
	}

	void undoTele() {
		_undo(phase: 'tele');
	}

	void changeTeleFuelTarget(String targetName) {
		if (state.teleActiveFuelTarget == targetName) {
			return;
		}
		state = state.updateField('tele_active_fuel_target', targetName);
	}
}

final scoutingDataProvider =
	StateNotifierProvider<ScoutingDataNotifier, ScoutingData>((ref) {
	return ScoutingDataNotifier(ref);
});
