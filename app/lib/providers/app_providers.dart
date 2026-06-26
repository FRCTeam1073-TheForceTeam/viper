import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' show Value;
import 'package:logger/logger.dart';
import '../data/database/scout_database.dart';
import '../data/api/viper_api_client.dart';
import '../services/csv_builder.dart';
import '../services/csv_parser.dart';
import '../models/match_model.dart';

// ============================================================================
// APP STATE
// ============================================================================

/// Represents the current state of the app based on persisted data
enum AppState {
	checkingConfig,      // Evaluating what data exists
	needsServer,         // No server configured
	needsEvent,          // Server OK, need event selection
	needsBotSelection,   // Event selected, need bot position
	needsMatchSelection, // Bot selected, need match
	scouting,            // Ready to scout
}

/// Navigation targets that screens can request
enum NavigationTarget {
	server,        // Go to server config screen (reset everything)
	event,         // Go to event picker (reset event, bot, match)
	botSelection,  // Go to bot selection (reset bot, match)
	match,         // Go to match selection (reset match)
}

// ============================================================================
// FORCED NAVIGATION (User explicitly selects a screen from menu)
// ============================================================================

/// When user clicks menu to navigate to a specific screen, or on startup state check
/// HomeRouter will show this screen directly
enum NavScreen {
	server,
	eventPicker,
	botSelection,
	matchSelection,
	scouting,
}

/// Manages navigation to different screens
final navigationProvider = StateNotifierProvider<NavigationNotifier, NavScreen?>((ref) {
	return NavigationNotifier();
});

class NavigationNotifier extends StateNotifier<NavScreen?> {
	NavigationNotifier() : super(null);

	void navigateTo(NavScreen screen) {
		print('[NAVIGATION] User selected: $screen');
		state = screen;
	}

	void clear() {
		print('[NAVIGATION] Cleared navigation');
		state = null;
	}
}

// ============================================================================
// INITIALIZATION TRACKING
// ============================================================================

/// Tracks whether we've passed the server config screen in this session
/// Once set to true, we don't re-check server config availability during navigation
final appInitializedProvider = StateNotifierProvider<_AppInitializedNotifier, bool>((ref) {
	return _AppInitializedNotifier();
});

class _AppInitializedNotifier extends StateNotifier<bool> {
	_AppInitializedNotifier() : super(false);

	void markInitialized() {
		state = true;
		print('[APP_INIT] App marked as initialized - server config check will be skipped on future AppState evaluations');
	}
}

/// Determines the current app state based on persisted database data
/// When called, evaluates the current state and sets forced navigation accordingly
final appStateProvider = FutureProvider<AppState>((ref) async {
	print('[APP_STATE] ═══════════════════════════════════════════════════════');
	print('[APP_STATE] Evaluating app state...');

	final db = await ref.watch(databaseProvider.future);
	final config = await db.getCurrentConfig();

	// ALWAYS check server config first (not just on startup)
	// The user might navigate back to it via the menu
	// Treat empty, null, or invalid URLs (like bare "https://") as not configured
	final isValidServerUrl = _isValidServerUrl(config?.backendUrl);
	if (!isValidServerUrl) {
		print('[APP_STATE] No valid server configured (url: "${config?.backendUrl}") → needsServer');
		print('[APP_STATE] ═══════════════════════════════════════════════════════');
		return AppState.needsServer;
	}

	print('[APP_STATE] Server configured (${config!.backendUrl}), continuing to check other requirements...');
	// Now evaluate post-server state
	final nextState = _evaluatePostServerState(config, ref);

	print('[APP_STATE] Next state: $nextState');
	print('[APP_STATE] ═══════════════════════════════════════════════════════');

	return nextState;
});

/// Check if a server URL is valid (not empty, not just a protocol, etc.)
bool _isValidServerUrl(String? url) {
	if (url == null || url.isEmpty) return false;
	// Reject bare protocols or just slashes
	if (url == 'https://' || url == 'http://' || url == '/') return false;
	// URL should have something after the protocol or hostname
	final trimmed = url.trim();
	if (trimmed.isEmpty) return false;
	return true;
}

/// Helper to evaluate state after server config is confirmed
AppState _evaluatePostServerState(ServerConfigData? config, Ref ref) {
	// Check if event is selected
	if ((config?.selectedEventId?.isNotEmpty ?? false) == false) {
		print('[APP_STATE] No event selected → needsEvent');
		return AppState.needsEvent;
	}

	// Check if bot position is selected
	final botPosition = ref.watch(selectedBotPositionProvider);
	print('[APP_STATE] Bot position: $botPosition (${botPosition == null ? "null" : botPosition.isEmpty ? "empty string" : "set"})');
	if (botPosition == null || botPosition.isEmpty) {
		print('[APP_STATE] No bot position selected → needsBotSelection');
		return AppState.needsBotSelection;
	}

	// Check if match is selected for this session
	final matchSelection = ref.watch(selectedMatchProvider);
	print('[APP_STATE] Match selection: match=${matchSelection.match}, team=${matchSelection.team}');
	if (matchSelection.match == null || matchSelection.team == null) {
		print('[APP_STATE] No match selected → needsMatchSelection');
		return AppState.needsMatchSelection;
	}

	print('[APP_STATE] All prerequisites met → scouting');
	return AppState.scouting;
}

