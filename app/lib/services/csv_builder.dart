import 'package:csv/csv.dart';

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

	/// Build CSV string from scout data maps
	/// Accepts Map<String, dynamic> with scouting data and metadata
	static String buildScoutCsv(List<Map<String, dynamic>> scoutDataMaps) {
		if (scoutDataMaps.isEmpty) {
			return '';
		}

		// Get all fields from the first scout to determine column order
		final firstScout = scoutDataMaps.first;
		final allHeaders = firstScout.keys.where((k) => !_excludedFields.contains(k)).toList();
		final headers = allHeaders.map(_camelToSnakeCase).toList();

		// Build rows with custom escaping
		final rows = <List<dynamic>>[
			headers.map((h) => safeCSV(h)).toList()
		];
		for (final scoutData in scoutDataMaps) {
			rows.add(allHeaders.map((header) {
				final value = scoutData[header];
				return safeCSV(value?.toString() ?? '');
			}).toList());
		}

		// Convert to CSV string
		return const ListToCsvConverter().convert(rows);
	}
}
