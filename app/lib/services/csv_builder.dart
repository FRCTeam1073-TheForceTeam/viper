import 'package:csv/csv.dart';
import '../data/database/scout_database.dart';

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

	/// Build CSV string from scout entries
	/// Returns CSV with headers and data rows
	/// Uses toJson() for automatic schema discovery - new fields are automatically included
	static String buildScoutCsv(List<ScoutData> scouts) {
		if (scouts.isEmpty) {
			return '';
		}

		// Get all fields from the first scout using toJson() to determine column order
		// This acts like "SELECT * FROM scout"
		final firstScoutJson = scouts.first.toJson();
		// Filter out internal-only fields
		final allHeaders = firstScoutJson.keys.where((k) => !_excludedFields.contains(k)).toList();
		final headers = allHeaders.map(_camelToSnakeCase).toList(); // Convert to snake_case

		// Build rows using toJson() output with custom escaping
		final rows = <List<dynamic>>[
			headers.map((h) => safeCSV(h)).toList() // Escape headers too
		];
		for (final scout in scouts) {
			final scoutJson = scout.toJson();
			rows.add(allHeaders.map((header) {
				final value = scoutJson[header];
				// Apply custom CSV escaping to match server's safeCSV() function
				return safeCSV(value?.toString() ?? '');
			}).toList());
		}

		// Convert to CSV string
		return const ListToCsvConverter().convert(rows);
	}
}
