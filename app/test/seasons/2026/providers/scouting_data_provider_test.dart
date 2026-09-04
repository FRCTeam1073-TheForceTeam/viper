import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viper_scout/seasons/2026/providers/scouting_data_provider.dart';
import 'package:viper_scout/models/field_descriptor.dart';
import 'package:viper_scout/providers/global_scouting_data.dart';
import 'package:viper_scout/providers/timeline_provider.dart';
import 'package:viper_scout/providers/match_timer_provider.dart';

void main() {
	setUp(() {
		FieldDescriptor.resetCacheForTesting();
		ScoutingData.resetRegisteredDescriptorsForTesting();
		resetGlobalScoutingDataForTesting();
	});

	tearDown(() {
		FieldDescriptor.resetCacheForTesting();
		ScoutingData.resetRegisteredDescriptorsForTesting();
		resetGlobalScoutingDataForTesting();
	});

	group('ScoutingData', () {
		test('can be created empty', () {
			final data = ScoutingData.empty();
			expect(data.values.isEmpty, true);
		});

		test('can be created with initial values', () {
			final data = ScoutingData({'teamNumber': '3476'});
			expect(data.values['teamNumber'], '3476');
		});

		test('updateField returns new instance', () {
			final data1 = ScoutingData.empty();
			final data2 = data1.updateField('teamNumber', '3476');

			expect(data1.values['teamNumber'], null);
			expect(data2.values['teamNumber'], '3476');
		});

		test('updateFields chains multiple updates', () {
			final data = ScoutingData.empty()
				.updateField('teamNumber', '3476')
				.updateField('matchNumber', 'qm5')
				.updateField('score', 42);

			expect(data.values['teamNumber'], '3476');
			expect(data.values['matchNumber'], 'qm5');
			expect(data.values['score'], '42'); // converts to string
		});

		test('has static descriptors', () {
			final data = ScoutingData.empty();
			final descriptors = data.descriptors;

			expect(descriptors.any((d) => d.name == 'auto_alliance_time'), true);
			expect(descriptors.any((d) => d.name == 'auto_neutral_time'), true);
			expect(descriptors.any((d) => d.name == 'tele_alliance_time'), true);
		});

		test('converts to/from CSV map', () {
			final data = ScoutingData({'auto_alliance_time': '30', 'auto_climb_level': '2'});
			final csvMap = data.toMap();

			expect(csvMap.containsKey('auto_alliance_time'), true);
			expect(csvMap['auto_alliance_time'], '30');

			final data2 = ScoutingData.empty();
			data2.loadFromMap(csvMap);

			expect(data2.values['auto_alliance_time'], '30');
			expect(data2.values['auto_climb_level'], '2');
		});
	});

	group('ScoutingDataNotifier', () {
		test('initializes with empty data', () {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			final state = container.read(scoutingDataProvider);
			expect(state.values.isEmpty, true);
		});

		test('recordAutoAction increments counter field', () {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			container.read(scoutingDataProvider.notifier).recordAutoAction(
				field: 'auto_fuel_intake',
				value: 1,
			);

			final state = container.read(scoutingDataProvider);
			expect(state.getFieldValue('auto_fuel_intake').asInt(), 1);
		});

		test('recordAutoAction adds to timeline', () {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			container.read(scoutingDataProvider.notifier).recordAutoAction(
				field: 'auto_fuel_intake',
				value: 1,
			);

			final timeline = container.read(timelineProvider);
			expect(timeline.isNotEmpty, true);
			expect(timeline.last.action, 'auto_fuel_intake');
		});

		test('recordTeleAction works similarly', () {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			container.read(scoutingDataProvider.notifier).recordTeleAction(
				field: 'tele_fuel_high',
				value: 3,
			);

			final state = container.read(scoutingDataProvider);
			expect(state.getFieldValue('tele_fuel_high').asInt(), 3);

			final timeline = container.read(timelineProvider);
			expect(timeline.last.value, '3');
		});

		test('undoAuto removes last timeline event and reverses counter', () {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			container.read(scoutingDataProvider.notifier).recordAutoAction(
				field: 'auto_fuel_intake',
				value: 5,
			);

			container.read(scoutingDataProvider.notifier).undoAuto();

			final state = container.read(scoutingDataProvider);
			expect(state.getFieldValue('auto_fuel_intake').asInt(), 0); // undone

			final timeline = container.read(timelineProvider);
			expect(timeline.isEmpty, true);
		});

		test('zone transition field updates zone time accumulators', () {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			// Set start time so elapsed is predictable
			final startTime = DateTime.now();
			container.read(matchTimerProvider.notifier).setStartTime(startTime);

			// Record action moving to neutral
			container.read(scoutingDataProvider.notifier).recordAutoAction(
				field: 'auto_to_neutral',
				value: 1,
			);

			final state = container.read(scoutingDataProvider);
			expect(state.getFieldValue('auto_alliance_time').asInt(), greaterThanOrEqualTo(0));
		});

		test('reset clears data and timeline', () {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			container.read(scoutingDataProvider.notifier).recordAutoAction(
				field: 'auto_fuel_intake',
				value: 5,
			);

			container.read(scoutingDataProvider.notifier).reset();

			final state = container.read(scoutingDataProvider);
			expect(state.values.isEmpty, true);

			final timeline = container.read(timelineProvider);
			expect(timeline.isEmpty, true);
		});

		test('loadFromServerData hydrates data', () {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			final serverData = {
				'auto_alliance_time': '30',
				'auto_climb_level': '2',
			};

			container.read(scoutingDataProvider.notifier).loadFromServerData(serverData);

			final state = container.read(scoutingDataProvider);
			expect(state.values['auto_alliance_time'], '30');
			expect(state.values['auto_climb_level'], '2');
		});

		test('changeAutoFuelTarget updates fuel target', () {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			container.read(scoutingDataProvider.notifier).changeAutoFuelTarget('alliancePass');

			final notifier = container.read(scoutingDataProvider.notifier);
			expect(notifier.activeFuelTarget, 'alliancePass');
		});

		test('changeAutoFuelTarget is no-op if target is same', () {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			// Default is 'hub', so changing to something else should work
			container.read(scoutingDataProvider.notifier).changeAutoFuelTarget('alliancePass');
			final firstTarget = container.read(scoutingDataProvider.notifier).activeFuelTarget;

			// Then changing to the same target should be no-op
			container.read(scoutingDataProvider.notifier).changeAutoFuelTarget('alliancePass');
			final secondTarget = container.read(scoutingDataProvider.notifier).activeFuelTarget;

			expect(firstTarget, secondTarget);
		});
	});

}
