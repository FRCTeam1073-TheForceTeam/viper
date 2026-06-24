import 'package:drift/drift.dart';
import 'drift_connection.dart';

part 'scout_database.g.dart';

// ============================================================================
// TABLES
// ============================================================================

/// Server configuration (backend URL, selected event, etc.)
@DataClassName('ServerConfigData')
class ServerConfig extends Table {
	IntColumn get id => integer().autoIncrement()();
	TextColumn get backendUrl => text()();
	TextColumn get username => text().nullable()();
	TextColumn get password => text().nullable()();
	TextColumn get selectedEventId => text().nullable()();
	TextColumn get selectedTeam => text().nullable()();
	TextColumn get scouterName => text().nullable()();
	DateTimeColumn get lastEventChangeDate => dateTime().nullable()();
}

/// Event metadata (cached during session)
@DataClassName('EventData')
class Event extends Table {
	TextColumn get eventId => text()();
	TextColumn get name => text()();
	TextColumn get location => text().nullable()();
	DateTimeColumn get startDate => dateTime().nullable()();
	DateTimeColumn get endDate => dateTime().nullable()();

	@override
	Set<Column> get primaryKey => {eventId};
}

/// Scout entry - represents one match scouting report
@DataClassName('ScoutData')
class Scout extends Table {
	// Composite primary key: event + match + team
	TextColumn get event => text()();
	TextColumn get match => text()();
	TextColumn get team => text()();

	// Pre-Match Tab
	TextColumn get startingPosition => text().nullable()();
	BoolColumn get noShow => boolean().withDefault(const Constant(false))();

	// Auto Tab
	IntColumn get autoFuelAlliance => integer().nullable()();
	IntColumn get autoFuelNeutral => integer().nullable()();
	IntColumn get autoFuelOpponent => integer().nullable()();
	IntColumn get autoFuelDepot => integer().nullable()();
	IntColumn get autoFuelOutpost => integer().nullable()();
	IntColumn get autoClimbLevel => integer().nullable()();

	// Teleop Tab
	IntColumn get teleopFuelAlliance => integer().nullable()();
	IntColumn get teleopFuelNeutral => integer().nullable()();
	IntColumn get teleopFuelOpponent => integer().nullable()();
	IntColumn get teleopClimbLevel => integer().nullable()();
	IntColumn get teleopAlliancePasses => integer().nullable()();
	IntColumn get teleopOpponentPasses => integer().nullable()();
	TextColumn get teleopZoneInteractions => text().nullable()();

	// End Game Tab
	TextColumn get climbPosition => text().nullable()();
	TextColumn get climbMethod => text().nullable()(); // Rungs, Uprights, Flip, No Climb
	BoolColumn get shootOnMove => boolean().withDefault(const Constant(false))();
	BoolColumn get shootWhileCollecting => boolean().withDefault(const Constant(false))();
	BoolColumn get climbing => boolean().withDefault(const Constant(false))();
	TextColumn get fuelStrategy => text().nullable()(); // Carried, Pushed, Passed, Received
	TextColumn get shootingLocations => text().nullable()();
	IntColumn get damageState => integer().nullable()(); // 0-100%
	TextColumn get defenseRating => text().nullable()(); // Good, Bad, Great
	TextColumn get defenseMethods => text().nullable()();
	TextColumn get defenseImpact => text().nullable()(); // Slowed, Unaffected, Turned tables
	IntColumn get shootingMissesRange => integer().nullable()();

	// Scouter Info Tab
	TextColumn get scouterName => text().nullable()();
	TextColumn get comments => text().nullable()();
	BoolColumn get reviewRequest => boolean().withDefault(const Constant(false))();

	// Metadata
	BoolColumn get synced => boolean().withDefault(const Constant(false))();
	DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
	DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now())();
	DateTimeColumn get syncedAt => dateTime().nullable()();

	@override
	Set<Column<Object>> get primaryKey => {event, match, team};
}

// ============================================================================
// DATABASE
// ============================================================================

@DriftDatabase(tables: [ServerConfig, Event, Scout])
class ScoutDatabase extends _$ScoutDatabase {
	ScoutDatabase() : super(_openConnection());

	@override
	int get schemaVersion => 2;

	@override
	MigrationStrategy get migration {
		return MigrationStrategy(
			onUpgrade: (migrator, from, to) async {
				if (from < 2) {
					// Add username and password columns to ServerConfig table
					await migrator.addColumn(
						serverConfig,
						serverConfig.username,
					);
					await migrator.addColumn(
						serverConfig,
						serverConfig.password,
					);
				}
			},
		);
	}

	// =========================================================================
	// ServerConfig Queries
	// =========================================================================

	/// Get the current server configuration
	Future<ServerConfigData?> getCurrentConfig() {
		return select(serverConfig).getSingleOrNull();
	}

	/// Update or insert server configuration
	Future<void> upsertConfig(ServerConfigData config) async {
		await into(serverConfig).insertOnConflictUpdate(config);
	}

	// =========================================================================
	// Scout Queries
	// =========================================================================

	/// Get all scout entries
	Future<List<ScoutData>> getAllScouts() => select(scout).get();

	/// Get scouts for a specific event
	Future<List<ScoutData>> getScoutsForEvent(String eventId) {
		return (select(scout)..where((s) => s.event.equals(eventId))).get();
	}

	/// Get pending (unsynced) scout entries
	Future<List<ScoutData>> getPendingScouts() {
		return (select(scout)..where((s) => s.synced.equals(false))).get();
	}

	/// Get a specific scout entry (composite key lookup)
	Future<ScoutData?> getScout(String event, String match, String team) {
		return (select(scout)
					..where((s) =>
							s.event.equals(event) &
							s.match.equals(match) &
							s.team.equals(team)))
				.getSingleOrNull();
	}

	/// Insert or update a scout entry
	Future<void> upsertScout(ScoutData scoutData) async {
		await into(scout).insertOnConflictUpdate(scoutData);
	}

	/// Mark scouts as synced
	Future<void> markAsSynced(List<String> eventMatchTeamIds) async {
		// Parse composite keys and update
		for (var id in eventMatchTeamIds) {
			final parts = id.split('_');
			if (parts.length == 3) {
				await (update(scout)
							..where((s) =>
									s.event.equals(parts[0]) &
									s.match.equals(parts[1]) &
									s.team.equals(parts[2])))
						.write(
					ScoutCompanion(
						synced: Value(true),
						syncedAt: Value(DateTime.now()),
					),
				);
			}
		}
	}

	/// Delete a scout entry
	Future<void> deleteScout(String event, String match, String team) async {
		await (delete(scout)
					..where((s) =>
							s.event.equals(event) &
							s.match.equals(match) &
							s.team.equals(team)))
				.go();
	}

	// =========================================================================
	// Event Queries
	// =========================================================================

	/// Get all cached events
	Future<List<EventData>> getAllEvents() => select(event).get();

	/// Get a specific event by ID
	Future<EventData?> getEvent(String eventId) {
		return (select(event)..where((e) => e.eventId.equals(eventId)))
				.getSingleOrNull();
	}

	/// Insert or update event(s)
	Future<void> upsertEvents(List<EventData> events) async {
		for (var e in events) {
			await into(event).insertOnConflictUpdate(e);
		}
	}

	/// Clear all cached events
	Future<void> clearEvents() async {
		await delete(event).go();
	}
}

// ============================================================================
// CONNECTION
// ============================================================================

LazyDatabase _openConnection() {
	return LazyDatabase(() => openDriftConnection());
}
