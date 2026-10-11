import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viper_scout/providers/match_timer_provider.dart';

void main() {
	group('MatchTimerNotifier', () {
		test('initializes with null start time', () {
			final notifier = MatchTimerNotifier();

			expect(notifier.state, isNull);
		});

		test('setStartTime stores the start time', () {
			final notifier = MatchTimerNotifier();
			final startTime = DateTime(2026, 3, 15, 10, 30);

			notifier.setStartTime(startTime);

			expect(notifier.state, startTime);
		});

		test('clear resets state to null', () {
			final notifier = MatchTimerNotifier();
			notifier.setStartTime(DateTime.now());

			notifier.clear();

			expect(notifier.state, isNull);
		});

		test('getElapsedSeconds returns 0 when timer is null', () {
			final notifier = MatchTimerNotifier();

			expect(notifier.getElapsedSeconds(), 0);
		});

		test('getElapsedSeconds calculates seconds since start time', () {
			final notifier = MatchTimerNotifier();
			final startTime = DateTime.now().subtract(Duration(seconds: 5));

			notifier.setStartTime(startTime);
			final elapsed = notifier.getElapsedSeconds();

			// Allow 1 second tolerance for test execution time
			expect(elapsed, greaterThanOrEqualTo(4));
			expect(elapsed, lessThanOrEqualTo(6));
		});
	});

	group('matchTimerProvider', () {
		test('provides MatchTimerNotifier with null initial state', () {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			final startTime = container.read(matchTimerProvider);

			expect(startTime, isNull);
		});

		test('allows setting start time via notifier', () {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			final testTime = DateTime(2026, 3, 15, 10, 30);
			container.read(matchTimerProvider.notifier).setStartTime(testTime);

			final startTime = container.read(matchTimerProvider);

			expect(startTime, testTime);
		});

		test('allows clearing timer via notifier', () {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			container.read(matchTimerProvider.notifier).setStartTime(DateTime.now());
			container.read(matchTimerProvider.notifier).clear();

			final startTime = container.read(matchTimerProvider);

			expect(startTime, isNull);
		});

		test('getElapsedSeconds works through provider', () {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			final startTime = DateTime.now().subtract(Duration(seconds: 3));
			container.read(matchTimerProvider.notifier).setStartTime(startTime);

			final elapsed = container.read(matchTimerProvider.notifier).getElapsedSeconds();

			expect(elapsed, greaterThanOrEqualTo(2));
			expect(elapsed, lessThanOrEqualTo(4));
		});
	});
}
