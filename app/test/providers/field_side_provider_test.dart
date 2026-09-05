import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viper_scout/providers/field_side_provider.dart';

void main() {
	setUp(() {
		SharedPreferences.setMockInitialValues({});
	});

	group('FieldSide enum', () {
		test('has left and right values', () {
			expect(FieldSide.left.name, 'left');
			expect(FieldSide.right.name, 'right');
		});
	});

	group('FieldSideNotifier', () {
		test('initializes with left side by default', () async {
			final notifier = FieldSideNotifier();
			// Give it time to load
			await Future.delayed(Duration(milliseconds: 100));

			expect(notifier.state, FieldSide.left);
		});

		test('setFieldSide changes state', () async {
			final notifier = FieldSideNotifier();

			await notifier.setFieldSide(FieldSide.right);

			expect(notifier.state, FieldSide.right);
		});

		test('setFieldSide persists to SharedPreferences', () async {
			final notifier = FieldSideNotifier();

			await notifier.setFieldSide(FieldSide.right);

			final prefs = await SharedPreferences.getInstance();
			expect(prefs.getString('fieldSide'), 'right');
		});

		test('toggleFieldSide switches between left and right', () async {
			final notifier = FieldSideNotifier();

			expect(notifier.state, FieldSide.left);

			await notifier.toggleFieldSide();
			expect(notifier.state, FieldSide.right);

			await notifier.toggleFieldSide();
			expect(notifier.state, FieldSide.left);
		});

		test('loads saved field side on initialization', () async {
			final prefs = await SharedPreferences.getInstance();
			await prefs.setString('fieldSide', 'right');

			final notifier = FieldSideNotifier();
			// Give it time to load
			await Future.delayed(Duration(milliseconds: 100));

			expect(notifier.state, FieldSide.right);
		});

		test('toggleFieldSide multiple times alternates correctly', () async {
			final notifier = FieldSideNotifier();

			for (int i = 0; i < 4; i++) {
				await notifier.toggleFieldSide();
			}

			expect(notifier.state, FieldSide.left);
		});
	});

}
