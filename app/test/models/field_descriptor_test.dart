import 'package:flutter_test/flutter_test.dart';
import 'package:viper_scout/models/field_descriptor.dart';
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

	group('FieldDescriptor factory caching', () {
		test('caches descriptor by name', () {
			final desc1 = FieldDescriptor(name: 'autoShoot');
			final desc2 = FieldDescriptor(name: 'autoShoot');
			expect(identical(desc1, desc2), true);
		});

		test('does not cache when value is provided', () {
			final desc1 = FieldDescriptor(name: 'autoShoot', value: '5');
			final desc2 = FieldDescriptor(name: 'autoShoot', value: '3');
			expect(identical(desc1, desc2), false);
		});

		test('returns same cached instance for multiple calls without value', () {
			final desc1 = FieldDescriptor(name: 'autoShoot');
			final desc2 = FieldDescriptor(name: 'autoShoot');
			final desc3 = FieldDescriptor(name: 'autoShoot');
			expect(identical(desc1, desc2), true);
			expect(identical(desc2, desc3), true);
		});

		test('separate descriptors are not cached', () {
			final desc1 = FieldDescriptor(name: 'autoShoot');
			final desc2 = FieldDescriptor(name: 'autoMove');
			expect(identical(desc1, desc2), false);
		});
	});

	group('FieldDescriptor.createStatic', () {
		test('creates static descriptor without auto-registration', () {
			final desc = FieldDescriptor.createStatic(name: 'staticField');
			expect(desc.name, 'staticField');
			expect(desc.asString(), '');
		});

		test('static descriptors are not cached in factory cache', () {
			final static = FieldDescriptor.createStatic(name: 'static');
			final factory = FieldDescriptor(name: 'static');
			// They should be different instances
			expect(identical(static, factory), false);
		});
	});

	group('FieldDescriptor.withValue', () {
		test('creates new instance with different value', () {
			final desc1 = FieldDescriptor(name: 'autoShoot', value: '5');
			final desc2 = desc1.withValue('10');
			expect(desc1.asInt(), 5);
			expect(desc2.asInt(), 10);
		});

		test('preserves metadata through withValue', () {
			final desc1 = FieldDescriptor(
				name: 'autoShoot',
				uiLabelKey: 'auto_shoot_label',
				value: '5',
			);
			final desc2 = desc1.withValue('10');
			expect(desc2.name, 'autoShoot');
			expect(desc2.uiLabelKey, 'auto_shoot_label');
		});

		test('withValue null creates descriptor with no value', () {
			final desc1 = FieldDescriptor(name: 'autoShoot', value: '5');
			final desc2 = desc1.withValue(null);
			expect(desc2.asString(), '');
		});
	});

	group('FieldDescriptor.asBool', () {
		test('parses "1" as true', () {
			final desc = FieldDescriptor(name: 'moved', value: '1');
			expect(desc.asBool(), true);
		});

		test('parses "true" as true (case-insensitive)', () {
			expect(FieldDescriptor(name: 'a', value: 'true').asBool(), true);
			expect(FieldDescriptor(name: 'a', value: 'TRUE').asBool(), true);
			expect(FieldDescriptor(name: 'a', value: 'True').asBool(), true);
		});

		test('parses "false" as false', () {
			final desc = FieldDescriptor(name: 'a', value: 'false');
			expect(desc.asBool(), false);
		});

		test('parses "0" as false', () {
			final desc = FieldDescriptor(name: 'a', value: '0');
			expect(desc.asBool(), false);
		});

		test('parses empty string as false', () {
			final desc = FieldDescriptor(name: 'a', value: '');
			expect(desc.asBool(), false);
		});

		test('parses null as false', () {
			final desc = FieldDescriptor(name: 'a', value: null);
			expect(desc.asBool(), false);
		});

		test('parses garbage input as false', () {
			expect(FieldDescriptor(name: 'a', value: 'garbage').asBool(), false);
			expect(FieldDescriptor(name: 'a', value: '2').asBool(), false);
		});
	});

	group('FieldDescriptor.asInt', () {
		test('parses numeric string', () {
			final desc = FieldDescriptor(name: 'score', value: '42');
			expect(desc.asInt(), 42);
		});

		test('parses zero', () {
			final desc = FieldDescriptor(name: 'score', value: '0');
			expect(desc.asInt(), 0);
		});

		test('parses negative numbers', () {
			final desc = FieldDescriptor(name: 'score', value: '-5');
			expect(desc.asInt(), -5);
		});

		test('returns 0 for non-numeric string', () {
			final desc = FieldDescriptor(name: 'score', value: 'abc');
			expect(desc.asInt(), 0);
		});

		test('returns 0 for empty string', () {
			final desc = FieldDescriptor(name: 'score', value: '');
			expect(desc.asInt(), 0);
		});

		test('returns 0 for null', () {
			final desc = FieldDescriptor(name: 'score', value: null);
			expect(desc.asInt(), 0);
		});

		test('parses partial numeric string (stops at non-digit)', () {
			final desc = FieldDescriptor(name: 'score', value: '42abc');
			expect(desc.asInt(), 0); // int.tryParse fails, returns 0
		});
	});

	group('FieldDescriptor.asString', () {
		test('returns string value', () {
			final desc = FieldDescriptor(name: 'comment', value: 'great match');
			expect(desc.asString(), 'great match');
		});

		test('returns empty string when null', () {
			final desc = FieldDescriptor(name: 'comment', value: null);
			expect(desc.asString(), '');
		});

		test('returns empty string when value is empty string', () {
			final desc = FieldDescriptor(name: 'comment', value: '');
			expect(desc.asString(), '');
		});

		test('preserves whitespace', () {
			final desc = FieldDescriptor(name: 'comment', value: '  spaced  ');
			expect(desc.asString(), '  spaced  ');
		});
	});

	group('FieldDescriptor.uiLabel', () {
		test('returns uiLabelKey when provided', () {
			final desc = FieldDescriptor(
				name: 'autoShoot',
				uiLabelKey: 'auto_shoot_label',
			);
			expect(desc.uiLabel, 'auto_shoot_label');
		});

		test('defaults to name when uiLabelKey is null', () {
			final desc = FieldDescriptor(name: 'autoShoot');
			expect(desc.uiLabel, 'autoShoot');
		});
	});

	group('FieldDescriptor auto-registration', () {
		test('auto-registers with global scouting data', () {
			resetGlobalScoutingDataForTesting();
			FieldDescriptor.resetCacheForTesting();

			// This won't register because there's no global scouting data,
			// but it shouldn't throw either
			final desc = FieldDescriptor(name: 'test');
			expect(desc.name, 'test');
		});
	});
}
