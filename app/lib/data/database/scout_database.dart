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
	IntColumn get noShow => integer().withDefault(const Constant(0))(); // 0=false, 1=true

	// Auto Tab - Movement counters (field interactions)
	IntColumn get autoTrenchDepotAllianceToNeutral => integer().withDefault(const Constant(0))();
	IntColumn get autoBumpDepotAllianceToNeutral => integer().withDefault(const Constant(0))();
	IntColumn get autoBumpOutpostAllianceToNeutral => integer().withDefault(const Constant(0))();
	IntColumn get autoTrenchOutpostAllianceToNeutral => integer().withDefault(const Constant(0))();
	IntColumn get autoTrenchDepotNeutralToAlliance => integer().withDefault(const Constant(0))();
	IntColumn get autoBumpDepotNeutralToAlliance => integer().withDefault(const Constant(0))();
	IntColumn get autoBumpOutpostNeutralToAlliance => integer().withDefault(const Constant(0))();
	IntColumn get autoTrenchOutpostNeutralToAlliance => integer().withDefault(const Constant(0))();

	// Auto Tab - Climb level
	IntColumn get autoClimbLevel => integer().nullable()();

	// Auto Tab - Fuel scoring and collection
	IntColumn get autoFuelScore => integer().withDefault(const Constant(0))();
	IntColumn get autoFuelNeutralAlliancePass => integer().withDefault(const Constant(0))();
	IntColumn get autoCollectOutpost => integer().withDefault(const Constant(0))(); // 0=false, 1=true
	IntColumn get autoCollectDepot => integer().withDefault(const Constant(0))(); // 0=false, 1=true

	// Auto Tab - Zone times (in seconds)
	IntColumn get autoAllianceTime => integer().withDefault(const Constant(0))();
	IntColumn get autoNeutralTime => integer().withDefault(const Constant(0))();

	// Timeline events (JSON array of {time, action, value}) - covers auto period only
	TextColumn get timeline => text().nullable()();

	// Tele Tab - Movement counters (alliance ↔ neutral)
	IntColumn get teleTrenchDepotAllianceToNeutral => integer().withDefault(const Constant(0))();
	IntColumn get teleBumpDepotAllianceToNeutral => integer().withDefault(const Constant(0))();
	IntColumn get teleBumpOutpostAllianceToNeutral => integer().withDefault(const Constant(0))();
	IntColumn get teleTrenchOutpostAllianceToNeutral => integer().withDefault(const Constant(0))();
	IntColumn get teleTrenchDepotNeutralToAlliance => integer().withDefault(const Constant(0))();
	IntColumn get teleBumpDepotNeutralToAlliance => integer().withDefault(const Constant(0))();
	IntColumn get teleBumpOutpostNeutralToAlliance => integer().withDefault(const Constant(0))();
	IntColumn get teleTrenchOutpostNeutralToAlliance => integer().withDefault(const Constant(0))();

	// Tele Tab - Movement counters (neutral ↔ opponent)
	IntColumn get teleTrenchOutpostNeutralToOpponent => integer().withDefault(const Constant(0))();
	IntColumn get teleBumpOutpostNeutralToOpponent => integer().withDefault(const Constant(0))();
	IntColumn get teleBumpDepotNeutralToOpponent => integer().withDefault(const Constant(0))();
	IntColumn get teleTrenchDepotNeutralToOpponent => integer().withDefault(const Constant(0))();
	IntColumn get teleTrenchOutpostOpponentToNeutral => integer().withDefault(const Constant(0))();
	IntColumn get teleBumpOutpostOpponentToNeutral => integer().withDefault(const Constant(0))();
	IntColumn get teleBumpDepotOpponentToNeutral => integer().withDefault(const Constant(0))();
	IntColumn get teleTrenchDepotOpponentToNeutral => integer().withDefault(const Constant(0))();

	// Tele Tab - Fuel scoring
	IntColumn get teleFuelScore => integer().withDefault(const Constant(0))();
	IntColumn get teleFuelAllianceDump => integer().withDefault(const Constant(0))();
	IntColumn get teleFuelOutpost => integer().withDefault(const Constant(0))();
	IntColumn get teleFuelNeutralAlliancePass => integer().withDefault(const Constant(0))();
	IntColumn get teleFuelOpponentNeutralPass => integer().withDefault(const Constant(0))();
	IntColumn get teleFuelOpponentAlliancePass => integer().withDefault(const Constant(0))();

	// Tele Tab - Zone times (in seconds)
	IntColumn get teleAllianceTime => integer().withDefault(const Constant(0))();
	IntColumn get teleNeutralTime => integer().withDefault(const Constant(0))();
	IntColumn get teleOpponentTime => integer().withDefault(const Constant(0))();

	// Tele Tab - Climb (renamed from teleopClimbLevel)
	IntColumn get teleClimbLevel => integer().nullable()();

	// Tele Tab - Timeline events
	TextColumn get teleTimeline => text().nullable()();

	// End Game Tab
	TextColumn get climbPosition => text().nullable()();
	TextColumn get climbMethod => text().nullable()(); // Rungs, Uprights, Flip, No Climb
	IntColumn get shootOnMove => integer().withDefault(const Constant(0))(); // 0=false, 1=true
	IntColumn get shootWhileCollecting => integer().withDefault(const Constant(0))(); // 0=false, 1=true
	IntColumn get climbing => integer().withDefault(const Constant(0))(); // 0=false, 1=true
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
	IntColumn get reviewRequest => integer().withDefault(const Constant(0))(); // 0=false, 1=true

	// Metadata
	BoolColumn get synced => boolean().withDefault(const Constant(false))();
	DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
	DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now())();
	DateTimeColumn get syncedAt => dateTime().nullable()();

	@override
	Set<Column<Object>> get primaryKey => {event, match, team};
}

