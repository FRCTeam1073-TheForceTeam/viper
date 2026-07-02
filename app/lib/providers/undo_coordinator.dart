import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'timeline_provider.dart';
import 'auto_tab_controller.dart';
import 'tele_tab_controller.dart';
import 'match_timer_provider.dart';

/// Coordinates undo between auto and tele tabs based on which period the last timeline event belongs to
/// Can undo timeline events or reset the match timer when timeline is empty
void undoLastAction(WidgetRef ref) {
	final timeline = ref.read(timelineProvider);

	if (timeline.isEmpty) {
		// Timeline is empty - undo the timer start
		ref.read(matchTimerProvider.notifier).clear();
		return;
	}

	final lastEvent = timeline.last;
	final field = lastEvent.action;

	// Determine which period this event belongs to
	if (field.startsWith('auto_')) {
		ref.read(autoTabControllerProvider.notifier).undo();
	} else if (field.startsWith('tele_')) {
		ref.read(teleTabControllerProvider.notifier).undo();
	}

	// After undo, check if timeline is now empty
	// If so, also reset the match timer
	final updatedTimeline = ref.read(timelineProvider);
	if (updatedTimeline.isEmpty) {
		ref.read(matchTimerProvider.notifier).clear();
	}
}
