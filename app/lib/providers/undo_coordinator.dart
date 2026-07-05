import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'timeline_provider.dart';
import 'scouting_data_provider.dart';
import 'match_timer_provider.dart';
import 'floating_popup_provider.dart';

/// Callback to get the position for the undo floater based on the field being undone
typedef UndoPositionCallback = Offset? Function(String field);

/// Coordinates undo between auto and tele tabs based on which period the last timeline event belongs to
/// Can undo timeline events or reset the match timer when timeline is empty
///
/// [getUndoPosition] is an optional callback that calculates where the floater should appear
/// based on the field being undone. If not provided, floater appears above the undo button.
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

	// Show floating popup with the negative value being undone
	try {
		final value = int.tryParse(lastEvent.value) ?? 1;

		// Try to get position from callback first
		Offset? popupPosition = getUndoPosition?.call(field);

		// Fall back to position above undo button if callback didn't provide position
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

	// Determine which period this event belongs to
	if (field.startsWith('auto_')) {
		ref.read(scoutingDataProvider.notifier).undoAuto();
	} else if (field.startsWith('tele_')) {
		ref.read(scoutingDataProvider.notifier).undoTele();
	}

	// After undo, check if timeline is now empty
	// If so, also reset the match timer
	final updatedTimeline = ref.read(timelineProvider);
	if (updatedTimeline.isEmpty) {
		ref.read(matchTimerProvider.notifier).clear();
	}
}
