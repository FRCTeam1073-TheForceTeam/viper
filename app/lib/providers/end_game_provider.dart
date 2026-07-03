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

	@override
	List<FieldDescriptor> get descriptors => _descriptors;

	// Field descriptors: single source of truth for all end-game fields
	static final _descriptors = [
		StringFieldDescriptor(fieldName: 'autoClimbPosition', csvKey: 'auto_climb_position'),
		StringFieldDescriptor(fieldName: 'teleClimbPosition', csvKey: 'tele_climb_position'),
		StringFieldDescriptor(fieldName: 'climbMethod', csvKey: 'climb_method'),
		BoolFieldDescriptor(fieldName: 'shootOnMove', csvKey: 'shoot_move', uiLabelKey: 'shoot_move_desc'),
		BoolFieldDescriptor(fieldName: 'shootWhileCollecting', csvKey: 'shoot_collecting', uiLabelKey: 'shoot_collecting_desc'),
		BoolFieldDescriptor(fieldName: 'shootTurret', csvKey: 'shoot_turret', uiLabelKey: 'shoot_turret_desc'),
		BoolFieldDescriptor(fieldName: 'shootClimbing', csvKey: 'shoot_climbing', uiLabelKey: 'shoot_climbing_desc'),
		StringFieldDescriptor(fieldName: 'fuelStrategy', csvKey: 'fuel_to_alliance'),
		StringFieldDescriptor(fieldName: 'bricked', csvKey: 'bricked'),
		StringFieldDescriptor(fieldName: 'defenseRating', csvKey: 'defense'),
		BoolFieldDescriptor(fieldName: 'defenseCollected', csvKey: 'defense_collected', uiLabelKey: 'defense_collected_desc'),
		BoolFieldDescriptor(fieldName: 'defenseHit', csvKey: 'defense_hit', uiLabelKey: 'defense_hit_desc'),
		BoolFieldDescriptor(fieldName: 'defenseBlocked', csvKey: 'defense_blocked', uiLabelKey: 'defense_blocked_desc'),
		BoolFieldDescriptor(fieldName: 'defensePinned', csvKey: 'defense_pinned', uiLabelKey: 'defense_pinned_desc'),
		StringFieldDescriptor(fieldName: 'defended', csvKey: 'defended'),
		StringFieldDescriptor(fieldName: 'misses', csvKey: 'misses'),
		StringFieldDescriptor(fieldName: 'scouterName', csvKey: 'scouter'),
		BoolFieldDescriptor(fieldName: 'reviewRequest', csvKey: 'review_requested', uiLabelKey: 'review_requested_button'),
		StringFieldDescriptor(fieldName: 'comments', csvKey: 'comments'),
	];

	// Typed getters - generated from descriptors
	String? get autoClimbPosition => values['autoClimbPosition'] as String?;
	String? get teleClimbPosition => values['teleClimbPosition'] as String?;
	String? get climbMethod => values['climbMethod'] as String?;
	bool get shootOnMove => values['shootOnMove'] as bool? ?? false;
	bool get shootWhileCollecting => values['shootWhileCollecting'] as bool? ?? false;
	bool get shootTurret => values['shootTurret'] as bool? ?? false;
	bool get shootClimbing => values['shootClimbing'] as bool? ?? false;
	String? get fuelStrategy => values['fuelStrategy'] as String?;
	String? get bricked => values['bricked'] as String?;
	String? get defenseRating => values['defenseRating'] as String?;
	bool get defenseCollected => values['defenseCollected'] as bool? ?? false;
	bool get defenseHit => values['defenseHit'] as bool? ?? false;
	bool get defenseBlocked => values['defenseBlocked'] as bool? ?? false;
	bool get defensePinned => values['defensePinned'] as bool? ?? false;
	String? get defended => values['defended'] as String?;
	String? get misses => values['misses'] as String?;
	String? get scouterName => values['scouterName'] as String?;
	bool get reviewRequest => values['reviewRequest'] as bool? ?? false;
	String? get comments => values['comments'] as String?;

	@override
	EndGameData updateField(String fieldName, dynamic value) {
		final newValues = {...values};
		newValues[fieldName] = value;
		return EndGameData(newValues);
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
		print('[END_GAME_LOAD] Received data with ${data.length} keys');
		final parsedValues = SerializationHelper.fromMap(EndGameData._descriptors, data);
		print('[END_GAME_LOAD] After SerializationHelper.fromMap: ${parsedValues.length} values');
		print('[END_GAME_LOAD] shootOnMove = ${parsedValues['shootOnMove']}');
		state = EndGameData(parsedValues);
		print('[END_GAME_LOAD] State updated: shootOnMove = ${state.shootOnMove}');
	}
}

final endGameProvider = StateNotifierProvider<EndGameNotifier, EndGameData>((ref) {
	return EndGameNotifier();
});
