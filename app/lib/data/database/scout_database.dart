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
// See: scoutProvider, timelineProvider, endGameProvider, scouterInfoProvider, preMatchProvider
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
	BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

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
	int get schemaVersion => 11;

	@override
	MigrationStrategy get migration {
		return MigrationStrategy(
			onUpgrade: (migrator, from, to) async {
				if (from < 11) {
					await migrator.addColumn(uploadHistory, uploadHistory.isDeleted);
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
	}) async {
		// Delete existing row for this match to avoid unique constraint conflicts
		await (delete(uploadHistory)
				..where((h) => h.event.equals(event) & h.match.equals(match) & h.team.equals(team)))
			.go();

		// Insert the new row
		return into(uploadHistory).insert(
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

	/// Get upload history entries by status (excluding soft-deleted except for 'deleted' status)
	Future<List<UploadHistoryData>> getUploadHistoryByStatus(String status) {
		if (status == 'deleted') {
			// Include items marked as deleted
			return (select(uploadHistory)..where((h) => h.uploadStatus.equals(status))).get();
		} else {
			// Exclude soft-deleted items for other statuses
			return (select(uploadHistory)
						..where((h) => h.uploadStatus.equals(status) & h.isDeleted.equals(false)))
					.get();
		}
	}

	/// Get pending upload history entries (first N entries, excluding soft-deleted)
	Future<List<UploadHistoryData>> getPendingUploadHistory({int limit = 10}) {
		return (select(uploadHistory)
					..where((h) => h.uploadStatus.equals('pending') & h.isDeleted.equals(false))
					..limit(limit))
				.get();
	}

	/// Get all pending upload entries (no limit, excluding soft-deleted)
	Future<List<UploadHistoryData>> getAllPendingUploadHistory() {
		return (select(uploadHistory)
					..where((h) => h.uploadStatus.equals('pending') & h.isDeleted.equals(false)))
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

	/// Soft-delete an upload history entry (marks as deleted, keeps in history)
	Future<void> softDeleteHistoryEntry(int id) async {
		await (update(uploadHistory)..where((h) => h.id.equals(id))).write(
			const UploadHistoryCompanion(
				isDeleted: Value(true),
				uploadStatus: Value('deleted'),
			),
		);
	}

	/// Restore a soft-deleted entry back to pending
	Future<void> restoreDeletedEntry(int id) async {
		await (update(uploadHistory)..where((h) => h.id.equals(id))).write(
			const UploadHistoryCompanion(
				isDeleted: Value(false),
				uploadStatus: Value('pending'),
			),
		);
	}

	/// Hard-delete an upload history entry (removes from database)
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

	/// Get pending uploads for an event/match/team
	/// Only checks local pending data (not yet sent to server)
	/// Does NOT check server data (that's handled by existingScoutDataProvider checking SharedPreferences cache)
	Future<UploadHistoryData?> getMatchData(String event, String match, String team) async {

		// Priority 1: Pending uploads (data not yet sent to server)
		final pendingData = await (select(uploadHistory)
					..where((h) =>
							h.event.equals(event) &
							h.match.equals(match) &
							h.team.equals(team) &
							h.uploadStatus.equals('pending') &
							h.isDeleted.equals(false))
					..orderBy([(u) => OrderingTerm(expression: u.createdAt, mode: OrderingMode.desc)])
					..limit(1))
				.getSingleOrNull();

		if (pendingData != null) {
			return pendingData;
		}

		return null;
	}
}

// ============================================================================
// CONNECTION
// ============================================================================

LazyDatabase _openConnection() {
	return LazyDatabase(() => openDriftConnection());
}
