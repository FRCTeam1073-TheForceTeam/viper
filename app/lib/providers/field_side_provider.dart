import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Field side where the scouter is positioned
/// left = default starting position for blue team (no rotation for blue team, 180° for red team)
/// right = opposite side (180° for blue team, no rotation for red team)
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
			print('📍 Field side changed to: ${side.name}');
		} catch (e) {
			print('⚠️ Failed to save field side: $e');
		}
	}

	Future<void> toggleFieldSide() async {
		final newSide = state == FieldSide.left ? FieldSide.right : FieldSide.left;
		await setFieldSide(newSide);
	}
}
