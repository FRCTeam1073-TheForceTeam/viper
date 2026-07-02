import 'package:flutter_riverpod/flutter_riverpod.dart';

/// End game match data - stored in-memory via provider, exported to CSV at upload
class EndGameData {
	final String? autoClimbPosition; // "Xx Yy" percent coordinates
	final String? teleClimbPosition; // "Xx Yy" percent coordinates
	final String? climbMethod; // Rungs, Uprights, Flip
	final bool shootOnMove;
	final bool shootWhileCollecting;
	final bool shootTurret;
	final bool shootClimbing;
	final String? fuelStrategy; // Carried, Pushed, Passed, Received
	final String? bricked; // No, Some, Half, Most, All (or '' for None)
	final String? defenseRating; // None, Bad, Ineffective, Good, Great (stored as '' for None)
	final bool defenseCollected;
	final bool defenseHit;
	final bool defenseBlocked;
	final bool defensePinned;
	final String? defended; // Undefended, Turned tables, Unaffected, Slowed, Slowed greatly (or '' for Undefended)
	final String? misses; // 0-1, 1-10, 10-30, 30-60, 60-100

	const EndGameData({
		this.autoClimbPosition,
		this.teleClimbPosition,
		this.climbMethod,
		this.shootOnMove = false,
		this.shootWhileCollecting = false,
		this.shootTurret = false,
		this.shootClimbing = false,
		this.fuelStrategy,
		this.bricked,
		this.defenseRating,
		this.defenseCollected = false,
		this.defenseHit = false,
		this.defenseBlocked = false,
		this.defensePinned = false,
		this.defended,
		this.misses,
	});

	EndGameData copyWith({
		String? autoClimbPosition,
		String? teleClimbPosition,
		String? climbMethod,
		bool? shootOnMove,
		bool? shootWhileCollecting,
		bool? shootTurret,
		bool? shootClimbing,
		String? fuelStrategy,
		String? bricked,
		String? defenseRating,
		bool? defenseCollected,
		bool? defenseHit,
		bool? defenseBlocked,
		bool? defensePinned,
		String? defended,
		String? misses,
	}) {
		return EndGameData(
			autoClimbPosition: autoClimbPosition ?? this.autoClimbPosition,
			teleClimbPosition: teleClimbPosition ?? this.teleClimbPosition,
			climbMethod: climbMethod ?? this.climbMethod,
			shootOnMove: shootOnMove ?? this.shootOnMove,
			shootWhileCollecting: shootWhileCollecting ?? this.shootWhileCollecting,
			shootTurret: shootTurret ?? this.shootTurret,
			shootClimbing: shootClimbing ?? this.shootClimbing,
			fuelStrategy: fuelStrategy ?? this.fuelStrategy,
			bricked: bricked ?? this.bricked,
			defenseRating: defenseRating ?? this.defenseRating,
			defenseCollected: defenseCollected ?? this.defenseCollected,
			defenseHit: defenseHit ?? this.defenseHit,
			defenseBlocked: defenseBlocked ?? this.defenseBlocked,
			defensePinned: defensePinned ?? this.defensePinned,
			defended: defended ?? this.defended,
			misses: misses ?? this.misses,
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
