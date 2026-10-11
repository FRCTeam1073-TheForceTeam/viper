import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Timeline event entry: tracks when an action happened and its value
/// Format matches web app: time:field:value
class TimelineEvent {
	final int timeSeconds;
	final String action;
	final String value;

	TimelineEvent({
		required this.timeSeconds,
		required this.action,
		required this.value,
	});

	Map<String, dynamic> toJson() => {
		'time': timeSeconds,
		'action': action,
		'value': value,
	};

	factory TimelineEvent.fromJson(Map<String, dynamic> json) => TimelineEvent(
		timeSeconds: json['time'] as int,
		action: json['action'] as String,
		value: json['value'] as String? ?? '1',
	);

	static String formatTimeline(List<TimelineEvent> events) {
		return events.map((e) => e.value == '1' ? '${e.timeSeconds}:${e.action}' : '${e.timeSeconds}:${e.action}:${e.value}').join(' ');
	}

	static List<TimelineEvent> parseTimeline(String timelineStr) {
		final events = <TimelineEvent>[];
		if (timelineStr.isEmpty) return events;

		final entries = timelineStr.split(' ');
		for (final entry in entries) {
			final parts = entry.split(':');
			if (parts.length == 2) {
				events.add(TimelineEvent(
					timeSeconds: int.parse(parts[0]),
					action: parts[1],
					value: '1',
				));
			} else if (parts.length == 3) {
				events.add(TimelineEvent(
					timeSeconds: int.parse(parts[0]),
					action: parts[1],
					value: parts[2],
				));
			}
		}
		return events;
	}

	@override
	String toString() => '[$timeSeconds] $action ($value)';
}

/// Shared timeline state notifier - manages timeline events for both auto and tele tabs
class TimelineNotifier extends StateNotifier<List<TimelineEvent>> {
	TimelineNotifier() : super([]);

	/// Add an event to the timeline
	void addEvent(TimelineEvent event) {
		state = [...state, event];
	}

	/// Remove the last event from the timeline
	void undo() {
		if (state.isNotEmpty) {
			state = state.sublist(0, state.length - 1);
		}
	}

	/// Replace entire timeline (for loading from database)
	void setTimeline(List<TimelineEvent> events) {
		state = events;
	}

	/// Clear all timeline events
	void clear() {
		state = [];
	}
}

/// Provider for shared timeline state
final timelineProvider = StateNotifierProvider<TimelineNotifier, List<TimelineEvent>>((ref) {
	return TimelineNotifier();
});
