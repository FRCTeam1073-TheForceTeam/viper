import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:logger/logger.dart';
import '../data/database/scout_database.dart';
import '../data/api/viper_api_client.dart';
import '../services/csv_builder.dart';

// ============================================================================
// DATABASE
// ============================================================================

final databaseProvider = FutureProvider((ref) async {
	return ScoutDatabase();
});

// ============================================================================
// CONFIGURATION & API
// ============================================================================

final sharedPreferencesProvider = FutureProvider((ref) async {
	return SharedPreferences.getInstance();
});

final backendUrlProvider = FutureProvider((ref) async {
	final db = await ref.watch(databaseProvider.future);
	final config = await db.getCurrentConfig();
	return config?.backendUrl ?? 'http://localhost';
});

final apiClientProvider = FutureProvider((ref) async {
	final db = await ref.watch(databaseProvider.future);
	final config = await db.getCurrentConfig();
	final baseUrl = config?.backendUrl ?? 'http://localhost';
	final username = config?.username;
	final password = config?.password;
	return ViperApiClient(
		baseUrl: baseUrl,
		username: username,
		password: password,
	);
});

// ============================================================================
// SELECTED EVENT
// ============================================================================

final selectedEventProvider = StateNotifierProvider<SelectedEventNotifier, String?>((ref) {
	return SelectedEventNotifier(ref);
});

class SelectedEventNotifier extends StateNotifier<String?> {
	final Ref ref;

	SelectedEventNotifier(this.ref) : super(null) {
		_loadSelectedEvent();
	}

	Future<void> _loadSelectedEvent() async {
		final db = await ref.read(databaseProvider.future);
		final config = await db.getCurrentConfig();
		state = config?.selectedEventId;
	}

	Future<void> setSelectedEvent(String eventId) async {
		state = eventId;
		final db = await ref.read(databaseProvider.future);
		final config = await db.getCurrentConfig();

		if (config != null) {
			await db.upsertConfig(
				config.copyWith(
					selectedEventId: Value(eventId),
					lastEventChangeDate: Value(DateTime.now()),
				),
			);
		} else {
			await db.upsertConfig(
				ServerConfigData(
					id: 1,
					backendUrl: '',
					selectedEventId: eventId,
					selectedTeam: null,
					scouterName: null,
					lastEventChangeDate: DateTime.now(),
				),
			);
		}
	}
}

// ============================================================================
// SELECTED BOT POSITION
// ============================================================================

final selectedBotPositionProvider = StateProvider<String?>((ref) {
	return null;
});

// CONNECTIVITY (SIMPLIFIED - TODO: Fix)
final connectivityProvider = StreamProvider((ref) async* {
	// Always assume online - connectivity detection needs API review
	yield true;
});

// ============================================================================
// EVENT LIST
// ============================================================================

final eventListProvider = FutureProvider((ref) async {
	final apiClient = await ref.watch(apiClientProvider.future);
	final events = await apiClient.fetchEventList();

	// Get current year
	final currentYear = DateTime.now().year;

	// Log filtering info
	final logger = Logger();
	logger.i('🎯 EVENT LIST FILTERING:');
	logger.i('   Total events fetched: ${events.length}');
	logger.i('   Current year: $currentYear');

	// Show breakdown by year
	final byYear = <int, int>{};
	for (var e in events) {
		byYear[e.season] = (byYear[e.season] ?? 0) + 1;
	}
	logger.i('   Events by year: $byYear');

	// Filter to current season only
	final filtered = events.where((e) => e.season == currentYear).toList();
	logger.i('   After filtering: ${filtered.length} events');

	if (filtered.isNotEmpty) {
		logger.d('   Filtered events: ${filtered.map((e) => e.eventId).join(", ")}');
	}

	// Sort by start date, most recent first
	// Events with no start date are placed at the bottom
	filtered.sort((a, b) {
		if (a.startDate == null && b.startDate == null) return 0;
		if (a.startDate == null) return 1;
		if (b.startDate == null) return -1;
		return b.startDate!.compareTo(a.startDate!);
	});

	return filtered;
});

// ============================================================================
// SCOUT ENTRIES
// ============================================================================

final scoutListProvider = StreamProvider<List<ScoutData>>((ref) async* {
	final db = await ref.watch(databaseProvider.future);
	final selectedEvent = ref.watch(selectedEventProvider);

	if (selectedEvent == null) {
		yield [];
		return;
	}

	// Initial load
	yield await db.getScoutsForEvent(selectedEvent);

	// Stream updates (poll every 2 seconds for now)
	await for (final _ in Stream.periodic(const Duration(seconds: 2))) {
		yield await db.getScoutsForEvent(selectedEvent);
	}
});

final pendingScoutsProvider = FutureProvider<List<ScoutData>>((ref) async {
	final db = await ref.watch(databaseProvider.future);
	return db.getPendingScouts();
});

// ============================================================================
// SYNC STATE
// ============================================================================

class SyncState {
	final bool isSyncing;
	final String? error;
	final DateTime? lastSyncTime;
	final int pendingCount;
	final int syncedCount;

	SyncState({
		this.isSyncing = false,
		this.error,
		this.lastSyncTime,
		this.pendingCount = 0,
		this.syncedCount = 0,
	});

	SyncState copyWith({
		bool? isSyncing,
		String? error,
		DateTime? lastSyncTime,
		int? pendingCount,
		int? syncedCount,
	}) {
		return SyncState(
			isSyncing: isSyncing ?? this.isSyncing,
			error: error ?? this.error,
			lastSyncTime: lastSyncTime ?? this.lastSyncTime,
			pendingCount: pendingCount ?? this.pendingCount,
			syncedCount: syncedCount ?? this.syncedCount,
		);
	}
}

// CONNECTIVITY (SIMPLIFIED - TODO: Fix)

final syncStateProvider = StateNotifierProvider<SyncStateNotifier, SyncState>((ref) {
	return SyncStateNotifier(ref);
});

class SyncStateNotifier extends StateNotifier<SyncState> {
	final Ref ref;

	SyncStateNotifier(this.ref) : super(SyncState());

	Future<void> syncScoutData() async {
		state = state.copyWith(isSyncing: true, error: null);

		try {
			final db = await ref.read(databaseProvider.future);
			final apiClient = await ref.read(apiClientProvider.future);
			final pendingScouts = await db.getPendingScouts();

			if (pendingScouts.isEmpty) {
				state = state.copyWith(
					isSyncing: false,
					lastSyncTime: DateTime.now(),
				);
				return;
			}

			// Build CSV string from pending scouts
			final csvContent = CsvBuilder.buildScoutCsv(pendingScouts);

			if (csvContent.isEmpty) {
				state = state.copyWith(isSyncing: false);
				return;
			}

			// Upload to backend
			await apiClient.uploadScoutData(csvContent);

			// Mark as synced
			final keys = pendingScouts
					.map((s) => '${s.event}_${s.match}_${s.team}')
					.toList();
			await db.markAsSynced(keys);

			state = state.copyWith(
				isSyncing: false,
				lastSyncTime: DateTime.now(),
				pendingCount: 0,
			);
		} catch (e) {
			state = state.copyWith(
				isSyncing: false,
				error: e.toString(),
			);
		}
	}
}

// CONNECTIVITY (SIMPLIFIED - TODO: Fix)
