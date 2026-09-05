import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A floating popup that appears temporarily to show value changes (+1, +5, etc)
class FloatingPopup {
	final String id; // Unique ID for tracking
	final String text; // Text to display (+1, +5, +10, -1, etc)
	final double initialX; // X position
	final double initialY; // Y position

	FloatingPopup({
		required this.id,
		required this.text,
		required this.initialX,
		required this.initialY,
	});
}

/// Manages floating popups that appear when values change
class FloatingPopupNotifier extends StateNotifier<List<FloatingPopup>> {
	FloatingPopupNotifier() : super([]);

	/// Add a floating popup
	void addPopup(String text, double x, double y) {
		final id = '${DateTime.now().millisecondsSinceEpoch}_${state.length}';
		state = [...state, FloatingPopup(id: id, text: text, initialX: x, initialY: y)];
	}

	/// Remove a floating popup by ID
	void removePopup(String id) {
		state = state.where((p) => p.id != id).toList();
	}

	/// Clear all popups
	void clear() {
		state = [];
	}
}

final floatingPopupProvider =
	StateNotifierProvider<FloatingPopupNotifier, List<FloatingPopup>>((ref) {
	return FloatingPopupNotifier();
});
