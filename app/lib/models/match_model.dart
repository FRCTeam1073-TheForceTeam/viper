/// Represents a single match in a competition schedule
class MatchModel {
	final String matchNumber;
	final Map<String, String> teams; // Position -> Team mapping (R1-R3, B1-B3)

	MatchModel({
		required this.matchNumber,
		required this.teams,
	});

	/// Get the team number for a specific position (e.g., "R1", "B2")
	String? getTeamForPosition(String position) {
		return teams[position];
	}

	@override
	String toString() => 'Match $matchNumber';
}
