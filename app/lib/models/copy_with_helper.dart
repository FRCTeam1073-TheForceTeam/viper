import '../providers/end_game_provider.dart';

extension EndGameDataUpdate on EndGameData {
	/// Update a single field by name without hardcoding a switch statement.
	/// Usage: state = state.updateField('shootOnMove', true)
	EndGameData updateField(String fieldName, dynamic value) {
		switch (fieldName) {
			case 'autoClimbPosition':
				return copyWith(autoClimbPosition: value as String?);
			case 'teleClimbPosition':
				return copyWith(teleClimbPosition: value as String?);
			case 'climbMethod':
				return copyWith(climbMethod: value as String?);
			case 'shootOnMove':
				return copyWith(shootOnMove: value as bool);
			case 'shootWhileCollecting':
				return copyWith(shootWhileCollecting: value as bool);
			case 'shootTurret':
				return copyWith(shootTurret: value as bool);
			case 'shootClimbing':
				return copyWith(shootClimbing: value as bool);
			case 'fuelStrategy':
				return copyWith(fuelStrategy: value as String?);
			case 'bricked':
				return copyWith(bricked: value as String?);
			case 'defenseRating':
				return copyWith(defenseRating: value as String?);
			case 'defenseCollected':
				return copyWith(defenseCollected: value as bool);
			case 'defenseHit':
				return copyWith(defenseHit: value as bool);
			case 'defenseBlocked':
				return copyWith(defenseBlocked: value as bool);
			case 'defensePinned':
				return copyWith(defensePinned: value as bool);
			case 'defended':
				return copyWith(defended: value as String?);
			case 'misses':
				return copyWith(misses: value as String?);
			case 'scouterName':
				return copyWith(scouterName: value as String?);
			case 'reviewRequest':
				return copyWith(reviewRequest: value as bool);
			case 'comments':
				return copyWith(comments: value as String?);
			default:
				return this;
		}
	}
}
