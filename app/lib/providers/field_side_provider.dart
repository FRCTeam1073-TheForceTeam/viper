import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Field side where the scouter is positioned
/// Determines field rotation: FieldSide.left rotates the field 180°, FieldSide.right shows it normally
enum FieldSide {
	left,
	right,
}

final selectedFieldSideProvider = StateNotifierProvider<FieldSideNotifier, FieldSide>((ref) {
	return FieldSideNotifier();
});

class FieldSideNotifier extends StateNotifier<FieldSide> {
	FieldSideNotifier() : super(FieldSide.left) {
		_loadFieldSide();
	}

	Future<void> _loadFieldSide() async {
		try {
			final prefs = await SharedPreferences.getInstance();
			final saved = prefs.getString('fieldSide');
			if (saved == 'right') {
				state = FieldSide.right;
			}
		} catch (e) {
			// Use default
		}
	}

	Future<void> setFieldSide(FieldSide side) async {
		state = side;
		try {
			final prefs = await SharedPreferences.getInstance();
			await prefs.setString('fieldSide', side.name);
		} catch (e) {
		}
	}

	Future<void> toggleFieldSide() async {
		final newSide = state == FieldSide.left ? FieldSide.right : FieldSide.left;
		await setFieldSide(newSide);
	}
}
