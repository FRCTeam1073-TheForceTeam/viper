/// Non-database scout data model - all scouting info stored in-memory via providers
class ScoutData {
	final String? event;
	final String? match;
	final String? team;
	final String? startingPosition;
	final bool noShow;
	final Map<String, int> autoCounts; // Counter values
	final Map<String, int> teleCounts; // Counter values
	final List<TimelineEvent> timeline;
	final DateTime? matchStartTime;
	final String? climbMethod;
	final String? climbPosition;
	final bool shootOnMove;
	final bool shootWhileCollecting;
	final bool climbing;
	final String? fuelStrategy;
	final String? shootingLocations;
	final int damageState;
	final String? defenseRating;
	final String? defenseMethods;
	final String? defenseImpact;
	final int? shootingMissesRange;
	final String? scouterName;
	final String? comments;
	final bool reviewRequest;
	final DateTime createdAt;
	final DateTime updatedAt;

	ScoutData({
		this.event,
		this.match,
		this.team,
		this.startingPosition,
		this.noShow = false,
		this.autoCounts = const {},
		this.teleCounts = const {},
		this.timeline = const [],
		this.matchStartTime,
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
		this.scouterName,
		this.comments,
		this.reviewRequest = false,
		DateTime? createdAt,
		DateTime? updatedAt,
	})	: createdAt = createdAt ?? DateTime.now(),
		updatedAt = updatedAt ?? DateTime.now();

	ScoutData copyWith({
		String? event,
		String? match,
		String? team,
		String? startingPosition,
		bool? noShow,
		Map<String, int>? autoCounts,
		Map<String, int>? teleCounts,
		List<TimelineEvent>? timeline,
		DateTime? matchStartTime,
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
		String? scouterName,
		String? comments,
		bool? reviewRequest,
		DateTime? createdAt,
		DateTime? updatedAt,
	}) {
		return ScoutData(
			event: event ?? this.event,
			match: match ?? this.match,
			team: team ?? this.team,
			startingPosition: startingPosition ?? this.startingPosition,
			noShow: noShow ?? this.noShow,
			autoCounts: autoCounts ?? this.autoCounts,
			teleCounts: teleCounts ?? this.teleCounts,
			timeline: timeline ?? this.timeline,
			matchStartTime: matchStartTime ?? this.matchStartTime,
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
			scouterName: scouterName ?? this.scouterName,
			comments: comments ?? this.comments,
			reviewRequest: reviewRequest ?? this.reviewRequest,
			createdAt: createdAt ?? this.createdAt,
			updatedAt: updatedAt ?? this.updatedAt,
		);
	}
}

class TimelineEvent {
	final String fieldName; // e.g., "auto_speaker_score", "tele_amp_score"
	final String action; // e.g., "increment", "decrement", "toggle"
	final DateTime timestamp;

	const TimelineEvent({
		required this.fieldName,
		required this.action,
		required this.timestamp,
	});
}
