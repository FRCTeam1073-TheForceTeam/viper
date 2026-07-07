class CsvBuilder {
	/// Escape CSV field values using the same logic as server's safeCSV()
	/// Matches: /www/scout.js safeCSV() function
	static String safeCSV(String s) {
		return s
			.replaceAll('\t', ' ') // Replace tabs with spaces
			.replaceAll(RegExp(r'\r\n|\r|\n'), '⏎') // Replace line breaks with ⏎
			.replaceAll('"', '״') // Replace quotes with Hebrew character
			.replaceAll(',', '،'); // Replace commas with Arabic character
	}

	/// Convert camelCase to snake_case
	/// Example: autoFuelScore -> auto_fuel_score
	static String _camelToSnakeCase(String input) {
		return input
			.replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)!.toLowerCase()}')
			.replaceFirst(RegExp(r'^_'), ''); // Remove leading underscore if present
	}

	/// Fields to exclude from CSV export (internal-only fields)
	static const Set<String> _excludedFields = {
		'id', // Database ID - not sent to server
		'synced', // Sync status flag
		'syncedAt', // Sync timestamp
	};

	/// Build CSV string from scout data maps without quoting (matching server expectations)
	/// Accepts `Map<String, dynamic>` with scouting data and metadata
	static String buildScoutCsv(List<Map<String, dynamic>> scoutDataMaps) {
		if (scoutDataMaps.isEmpty) {
			return '';
		}

		// Start with fields from the first scout to preserve header order
		final firstScout = scoutDataMaps.first;
		final allHeaders = <String>[];

		// Add fields from first scout in their original order
		for (final key in firstScout.keys) {
			if (!_excludedFields.contains(key)) {
				allHeaders.add(key);
			}
		}

		// Add any new fields from subsequent scouts (preserving their order)
		for (int i = 1; i < scoutDataMaps.length; i++) {
			for (final key in scoutDataMaps[i].keys) {
				if (!_excludedFields.contains(key) && !allHeaders.contains(key)) {
					allHeaders.add(key);
				}
			}
		}

		final headers = allHeaders.map(_camelToSnakeCase).toList();

		// Build CSV manually with safeCSV escaping and no quoting
		final csvLines = <String>[];

		// Add header row with escaped field names
		csvLines.add(headers.map((h) => safeCSV(h)).join(','));

		// Add data rows with escaped field values
		for (final scoutData in scoutDataMaps) {
			final rowValues = allHeaders.map((header) {
				final value = scoutData[header];
				return safeCSV(value?.toString() ?? '');
			}).toList();
			csvLines.add(rowValues.join(','));
		}

		return csvLines.join('\n');
	}
}
