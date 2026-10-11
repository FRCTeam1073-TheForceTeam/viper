import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viper_scout/services/config_service.dart';

void main() {
	setUp(() {
		SharedPreferences.setMockInitialValues({});
	});

	group('ConfigService', () {
		test('getBackendUrl returns default localhost', () async {
			final prefs = await SharedPreferences.getInstance();
			final service = ConfigService(prefs);

			expect(service.getBackendUrl(), 'http://localhost');
		});

		test('setBackendUrl and retrieves it', () async {
			final prefs = await SharedPreferences.getInstance();
			final service = ConfigService(prefs);

			await service.setBackendUrl('http://192.168.1.1:3000');

			expect(service.getBackendUrl(), 'http://192.168.1.1:3000');
		});

		test('getSelectedEvent returns null when not set', () async {
			final prefs = await SharedPreferences.getInstance();
			final service = ConfigService(prefs);

			expect(service.getSelectedEvent(), null);
		});

		test('setSelectedEvent and retrieves it', () async {
			final prefs = await SharedPreferences.getInstance();
			final service = ConfigService(prefs);

			await service.setSelectedEvent('2026week2');

			expect(service.getSelectedEvent(), '2026week2');
		});

		test('setSelectedEvent updates date changed timestamp', () async {
			final prefs = await SharedPreferences.getInstance();
			final service = ConfigService(prefs);

			await service.setSelectedEvent('2026week2');

			final storedDate = prefs.getString('last_event_change_date');
			expect(storedDate, isNotNull);
		});

		test('getScouterName returns null when not set', () async {
			final prefs = await SharedPreferences.getInstance();
			final service = ConfigService(prefs);

			expect(service.getScouterName(), null);
		});

		test('setScouterName and retrieves it', () async {
			final prefs = await SharedPreferences.getInstance();
			final service = ConfigService(prefs);

			await service.setScouterName('Alice');

			expect(service.getScouterName(), 'Alice');
		});

		test('hasEventSelectionDateChanged returns true when no prior date', () async {
			final prefs = await SharedPreferences.getInstance();
			final service = ConfigService(prefs);

			expect(service.hasEventSelectionDateChanged(), true);
		});

		test('hasEventSelectionDateChanged returns false for today', () async {
			final prefs = await SharedPreferences.getInstance();
			final service = ConfigService(prefs);

			// Set to today
			await service.setSelectedEvent('event1');

			expect(service.hasEventSelectionDateChanged(), false);
		});

		test('hasEventSelectionDateChanged returns true for yesterday', () async {
			final prefs = await SharedPreferences.getInstance();
			final service = ConfigService(prefs);

			final yesterday = DateTime.now().subtract(Duration(days: 1));
			await prefs.setString('last_event_change_date', yesterday.toIso8601String());

			expect(service.hasEventSelectionDateChanged(), true);
		});

		test('hasEventSelectionDateChanged handles malformed date', () async {
			final prefs = await SharedPreferences.getInstance();
			final service = ConfigService(prefs);

			await prefs.setString('last_event_change_date', 'not-a-date');

			expect(service.hasEventSelectionDateChanged(), true);
		});

		test('clearAll removes all preferences', () async {
			final prefs = await SharedPreferences.getInstance();
			final service = ConfigService(prefs);

			await service.setBackendUrl('http://example.com');
			await service.setScouterName('Alice');

			await service.clearAll();

			expect(service.getBackendUrl(), 'http://localhost');
			expect(service.getScouterName(), null);
		});
	});
}
