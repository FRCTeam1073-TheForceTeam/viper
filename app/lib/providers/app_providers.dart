import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' show Value;
import 'package:logger/logger.dart';
import '../data/database/scout_database.dart';
import '../data/api/viper_api_client.dart';
import '../services/csv_builder.dart';
import '../models/match_model.dart';

// ============================================================================
// CSV PARSING
// ============================================================================

/// Parse CSV string into list of maps with headers as keys
/// Matches the JavaScript csvToArrayOfMaps behavior
List<Map<String, dynamic>> csvToArrayOfMaps(String csv) {
	final List<Map<String, dynamic>> arr = [];
	final List<String> lines = csv.split(RegExp(r'[\r\n]+'));

	if (lines.isEmpty) return arr;

	// Parse header
	final List<String> headers = lines[0].split(',');

	// Parse data rows
	for (int i = 1; i < lines.length; i++) {
		if (lines[i].trim().isEmpty) continue;

		final List<String> data = lines[i].split(',').map((s) => s.trim()).toList();
		final Map<String, dynamic> map = {};

		for (int j = 0; j < data.length; j++) {
			if (j < headers.length) {
				final String value = data[j];
				// Try to parse as integer if it's all digits
				if (RegExp(r'^[0-9]+$').hasMatch(value)) {
					map[headers[j]] = int.parse(value);
				} else {
					map[headers[j]] = unescapeField(value);
				}
			}
		}

		arr.add(map);
	}

	return arr;
}

/// Unescape CSV field values
String unescapeField(String s) {
	return s
		.replaceAll('⏎', '\n')
		.replaceAll('״', '"')
		.replaceAll('،', ',');
}

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
	// This is now just for reference - SharedPreferences is already initialized in main()
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
		print('[SELECTED_EVENT_NOTIFIER] setSelectedEvent($eventId) called');
		state = eventId;
		print('[SELECTED_EVENT_NOTIFIER] state set to $eventId');
		final db = await ref.read(databaseProvider.future);
		print('[SELECTED_EVENT_NOTIFIER] got database');
		final config = await db.getCurrentConfig();
		print('[SELECTED_EVENT_NOTIFIER] got config: $config');

		if (config != null) {
			print('[SELECTED_EVENT_NOTIFIER] upserting config with selectedEventId=$eventId');
			await db.upsertConfig(
				config.copyWith(
					selectedEventId: Value(eventId),
					lastEventChangeDate: Value(DateTime.now()),
				),
			);
			print('[SELECTED_EVENT_NOTIFIER] upsertConfig completed');
		} else {
			print('[SELECTED_EVENT_NOTIFIER] creating new config with selectedEventId=$eventId');
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
			print('[SELECTED_EVENT_NOTIFIER] upsertConfig (new) completed');
		}
	}
}

// ============================================================================
// SELECTED BOT POSITION
// ============================================================================

class _BotPositionNotifier extends StateNotifier<String?> {
	final SharedPreferences? _prefs;

	_BotPositionNotifier(this._prefs)
		: super(_prefs?.getString('selected_bot_position') ?? null);

	Future<void> setPosition(String? position) async {
		if (_prefs == null) return;

		state = position;
		if (position == null) {
			await _prefs!.remove('selected_bot_position');
		} else {
			await _prefs!.setString('selected_bot_position', position);
		}
	}
}

