import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/timeline_provider.dart';
import 'scouting_data_provider.dart';
import '../../../providers/match_timer_provider.dart';
import '../../../providers/floating_popup_provider.dart';

/// Callback to get the position for the undo floater based on the field being undone
typedef UndoPositionCallback = Offset? Function(String field);

/// Undoes the last timeline entry, whichever tab it came from.
/// Shows a "-X" floater over the field being undone when [getUndoPosition] provides a position.
/// Otherwise the floater appears above the undo button.
/// When the timeline is empty, the match timer is reset.
void undoLastAction(
	WidgetRef ref,
	BuildContext context,
	GlobalKey undoButtonKey, {
	UndoPositionCallback? getUndoPosition,
}) {
	final timeline = ref.read(timelineProvider);

	if (timeline.isEmpty) {
		// Timeline is empty - undo the timer start
		ref.read(matchTimerProvider.notifier).clear();
		return;
	}

	final lastEvent = timeline.last;
	final field = lastEvent.action;

	// Checkboxes reverse without a count, so they get no floater (web: only .num inputs do)
	if (!checkboxFields.contains(field)) {
		try {
			final value = int.tryParse(lastEvent.value) ?? 1;

			Offset? popupPosition = getUndoPosition?.call(field);

			if (popupPosition == null) {
				final undoButtonBox = undoButtonKey.currentContext?.findRenderObject() as RenderBox?;
				if (undoButtonBox != null) {
					final offset = undoButtonBox.localToGlobal(Offset.zero);
					final centerX = offset.dx + undoButtonBox.size.width / 2;
					final centerY = offset.dy - 30; // Show above the button
					popupPosition = Offset(centerX, centerY);
				}
			}

			if (popupPosition != null) {
				ref.read(floatingPopupProvider.notifier).addPopup(
					'-$value',
					popupPosition.dx,
					popupPosition.dy,
				);
			}
		} catch (e) {
			// Silently fail if we can't create popup
		}
	}

	ref.read(scoutingDataProvider.notifier).undoLast();

	// After undo, check if timeline is now empty
	// If so, also reset the match timer
	final updatedTimeline = ref.read(timelineProvider);
	if (updatedTimeline.isEmpty) {
		ref.read(matchTimerProvider.notifier).clear();
	}
}
