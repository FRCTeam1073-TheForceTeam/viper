import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Scouter info data - stored in-memory via provider, exported to CSV at upload
class ScouterInfoData {
	final String? scouterName;
	final String? comments;
	final bool reviewRequest;

	const ScouterInfoData({
		this.scouterName,
		this.comments,
		this.reviewRequest = false,
	});

	ScouterInfoData copyWith({
		String? scouterName,
		String? comments,
		bool? reviewRequest,
	}) {
		return ScouterInfoData(
			scouterName: scouterName ?? this.scouterName,
			comments: comments ?? this.comments,
			reviewRequest: reviewRequest ?? this.reviewRequest,
		);
	}
}

class ScouterInfoNotifier extends StateNotifier<ScouterInfoData> {
	ScouterInfoNotifier() : super(const ScouterInfoData());

	void update(ScouterInfoData data) {
		state = data;
	}

	void reset() {
		state = const ScouterInfoData();
	}
}

final scouterInfoProvider = StateNotifierProvider<ScouterInfoNotifier, ScouterInfoData>((ref) {
	return ScouterInfoNotifier();
});
