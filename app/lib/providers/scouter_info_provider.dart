import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Scouter info data - stored in-memory via provider, exported to CSV at upload
class ScoterInfoData {
	final String? scouterName;
	final String? comments;
	final bool reviewRequest;

	const ScoterInfoData({
		this.scouterName,
		this.comments,
		this.reviewRequest = false,
	});

	ScoterInfoData copyWith({
		String? scouterName,
		String? comments,
		bool? reviewRequest,
	}) {
		return ScoterInfoData(
			scouterName: scouterName ?? this.scouterName,
			comments: comments ?? this.comments,
			reviewRequest: reviewRequest ?? this.reviewRequest,
		);
	}
}

class ScoterInfoNotifier extends StateNotifier<ScoterInfoData> {
	ScoterInfoNotifier() : super(const ScoterInfoData());

	void update(ScoterInfoData data) {
		state = data;
	}

	void reset() {
		state = const ScoterInfoData();
	}
}

final scoterInfoProvider = StateNotifierProvider<ScoterInfoNotifier, ScoterInfoData>((ref) {
	return ScoterInfoNotifier();
});
