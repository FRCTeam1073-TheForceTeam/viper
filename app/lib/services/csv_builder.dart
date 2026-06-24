import 'package:csv/csv.dart';
import '../data/database/scout_database.dart';

class CsvBuilder {
	/// Build CSV string from scout entries
	/// Returns CSV with headers and data rows
	static String buildScoutCsv(List<ScoutData> scouts) {
		if (scouts.isEmpty) {
			return '';
		}

		// Define column order (must match web backend expectations)
		final headers = [
			'event',
			'match',
			'team',
			'noShow',
			'autoFuelAlliance',
			'autoFuelNeutral',
			'autoFuelOpponent',
			'autoFuelDepot',
			'autoFuelOutpost',
			'autoClimbLevel',
			'teleopFuelAlliance',
			'teleopFuelNeutral',
			'teleopFuelOpponent',
			'teleopClimbLevel',
			'teleopAlliancePasses',
			'teleopOpponentPasses',
			'climbMethod',
			'damageState',
			'defenseRating',
			'defenseImpact',
			'shootOnMove',
			'shootWhileCollecting',
			'climbing',
			'shootingMissesRange',
			'startingPosition',
			'scouterName',
			'comments',
			'reviewRequest',
		];

		// Build rows
		final rows = <List<dynamic>>[headers];
		for (final scout in scouts) {
			rows.add([
				scout.event,
				scout.match,
				scout.team,
				scout.noShow ? '1' : '0',
				scout.autoFuelAlliance?.toString() ?? '',
				scout.autoFuelNeutral?.toString() ?? '',
				scout.autoFuelOpponent?.toString() ?? '',
				scout.autoFuelDepot?.toString() ?? '',
				scout.autoFuelOutpost?.toString() ?? '',
				scout.autoClimbLevel?.toString() ?? '',
				scout.teleopFuelAlliance?.toString() ?? '',
				scout.teleopFuelNeutral?.toString() ?? '',
				scout.teleopFuelOpponent?.toString() ?? '',
				scout.teleopClimbLevel?.toString() ?? '',
				scout.teleopAlliancePasses?.toString() ?? '',
				scout.teleopOpponentPasses?.toString() ?? '',
				scout.climbMethod ?? '',
				scout.damageState?.toString() ?? '',
				scout.defenseRating ?? '',
				scout.defenseImpact ?? '',
				scout.shootOnMove ? '1' : '0',
				scout.shootWhileCollecting ? '1' : '0',
				scout.climbing ? '1' : '0',
				scout.shootingMissesRange?.toString() ?? '',
				scout.startingPosition ?? '',
				scout.scouterName ?? '',
				scout.comments ?? '',
				scout.reviewRequest ? '1' : '0',
			]);
		}

		// Convert to CSV string
		return const ListToCsvConverter().convert(rows);
	}
}
