import 'package:flutter_test/flutter_test.dart';
import 'package:viper_scout/seasons/season_registry.dart';

void main() {
	group('defaultSeason', () {
		test('returns a season key string', () {
			expect(defaultSeason, isNotNull);
			expect(defaultSeason, isA<String>());
		});

		test('returns a key for an implemented season', () {
			final module = seasonModuleFor(defaultSeason);
			expect(module, isNotNull);
		});
	});

	group('seasonModuleFor', () {
		test('returns module for 2026', () {
			final season = seasonModuleFor('2026');
			expect(season, isNotNull);
		});

		test('returns module for 2025-26', () {
			final season = seasonModuleFor('2025-26');
			expect(season, isNotNull);
		});

		test('returns null for unknown season', () {
			final season = seasonModuleFor('9999');
			expect(season, null);
		});

		test('returns null for empty string', () {
			final season = seasonModuleFor('');
			expect(season, null);
		});
	});
}
