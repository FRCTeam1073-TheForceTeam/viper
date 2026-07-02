import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auto_tab_controller.dart';

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
