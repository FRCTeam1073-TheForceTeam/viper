import 'package:flutter_test/flutter_test.dart';
import 'package:viper_scout/models/field_descriptor.dart';
import 'package:viper_scout/models/ui_helper.dart';
import 'package:viper_scout/models/map_data_model.dart';

/// Minimal test-only MapDataModel subclass for UiHelper testing
class _TestModel extends MapDataModel {
	final List<FieldDescriptor> _descriptors;

	_TestModel(super.values, this._descriptors);

	@override
	List<FieldDescriptor> get descriptors => _descriptors;

	@override
	MapDataModel updateField(String fieldName, dynamic value) {
		final newValues = updateFieldValues(fieldName, value);
		return _TestModel(newValues, _descriptors);
	}
}

void main() {
	setUp(() {
		FieldDescriptor.resetCacheForTesting();
	});

	tearDown(() {
		FieldDescriptor.resetCacheForTesting();
	});

	group('UiHelper.getCheckboxValues', () {
		test('returns empty list when no descriptors have uiLabelKey', () {
			final desc1 = FieldDescriptor(name: 'field1'); // no uiLabelKey
			final desc2 = FieldDescriptor(name: 'field2'); // no uiLabelKey
			final model = _TestModel({}, [desc1, desc2]);

			final values = UiHelper.getCheckboxValues(model);

			expect(values.isEmpty, true);
		});

		test('returns boolean values for descriptors with uiLabelKey', () {
			final desc1 = FieldDescriptor(
				name: 'checkbox1',
				uiLabelKey: 'label.checkbox1',
			);
			final desc2 = FieldDescriptor(
				name: 'checkbox2',
				uiLabelKey: 'label.checkbox2',
			);
			final model = _TestModel(
				{'checkbox1': 'true', 'checkbox2': 'false'},
				[desc1, desc2],
			);

			final values = UiHelper.getCheckboxValues(model);

			expect(values.length, 2);
			expect(values[0], true);
			expect(values[1], false);
		});

		test('converts "1" to true', () {
			final desc = FieldDescriptor(name: 'check', uiLabelKey: 'label.check');
			final model = _TestModel({'check': '1'}, [desc]);

			final values = UiHelper.getCheckboxValues(model);

			expect(values[0], true);
		});

		test('converts "0" to false', () {
			final desc = FieldDescriptor(name: 'check', uiLabelKey: 'label.check');
			final model = _TestModel({'check': '0'}, [desc]);

			final values = UiHelper.getCheckboxValues(model);

			expect(values[0], false);
		});

		test('handles missing values as false', () {
			final desc = FieldDescriptor(name: 'check', uiLabelKey: 'label.check');
			final model = _TestModel({}, [desc]); // check value not in values map

			final values = UiHelper.getCheckboxValues(model);

			expect(values[0], false);
		});

		test('filters descriptors by uiLabelKey presence', () {
			final checkboxDesc = FieldDescriptor(
				name: 'checkbox',
				uiLabelKey: 'label.check',
			);
			final regularDesc = FieldDescriptor(name: 'regular'); // no uiLabelKey
			final model = _TestModel(
				{'checkbox': 'true', 'regular': 'value'},
				[checkboxDesc, regularDesc],
			);

			final values = UiHelper.getCheckboxValues(model);

			expect(values.length, 1);
			expect(values[0], true);
		});

		test('preserves order of uiLabelKey descriptors', () {
			final desc1 = FieldDescriptor(name: 'a', uiLabelKey: 'l1');
			final desc2 = FieldDescriptor(name: 'b');
			final desc3 = FieldDescriptor(name: 'c', uiLabelKey: 'l3');
			final model = _TestModel(
				{'a': 'true', 'c': 'false'},
				[desc1, desc2, desc3],
			);

			final values = UiHelper.getCheckboxValues(model);

			expect(values.length, 2);
			expect(values[0], true);
			expect(values[1], false);
		});
	});

	group('UiHelper.getCheckboxDescriptors', () {
		test('returns empty list when no descriptors have uiLabelKey', () {
			final desc1 = FieldDescriptor(name: 'field1');
			final desc2 = FieldDescriptor(name: 'field2');

			final result = UiHelper.getCheckboxDescriptors([desc1, desc2]);

			expect(result.isEmpty, true);
		});

		test('returns only descriptors with uiLabelKey', () {
			final checkboxDesc = FieldDescriptor(
				name: 'checkbox',
				uiLabelKey: 'label.check',
			);
			final regularDesc = FieldDescriptor(name: 'regular');

			final result = UiHelper.getCheckboxDescriptors([checkboxDesc, regularDesc]);

			expect(result.length, 1);
			expect(result[0].name, 'checkbox');
		});

		test('preserves descriptor order', () {
			final desc1 = FieldDescriptor(name: 'a', uiLabelKey: 'l1');
			final desc2 = FieldDescriptor(name: 'b');
			final desc3 = FieldDescriptor(name: 'c', uiLabelKey: 'l3');

			final result = UiHelper.getCheckboxDescriptors([desc1, desc2, desc3]);

			expect(result.length, 2);
			expect(result[0].name, 'a');
			expect(result[1].name, 'c');
		});

		test('handles empty descriptor list', () {
			final result = UiHelper.getCheckboxDescriptors([]);

			expect(result.isEmpty, true);
		});
	});
}
