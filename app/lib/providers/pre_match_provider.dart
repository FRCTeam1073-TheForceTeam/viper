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

	Map<String, dynamic> toMap() {
		return {
			'starting_position': startingPosition,
			'no_show': noShow ? 1 : 0,
		};
	}

	static PreMatchData fromMap(Map<String, dynamic> map) {
		return PreMatchData(
			startingPosition: map['starting_position'] as String?,
			noShow: (map['no_show'] as int?) == 1,
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

	void loadFromData(Map<String, dynamic> data) {
		try {
			if (data.containsKey('starting_position') || data.containsKey('no_show')) {
				state = PreMatchData.fromMap(data);
			}
		} catch (e) {
			print('Error loading pre-match data: $e');
		}
	}
}

final preMatchProvider = StateNotifierProvider<PreMatchNotifier, PreMatchData>((ref) {
	return PreMatchNotifier();
});
