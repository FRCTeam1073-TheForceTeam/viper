import 'package:flutter_test/flutter_test.dart';
import 'package:viper_scout/services/csv_parser.dart';
import 'package:viper_scout/services/csv_builder.dart';

void main() {
	group('unescapeField', () {
		test('unescapes ⏎ to newline', () {
			expect(unescapeField('hello⏎world'), 'hello\nworld');
		});

		test('unescapes Hebrew quote character', () {
			expect(unescapeField('hello״world'), 'hello"world');
		});

		test('unescapes Arabic comma character', () {
			expect(unescapeField('hello،world'), 'hello,world');
		});

		test('handles multiple escape characters', () {
			expect(unescapeField('a،b"c⏎d'), 'a,b"c\nd');
		});

		test('returns unchanged string with no escapes', () {
			expect(unescapeField('normal text'), 'normal text');
		});
	});

	group('csvToArrayOfMaps', () {
		test('parses empty CSV', () {
			expect(csvToArrayOfMaps(''), []);
		});

		test('parses header-only CSV', () {
			expect(csvToArrayOfMaps('name,age'), []);
		});

		test('parses single row', () {
			final result = csvToArrayOfMaps('name,age\nAlice,30');
			expect(result.length, 1);
			expect(result[0]['name'], 'Alice');
			expect(result[0]['age'], 30); // parsed as int
		});

		test('parses numeric values as integers', () {
			final result = csvToArrayOfMaps('team,score\n123,42');
			expect(result[0]['team'], 123);
			expect(result[0]['score'], 42);
		});

		test('keeps non-numeric strings as strings', () {
			final result = csvToArrayOfMaps('name,code\nAlice,qm5');
			expect(result[0]['name'], 'Alice');
			expect(result[0]['code'], 'qm5');
		});

		test('skips blank lines', () {
			final result = csvToArrayOfMaps('name,age\nAlice,30\n\nBob,25');
			expect(result.length, 2);
			expect(result[0]['name'], 'Alice');
			expect(result[1]['name'], 'Bob');
		});

		test('handles ragged rows (fewer values than headers)', () {
			final result = csvToArrayOfMaps('a,b,c\n1,2\n3,4,5');
			expect(result.length, 2);
			expect(result[0].containsKey('a'), true);
			expect(result[0].containsKey('b'), true);
			expect(result[0].containsKey('c'), false);
		});

		test('unescapes field values', () {
			final result = csvToArrayOfMaps('comment\nhello،world');
			expect(result[0]['comment'], 'hello,world');
		});

		test('handles windows and unix line endings', () {
			final result = csvToArrayOfMaps('a,b\r\n1,2\r\n3,4');
			expect(result.length, 2);
		});

		test('trims whitespace from values', () {
			final result = csvToArrayOfMaps('name,age\n  Alice  ,  30  ');
			expect(result[0]['name'], 'Alice');
			expect(result[0]['age'], 30);
		});
	});

	group('CSV round-trip (builder + parser)', () {
		test('round-trip preserves simple data', () {
			final original = [
				{'teamNumber': '123', 'matchNumber': 'qm5'},
				{'teamNumber': '456', 'matchNumber': 'qm6'},
			];
			final csv = CsvBuilder.buildScoutCsv(original);
			final parsed = csvToArrayOfMaps(csv);

			expect(parsed.length, 2);
			expect(parsed[0]['team_number'], 123); // parsed as int
			expect(parsed[0]['match_number'], 'qm5');
			expect(parsed[1]['team_number'], 456); // parsed as int
			expect(parsed[1]['match_number'], 'qm6');
		});

		test('round-trip preserves escaped characters', () {
			final original = [
				{'comments': 'good,match\nperformance'},
			];
			final csv = CsvBuilder.buildScoutCsv(original);
			final parsed = csvToArrayOfMaps(csv);

			expect(parsed[0]['comments'], 'good,match\nperformance');
		});

		test('round-trip with quotes in text', () {
			final original = [
				{'description': 'robot said "hello"'},
			];
			final csv = CsvBuilder.buildScoutCsv(original);
			final parsed = csvToArrayOfMaps(csv);

			expect(parsed[0]['description'], 'robot said "hello"');
		});

		test('round-trip with multiple special chars', () {
			final original = [
				{'data': 'a,b"c\nd\te'},
			];
			final csv = CsvBuilder.buildScoutCsv(original);
			final parsed = csvToArrayOfMaps(csv);

			expect(parsed[0]['data'], 'a,b"c\nd e'); // tab → space via safeCSV
		});
	});
}
