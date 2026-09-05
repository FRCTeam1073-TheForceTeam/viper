import 'package:flutter_test/flutter_test.dart';
import 'package:viper_scout/services/form_validation.dart';

void main() {
	group('FormValidation.validateTeamNumber', () {
		test('accepts valid team numbers', () {
			expect(FormValidation.validateTeamNumber('0'), null);
			expect(FormValidation.validateTeamNumber('1'), null);
			expect(FormValidation.validateTeamNumber('3476'), null);
			expect(FormValidation.validateTeamNumber('99999'), null);
		});

		test('rejects null', () {
			expect(FormValidation.validateTeamNumber(null), isNotNull);
		});

		test('rejects empty string', () {
			expect(FormValidation.validateTeamNumber(''), isNotNull);
		});

		test('rejects non-numeric input', () {
			expect(FormValidation.validateTeamNumber('abc'), isNotNull);
			expect(FormValidation.validateTeamNumber('12a'), isNotNull);
		});

		test('rejects negative numbers', () {
			expect(FormValidation.validateTeamNumber('-1'), isNotNull);
		});

		test('rejects numbers > 99999', () {
			expect(FormValidation.validateTeamNumber('100000'), isNotNull);
			expect(FormValidation.validateTeamNumber('999999'), isNotNull);
		});
	});

	group('FormValidation.validateMatchNumber', () {
		test('accepts valid match numbers', () {
			expect(FormValidation.validateMatchNumber('qm5'), null);
			expect(FormValidation.validateMatchNumber('sf1'), null);
			expect(FormValidation.validateMatchNumber('1p3'), null);
			expect(FormValidation.validateMatchNumber('abc123'), null);
		});

		test('rejects null', () {
			expect(FormValidation.validateMatchNumber(null), isNotNull);
		});

		test('rejects empty string', () {
			expect(FormValidation.validateMatchNumber(''), isNotNull);
		});

		test('rejects non-alphanumeric', () {
			expect(FormValidation.validateMatchNumber('qm-5'), isNotNull);
			expect(FormValidation.validateMatchNumber('qm 5'), isNotNull);
			expect(FormValidation.validateMatchNumber('qm_5'), isNotNull);
		});
	});

	group('FormValidation.validateNumeric', () {
		test('accepts valid numbers within range', () {
			expect(FormValidation.validateNumeric(value: '5', min: 0, max: 10, fieldName: 'Test'), null);
			expect(FormValidation.validateNumeric(value: '0', min: 0, max: 10, fieldName: 'Test'), null);
			expect(FormValidation.validateNumeric(value: '10', min: 0, max: 10, fieldName: 'Test'), null);
		});

		test('accepts null or empty as optional', () {
			expect(FormValidation.validateNumeric(value: null, min: 0, max: 10, fieldName: 'Test'), null);
			expect(FormValidation.validateNumeric(value: '', min: 0, max: 10, fieldName: 'Test'), null);
		});

		test('rejects non-numeric', () {
			expect(FormValidation.validateNumeric(value: 'abc', min: 0, max: 10, fieldName: 'Test'), isNotNull);
		});

		test('rejects values below min', () {
			expect(FormValidation.validateNumeric(value: '-1', min: 0, max: 10, fieldName: 'Test'), isNotNull);
		});

		test('rejects values above max', () {
			expect(FormValidation.validateNumeric(value: '11', min: 0, max: 10, fieldName: 'Test'), isNotNull);
		});
	});

	group('FormValidation.validateHostname', () {
		test('accepts valid hostnames', () {
			expect(FormValidation.validateHostname('localhost'), null);
			expect(FormValidation.validateHostname('example.com'), null);
			expect(FormValidation.validateHostname('sub.example.com'), null);
			expect(FormValidation.validateHostname('192.168.1.1'), null);
		});

		test('accepts URLs with protocol', () {
			expect(FormValidation.validateHostname('http://localhost'), null);
			expect(FormValidation.validateHostname('https://example.com'), null);
		});

		test('accepts hostnames with ports', () {
			expect(FormValidation.validateHostname('localhost:8080'), null);
			expect(FormValidation.validateHostname('http://localhost:3000'), null);
		});

		test('accepts optional empty as valid', () {
			expect(FormValidation.validateHostname(null), null);
			expect(FormValidation.validateHostname(''), null);
		});

		test('rejects invalid formats', () {
			expect(FormValidation.validateHostname('host name with spaces'), isNotNull);
		});
	});

	group('FormValidation.validateScouterName', () {
		test('accepts valid names', () {
			expect(FormValidation.validateScouterName('Alice'), null);
			expect(FormValidation.validateScouterName('John Doe'), null);
		});

		test('accepts null and empty as optional', () {
			expect(FormValidation.validateScouterName(null), null);
			expect(FormValidation.validateScouterName(''), null);
		});

		test('rejects names > 100 characters', () {
			final longName = 'a' * 101;
			expect(FormValidation.validateScouterName(longName), isNotNull);
		});

		test('accepts exactly 100 characters', () {
			final exactName = 'a' * 100;
			expect(FormValidation.validateScouterName(exactName), null);
		});
	});

	group('FormValidation.validateComments', () {
		test('accepts valid comments', () {
			expect(FormValidation.validateComments('Great match!'), null);
			expect(FormValidation.validateComments('Multiple line\ncomments\nhere'), null);
		});

		test('accepts null and empty as optional', () {
			expect(FormValidation.validateComments(null), null);
			expect(FormValidation.validateComments(''), null);
		});

		test('rejects comments > 500 characters', () {
			final longComment = 'a' * 501;
			expect(FormValidation.validateComments(longComment), isNotNull);
		});

		test('accepts exactly 500 characters', () {
			final exactComment = 'a' * 500;
			expect(FormValidation.validateComments(exactComment), null);
		});
	});
}
