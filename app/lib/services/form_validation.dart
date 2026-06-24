class FormValidation {
	/// Validate team number (0-99999)
	static String? validateTeamNumber(String? value) {
		if (value == null || value.isEmpty) {
			return 'Team number is required';
		}

		final team = int.tryParse(value);
		if (team == null) {
			return 'Team number must be numeric';
		}

		if (team < 0 || team > 99999) {
			return 'Team number must be 0-99999';
		}

		return null;
	}

	/// Validate match number (required, alphanumeric)
	static String? validateMatchNumber(String? value) {
		if (value == null || value.isEmpty) {
			return 'Match number is required';
		}

		if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
			return 'Match number must be alphanumeric';
		}

		return null;
	}

	/// Validate numeric field with min/max
	static String? validateNumeric({
		required String? value,
		required int min,
		required int max,
		required String fieldName,
	}) {
		if (value == null || value.isEmpty) {
			return null; // Optional fields are fine when empty
		}

		final num = int.tryParse(value);
		if (num == null) {
			return '$fieldName must be numeric';
		}

		if (num < min || num > max) {
			return '$fieldName must be between $min and $max';
		}

		return null;
	}

	/// Validate hostname/URL for transferHosts
	static String? validateHostname(String? value) {
		if (value == null || value.isEmpty) {
			return null; // Optional
		}

		// Allow http://, https://, or just hostname
		final pattern = r'^((https?:\/\/)?)([a-zA-Z0-9\-\.\:]+)(\/?)$';
		if (!RegExp(pattern).hasMatch(value)) {
			return 'Invalid hostname format';
		}

		return null;
	}

	/// Validate scouter name (optional but check length if provided)
	static String? validateScouterName(String? value) {
		if (value == null || value.isEmpty) {
			return null; // Optional
		}

		if (value.length > 100) {
			return 'Scouter name must be 100 characters or less';
		}

		return null;
	}

	/// Validate comments (optional but check length)
	static String? validateComments(String? value) {
		if (value == null || value.isEmpty) {
			return null; // Optional
		}

		if (value.length > 500) {
			return 'Comments must be 500 characters or less';
		}

		return null;
	}
}
