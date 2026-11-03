import 'package:flutter_test/flutter_test.dart';
import 'package:viper_scout/providers/timeline_provider.dart';
import 'package:viper_scout/seasons/2026-27/providers/scouting_data_provider.dart';
import 'package:viper_scout/seasons/season_registry.dart';

void main() {
	group('2026-27 timeline', () {
		test('round-trips a web timeline string unchanged', () {
			const web = '3:auto_leave 5:auto_collect_pollen 6:auto_cell_pollen:2 9:tele_hive_tip';
			final events = TimelineEvent.parseTimeline(web);
			expect(TimelineEvent.formatTimeline(events), web);
		});

		test('hive tip is enabled only right after a cell placement', () {
			expect(hiveTipEnabled([]), isFalse);
			expect(hiveTipEnabled(TimelineEvent.parseTimeline('4:auto_cell_nectar')), isTrue);
			expect(hiveTipEnabled(TimelineEvent.parseTimeline('4:tele_cell_pollen')), isTrue);
			expect(hiveTipEnabled(TimelineEvent.parseTimeline('4:tele_flower1_pollen')), isFalse);
			expect(hiveTipEnabled(TimelineEvent.parseTimeline('4:auto_cell_pollen 6:auto_hive_tip')), isFalse);
		});
	});

	group('2026-27 held counts', () {
		test('robot starts with 4 pollen, so collection is blocked and nectar placement is too', () {
			final held = computeHeld(ScoutingData.empty());
			expect(held.pollen, preloadPollen);
			expect(held.nectar, 0);
			expect(held.collectBlocked, isTrue);
			expect(held.nectarPlaceBlocked, isTrue);
			expect(held.pollenPlaceBlocked, isFalse);
		});

		test('placing pollen frees collection and counts across auto and teleop', () {
			final data = ScoutingData({
				'auto_cell_pollen': '2',
				'tele_flower1_pollen': '1',
			});
			final held = computeHeld(data);
			expect(held.pollen, 1);
			expect(held.collectBlocked, isFalse);
			expect(held.pollenPlaceBlocked, isFalse);
		});

		test('collecting nectar moves toward the cap of 4', () {
			final data = ScoutingData({
				'tele_collect_nectar': '2',
			});
			final held = computeHeld(data);
			expect(held.nectar, 2);
			expect(held.total, 6);
			expect(held.collectBlocked, isTrue);
		});
	});

	test('season registry includes 2026-27', () {
		expect(seasonModuleFor('2026-27'), isNotNull);
		expect(seasonModuleFor('2026-27')!.season, '2026-27');
	});
}
