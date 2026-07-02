import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pre-match data - stored in-memory via provider, exported to CSV at upload
class PreMatchData {
	final String? startingPosition;
	final bool noShow;

	const PreMatchData({
		this.startingPosition,
		this.noShow = false,
	});

	PreMatchData copyWith({
		String? startingPosition,
		bool? noShow,
	}) {
		return PreMatchData(
			startingPosition: startingPosition ?? this.startingPosition,
			noShow: noShow ?? this.noShow,
		);
	}
}

class PreMatchNotifier extends StateNotifier<PreMatchData> {
	PreMatchNotifier() : super(const PreMatchData());

	void update(PreMatchData data) {
		state = data;
	}

	void reset() {
		state = const PreMatchData();
	}
}

final preMatchProvider = StateNotifierProvider<PreMatchNotifier, PreMatchData>((ref) {
	return PreMatchNotifier();
});
