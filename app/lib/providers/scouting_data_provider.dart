import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/field_descriptor.dart';
import '../models/map_data_model.dart';
import 'timeline_provider.dart';
import 'match_timer_provider.dart';
import 'global_scouting_data.dart';

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
		if (_registeredDescriptors.containsKey(descriptor.name)) {
			// Allow re-registration of the same descriptor (widget rebuilds)
			return;
		}
		// Check if it's in the static list
		if (_staticDescriptors.any((d) => d.name == descriptor.name)) {
			throw ArgumentError('Field descriptor conflicts with static definition: ${descriptor.name}');
		}
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

	static final List<FieldDescriptor> _staticDescriptors = [
		// Auto non-button fields
		FieldDescriptor.createStatic(name: 'auto_alliance_time', autoValuesTableDescription: 'alliance_time'),
		FieldDescriptor.createStatic(name: 'auto_neutral_time', autoValuesTableDescription: 'neutral_time'),
		FieldDescriptor.createStatic(name: 'auto_climb_level'),
		// Tele non-button fields
		FieldDescriptor.createStatic(name: 'tele_alliance_time', teleValuesTableDescription: 'alliance_time'),
		FieldDescriptor.createStatic(name: 'tele_neutral_time', teleValuesTableDescription: 'neutral_time'),
		FieldDescriptor.createStatic(name: 'tele_opponent_time', teleValuesTableDescription: 'opponent_time'),
		FieldDescriptor.createStatic(name: 'tele_climb_level'),
	];

}

class ScoutingDataNotifier extends StateNotifier<ScoutingData> {
	final Ref _ref;
	DateTime? _autoLastZoneChangeTime;
	DateTime? _teleLastZoneChangeTime;
	String _activeZone = 'alliance';
	String _activeFuelTarget = 'hub';

	ScoutingDataNotifier(this._ref) : super(_initializeDefaults(ScoutingData.empty()));

	String get activeZone => _activeZone;
	String get activeFuelTarget => _activeFuelTarget;

	static ScoutingData _initializeDefaults(ScoutingData data) {
		return data;
	}

	void update(ScoutingData data) {
		state = data;
		setGlobalScoutingData(data);
	}

	void reset() {
		state = _initializeDefaults(ScoutingData.empty());
		setGlobalScoutingData(state);
		_ref.read(timelineProvider.notifier).clear();
		_ref.read(matchTimerProvider.notifier).clear();
		_ref.read(activeZoneProvider.notifier).reset();
		_ref.read(activeFuelTargetProvider.notifier).reset();
		_autoLastZoneChangeTime = null;
		_teleLastZoneChangeTime = null;
		_activeZone = 'alliance';
		_activeFuelTarget = 'hub';
	}

