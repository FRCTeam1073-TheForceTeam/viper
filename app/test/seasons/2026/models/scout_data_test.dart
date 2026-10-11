import 'package:flutter_test/flutter_test.dart';
import 'package:viper_scout/seasons/2026/models/scout_data.dart';

void main() {
	group('ScoutData construction', () {
		test('creates with minimal arguments', () {
			final data = ScoutData();

			expect(data.event, isNull);
			expect(data.match, isNull);
			expect(data.team, isNull);
			expect(data.noShow, false);
			expect(data.autoCounts, {});
			expect(data.teleCounts, {});
			expect(data.timeline, []);
		});

		test('creates with specified values', () {
			final data = ScoutData(
				event: '2026casf',
				match: 'qm5',
				team: '3476',
				noShow: true,
				climbing: true,
			);

			expect(data.event, '2026casf');
			expect(data.match, 'qm5');
			expect(data.team, '3476');
			expect(data.noShow, true);
			expect(data.climbing, true);
		});

		test('initializes createdAt and updatedAt with current time', () {
			final before = DateTime.now();
			final data = ScoutData();
			final after = DateTime.now();

			expect(data.createdAt.isAfter(before.subtract(Duration(seconds: 1))), true);
			expect(data.createdAt.isBefore(after.add(Duration(seconds: 1))), true);
			expect(data.updatedAt.isAfter(before.subtract(Duration(seconds: 1))), true);
			expect(data.updatedAt.isBefore(after.add(Duration(seconds: 1))), true);
		});

		test('accepts explicit createdAt and updatedAt', () {
			final created = DateTime(2026, 3, 15, 10, 30);
			final updated = DateTime(2026, 3, 15, 11, 45);
			final data = ScoutData(
				createdAt: created,
				updatedAt: updated,
			);

			expect(data.createdAt, created);
			expect(data.updatedAt, updated);
		});

		test('uses default values for boolean fields', () {
			final data = ScoutData();

			expect(data.noShow, false);
			expect(data.shootOnMove, false);
			expect(data.shootWhileCollecting, false);
			expect(data.climbing, false);
			expect(data.reviewRequest, false);
		});

		test('uses default value 0 for damageState', () {
			final data = ScoutData();

			expect(data.damageState, 0);
		});
	});

	group('ScoutData.copyWith', () {
		test('creates copy with single field changed', () {
			final original = ScoutData(
				event: '2026casf',
				match: 'qm5',
				team: '3476',
			);

			final copy = original.copyWith(match: 'qm6');

			expect(copy.event, '2026casf');
			expect(copy.match, 'qm6');
			expect(copy.team, '3476');
		});

		test('preserves unchanged fields', () {
			final created = DateTime(2026, 3, 15, 10, 30);
			final original = ScoutData(
				event: '2026casf',
				createdAt: created,
				comments: 'original comments',
			);

			final copy = original.copyWith(match: 'qm5');

			expect(copy.event, '2026casf');
			expect(copy.createdAt, created);
			expect(copy.comments, 'original comments');
		});

		test('updates multiple fields at once', () {
			final original = ScoutData(
				event: '2026casf',
				match: 'qm5',
				team: '3476',
			);

			final copy = original.copyWith(
				match: 'qm6',
				team: '2064',
				noShow: true,
			);

			expect(copy.event, '2026casf');
			expect(copy.match, 'qm6');
			expect(copy.team, '2064');
			expect(copy.noShow, true);
		});

		test('copies nested collections correctly', () {
			final original = ScoutData(
				autoCounts: {'score': 5, 'intake': 3},
				teleCounts: {'shoot': 10},
			);

			final copy = original.copyWith(
				autoCounts: {'score': 7},
			);

			expect(copy.autoCounts, {'score': 7});
			expect(copy.teleCounts, {'shoot': 10});
		});

		test('preserves fields when null is passed due to ?? operator', () {
			// copyWith uses field ?? this.field, so passing null preserves original
			final original = ScoutData(
				event: '2026casf',
				comments: 'test comments',
			);

			final copy = original.copyWith(
				event: null,
				comments: null,
			);

			expect(copy.event, '2026casf'); // null preserves original
			expect(copy.comments, 'test comments'); // null preserves original
		});

		test('preserves timestamps by default', () {
			final created = DateTime(2026, 3, 15, 10, 30);
			final updated = DateTime(2026, 3, 15, 11, 45);
			final original = ScoutData(
				createdAt: created,
				updatedAt: updated,
			);

			final copy = original.copyWith(team: '3476');

			expect(copy.createdAt, created);
			expect(copy.updatedAt, updated);
		});

		test('can update timestamps', () {
			final newUpdated = DateTime(2026, 3, 15, 12, 00);
			final original = ScoutData();

			final copy = original.copyWith(updatedAt: newUpdated);

			expect(copy.updatedAt, newUpdated);
		});
	});

	group('TimelineEvent construction', () {
		test('creates timeline event with all fields', () {
			final timestamp = DateTime(2026, 3, 15, 10, 30);
			final event = TimelineEvent(
				fieldName: 'auto_speaker_score',
				action: 'increment',
				timestamp: timestamp,
			);

			expect(event.fieldName, 'auto_speaker_score');
			expect(event.action, 'increment');
			expect(event.timestamp, timestamp);
		});

		test('stores various action types', () {
			final timestamp = DateTime.now();

			final increment = TimelineEvent(
				fieldName: 'score',
				action: 'increment',
				timestamp: timestamp,
			);
			final decrement = TimelineEvent(
				fieldName: 'score',
				action: 'decrement',
				timestamp: timestamp,
			);
			final toggle = TimelineEvent(
				fieldName: 'climbing',
				action: 'toggle',
				timestamp: timestamp,
			);

			expect(increment.action, 'increment');
			expect(decrement.action, 'decrement');
			expect(toggle.action, 'toggle');
		});
	});

	group('ScoutData with timeline', () {
		test('can store timeline events', () {
			final timestamp = DateTime(2026, 3, 15, 10, 30);
			final events = [
				TimelineEvent(
					fieldName: 'auto_speaker_score',
					action: 'increment',
					timestamp: timestamp,
				),
				TimelineEvent(
					fieldName: 'auto_intake',
					action: 'increment',
					timestamp: timestamp.add(Duration(seconds: 1)),
				),
			];

			final data = ScoutData(timeline: events);

			expect(data.timeline.length, 2);
			expect(data.timeline[0].fieldName, 'auto_speaker_score');
			expect(data.timeline[1].fieldName, 'auto_intake');
		});

		test('copyWith can update timeline', () {
			final timestamp = DateTime(2026, 3, 15, 10, 30);
			final original = ScoutData(
				timeline: [
					TimelineEvent(
						fieldName: 'auto_speaker_score',
						action: 'increment',
						timestamp: timestamp,
					),
				],
			);

			final newEvent = TimelineEvent(
				fieldName: 'tele_amp_score',
				action: 'increment',
				timestamp: timestamp.add(Duration(seconds: 10)),
			);

			final copy = original.copyWith(
				timeline: [...original.timeline, newEvent],
			);

			expect(copy.timeline.length, 2);
			expect(copy.timeline[1].fieldName, 'tele_amp_score');
		});
	});

	group('ScoutData field defaults', () {
		test('all string fields are null by default', () {
			final data = ScoutData();

			expect(data.event, isNull);
			expect(data.match, isNull);
			expect(data.team, isNull);
			expect(data.startingPosition, isNull);
			expect(data.climbMethod, isNull);
			expect(data.climbPosition, isNull);
			expect(data.fuelStrategy, isNull);
			expect(data.shootingLocations, isNull);
			expect(data.defenseRating, isNull);
			expect(data.defenseMethods, isNull);
			expect(data.defenseImpact, isNull);
			expect(data.scouterName, isNull);
			expect(data.comments, isNull);
		});

		test('all nullable int fields are null by default', () {
			final data = ScoutData();

			expect(data.shootingMissesRange, isNull);
		});

		test('all collection fields are empty by default', () {
			final data = ScoutData();

			expect(data.autoCounts, isEmpty);
			expect(data.teleCounts, isEmpty);
			expect(data.timeline, isEmpty);
		});
	});
}
