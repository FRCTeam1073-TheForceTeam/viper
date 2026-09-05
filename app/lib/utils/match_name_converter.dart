/// Extracts the numeric portion of a match ID
/// Example: "qm5" → "5", "sf2" → "2"
String getMatchNumber(String matchId) {
	final match = RegExp(r'[0-9]+$').firstMatch(matchId);
	return match?.group(0) ?? '';
}

/// Extracts the match type prefix from a match ID
/// Example: "qm5" → "qm", "sf2" → "sf", "1p3" → "1p"
String getMatchTypeKey(String matchId) {
	final match = RegExp(r'^(pm|qm|qf|sf|(?:[1-5]p)|f)').firstMatch(matchId);
	return match?.group(0) ?? '';
}

/// Maps match type keys to human-readable full names
String getMatchTypeName(String typeKey) {
	final typeNames = {
		'pm': 'Practice ',
		'qm': 'Qualification ',
		'qf': 'Quarter-final ',
		'sf': 'Semi-final ',
		'1p': 'Playoffs first round ',
		'2p': 'Playoffs second round ',
		'3p': 'Playoffs third round ',
		'4p': 'Playoffs fourth round ',
		'5p': 'Playoffs fifth round ',
		'f': 'Final ',
	};
	return typeNames[typeKey] ?? '';
}

/// Maps match type keys to short names
String getShortMatchTypeName(String typeKey) {
	final shortNames = {
		'pm': 'Prac ',
		'qm': 'Qual ',
		'qf': 'QF ',
		'sf': 'SF ',
		'1p': 'Playoff R1 M',
		'2p': 'Playoff R2 M',
		'3p': 'Playoff R3 M',
		'4p': 'Playoff R4 M',
		'5p': 'Playoff R5 M',
		'f': 'Final ',
	};
	return shortNames[typeKey] ?? '';
}

/// Returns the full human-readable name for a match
/// Example: "qm5" → "Qualification 5"
String getMatchName(String matchId) {
	if (matchId.isEmpty) return '';
	final typeKey = getMatchTypeKey(matchId);
	final number = getMatchNumber(matchId);
	return '${getMatchTypeName(typeKey)}$number';
}

/// Returns the short display name for a match
/// Example: "qm5" → "Qual 5"
String getShortMatchName(String matchId) {
	if (matchId.isEmpty) return '';
	final typeKey = getMatchTypeKey(matchId);
	final number = getMatchNumber(matchId);
	return '${getShortMatchTypeName(typeKey)}$number';
}