	void loadFromServerData(Map<String, dynamic> data) {
		final newState = ScoutingData();
		newState.loadFromMap(data);

		state = newState;
		setGlobalScoutingData(state);
		_autoLastZoneChangeTime = null;
		_teleLastZoneChangeTime = null;
		// Always reset to alliance/hub when loading. Each phase will set its own zone.
		_activeZone = 'alliance';
		_activeFuelTarget = 'hub';
		_ref.read(activeZoneProvider.notifier).changeZone(_activeZone);
		_ref.read(activeFuelTargetProvider.notifier).changeTarget(_activeFuelTarget);
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
		// Read current zone from provider (source of truth) instead of internal variable
		final currentZone = _ref.read(activeZoneProvider);
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
		final allianceTimeKey = '${phase}_alliance_time';
		final neutralTimeKey = '${phase}_neutral_time';
		final opponentTimeKey = '${phase}_opponent_time';

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
		if (newZone != null && newZone != currentZone) {
			final lastZoneTime = lastZoneChangeTime ?? startTime;
			final zoneElapsedSeconds = now.difference(lastZoneTime).inSeconds;


			if (currentZone == 'alliance' && zoneElapsedSeconds > 0) {
				final currentTime = newState.getFieldValue(allianceTimeKey).asInt();
				newState = newState.updateField(allianceTimeKey, currentTime + zoneElapsedSeconds);
			} else if (currentZone == 'neutral' && zoneElapsedSeconds > 0) {
				final currentTime = newState.getFieldValue(neutralTimeKey).asInt();
				newState = newState.updateField(neutralTimeKey, currentTime + zoneElapsedSeconds);
			} else if (currentZone == 'opponent' && zoneElapsedSeconds > 0) {
				final currentTime = newState.getFieldValue(opponentTimeKey).asInt();
				newState = newState.updateField(opponentTimeKey, currentTime + zoneElapsedSeconds);
			}

			_activeZone = newZone;
			_ref.read(activeZoneProvider.notifier).changeZone(newZone);
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
				final targetName = phase == 'auto' ? 'alliancePass' : 'neutralAlliancePass';
				_activeFuelTarget = targetName;
				_ref.read(activeFuelTargetProvider.notifier).changeTarget(targetName);
			} else if (isToOpponent) {
				_activeFuelTarget = 'opponentNeutralPass';
				_ref.read(activeFuelTargetProvider.notifier).changeTarget('opponentNeutralPass');
			} else {
				_activeFuelTarget = 'hub';
				_ref.read(activeFuelTargetProvider.notifier).changeTarget('hub');
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
		setGlobalScoutingData(newState);
	}

	// Parameterized undo for both phases
	void _undo({required String phase}) {
		final currentTimeline = _ref.read(timelineProvider);
		if (currentTimeline.isEmpty) return;

		final lastEvent = currentTimeline.last;
		final field = lastEvent.action;
		final actionValue = int.tryParse(lastEvent.value) ?? 1;

		ScoutingData newState = state;

		// Handle undo based on field type
		if (field.contains('_to_')) {
			// Zone transition field
			final currentValue = newState.getFieldValue(field).asInt();
			final newValue = (currentValue - actionValue).clamp(0, 999);
			newState = newState.updateField(field, newValue);

			if (field.endsWith('_to_neutral')) {
				_activeZone = 'alliance';
				_activeFuelTarget = 'hub';
				_ref.read(activeZoneProvider.notifier).changeZone('alliance');
				_ref.read(activeFuelTargetProvider.notifier).changeTarget('hub');
			} else if (field.endsWith('_to_alliance')) {
				_activeZone = 'neutral';
				_activeFuelTarget = 'alliancePass';
				_ref.read(activeZoneProvider.notifier).changeZone('neutral');
				_ref.read(activeFuelTargetProvider.notifier).changeTarget('alliancePass');
			} else if (field.endsWith('_to_opponent')) {
				_activeZone = 'neutral';
				_activeFuelTarget = 'opponentAlliancePass';
				_ref.read(activeZoneProvider.notifier).changeZone('neutral');
				_ref.read(activeFuelTargetProvider.notifier).changeTarget('opponentAlliancePass');
			}
		} else if (field.contains('_fuel_') || field.contains('_collect_')) {
			final currentValue = newState.getFieldValue(field).asInt();
			newState = newState.updateField(field, (currentValue - actionValue).clamp(0, 999));
		} else if (field.endsWith('_level')) {
			newState = newState.updateField(field, actionValue);
		}

		_ref.read(timelineProvider.notifier).undo();
		state = newState;
		setGlobalScoutingData(newState);
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
		if (_activeFuelTarget == targetName) {
			return;
		}
		_activeFuelTarget = targetName;
		_ref.read(activeFuelTargetProvider.notifier).changeTarget(targetName);
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
		if (_activeFuelTarget == targetName) {
			return;
		}
		_activeFuelTarget = targetName;
		_ref.read(activeFuelTargetProvider.notifier).changeTarget(targetName);
	}
}

final scoutingDataProvider =
	StateNotifierProvider<ScoutingDataNotifier, ScoutingData>((ref) {
	final notifier = ScoutingDataNotifier(ref);
	setGlobalScoutingData(notifier.state);
	return notifier;
});

final activeZoneProvider =
	StateNotifierProvider<_ActiveZoneNotifier, String>((ref) {
	return _ActiveZoneNotifier();
});

final activeFuelTargetProvider =
	StateNotifierProvider<_ActiveFuelTargetNotifier, String>((ref) {
	return _ActiveFuelTargetNotifier();
});

class _ActiveZoneNotifier extends StateNotifier<String> {
	_ActiveZoneNotifier() : super('alliance');

	void changeZone(String zone) {
		state = zone;
	}

	void reset() {
		state = 'alliance';
	}
}

class _ActiveFuelTargetNotifier extends StateNotifier<String> {
	_ActiveFuelTargetNotifier() : super('hub');

	void changeTarget(String target) {
		state = target;
	}

	void reset() {
		state = 'hub';
	}
}
