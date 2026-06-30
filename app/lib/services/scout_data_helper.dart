import '../data/database/scout_database.dart';

/// Helper to create a new ScoutData object with all required fields
class ScoutDataHelper {
	static ScoutData createNewScout({
		required String event,
		required String match,
		required String team,
	}) {
		final now = DateTime.now();
		return ScoutData(
			event: event,
			match: match,
			team: team,
			// Pre-Match
			startingPosition: null,
			noShow: 0,
			// Auto
			autoClimbLevel: null,
			autoTrenchDepotAllianceToNeutral: 0,
			autoBumpDepotAllianceToNeutral: 0,
			autoBumpOutpostAllianceToNeutral: 0,
			autoTrenchOutpostAllianceToNeutral: 0,
			autoTrenchDepotNeutralToAlliance: 0,
			autoBumpDepotNeutralToAlliance: 0,
			autoBumpOutpostNeutralToAlliance: 0,
			autoTrenchOutpostNeutralToAlliance: 0,
			autoFuelScore: 0,
			autoFuelNeutralAlliancePass: 0,
			autoCollectOutpost: 0,
			autoCollectDepot: 0,
			autoAllianceTime: 0,
			autoNeutralTime: 0,
			timeline: null,
			// Teleop
			teleopFuelAlliance: null,
			teleopFuelNeutral: null,
			teleopFuelOpponent: null,
			teleopClimbLevel: null,
			teleopAlliancePasses: null,
			teleopOpponentPasses: null,
			teleopZoneInteractions: null,
			// End Game
			climbPosition: null,
			climbMethod: null,
			shootOnMove: 0,
			shootWhileCollecting: 0,
			climbing: 0,
			fuelStrategy: null,
			shootingLocations: null,
			damageState: null,
			defenseRating: null,
			defenseMethods: null,
			defenseImpact: null,
			shootingMissesRange: null,
			// Scouter Info
			scouterName: null,
			comments: null,
			reviewRequest: 0,
			// Metadata
			synced: false,
			createdAt: now,
			updatedAt: now,
			syncedAt: null,
		);
	}
}
