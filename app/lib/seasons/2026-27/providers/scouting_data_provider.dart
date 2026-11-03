import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/field_descriptor.dart';
import '../../../models/map_data_model.dart';
import '../../../providers/timeline_provider.dart';
import '../../../providers/match_timer_provider.dart';
import '../../../providers/global_scouting_data.dart';

/// Pollen every robot starts with, counted against the held total (web: PRELOAD_POLLEN)
const int preloadPollen = 4;

/// Most pieces a robot can hold at once, pollen and nectar combined (web: HELD_MAX)
const int heldMax = 4;

const _collectPollen = ['auto_collect_pollen', 'tele_collect_pollen'];
const _collectNectar = ['auto_collect_nectar', 'tele_collect_nectar'];

const _placePollen = [
	'auto_cell_pollen',
	'auto_garden_pollen',
	'tele_cell_pollen',
	'tele_flower1_pollen',
	'tele_flower2_pollen',
	'tele_flower3_pollen',
	'tele_flower4_pollen',
	'tele_garden_pollen',
];

const _placeNectar = [
	'auto_cell_nectar',
	'auto_garden_nectar',
	'tele_cell_nectar',
	'tele_flower1_nectar',
	'tele_flower2_nectar',
	'tele_flower3_nectar',
	'tele_flower4_nectar',
	'tele_garden_nectar',
];

/// Checkboxes that are recorded on the timeline (web: the auto tab and the no-show area)
const timelineCheckboxFields = {'no_show', 'auto_leave', 'auto_park'};

/// Every checkbox on the form. End-game checkboxes are not on the timeline.
const checkboxFields = {'no_show', 'auto_leave', 'auto_park', 'end_park', 'robot_disabled'};

final _cellActionPattern = RegExp(r'^(auto|tele)_cell_(pollen|nectar)$');

/// Pieces held by the robot, per color, derived from the counters
class HeldCounts {
	final int pollen;
	final int nectar;

	const HeldCounts(this.pollen, this.nectar);

	int get total => pollen + nectar;

	/// Collection is blocked once the robot holds the max
	bool get collectBlocked => total >= heldMax;

	/// A color can only be placed while the robot holds some of it
	bool get pollenPlaceBlocked => pollen <= 0;
	bool get nectarPlaceBlocked => nectar <= 0;
}

HeldCounts computeHeld(ScoutingData data) {
	int sum(List<String> fields) =>
		fields.fold(0, (total, f) => total + data.getFieldValue(f).asInt());

	final pollen = preloadPollen + sum(_collectPollen) - sum(_placePollen);
	final nectar = sum(_collectNectar) - sum(_placeNectar);
	return HeldCounts(pollen, nectar);
}

/// HIVE TIP only counts right after a POLLEN or NECTAR goes into a CELL, since only a
/// launch into the upward-facing CELL can tip the HIVE (web: updateHiveTipGate)
bool hiveTipEnabled(List<TimelineEvent> timeline) {
	if (timeline.isEmpty) return false;
	return _cellActionPattern.hasMatch(timeline.last.action);
}

/// Unified scouting data for an entire season match
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
		// Checkboxes
		for (final name in checkboxFields) FieldDescriptor.createStatic(name: name),
		// Counters
		FieldDescriptor.createStatic(name: 'auto_collect_pollen'),
		FieldDescriptor.createStatic(name: 'auto_collect_nectar'),
		FieldDescriptor.createStatic(name: 'auto_cell_pollen'),
		FieldDescriptor.createStatic(name: 'auto_cell_nectar'),
		FieldDescriptor.createStatic(name: 'auto_hive_tip'),
		FieldDescriptor.createStatic(name: 'auto_garden_pollen'),
		FieldDescriptor.createStatic(name: 'auto_garden_nectar'),
		FieldDescriptor.createStatic(name: 'tele_collect_pollen'),
		FieldDescriptor.createStatic(name: 'tele_collect_nectar'),
		FieldDescriptor.createStatic(name: 'tele_cell_pollen'),
		FieldDescriptor.createStatic(name: 'tele_cell_nectar'),
		FieldDescriptor.createStatic(name: 'tele_hive_tip'),
		for (var i = 1; i <= 4; i++) ...[
			FieldDescriptor.createStatic(name: 'tele_flower${i}_pollen'),
			FieldDescriptor.createStatic(name: 'tele_flower${i}_nectar'),
		],
		FieldDescriptor.createStatic(name: 'tele_garden_pollen'),
		FieldDescriptor.createStatic(name: 'tele_garden_nectar'),
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

	/// Count one tap on a counter and add it to the timeline
	void recordAction({required String field, int value = 1}) {
		final current = state.getFieldValue(field).asInt();
		final updated = state.updateField(field, (current + value).clamp(0, 999));
		_ref.read(timelineProvider.notifier).addEvent(
			TimelineEvent(timeSeconds: _elapsedSeconds(), action: field, value: value.toString()));
		state = updated;
		setGlobalScoutingData(updated);
	}

	/// Check or uncheck a timeline checkbox. Unchecking removes its timeline entry.
	void toggleCheckbox({required String field, required bool checked}) {
		syncStartTime(DateTime.now());
		final updated = state.updateField(field, checked ? 1 : 0);
		final timeline = _ref.read(timelineProvider.notifier);
		if (checked) {
			timeline.addEvent(
				TimelineEvent(timeSeconds: _elapsedSeconds(), action: field, value: '1'));
		} else {
			timeline.setTimeline(
				_ref.read(timelineProvider).where((e) => e.action != field).toList());
		}
		state = updated;
		setGlobalScoutingData(updated);
	}

	/// Set an end-game checkbox. These are not on the timeline.
	void setCheckbox({required String field, required bool checked}) {
		final updated = state.updateField(field, checked ? 1 : 0);
		state = updated;
		setGlobalScoutingData(updated);
	}

	/// Reverse the last timeline entry: a counter goes back by its amount, a checkbox is cleared
	void undoLast() {
		final timeline = _ref.read(timelineProvider);
		if (timeline.isEmpty) return;
		final last = timeline.last;
		final ScoutingData updated;
		if (checkboxFields.contains(last.action)) {
			updated = state.updateField(last.action, 0);
		} else {
			final amount = int.tryParse(last.value) ?? 1;
			final current = state.getFieldValue(last.action).asInt();
			updated = state.updateField(last.action, (current - amount).clamp(0, 999));
		}
		_ref.read(timelineProvider.notifier).undo();
		state = updated;
		setGlobalScoutingData(updated);
	}
}

final scoutingDataProvider =
	StateNotifierProvider<ScoutingDataNotifier, ScoutingData>((ref) {
	final notifier = ScoutingDataNotifier(ref);
	// ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
	setGlobalScoutingData(notifier.state);
	return notifier;
});
