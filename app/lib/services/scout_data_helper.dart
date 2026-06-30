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
			// Tele - Movement counters (alliance ↔ neutral)
			teleTrenchDepotAllianceToNeutral: 0,
			teleBumpDepotAllianceToNeutral: 0,
			teleBumpOutpostAllianceToNeutral: 0,
			teleTrenchOutpostAllianceToNeutral: 0,
			teleTrenchDepotNeutralToAlliance: 0,
			teleBumpDepotNeutralToAlliance: 0,
			teleBumpOutpostNeutralToAlliance: 0,
			teleTrenchOutpostNeutralToAlliance: 0,
			// Tele - Movement counters (neutral ↔ opponent)
			teleTrenchOutpostNeutralToOpponent: 0,
			teleBumpOutpostNeutralToOpponent: 0,
			teleBumpDepotNeutralToOpponent: 0,
			teleTrenchDepotNeutralToOpponent: 0,
			teleTrenchOutpostOpponentToNeutral: 0,
			teleBumpOutpostOpponentToNeutral: 0,
			teleBumpDepotOpponentToNeutral: 0,
			teleTrenchDepotOpponentToNeutral: 0,
			// Tele - Fuel scoring
			teleFuelScore: 0,
			teleFuelAllianceDump: 0,
			teleFuelOutpost: 0,
			teleFuelNeutralAlliancePass: 0,
			teleFuelOpponentNeutralPass: 0,
			teleFuelOpponentAlliancePass: 0,
			// Tele - Zone times
			teleAllianceTime: 0,
			teleNeutralTime: 0,
			teleOpponentTime: 0,
			// Tele - Climb and timeline
			teleClimbLevel: null,
			teleTimeline: null,
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
