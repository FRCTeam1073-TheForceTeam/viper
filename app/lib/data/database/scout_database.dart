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

// Scout table REMOVED - all scouting data now stored in-memory via providers
// See: scoutProvider, timelineProvider, endGameProvider, scoterInfoProvider, preMatchProvider
// Scouting data is exported to CSV at upload time, not persisted to database

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

@DriftDatabase(tables: [ServerConfig, Event, UploadHistory])
class ScoutDatabase extends _$ScoutDatabase {
	ScoutDatabase() : super(_openConnection());

	@override
	int get schemaVersion => 10;

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
					// Schema v7: Old Scout table schema changes - ignored now
				}
				if (from < 8) {
					// Schema v8: Old Scout table schema changes - ignored now
				}
				if (from < 9) {
					// Schema v9: Removed scouting counter persistence - ignored now
				}
				if (from < 10) {
					// Schema v10: Dropped Scout table completely
					// All scouting data now stored in-memory via providers
					// No migration needed - old databases will keep the table, new ones don't create it
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
