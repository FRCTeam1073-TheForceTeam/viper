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
      noShow: false,
      // Auto
      autoFuelAlliance: null,
      autoFuelNeutral: null,
      autoFuelOpponent: null,
      autoFuelDepot: null,
      autoFuelOutpost: null,
      autoClimbLevel: null,
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
      shootOnMove: false,
      shootWhileCollecting: false,
      climbing: false,
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
      reviewRequest: false,
      // Metadata
      synced: false,
      createdAt: now,
      updatedAt: now,
      syncedAt: null,
    );
  }
}
