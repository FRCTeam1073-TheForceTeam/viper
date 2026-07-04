import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to store GlobalKeys for any UI element by field name
/// Allows looking up positions dynamically (jQuery-like behavior)
/// Keys are created once and reused across rebuilds
class UiElementKeysNotifier extends StateNotifier<Map<String, GlobalKey>> {
	// Cache of all created keys, separate from state to allow creation during build
	final Map<String, GlobalKey> _allKeys = {};

	UiElementKeysNotifier() : super({});

	/// Register or get a UI element's GlobalKey by field name
	/// Creates the key if it doesn't exist, reuses it if it does
	GlobalKey getOrCreateKey(String fieldName) {
		// Check local cache first
		if (_allKeys.containsKey(fieldName)) {
			return _allKeys[fieldName]!;
		}

		// Create new key and cache it locally (avoid state modification during build)
		final newKey = GlobalKey();
		_allKeys[fieldName] = newKey;

		// Update state asynchronously to avoid build-phase errors
		Future(() {
			try {
				state = {...state, fieldName: newKey};
			} catch (e) {
				// Silently ignore errors
			}
		});

		return newKey;
	}

	/// Get the GlobalKey for an element by field name
	GlobalKey? getElement(String fieldName) => _allKeys[fieldName] ?? state[fieldName];

	/// Clear all registered elements
	void clear() {
		_allKeys.clear();
		state = {};
	}
}

final uiElementKeysProvider =
	StateNotifierProvider<UiElementKeysNotifier, Map<String, GlobalKey>>((ref) {
	return UiElementKeysNotifier();
});

/// Get the position of a UI element by field name
/// Returns Stack-relative offset if stackBox is provided, otherwise global offset
Offset? getElementPosition(
	String fieldName,
	UiElementKeysNotifier notifier, {
	RenderBox? stackBox,
}) {
	// Check both cache and state via notifier's getElement method
	final key = notifier.getElement(fieldName);
	if (key == null) {
		print('getElementPosition: "$fieldName" not found in notifier');
		return null;
	}

	try {
		final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
		if (renderBox == null) return null;
		final globalOffset = renderBox.localToGlobal(Offset.zero);

		// If stackBox is provided, convert to stack-relative coordinates
		if (stackBox != null) {
			final stackGlobalOffset = stackBox.localToGlobal(Offset.zero);
			return globalOffset - stackGlobalOffset;
		}

		return globalOffset;
	} catch (e) {
		print('getElementPosition ERROR for $fieldName: $e');
		return null;
	}
}