final selectedBotPositionProvider =
	StateNotifierProvider<_BotPositionNotifier, String?>((ref) {
	final prefsAsync = ref.watch(sharedPreferencesProvider);

	return prefsAsync.when(
		data: (prefs) => _BotPositionNotifier(prefs),
		loading: () => _BotPositionNotifier(null),
		error: (error, stack) => _BotPositionNotifier(null),
	);
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

final scoutedMatchesProvider = FutureProvider<Set<String>>((ref) async {
	final db = await ref.watch(databaseProvider.future);
	final selectedEvent = ref.watch(selectedEventProvider);

	if (selectedEvent == null) {
		return {};
	}

	// Get local scouting data - track which matches have been scouted (by any position)
	final localScouts = await db.getScoutsForEvent(selectedEvent);
	final scoutedMatches = <String>{};
	for (final scout in localScouts) {
		scoutedMatches.add(scout.match);
	}

	// Try to download event scouting data from server
	try {
		final apiClient = await ref.watch(apiClientProvider.future);
		final serverCsv = await apiClient.fetchRaw('/data/$selectedEvent.scouting.csv');

		// Parse server CSV using proper CSV parser that matches JavaScript behavior
		final List<Map<String, dynamic>> scoutingData = csvToArrayOfMaps(serverCsv);

		for (final entry in scoutingData) {
			if (entry.containsKey('match')) {
				final match = entry['match'].toString();
				scoutedMatches.add(match);
			}
		}
	} catch (e) {
		// If download fails, just use local data
		Logger().w('Failed to download event scouting data: $e');
	}

	return scoutedMatches;
});

final scoutListProvider = FutureProvider<List<ScoutData>>((ref) async {
	final db = await ref.watch(databaseProvider.future);
	final selectedEvent = ref.watch(selectedEventProvider);

	if (selectedEvent == null) {
		return [];
	}

	return db.getScoutsForEvent(selectedEvent);
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

// ============================================================================
// MATCH LIST
// ============================================================================

/// Helper provider that ensures selectedEventProvider is loaded
final _ensureSelectedEventProvider = FutureProvider<String?>((ref) async {
	// Keep re-watching until selectedEventProvider is non-null or we've waited enough
	// This gives the async load time to complete
	for (int i = 0; i < 50; i++) {
		final event = ref.watch(selectedEventProvider);
		if (event != null) {
			return event;
		}
		// Wait a bit and retry
		await Future.delayed(const Duration(milliseconds: 10));
	}
	// Even if still null, return what we have
	return ref.watch(selectedEventProvider);
});

final matchListProvider = FutureProvider<List<MatchModel>>((ref) async {
	final apiClient = await ref.watch(apiClientProvider.future);
	// Use the helper provider to ensure event is loaded
	final selectedEvent = await ref.watch(_ensureSelectedEventProvider.future);

	if (selectedEvent == null) {
		return [];
	}

	try {
		// Fetch schedule CSV
		final scheduleUrl = '/data/$selectedEvent.schedule.csv';
		final response = await apiClient.fetchRaw(scheduleUrl);

		// Parse CSV
		final matches = _parseScheduleCSV(response);
		return matches;
	} catch (e) {
		Logger().e('Failed to fetch matches: $e');
		return [];
	}
});

/// Parse schedule CSV into MatchModel list
List<MatchModel> _parseScheduleCSV(String csvContent) {
	final lines = csvContent.trim().split('\n');
	if (lines.isEmpty) return [];

	// Parse header row
	final headers = lines[0].split(',').map((h) => h.trim()).toList();
	final matchIndex = headers.indexOf('Match');

	if (matchIndex == -1) {
		Logger().w('Match column not found in schedule');
		return [];
	}

	// Parse data rows
	final matches = <MatchModel>[];
	for (int i = 1; i < lines.length; i++) {
		final values = lines[i].split(',').map((v) => v.trim()).toList();
		if (values.length <= matchIndex) continue;

		final matchNumber = values[matchIndex];
		final teams = <String, String>{};

		// Extract team numbers for each position
		const positions = ['R1', 'R2', 'R3', 'B1', 'B2', 'B3'];
		for (final pos in positions) {
			final posIndex = headers.indexOf(pos);
			if (posIndex >= 0 && posIndex < values.length) {
				teams[pos] = values[posIndex];
			}
		}

		matches.add(MatchModel(
			matchNumber: matchNumber,
			teams: teams,
		));
	}

	return matches;
}

// CONNECTIVITY (SIMPLIFIED - TODO: Fix)
