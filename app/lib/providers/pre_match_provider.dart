import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/field_descriptor.dart';
import '../models/map_data_model.dart';
import '../models/serialization_helper.dart';

/// Pre-match data - map-based with typed accessors
class PreMatchData extends MapDataModel {
	PreMatchData([Map<String, dynamic>? initialValues])
		: super(initialValues ?? {});

	PreMatchData.empty() : super.empty();

	static const List<FieldDescriptor> _descriptors = [
		FieldDescriptor(name: 'starting_position'),
	];

	@override
	List<FieldDescriptor> get descriptors => _descriptors;

	@override
	PreMatchData updateField(String fieldName, dynamic value) {
		return PreMatchData(updateFieldValues(fieldName, value));
	}
}

class PreMatchNotifier extends StateNotifier<PreMatchData> {
	PreMatchNotifier() : super(PreMatchData.empty());

	void update(PreMatchData data) {
		state = data;
	}

	void reset() {
		state = PreMatchData.empty();
	}

	void loadFromData(Map<String, dynamic> data) {
		try {
			final newState = PreMatchData();
			newState.loadFromMap(data);
			state = newState;
		} catch (e) {
			print('Error loading pre-match data: $e');
		}
	}
}

final preMatchProvider = StateNotifierProvider<PreMatchNotifier, PreMatchData>((ref) {
	return PreMatchNotifier();
});
