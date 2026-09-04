import 'package:flutter_test/flutter_test.dart';
import 'package:viper_scout/models/field_descriptor.dart';
import 'package:viper_scout/models/serialization_helper.dart';
import 'package:viper_scout/providers/global_scouting_data.dart';

void main() {
	setUp(() {
		FieldDescriptor.resetCacheForTesting();
		resetGlobalScoutingDataForTesting();
	});

	tearDown(() {
		FieldDescriptor.resetCacheForTesting();
		resetGlobalScoutingDataForTesting();
	});

	group('SerializationHelper.toMap', () {
		test('extracts values from map using descriptors', () {
			final descriptors = [
				FieldDescriptor.createStatic(name: 'teamNumber'),
				FieldDescriptor.createStatic(name: 'matchNumber'),
			];
			final values = {'teamNumber': '123', 'matchNumber': 'qm5'};

			final result = SerializationHelper.toMap(descriptors, values);

			expect(result['teamNumber'], '123');
			expect(result['matchNumber'], 'qm5');
		});

		test('omits null values', () {
			final descriptors = [
				FieldDescriptor.createStatic(name: 'teamNumber'),
				FieldDescriptor.createStatic(name: 'comment'),
			];
			final values = {'teamNumber': '123', 'comment': null};

			final result = SerializationHelper.toMap(descriptors, values);

			expect(result.containsKey('teamNumber'), true);
			expect(result.containsKey('comment'), false);
		});

		test('handles empty descriptor list', () {
			final result = SerializationHelper.toMap([], {'a': '1', 'b': '2'});
			expect(result.isEmpty, true);
		});
	});

	group('SerializationHelper.fromMap', () {
		test('converts CSV data to field values', () {
			final descriptors = [
				FieldDescriptor.createStatic(name: 'teamNumber'),
				FieldDescriptor.createStatic(name: 'matchNumber'),
			];
			final csvData = {'teamNumber': '123', 'matchNumber': 'qm5'};

			final result = SerializationHelper.fromMap(descriptors, csvData);

			expect(result['teamNumber'], '123');
			expect(result['matchNumber'], 'qm5');
		});

		test('converts values to strings', () {
			final descriptors = [
				FieldDescriptor.createStatic(name: 'score'),
			];
			final csvData = {'score': 42}; // int input

			final result = SerializationHelper.fromMap(descriptors, csvData);

			expect(result['score'], '42'); // converted to string
		});

		test('omits null values', () {
			final descriptors = [
				FieldDescriptor.createStatic(name: 'teamNumber'),
				FieldDescriptor.createStatic(name: 'comment'),
			];
			final csvData = {'teamNumber': '123', 'comment': null};

			final result = SerializationHelper.fromMap(descriptors, csvData);

			expect(result.containsKey('teamNumber'), true);
			expect(result.containsKey('comment'), false);
		});
	});

	group('SerializationHelper.toMapFromMapObject', () {
		test('extracts values from object map using descriptors', () {
			final descriptors = [
				FieldDescriptor.createStatic(name: 'teamNumber'),
				FieldDescriptor.createStatic(name: 'matchNumber'),
			];
			final values = {'teamNumber': '123', 'matchNumber': 'qm5'};

			final result = SerializationHelper.toMapFromMapObject(descriptors, values);

			expect(result['teamNumber'], '123');
			expect(result['matchNumber'], 'qm5');
		});

		test('omits null values', () {
			final descriptors = [
				FieldDescriptor.createStatic(name: 'teamNumber'),
				FieldDescriptor.createStatic(name: 'comment'),
			];
			final values = {'teamNumber': '123', 'comment': null};

			final result = SerializationHelper.toMapFromMapObject(descriptors, values);

			expect(result.containsKey('teamNumber'), true);
			expect(result.containsKey('comment'), false);
		});

		test('preserves value types', () {
			final descriptors = [
				FieldDescriptor.createStatic(name: 'score'),
			];
			final values = {'score': 42};

			final result = SerializationHelper.toMapFromMapObject(descriptors, values);

			expect(result['score'], 42);
		});
	});

	group('SerializationHelper.getFieldValue', () {
		test('retrieves typed value from map', () {
			final map = {'name': 'Alice', 'age': 30};

			final name = SerializationHelper.getFieldValue<String>(map, 'name');
			final age = SerializationHelper.getFieldValue<int>(map, 'age');

			expect(name, 'Alice');
			expect(age, 30);
		});

		test('returns null for missing key', () {
			final map = {'name': 'Alice'};

			final missing = SerializationHelper.getFieldValue<String>(map, 'missing');

			expect(missing, null);
		});

		test('returns null for type mismatch', () {
			final map = {'name': 'Alice'};

			final wrongType = SerializationHelper.getFieldValue<int>(map, 'name');

			expect(wrongType, null);
		});

		test('handles null values in map', () {
			final map = {'name': null};

			final result = SerializationHelper.getFieldValue<String>(map, 'name');

			expect(result, null);
		});
	});
}
