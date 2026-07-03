import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/field_descriptor.dart';
import '../models/map_data_model.dart';
import '../models/serialization_helper.dart';

/// Pre-match data - map-based with typed accessors
class PreMatchData extends MapDataModel {
	PreMatchData([Map<String, dynamic>? initialValues])
		: super(initialValues ?? {});

	PreMatchData.empty() : super.empty();

	static final Map<String, FieldDescriptor> _registeredDescriptors = {};

	static const List<FieldDescriptor> _descriptors = [];

	@override
	List<FieldDescriptor> get descriptors {
		final baseDescriptors = _descriptors.toList();
		final registered = _registeredDescriptors.values.where(
			(d) => !baseDescriptors.any((bd) => bd.name == d.name),
		);
		return [...baseDescriptors, ...registered];
	}

	@override
	PreMatchData updateField(String fieldName, dynamic value) {
		return PreMatchData(updateFieldValues(fieldName, value));
	}

	@override
	void registerDescriptor(FieldDescriptor descriptor) {
		_registeredDescriptors[descriptor.name] = descriptor;
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