// ============================================================================
// CSV PARSING
// ============================================================================

// CSV parsing utilities are in services/csv_parser.dart

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

	// Validate that we have a proper server URL configured
	final baseUrl = config?.backendUrl;
	if (!_isValidServerUrl(baseUrl)) {
		// Return a no-op client or throw - this shouldn't be called without valid config
		throw Exception('No valid server configured');
	}

	final username = config?.username;
	final password = config?.password;
	return ViperApiClient(
		baseUrl: baseUrl!,
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

/// Track selected match and team for current session
class _MatchSelectionNotifier extends StateNotifier<({String? match, String? team})> {
	_MatchSelectionNotifier() : super((match: null, team: null));

	void setMatch(String matchNumber, String teamNumber) {
		state = (match: matchNumber, team: teamNumber);
	}

	void clear() {
		state = (match: null, team: null);
	}
}

final selectedMatchProvider =
	StateNotifierProvider<_MatchSelectionNotifier, ({String? match, String? team})>((ref) {
	return _MatchSelectionNotifier();
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
	try {
		// First check if we have a valid server configured
		final db = await ref.watch(databaseProvider.future);
		final config = await db.getCurrentConfig();
		if (!_isValidServerUrl(config?.backendUrl)) {
			// No valid server configured, return empty list
			return [];
		}

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
	} catch (e, stack) {
		final logger = Logger();
		logger.e('Error in eventListProvider: $e');
		logger.e('Stack trace: $stack');
		// Return empty list to allow offline/no-server operation
		return [];
	}
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

	// Try to download event scouting data from server (only if valid server configured)
	final config = await db.getCurrentConfig();
	if (_isValidServerUrl(config?.backendUrl)) {
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
			final config = await db.getCurrentConfig();

			// Check if we have a valid server configured
			if (!_isValidServerUrl(config?.backendUrl)) {
				state = state.copyWith(
					isSyncing: false,
					error: 'No server configured. Sync skipped.',
				);
				return;
			}

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
	// First check if we have a valid server configured
	final db = await ref.watch(databaseProvider.future);
	final config = await db.getCurrentConfig();
	if (!_isValidServerUrl(config?.backendUrl)) {
		// No valid server configured, return empty list
		return [];
	}

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

// ============================================================================
// NAVIGATION COMMANDS
// ============================================================================

/// Notifier that handles all navigation state transitions
class _NavigationCommandNotifier extends StateNotifier<NavigationTarget?> {
	final Ref ref;

	_NavigationCommandNotifier(this.ref) : super(null);

	/// Navigate to the specified target - sets forced navigation to display that screen directly
	Future<void> navigateTo(NavigationTarget target) async {
		try {
			print('[NAV_COMMAND] ═══════════════════════════════════════════════════════');
			print('[NAV_COMMAND] Navigation requested: $target');

			// Map NavigationTarget to NavScreen for direct navigation
			switch (target) {
				case NavigationTarget.server:
					print('[NAV_COMMAND] Navigating to ServerConfigScreen');
					ref.read(navigationProvider.notifier).navigateTo(NavScreen.server);

				case NavigationTarget.event:
					print('[NAV_COMMAND] Navigating to EventPickerScreen');
					ref.read(navigationProvider.notifier).navigateTo(NavScreen.eventPicker);

				case NavigationTarget.botSelection:
					print('[NAV_COMMAND] Navigating to BotSelectionScreen');
					ref.read(navigationProvider.notifier).navigateTo(NavScreen.botSelection);

				case NavigationTarget.match:
					print('[NAV_COMMAND] Navigating to MatchSelectionScreen');
					ref.read(navigationProvider.notifier).navigateTo(NavScreen.matchSelection);
			}

			print('[NAV_COMMAND] ═══════════════════════════════════════════════════════');
		} catch (e) {
			print('[NAV_COMMAND] ERROR: $e');
			Logger().e('Navigation error: $e');
		}
	}
}

/// Provider for navigation commands - screens can call this to navigate
final navigationCommandProvider =
	StateNotifierProvider<_NavigationCommandNotifier, NavigationTarget?>((ref) {
	return _NavigationCommandNotifier(ref);
});

// CONNECTIVITY (SIMPLIFIED - TODO: Fix)
