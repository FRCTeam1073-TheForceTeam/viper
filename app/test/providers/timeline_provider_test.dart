import 'package:flutter_test/flutter_test.dart';
import 'package:viper_scout/providers/timeline_provider.dart';

void main() {
	group('TimelineEvent.toJson', () {
		test('serializes to map', () {
			final event = TimelineEvent(
				timeSeconds: 30,
				action: 'autoShoot',
				value: '5',
			);
			final json = event.toJson();

			expect(json['time'], 30);
			expect(json['action'], 'autoShoot');
			expect(json['value'], '5');
		});
	});

	group('TimelineEvent.fromJson', () {
		test('deserializes from map', () {
			final json = {
				'time': 30,
				'action': 'autoShoot',
				'value': '5',
			};
			final event = TimelineEvent.fromJson(json);

			expect(event.timeSeconds, 30);
			expect(event.action, 'autoShoot');
			expect(event.value, '5');
		});

		test('defaults value to "1" when missing', () {
			final json = {
				'time': 30,
				'action': 'autoShoot',
			};
			final event = TimelineEvent.fromJson(json);

			expect(event.value, '1');
		});

		test('defaults value to "1" when null', () {
			final json = {
				'time': 30,
				'action': 'autoShoot',
				'value': null,
			};
			final event = TimelineEvent.fromJson(json);

			expect(event.value, '1');
		});
	});

	group('TimelineEvent.formatTimeline', () {
		test('formats single event with default value', () {
			final events = [
				TimelineEvent(timeSeconds: 30, action: 'autoShoot', value: '1'),
			];
			final formatted = TimelineEvent.formatTimeline(events);

			expect(formatted, '30:autoShoot');
		});

		test('formats single event with non-default value', () {
			final events = [
				TimelineEvent(timeSeconds: 30, action: 'autoShoot', value: '5'),
			];
			final formatted = TimelineEvent.formatTimeline(events);

			expect(formatted, '30:autoShoot:5');
		});

		test('formats multiple events with spaces', () {
			final events = [
				TimelineEvent(timeSeconds: 10, action: 'autoMove', value: '1'),
				TimelineEvent(timeSeconds: 30, action: 'autoShoot', value: '5'),
				TimelineEvent(timeSeconds: 45, action: 'autoLeave', value: '1'),
			];
			final formatted = TimelineEvent.formatTimeline(events);

			expect(formatted, '10:autoMove 30:autoShoot:5 45:autoLeave');
		});

		test('handles empty list', () {
			final formatted = TimelineEvent.formatTimeline([]);

			expect(formatted, '');
		});

		test('omits value when it is "1"', () {
			final events = [
				TimelineEvent(timeSeconds: 30, action: 'autoShoot', value: '1'),
				TimelineEvent(timeSeconds: 31, action: 'teleShoot', value: '1'),
			];
			final formatted = TimelineEvent.formatTimeline(events);

			expect(formatted, contains('30:autoShoot '));
			expect(formatted, contains('31:teleShoot'));
			expect(formatted, isNot(contains('30:autoShoot:1')));
		});
	});

	group('TimelineEvent.parseTimeline', () {
		test('parses single event with default value', () {
			final parsed = TimelineEvent.parseTimeline('30:autoShoot');

			expect(parsed.length, 1);
			expect(parsed[0].timeSeconds, 30);
			expect(parsed[0].action, 'autoShoot');
			expect(parsed[0].value, '1');
		});

		test('parses single event with explicit value', () {
			final parsed = TimelineEvent.parseTimeline('30:autoShoot:5');

			expect(parsed.length, 1);
			expect(parsed[0].timeSeconds, 30);
			expect(parsed[0].action, 'autoShoot');
			expect(parsed[0].value, '5');
		});

		test('parses multiple events', () {
			final parsed = TimelineEvent.parseTimeline('10:autoMove 30:autoShoot:5 45:autoLeave');

			expect(parsed.length, 3);
			expect(parsed[0].timeSeconds, 10);
			expect(parsed[0].action, 'autoMove');
			expect(parsed[0].value, '1');
			expect(parsed[1].timeSeconds, 30);
			expect(parsed[1].action, 'autoShoot');
			expect(parsed[1].value, '5');
			expect(parsed[2].timeSeconds, 45);
			expect(parsed[2].action, 'autoLeave');
			expect(parsed[2].value, '1');
		});

		test('returns empty list for empty string', () {
			final parsed = TimelineEvent.parseTimeline('');

			expect(parsed.isEmpty, true);
		});

		test('ignores malformed entries', () {
			final parsed = TimelineEvent.parseTimeline('10:autoMove invalid 30:autoShoot:5');

			expect(parsed.length, 2);
			expect(parsed[0].action, 'autoMove');
			expect(parsed[1].action, 'autoShoot');
		});
	});

	group('TimelineEvent round-trip', () {
		test('format then parse recovers original events', () {
			final original = [
				TimelineEvent(timeSeconds: 10, action: 'autoMove', value: '1'),
				TimelineEvent(timeSeconds: 30, action: 'autoShoot', value: '5'),
				TimelineEvent(timeSeconds: 45, action: 'autoLeave', value: '1'),
			];

			final formatted = TimelineEvent.formatTimeline(original);
			final parsed = TimelineEvent.parseTimeline(formatted);

			expect(parsed.length, 3);
			for (int i = 0; i < original.length; i++) {
				expect(parsed[i].timeSeconds, original[i].timeSeconds);
				expect(parsed[i].action, original[i].action);
				expect(parsed[i].value, original[i].value);
			}
		});

		test('JSON round-trip preserves data', () {
			final original = TimelineEvent(
				timeSeconds: 30,
				action: 'autoShoot',
				value: '5',
			);

			final json = original.toJson();
			final parsed = TimelineEvent.fromJson(json);

			expect(parsed.timeSeconds, original.timeSeconds);
			expect(parsed.action, original.action);
			expect(parsed.value, original.value);
		});
	});

	group('TimelineNotifier', () {
		test('starts with empty timeline', () {
			final notifier = TimelineNotifier();
			expect(notifier.state.isEmpty, true);
		});

		test('addEvent appends event', () {
			final notifier = TimelineNotifier();
			final event = TimelineEvent(timeSeconds: 10, action: 'autoShoot', value: '1');

			notifier.addEvent(event);

			expect(notifier.state.length, 1);
			expect(notifier.state[0].action, 'autoShoot');
		});

		test('undo removes last event', () {
			final notifier = TimelineNotifier();
			notifier.addEvent(TimelineEvent(timeSeconds: 10, action: 'autoShoot', value: '1'));
			notifier.addEvent(TimelineEvent(timeSeconds: 20, action: 'autoMove', value: '1'));

			notifier.undo();

			expect(notifier.state.length, 1);
			expect(notifier.state[0].action, 'autoShoot');
		});

		test('undo on empty timeline does nothing', () {
			final notifier = TimelineNotifier();
			notifier.undo();

			expect(notifier.state.isEmpty, true);
		});

		test('setTimeline replaces entire timeline', () {
			final notifier = TimelineNotifier();
			notifier.addEvent(TimelineEvent(timeSeconds: 10, action: 'old', value: '1'));

			final newEvents = [
				TimelineEvent(timeSeconds: 20, action: 'new', value: '1'),
				TimelineEvent(timeSeconds: 30, action: 'newer', value: '2'),
			];
			notifier.setTimeline(newEvents);

			expect(notifier.state.length, 2);
			expect(notifier.state[0].action, 'new');
			expect(notifier.state[1].action, 'newer');
		});

		test('clear removes all events', () {
			final notifier = TimelineNotifier();
			notifier.addEvent(TimelineEvent(timeSeconds: 10, action: 'autoShoot', value: '1'));
			notifier.addEvent(TimelineEvent(timeSeconds: 20, action: 'autoMove', value: '1'));

			notifier.clear();

			expect(notifier.state.isEmpty, true);
		});
	});
}
