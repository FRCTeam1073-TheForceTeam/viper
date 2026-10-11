import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stores the current position of UI buttons for undo popup placement
/// Position is stack-relative (relative to the main Stack in auto/tele tabs)
class ButtonPositionNotifier extends StateNotifier<Map<String, Offset>> {
	ButtonPositionNotifier() : super({});

	/// Batch update multiple button positions at once
	void setButtonPositions(Map<String, Offset> positions) {
		// Delay state update to avoid modifying during build
		Future(() {
			state = {...state, ...positions};
		});
	}

	/// Register or update a button's position (single update)
	void setButtonPosition(String fieldName, Offset stackRelativePosition) {
		setButtonPositions({fieldName: stackRelativePosition});
	}

	/// Get a button's position
	Offset? getButtonPosition(String fieldName) => state[fieldName];

	/// Clear all positions (e.g., on tab switch or reset)
	void clear() {
		state = {};
	}
}

final buttonPositionProvider =
	StateNotifierProvider<ButtonPositionNotifier, Map<String, Offset>>((ref) {
	return ButtonPositionNotifier();
});
