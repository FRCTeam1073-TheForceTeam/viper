import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/field_descriptor.dart';
import '../../../models/map_data_model.dart';
import '../../../providers/timeline_provider.dart';
import '../../../providers/match_timer_provider.dart';
import '../../../providers/global_scouting_data.dart';

/// Unified scouting data for an entire FTC match
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
		// Counter fields (programmatically only, not via descriptor-constructing widgets)
		FieldDescriptor.createStatic(name: 'auto_goal'),
		FieldDescriptor.createStatic(name: 'auto_depot'),
		FieldDescriptor.createStatic(name: 'auto_gate'),
		FieldDescriptor.createStatic(name: 'tele_goal'),
		FieldDescriptor.createStatic(name: 'tele_depot'),
		FieldDescriptor.createStatic(name: 'tele_gate'),
	];
}

class ScoutingDataNotifier extends StateNotifier<ScoutingData> {
	final Ref _ref;

	ScoutingDataNotifier(this._ref) : super(ScoutingData.empty());

	void update(ScoutingData data) {
		state = data;
		setGlobalScoutingData(data);
	}

	void reset() {
		state = ScoutingData.empty();
		setGlobalScoutingData(state);
		_ref.read(timelineProvider.notifier).clear();
		_ref.read(matchTimerProvider.notifier).clear();
	}

	void loadFromServerData(Map<String, dynamic> data) {
		final newState = ScoutingData();
		newState.loadFromMap(data);
		state = newState;
		setGlobalScoutingData(state);
	}

	void syncStartTime(DateTime matchStartTime) {
		if (_ref.read(matchTimerProvider) == null) {
			_ref.read(matchTimerProvider.notifier).setStartTime(matchStartTime);
		}
	}

	int _elapsedSeconds() {
		final now = DateTime.now();
		final start = _ref.read(matchTimerProvider) ?? now;
		return now.difference(start).inSeconds;
	}

	// Web parity (www/2025-26/scout.js:187-217): any OTHER auto-tab interaction
	// auto-checks auto_leave once; that check is itself an undoable timeline event.
	void _autoCheckLeaveIfNeeded() {
		if (!state.getFieldValue('auto_leave').asBool()) {
			state = state.updateField('auto_leave', 1);
			_ref.read(timelineProvider.notifier).addEvent(
				TimelineEvent(timeSeconds: _elapsedSeconds(), action: 'auto_leave', value: '1'));
			setGlobalScoutingData(state);
		}
	}

	void notifyAutoTouch(String field) {
		if (field != 'auto_leave') _autoCheckLeaveIfNeeded();
	}

	void _record(String field, int value, {required bool isAutoPhase}) {
		if (isAutoPhase && field != 'auto_leave') _autoCheckLeaveIfNeeded();
		final current = state.getFieldValue(field).asInt();
		final updated = state.updateField(field, (current + value).clamp(0, 999));
		_ref.read(timelineProvider.notifier).addEvent(
			TimelineEvent(timeSeconds: _elapsedSeconds(), action: field, value: value.toString()));
		state = updated;
		setGlobalScoutingData(updated);
	}

	void recordAutoAction({required String field, required int value}) =>
		_record(field, value, isAutoPhase: true);

	void recordTeleAction({required String field, required int value}) =>
		_record(field, value, isAutoPhase: false);

	void _undo() {
		final timeline = _ref.read(timelineProvider);
		if (timeline.isEmpty) return;
		final last = timeline.last;
		final amount = int.tryParse(last.value) ?? 1;
		var updated = state;
		updated = last.action == 'auto_leave'
			? updated.updateField('auto_leave', 0)
			: updated.updateField(last.action,
				(updated.getFieldValue(last.action).asInt() - amount).clamp(0, 999));
		_ref.read(timelineProvider.notifier).undo();
		state = updated;
		setGlobalScoutingData(updated);
	}

	void undoAuto() => _undo();
	void undoTele() => _undo();
}

final scoutingDataProvider =
	StateNotifierProvider<ScoutingDataNotifier, ScoutingData>((ref) {
	final notifier = ScoutingDataNotifier(ref);
	// ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
	setGlobalScoutingData(notifier.state);
	return notifier;
});
