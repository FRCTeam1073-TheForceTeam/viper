import 'package:flutter_test/flutter_test.dart';
import 'package:viper_scout/models/field_descriptor.dart';
import 'package:viper_scout/models/map_data_model.dart';

/// Test-only subclass of MapDataModel for testing abstract base behavior
class _TestMapDataModel extends MapDataModel {
	final List<FieldDescriptor> _descriptors;

	_TestMapDataModel(super.values, this._descriptors);

	_TestMapDataModel.empty() : _descriptors = [], super.empty();

	@override
	List<FieldDescriptor> get descriptors => _descriptors;

	@override
	MapDataModel updateField(String fieldName, dynamic value) {
		final newValues = updateFieldValues(fieldName, value);
		return _TestMapDataModel(newValues, _descriptors);
	}
}

void main() {
	setUp(() {
		FieldDescriptor.resetCacheForTesting();
	});

	tearDown(() {
		FieldDescriptor.resetCacheForTesting();
	});

	group('MapDataModel.updateField', () {
		test('returns new instance with updated field', () {
			final data = _TestMapDataModel.empty();

			final updated = data.updateField('teamNumber', '3476');

			expect(data.values['teamNumber'], isNull);
			expect(updated.values['teamNumber'], '3476');
		});

		test('converts value to string', () {
			final data = _TestMapDataModel.empty();

			final updated = data.updateField('score', 42);

			expect(updated.values['score'], '42');
		});

		test('returns original data when value is null', () {
			final data = _TestMapDataModel({'teamNumber': '3476'}, []);
			final updated = data.updateField('score', null);

			expect(updated.values, data.values);
		});

		test('chains multiple updates', () {
			final data = _TestMapDataModel.empty()
				.updateField('teamNumber', '3476')
				.updateField('matchNumber', 'qm5');

			expect(data.values['teamNumber'], '3476');
			expect(data.values['matchNumber'], 'qm5');
		});
	});

	group('MapDataModel.updateFields', () {
		test('updates multiple fields at once', () {
			final data = _TestMapDataModel.empty().updateFields({
				'teamNumber': '3476',
				'matchNumber': 'qm5',
				'score': 42,
			});

			expect(data.values['teamNumber'], '3476');
			expect(data.values['matchNumber'], 'qm5');
			expect(data.values['score'], '42');
		});

		test('chains updates from updateFields', () {
			final data = _TestMapDataModel.empty()
				.updateFields({'a': 1, 'b': 2})
				.updateField('c', 3);

			expect(data.values['a'], '1');
			expect(data.values['b'], '2');
			expect(data.values['c'], '3');
		});
	});

	group('MapDataModel.toMap and loadFromMap', () {
		test('toMap returns map via descriptors', () {
			final desc = FieldDescriptor(name: 'teamNumber');
			final data = _TestMapDataModel(
				{'teamNumber': '3476'},
				[desc],
			);

			final csvMap = data.toMap();

			// toMap should return the descriptor-serialized map
			expect(csvMap, isNotNull);
		});

		test('loadFromMap hydrates data from CSV map', () {
			final desc = FieldDescriptor(name: 'teamNumber');
			// Need to add descriptor to data's _descriptors
			final dataWithDesc = _TestMapDataModel({}, [desc]);

			dataWithDesc.loadFromMap({'teamNumber': '3476'});

			expect(dataWithDesc.values.containsKey('teamNumber'), true);
		});

		test('values persist when updated', () {
			final desc = FieldDescriptor(name: 'teamNumber');
			final data = _TestMapDataModel({}, [desc]);

			final updated = data.updateField('teamNumber', '3476');

			expect(updated.values['teamNumber'], '3476');
		});
	});

	group('MapDataModel.getDescriptor', () {
		test('returns descriptor by name', () {
			final desc = FieldDescriptor(name: 'teamNumber');
			// Manually set descriptor via constructor
			final dataWithDesc = _TestMapDataModel({}, [desc]);

			final found = dataWithDesc.getDescriptor('teamNumber');

			expect(found, desc);
		});

		test('returns null for missing descriptor', () {
			final data = _TestMapDataModel.empty();

			expect(data.getDescriptor('missing'), isNull);
		});

		test('returns null when descriptors list is empty', () {
			final data = _TestMapDataModel.empty();

			expect(data.getDescriptor('anything'), isNull);
		});
	});

	group('MapDataModel.getFieldValue', () {
		test('returns field descriptor with value bound', () {
			final desc = FieldDescriptor(name: 'teamNumber');
			final data = _TestMapDataModel(
				{'teamNumber': '3476'},
				[desc],
			);

			final field = data.getFieldValue('teamNumber');

			expect(field.name, 'teamNumber');
			expect(field.asString(), '3476');
		});

		test('returns descriptor without value for missing field', () {
			final desc = FieldDescriptor(name: 'teamNumber');
			// Manually set descriptors
			final dataWithDesc = _TestMapDataModel({}, [desc]);

			final field = dataWithDesc.getFieldValue('teamNumber');

			expect(field.name, 'teamNumber');
			expect(field.asString(), ''); // default empty string when no value
		});

		test('creates synthetic descriptor for unknown field', () {
			final data = _TestMapDataModel.empty();

			final field = data.getFieldValue('unknownField');

			expect(field.name, 'unknownField');
		});
	});

	group('MapDataModel.fieldValue', () {
		test('creates field value map from name and value', () {
			final map = MapDataModel.fieldValue('teamNumber', 3476);

			expect(map, {'teamNumber': '3476'});
		});

		test('converts various types to string', () {
			final intMap = MapDataModel.fieldValue('score', 42);
			final boolMap = MapDataModel.fieldValue('noShow', true);
			final stringMap = MapDataModel.fieldValue('team', 'Alpha');

			expect(intMap['score'], '42');
			expect(boolMap['noShow'], 'true');
			expect(stringMap['team'], 'Alpha');
		});
	});
}
