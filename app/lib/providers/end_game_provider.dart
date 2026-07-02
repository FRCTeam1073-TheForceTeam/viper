import 'package:flutter_riverpod/flutter_riverpod.dart';

/// End game match data - stored in-memory via provider, exported to CSV at upload
class EndGameData {
	final String? climbMethod; // Rungs, Uprights, Flip, No Climb
	final String? climbPosition;
	final bool shootOnMove;
	final bool shootWhileCollecting;
	final bool climbing;
	final String? fuelStrategy; // Carried, Pushed, Passed, Received
	final String? shootingLocations;
	final int damageState; // 0-100%
	final String? defenseRating; // Good, Bad, Great
	final String? defenseMethods;
	final String? defenseImpact; // Slowed, Unaffected, Turned tables
	final int? shootingMissesRange;

	const EndGameData({
		this.climbMethod,
		this.climbPosition,
		this.shootOnMove = false,
		this.shootWhileCollecting = false,
		this.climbing = false,
		this.fuelStrategy,
		this.shootingLocations,
		this.damageState = 0,
		this.defenseRating,
		this.defenseMethods,
		this.defenseImpact,
		this.shootingMissesRange,
	});

	EndGameData copyWith({
		String? climbMethod,
		String? climbPosition,
		bool? shootOnMove,
		bool? shootWhileCollecting,
		bool? climbing,
		String? fuelStrategy,
		String? shootingLocations,
		int? damageState,
		String? defenseRating,
		String? defenseMethods,
		String? defenseImpact,
		int? shootingMissesRange,
	}) {
		return EndGameData(
			climbMethod: climbMethod ?? this.climbMethod,
			climbPosition: climbPosition ?? this.climbPosition,
			shootOnMove: shootOnMove ?? this.shootOnMove,
			shootWhileCollecting: shootWhileCollecting ?? this.shootWhileCollecting,
			climbing: climbing ?? this.climbing,
			fuelStrategy: fuelStrategy ?? this.fuelStrategy,
			shootingLocations: shootingLocations ?? this.shootingLocations,
			damageState: damageState ?? this.damageState,
			defenseRating: defenseRating ?? this.defenseRating,
			defenseMethods: defenseMethods ?? this.defenseMethods,
			defenseImpact: defenseImpact ?? this.defenseImpact,
			shootingMissesRange: shootingMissesRange ?? this.shootingMissesRange,
		);
	}
}

class EndGameNotifier extends StateNotifier<EndGameData> {
	EndGameNotifier() : super(const EndGameData());

	void update(EndGameData data) {
		state = data;
	}

	void reset() {
		state = const EndGameData();
	}
}

final endGameProvider = StateNotifierProvider<EndGameNotifier, EndGameData>((ref) {
	return EndGameNotifier();
});
