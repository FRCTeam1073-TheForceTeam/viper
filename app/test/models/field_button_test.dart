import 'package:flutter_test/flutter_test.dart';
import 'package:viper_scout/models/field_button.dart';
import 'package:viper_scout/models/field_descriptor.dart';

void main() {
	group('FieldButton construction', () {
		test('creates button with required fields', () {
			final button = FieldButton(
				field: 'auto_alliance_score',
				label: 'Alliance Shoot',
				imagePath: 'assets/alliance.png',
				zone: 'alliance',
				bottomPercent: 20.0,
			);

			expect(button.field, 'auto_alliance_score');
			expect(button.label, 'Alliance Shoot');
			expect(button.imagePath, 'assets/alliance.png');
			expect(button.zone, 'alliance');
			expect(button.bottomPercent, 20.0);
		});

		test('uses default values for optional positioning', () {
			final button = FieldButton(
				field: 'test',
				label: 'Test',
				imagePath: 'test.png',
				zone: 'neutral',
				bottomPercent: 50.0,
			);

			expect(button.rightPercent, 0.0);
			expect(button.leftPercent, isNull);
			expect(button.topPercent, isNull);
			expect(button.widthPercent, 7.0);
			expect(button.aspectRatio, 1.0);
		});

		test('accepts leftPercent instead of rightPercent', () {
			final button = FieldButton(
				field: 'auto_opponent_score',
				label: 'Opponent Shoot',
				leftPercent: 10.0,
				imagePath: 'assets/opponent.png',
				zone: 'opponent',
				bottomPercent: 30.0,
			);

			expect(button.leftPercent, 10.0);
			expect(button.rightPercent, 0.0);
		});

		test('accepts topPercent instead of bottomPercent', () {
			final button = FieldButton(
				field: 'auto_neutral_intake',
				label: 'Neutral Intake',
				imagePath: 'assets/neutral.png',
				zone: 'neutral',
				topPercent: 40.0,
			);

			expect(button.topPercent, 40.0);
			expect(button.bottomPercent, isNull);
		});

		test('accepts custom width and aspect ratio', () {
			final button = FieldButton(
				field: 'test',
				label: 'Test',
				imagePath: 'test.png',
				zone: 'alliance',
				bottomPercent: 50.0,
				widthPercent: 12.0,
				aspectRatio: 1.5,
			);

			expect(button.widthPercent, 12.0);
			expect(button.aspectRatio, 1.5);
		});

		test('accepts optional field descriptor', () {
			final desc = FieldDescriptor(name: 'auto_alliance_score');
			final button = FieldButton(
				field: 'auto_alliance_score',
				label: 'Score',
				imagePath: 'test.png',
				zone: 'alliance',
				bottomPercent: 50.0,
				descriptor: desc,
			);

			expect(button.descriptor, desc);
		});

		test('enforces bottomPercent or topPercent via assertion', () {
			expect(
				() => FieldButton(
					field: 'test',
					label: 'Test',
					imagePath: 'test.png',
					zone: 'test',
					// Neither bottomPercent nor topPercent provided
				),
				throwsAssertionError,
			);
		});
	});

	group('FieldButton zones', () {
		test('accepts alliance zone', () {
			final button = FieldButton(
				field: 'test',
				label: 'Test',
				imagePath: 'test.png',
				zone: 'alliance',
				bottomPercent: 50.0,
			);

			expect(button.zone, 'alliance');
		});

		test('accepts neutral zone', () {
			final button = FieldButton(
				field: 'test',
				label: 'Test',
				imagePath: 'test.png',
				zone: 'neutral',
				bottomPercent: 50.0,
			);

			expect(button.zone, 'neutral');
		});

		test('accepts opponent zone', () {
			final button = FieldButton(
				field: 'test',
				label: 'Test',
				imagePath: 'test.png',
				zone: 'opponent',
				bottomPercent: 50.0,
			);

			expect(button.zone, 'opponent');
		});
	});

	group('FieldButton.toString', () {
		test('formats button info in toString', () {
			final button = FieldButton(
				field: 'auto_alliance',
				label: 'Alliance',
				imagePath: 'test.png',
				zone: 'alliance',
				rightPercent: 15.0,
				bottomPercent: 25.0,
			);

			final str = button.toString();

			expect(str, contains('auto_alliance'));
			expect(str, contains('Alliance'));
			expect(str, contains('alliance'));
			expect(str, contains('15'));
			expect(str, contains('25'));
		});

		test('includes null values in toString', () {
			final button = FieldButton(
				field: 'auto_opponent',
				label: 'Opponent',
				imagePath: 'test.png',
				zone: 'opponent',
				leftPercent: 10.0,
				topPercent: 30.0,
			);

			final str = button.toString();

			expect(str, contains('null')); // rightPercent and bottomPercent are null
		});
	});

	group('FieldButton positioning', () {
		test('left/right positioning is mutually exclusive concept', () {
			final leftButton = FieldButton(
				field: 'test',
				label: 'Test',
				imagePath: 'test.png',
				zone: 'opponent',
				leftPercent: 5.0,
				bottomPercent: 50.0,
			);

			final rightButton = FieldButton(
				field: 'test',
				label: 'Test',
				imagePath: 'test.png',
				zone: 'alliance',
				rightPercent: 5.0,
				bottomPercent: 50.0,
			);

			expect(leftButton.leftPercent, 5.0);
			expect(rightButton.rightPercent, 5.0);
		});

		test('top/bottom positioning is mutually exclusive concept', () {
			final topButton = FieldButton(
				field: 'test',
				label: 'Test',
				imagePath: 'test.png',
				zone: 'neutral',
				rightPercent: 50.0,
				topPercent: 10.0,
			);

			final bottomButton = FieldButton(
				field: 'test',
				label: 'Test',
				imagePath: 'test.png',
				zone: 'neutral',
				rightPercent: 50.0,
				bottomPercent: 10.0,
			);

			expect(topButton.topPercent, 10.0);
			expect(bottomButton.bottomPercent, 10.0);
		});
	});
}