/// Upload history - tracks pending/uploaded/failed scouting data batches
@DataClassName('UploadHistoryData')
class UploadHistory extends Table {
	IntColumn get id => integer().autoIncrement()();
	TextColumn get event => text()();
	TextColumn get match => text()();
	TextColumn get team => text()();
	TextColumn get uploadStatus => text().withDefault(const Constant('pending'))();
	DateTimeColumn get uploadDate => dateTime().nullable()();
	TextColumn get csvHeaders => text()();
	TextColumn get csvData => text()();
	DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();

	@override
	List<Set<Column<Object>>> get uniqueKeys => [
		{event, match, team},
	];
}

// ============================================================================
// DATABASE
// ============================================================================

@DriftDatabase(tables: [ServerConfig, Event, Scout, UploadHistory])
class ScoutDatabase extends _$ScoutDatabase {
	ScoutDatabase() : super(_openConnection());

	@override
	int get schemaVersion => 8;

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
				if (from < 3) {
					// Create UploadHistory table
					await migrator.createTable(uploadHistory);
				}
				if (from < 4) {
					// Add event, match, team columns to UploadHistory table
					await migrator.addColumn(uploadHistory, uploadHistory.event);
					await migrator.addColumn(uploadHistory, uploadHistory.match);
					await migrator.addColumn(uploadHistory, uploadHistory.team);
				}
				if (from < 5) {
					// Schema v5: Removed unused auto fuel fields from UI/code
					// Old databases may still have these columns, but they're ignored
					// No migration needed as new databases won't have them
				}
				if (from < 6) {
					// Schema v6: Convert boolean fields to integers (0/1)
					// SQLite handles this automatically when columns already exist
					// New databases created with v6+ will have these as integers from the start
				}
				if (from < 7) {
					// Schema v7: Add timeline column to Scout table
					await migrator.addColumn(scout, scout.timeline);
				}
				if (from < 8) {
					// Schema v8: Add new tele tab columns with proper naming
					// Add all the new tele columns (old placeholder columns remain unused)
					await migrator.addColumn(scout, scout.teleTrenchDepotAllianceToNeutral);
					await migrator.addColumn(scout, scout.teleBumpDepotAllianceToNeutral);
					await migrator.addColumn(scout, scout.teleBumpOutpostAllianceToNeutral);
					await migrator.addColumn(scout, scout.teleTrenchOutpostAllianceToNeutral);
					await migrator.addColumn(scout, scout.teleTrenchDepotNeutralToAlliance);
					await migrator.addColumn(scout, scout.teleBumpDepotNeutralToAlliance);
					await migrator.addColumn(scout, scout.teleBumpOutpostNeutralToAlliance);
					await migrator.addColumn(scout, scout.teleTrenchOutpostNeutralToAlliance);
					await migrator.addColumn(scout, scout.teleTrenchOutpostNeutralToOpponent);
					await migrator.addColumn(scout, scout.teleBumpOutpostNeutralToOpponent);
					await migrator.addColumn(scout, scout.teleBumpDepotNeutralToOpponent);
					await migrator.addColumn(scout, scout.teleTrenchDepotNeutralToOpponent);
					await migrator.addColumn(scout, scout.teleTrenchOutpostOpponentToNeutral);
					await migrator.addColumn(scout, scout.teleBumpOutpostOpponentToNeutral);
					await migrator.addColumn(scout, scout.teleBumpDepotOpponentToNeutral);
					await migrator.addColumn(scout, scout.teleTrenchDepotOpponentToNeutral);
					await migrator.addColumn(scout, scout.teleFuelScore);
					await migrator.addColumn(scout, scout.teleFuelAllianceDump);
					await migrator.addColumn(scout, scout.teleFuelOutpost);
					await migrator.addColumn(scout, scout.teleFuelNeutralAlliancePass);
					await migrator.addColumn(scout, scout.teleFuelOpponentNeutralPass);
					await migrator.addColumn(scout, scout.teleFuelOpponentAlliancePass);
					await migrator.addColumn(scout, scout.teleAllianceTime);
					await migrator.addColumn(scout, scout.teleNeutralTime);
					await migrator.addColumn(scout, scout.teleOpponentTime);
					await migrator.addColumn(scout, scout.teleClimbLevel);
					await migrator.addColumn(scout, scout.teleTimeline);
				}
			},
		);
	}

	// =========================================================================	// ServerConfig Queries
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

	// =========================================================================
	// UploadHistory Queries
	// =========================================================================

	/// Insert a new upload history entry
	Future<int> insertUploadHistory({
		required String event,
		required String match,
		required String team,
		required String csvHeaders,
		required String csvData,
		required String status,
	}) {
		return into(uploadHistory).insertOnConflictUpdate(
			UploadHistoryCompanion(
				event: Value(event),
				match: Value(match),
				team: Value(team),
				uploadStatus: Value(status),
				csvHeaders: Value(csvHeaders),
				csvData: Value(csvData),
			),
		);
	}

	/// Get upload history entries by status
	Future<List<UploadHistoryData>> getUploadHistoryByStatus(String status) {
		return (select(uploadHistory)..where((h) => h.uploadStatus.equals(status)))
				.get();
	}

	/// Get pending upload history entries (first N entries)
	Future<List<UploadHistoryData>> getPendingUploadHistory({int limit = 10}) {
		return (select(uploadHistory)
					..where((h) => h.uploadStatus.equals('pending'))
					..limit(limit))
				.get();
	}

	/// Get all pending upload entries (no limit)
	Future<List<UploadHistoryData>> getAllPendingUploadHistory() {
		return (select(uploadHistory)
					..where((h) => h.uploadStatus.equals('pending')))
				.get();
	}

	/// Mark upload history entries as uploaded
	Future<void> markHistoryAsUploaded(List<int> ids) async {
		await (update(uploadHistory)
					..where((h) => h.id.isIn(ids)))
				.write(
			UploadHistoryCompanion(
				uploadStatus: const Value('uploaded'),
				uploadDate: Value(DateTime.now()),
			),
		);
	}

	/// Mark an upload history entry for reupload
	Future<void> markHistoryForReupload(int id) async {
		await (update(uploadHistory)..where((h) => h.id.equals(id))).write(
			const UploadHistoryCompanion(
				uploadStatus: Value('pending'),
				uploadDate: Value(null),
			),
		);
	}

	/// Delete an upload history entry
	Future<void> deleteHistoryEntry(int id) async {
		await (delete(uploadHistory)..where((h) => h.id.equals(id))).go();
	}

	/// Delete uploaded history entries older than N days
	Future<void> deleteOldUploadedHistory({int daysOld = 18}) async {
		final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
		await (delete(uploadHistory)
					..where((h) =>
							h.uploadStatus.equals('uploaded') &
							h.uploadDate.isSmallerThanValue(cutoffDate)))
				.go();
	}

	/// Delete any pending upload history entries for a given event/match/team
	Future<void> deletePendingHistoryForMatch(String event, String match, String team) async {
		await (delete(uploadHistory)
					..where((h) =>
							h.uploadStatus.equals('pending') &
							h.event.equals(event) &
							h.match.equals(match) &
							h.team.equals(team)))
				.go();
	}

	/// Clear all upload history
	Future<void> clearUploadHistory() async {
		await delete(uploadHistory).go();
	}
}

// ============================================================================
// CONNECTION
// ============================================================================

LazyDatabase _openConnection() {
	return LazyDatabase(() => openDriftConnection());
}
