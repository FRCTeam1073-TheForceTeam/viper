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

	// Helper functions to safely convert CSV data types
	String? _toString(dynamic value) {
		if (value == null) return null;
		if (value is String) return value.isEmpty ? null : value;
		return value.toString();
	}

	int _toInt(dynamic value) {
		if (value == null) return 0;
		if (value is int) return value;
		if (value is String) return int.tryParse(value) ?? 0;
		return 0;
	}

	void update(EndGameData data) {
		state = data;
	}

	void reset() {
		state = const EndGameData();
	}

	void loadFromData(Map<String, dynamic> data) {
		state = EndGameData(
			autoClimbPosition: _toString(data['auto_climb_position']),
			teleClimbPosition: _toString(data['tele_climb_position']),
			climbMethod: _toString(data['climb_method']),
			shootOnMove: _toInt(data['shoot_move']) == 1,
			shootWhileCollecting: _toInt(data['shoot_collecting']) == 1,
			shootTurret: _toInt(data['shoot_turret']) == 1,
			shootClimbing: _toInt(data['shoot_climbing']) == 1,
			fuelStrategy: _toString(data['fuel_to_alliance']),
			bricked: _toString(data['bricked']),
			defenseRating: _toString(data['defense']),
			defenseCollected: _toInt(data['defense_collected']) == 1,
			defenseHit: _toInt(data['defense_hit']) == 1,
			defenseBlocked: _toInt(data['defense_blocked']) == 1,
			defensePinned: _toInt(data['defense_pinned']) == 1,
			defended: _toString(data['defended']),
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
