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
	final String? scouterName;
	final bool reviewRequest;
	final String? comments;

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
		this.scouterName,
		this.reviewRequest = false,
		this.comments,
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
		String? scouterName,
		bool? reviewRequest,
		String? comments,
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
			scouterName: scouterName ?? this.scouterName,
			reviewRequest: reviewRequest ?? this.reviewRequest,
			comments: comments ?? this.comments,
		);
	}

	/// Convert state to map for database storage
	Map<String, dynamic> toMap() {
		return {
			'auto_climb_position': autoClimbPosition,
			'tele_climb_position': teleClimbPosition,
			'climb_method': climbMethod,
			'shoot_move': shootOnMove ? 1 : 0,
			'shoot_collecting': shootWhileCollecting ? 1 : 0,
			'shoot_turret': shootTurret ? 1 : 0,
			'shoot_climbing': shootClimbing ? 1 : 0,
			'fuel_to_alliance': fuelStrategy,
			'bricked': bricked,
			'defense': defenseRating,
			'defense_collected': defenseCollected ? 1 : 0,
			'defense_hit': defenseHit ? 1 : 0,
			'defense_blocked': defenseBlocked ? 1 : 0,
			'defense_pinned': defensePinned ? 1 : 0,
			'defended': defended,
			'misses': misses,
			'scouter': scouterName,
			'review_requested': reviewRequest ? 1 : 0,
			'comments': comments,
		};
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

	void loadFromData(Map<String, dynamic> data) {
		state = EndGameData(
			autoClimbPosition: data['auto_climb_position'] as String?,
			teleClimbPosition: data['tele_climb_position'] as String?,
			climbMethod: data['climb_method'] as String?,
			shootOnMove: (data['shoot_move'] as int? ?? 0) == 1,
			shootWhileCollecting: (data['shoot_collecting'] as int? ?? 0) == 1,
			shootTurret: (data['shoot_turret'] as int? ?? 0) == 1,
			shootClimbing: (data['shoot_climbing'] as int? ?? 0) == 1,
			fuelStrategy: data['fuel_to_alliance'] as String?,
			bricked: data['bricked'] as String?,
			defenseRating: data['defense'] as String?,
			defenseCollected: (data['defense_collected'] as int? ?? 0) == 1,
			defenseHit: (data['defense_hit'] as int? ?? 0) == 1,
			defenseBlocked: (data['defense_blocked'] as int? ?? 0) == 1,
			defensePinned: (data['defense_pinned'] as int? ?? 0) == 1,
			defended: data['defended'] as String?,
			misses: data['misses'] as String?,
			scouterName: data['scouter'] as String?,
			reviewRequest: (data['review_requested'] as int? ?? 0) == 1,
			comments: data['comments'] as String?,
		);
	}
}

final endGameProvider = StateNotifierProvider<EndGameNotifier, EndGameData>((ref) {
	return EndGameNotifier();
});
