import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/field_descriptor.dart';
import '../models/map_data_model.dart';
import '../models/serialization_helper.dart';

/// End game match data - map-based with typed accessors
/// Eliminates constructor, copyWith, and property boilerplate
class EndGameData extends MapDataModel {
	EndGameData([Map<String, dynamic>? initialValues])
		: super(initialValues ?? {});

	EndGameData.empty() : super.empty();

	static final Map<String, FieldDescriptor> _registeredDescriptors = {};

	@override
	void registerDescriptor(FieldDescriptor descriptor) {
		_registeredDescriptors[descriptor.name] = descriptor;
	}

	@override
	List<FieldDescriptor> get descriptors {
		final baseDescriptors = _descriptors.toList();
		final registered = _registeredDescriptors.values.where(
			(d) => !baseDescriptors.any((bd) => bd.name == d.name),
		);
		return [...baseDescriptors, ...registered];
	}

	// Field descriptors: single source of truth for non-UI fields
	// UI-defined fields (checkboxes, radio buttons) register themselves dynamically
	static const List<FieldDescriptor> _descriptors = [
		FieldDescriptor(name: 'auto_climb_position'),
		FieldDescriptor(name: 'tele_climb_position'),
		FieldDescriptor(name: 'shoot_move', uiLabelKey: 'shoot_move_desc'),
		FieldDescriptor(name: 'shoot_collecting', uiLabelKey: 'shoot_collecting_desc'),
		FieldDescriptor(name: 'shoot_turret', uiLabelKey: 'shoot_turret_desc'),
		FieldDescriptor(name: 'shoot_climbing', uiLabelKey: 'shoot_climbing_desc'),
		FieldDescriptor(name: 'defense_collected', uiLabelKey: 'defense_collected_desc'),
		FieldDescriptor(name: 'defense_hit', uiLabelKey: 'defense_hit_desc'),
		FieldDescriptor(name: 'defense_blocked', uiLabelKey: 'defense_blocked_desc'),
		FieldDescriptor(name: 'defense_pinned', uiLabelKey: 'defense_pinned_desc'),
		FieldDescriptor(name: 'scouter'),
		FieldDescriptor(name: 'comments'),
	];

	@override
	EndGameData updateField(String fieldName, dynamic value) {
		return EndGameData(updateFieldValues(fieldName, value));
	}
}

class EndGameNotifier extends StateNotifier<EndGameData> {
	EndGameNotifier() : super(EndGameData.empty());

	void update(EndGameData data) {
		state = data;
	}

	void reset() {
		state = EndGameData.empty();
	}

	void loadFromData(Map<String, dynamic> data) {
		try {
			print('[END_GAME_LOAD] Received data with ${data.length} keys');
			final newState = EndGameData();
			newState.loadFromMap(data);
			state = newState;
			print('[END_GAME_LOAD] State updated');
		} catch (e) {
			print('Error loading end-game data: $e');
		}
	}
}

final endGameProvider = StateNotifierProvider<EndGameNotifier, EndGameData>((ref) {
	return EndGameNotifier();
});
