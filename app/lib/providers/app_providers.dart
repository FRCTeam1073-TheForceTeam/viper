import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' show Value;
import 'package:logger/logger.dart';
import 'dart:convert';
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
	upload,        // Go to upload data screen
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
	uploadData,
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
class _AppInitializedNotifier extends StateNotifier<bool> {
	_AppInitializedNotifier() : super(false);

	Future<void> markInitialized() async {
		state = true;
		print('[APP_INIT] ✅ App initialized - auto-navigation disabled for this session');
	}
}

final appInitializedProvider = StateNotifierProvider<_AppInitializedNotifier, bool>((ref) {
	return _AppInitializedNotifier();
});

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

	// Wait for SharedPreferences to load before evaluating post-server state
	// This ensures selectedBotPositionProvider has loaded the persisted bot position
	await ref.watch(sharedPreferencesProvider.future);

	// Restore the selected event from the database if it exists
	if (config.selectedEventId?.isNotEmpty ?? false) {
		print('[APP_STATE] Restoring selected event from database: ${config.selectedEventId}');
		ref.read(selectedEventProvider.notifier).state = config.selectedEventId;
	}

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
		// Don't load here - let setSelectedEvent() manage the state
		// Constructor starts with null, event is set explicitly when user selects one
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

/// Cache key for storing event list CSV in SharedPreferences
const String _eventListCsvCacheKey = 'event_list_csv_cache';

/// Helper to filter and sort events
List<EventModel> _filterAndSortEvents(List<EventModel> events) {
	// Get current year
	final currentYear = DateTime.now().year;

	// Log filtering info
	final logger = Logger();
	logger.i('🎯 EVENT LIST FILTERING:');
	logger.i('   Total events: ${events.length}');
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
}

/// StateNotifier for event list with cache-first synchronous loading
class EventListNotifier extends StateNotifier<List<EventModel>> {
	final Ref ref;
	final Logger _logger = Logger();

	EventListNotifier(this.ref) : super([]) {
		_initializeWithCache();
	}

	Future<void> _initializeWithCache() async {
		try {
			// Load from SharedPreferences synchronously where possible
			final prefs = await ref.watch(sharedPreferencesProvider.future);
			final cachedCsv = prefs.getString(_eventListCsvCacheKey);

			if (cachedCsv != null) {
				try {
					final apiClient = await ref.watch(apiClientProvider.future);
					final events = apiClient.parseEventCsv(cachedCsv);
					state = _filterAndSortEvents(events);
					_logger.i('📦 Initialized with cached events: ${events.length}');

					// Fetch fresh data in background
					_refreshInBackground(prefs);
				} catch (e) {
					_logger.e('Error parsing cached CSV: $e');
				}
			} else {
				// No cache, fetch from server
				_refreshInBackground(prefs);
			}
		} catch (e) {
			_logger.e('Error initializing event list: $e');
		}
	}

	Future<void> _refreshInBackground(SharedPreferences prefs) async {
		try {
			final apiClient = await ref.watch(apiClientProvider.future);
			final freshCsv = await apiClient.fetchEventListCsv();
			if (freshCsv != null) {
				await prefs.setString(_eventListCsvCacheKey, freshCsv);
				final events = apiClient.parseEventCsv(freshCsv);
				state = _filterAndSortEvents(events);
				_logger.i('✅ Updated event list from server: ${events.length}');
			}
		} catch (e) {
			_logger.e('Background refresh failed: $e');
		}
	}

	Future<void> refresh() async {
		try {
			final prefs = await ref.watch(sharedPreferencesProvider.future);
			await _refreshInBackground(prefs);
		} catch (e) {
			_logger.e('Manual refresh failed: $e');
		}
	}
}

final eventListProvider = StateNotifierProvider((ref) => EventListNotifier(ref));

// ============================================================================
// PIT SCOUTING DATA (fuel capacity, etc.)
// ============================================================================

final pitScoutingDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
	try {
		final db = await ref.watch(databaseProvider.future);
		final selectedEvent = ref.watch(selectedEventProvider);

		// If no event selected, return empty map
		if (selectedEvent == null) {
			return {};
		}

		final dbConfig = await db.getCurrentConfig();
		if (!_isValidServerUrl(dbConfig?.backendUrl)) {
			// No valid server configured, try to load from cache
			final prefs = await ref.watch(sharedPreferencesProvider.future);
			final cacheKey = 'pit_scouting_data_cache_$selectedEvent';
			final cachedJson = prefs.getString(cacheKey);
			if (cachedJson != null) {
				Logger().i('📦 Loading cached pit scouting data (no server configured)');
				try {
					final jsonData = jsonDecode(cachedJson) as Map<String, dynamic>;
					return jsonData;
				} catch (e) {
					Logger().e('Error decoding cached pit scouting data: $e');
				}
			}
			return {};
		}

		final logger = Logger();
		final apiClient = await ref.watch(apiClientProvider.future);
		final prefs = await ref.watch(sharedPreferencesProvider.future);
		final cacheKey = 'pit_scouting_data_cache_$selectedEvent';

		// Try to load from cache first to show immediately
		Map<String, dynamic>? cachedData;
		final cachedJson = prefs.getString(cacheKey);
		if (cachedJson != null) {
			logger.i('📦 Loading cached pit scouting data for event: $selectedEvent');
			try {
				cachedData = jsonDecode(cachedJson) as Map<String, dynamic>;
			} catch (e) {
				logger.w('Error decoding cached pit scouting data: $e');
			}
		}

		// Fetch fresh data from server
		try {
			final freshData = await apiClient.fetchPitScoutingData(selectedEvent);

			if (freshData.isNotEmpty) {
				// Cache the fresh data as JSON
				try {
					await prefs.setString(cacheKey, jsonEncode(freshData));
					logger.i('💾 Pit scouting data cached for ${freshData.length} teams');
				} catch (e) {
					logger.w('Could not cache pit scouting data: $e');
				}
				logger.i('✅ Fresh pit scouting data loaded for ${freshData.length} teams');
				return freshData;
			} else if (cachedData != null && cachedData.isNotEmpty) {
				// Server returned empty, use cache
				logger.i('⚠️  Server returned no pit scouting data, using cache');
				return cachedData;
			}
		} catch (e) {
			logger.w('Failed to fetch pit scouting data: $e');
			if (cachedData != null && cachedData.isNotEmpty) {
				logger.i('⚠️  Server fetch failed, using cached pit scouting data');
				return cachedData;
			}
		}

		return cachedData ?? {};
	} catch (e) {
		Logger().e('Error in pitScoutingDataProvider: $e');
		return {};
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

	// Always include local scouting data from upload history
	// (actual scout data is in-memory via providers, not persisted in database)
	final localMatches = <String>{};
	// TODO: Could read from upload history if needed to show previously scouted matches

	// Try to get server scouting data (if valid server configured)
	final config = await db.getCurrentConfig();
	if (!_isValidServerUrl(config?.backendUrl)) {
		return localMatches;
	}

	final cacheKey = 'scouting_csv_cache_$selectedEvent';
	final sharedPrefs = await ref.watch(sharedPreferencesProvider.future);

	// Load cached data first to show immediately
	Set<String> serverMatches = {};
	final cachedCsv = sharedPrefs.getString(cacheKey);
	if (cachedCsv != null) {
		try {
			final List<Map<String, dynamic>> scoutingData = csvToArrayOfMaps(cachedCsv);
			for (final entry in scoutingData) {
				if (entry.containsKey('match')) {
					serverMatches.add(entry['match'].toString());
				}
			}
		} catch (e) {
			Logger().w('Failed to parse cached scouting CSV: $e');
		}
	}

	// Fetch fresh data from server
	try {
		final apiClient = await ref.watch(apiClientProvider.future);
		final serverCsv = await apiClient.fetchScoutingCsv(selectedEvent);

		if (serverCsv != null && serverCsv.isNotEmpty) {
			// Cache the fresh CSV
			await sharedPrefs.setString(cacheKey, serverCsv);

			// Parse fresh data (replaces cached)
			final List<Map<String, dynamic>> scoutingData = csvToArrayOfMaps(serverCsv);
			serverMatches.clear();
			for (final entry in scoutingData) {
				if (entry.containsKey('match')) {
					serverMatches.add(entry['match'].toString());
				}
			}
		}
	} catch (e) {
		// If download fails, keep cached/empty server matches
		Logger().w('Failed to download event scouting data: $e');
	}

	// Combine server matches (fresh or cached) with local matches
	return {...localMatches, ...serverMatches};
});

// Scout list providers removed - all scouting data now stored in-memory via providers
// (scoutProvider, timelineProvider, endGameProvider, etc.)
// Database no longer has scout table - see scout_data.dart for in-memory model

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
			// Get pending upload history entries (CSV data pre-built at upload time)
			final pendingHistory = await db.getPendingUploadHistory();

			if (pendingHistory.isEmpty) {
				state = state.copyWith(
					isSyncing: false,
					lastSyncTime: DateTime.now(),
				);
				return;
			}

			// Upload each pending entry to backend
			List<int> uploadedIds = [];
			for (final entry in pendingHistory) {
				try {
					await apiClient.uploadScoutData(entry.csvData);
					uploadedIds.add(entry.id);
				} catch (e) {
					Logger().w('Failed to upload scout entry ${entry.id}: $e');
				}
			}

			// Mark uploaded entries as synced
			if (uploadedIds.isNotEmpty) {
				await db.markHistoryAsUploaded(uploadedIds);
			}

			state = state.copyWith(
				isSyncing: false,
				lastSyncTime: DateTime.now(),
				pendingCount: pendingHistory.length - uploadedIds.length,
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
// UPLOAD PAGE STATE
// ============================================================================

class UploadPageState {
	final List<UploadHistoryData> readyToUpload;    // First 10 pending
	final List<UploadHistoryData> uploadLater;       // Remaining pending
	final List<UploadHistoryData> history;           // Uploaded + failed
	final bool isUploading;
	final String? error;
	final DateTime? lastUploadTime;

	static const _unspecified = Object();

	UploadPageState({
		this.readyToUpload = const [],
		this.uploadLater = const [],
		this.history = const [],
		this.isUploading = false,
		this.error,
		this.lastUploadTime,
	});

	UploadPageState copyWith({
		List<UploadHistoryData>? readyToUpload,
		List<UploadHistoryData>? uploadLater,
		List<UploadHistoryData>? history,
		bool? isUploading,
		Object? error = _unspecified,
		DateTime? lastUploadTime,
	}) {
		return UploadPageState(
			readyToUpload: readyToUpload ?? this.readyToUpload,
			uploadLater: uploadLater ?? this.uploadLater,
			history: history ?? this.history,
			isUploading: isUploading ?? this.isUploading,
			error: error == _unspecified ? this.error : error as String?,
			lastUploadTime: lastUploadTime ?? this.lastUploadTime,
		);
	}
}

final uploadPageStateProvider = StateNotifierProvider<UploadPageStateNotifier, UploadPageState>((ref) {
	return UploadPageStateNotifier(ref);
});

class UploadPageStateNotifier extends StateNotifier<UploadPageState> {
	final Ref ref;
	static const int BATCH_SIZE = 10;

	UploadPageStateNotifier(this.ref) : super(UploadPageState());

	/// Initialize upload page - clean up old history and load current data
	Future<void> initializeUploadPage() async {
		try {
			print('[UPLOAD_STATE] Initializing upload page...');
			final db = await ref.read(databaseProvider.future);

			// Clean up uploaded history older than 18 days
			print('[UPLOAD_STATE] Cleaning up history older than 18 days');
			await db.deleteOldUploadedHistory(daysOld: 18);

			// Load current data
			await _loadUploadData();
			print('[UPLOAD_STATE] Upload page initialized successfully');
		} catch (e) {
			print('[UPLOAD_STATE] Error initializing upload page: $e');
			state = state.copyWith(error: 'Failed to initialize upload page: $e');
		}
	}

	/// Reload upload data from database
	Future<void> _loadUploadData() async {
		try {
			print('[UPLOAD_STATE] Loading upload data...');
			final db = await ref.read(databaseProvider.future);

			// Get all pending entries
			final allPending = await db.getAllPendingUploadHistory();
			print('[UPLOAD_STATE] Found ${allPending.length} pending entries');

			// Split into ready (first 10) and later (rest)
			final readyToUpload = allPending.length > BATCH_SIZE
					? allPending.sublist(0, BATCH_SIZE)
					: allPending;
			final uploadLater = allPending.length > BATCH_SIZE
					? allPending.sublist(BATCH_SIZE)
				: <UploadHistoryData>[];

			print('[UPLOAD_STATE] Ready to upload: ${readyToUpload.length}, Upload later: ${uploadLater.length}');

			// Get history (uploaded + failed)
			final uploaded = await db.getUploadHistoryByStatus('uploaded');
			final failed = await db.getUploadHistoryByStatus('failed');
			final history = [...uploaded, ...failed];

			print('[UPLOAD_STATE] History: ${history.length} entries');

			state = state.copyWith(
				readyToUpload: readyToUpload,
				uploadLater: uploadLater,
				history: history,
				error: null,
			);
			print('[UPLOAD_STATE] State updated successfully');
		} catch (e) {
			print('[UPLOAD_STATE] Error loading upload data: $e');
			state = state.copyWith(error: 'Failed to load upload data: $e');
		}
	}

	/// Upload all items in ready-to-upload section
	Future<void> uploadReadyEntries() async {
		if (state.readyToUpload.isEmpty) {
			state = state.copyWith(error: 'No entries to upload');
			return;
		}

		state = state.copyWith(isUploading: true, error: null);

		try {
			final db = await ref.read(databaseProvider.future);
			final config = await db.getCurrentConfig();

			// Check if we have a valid server configured
			if (!_isValidServerUrl(config?.backendUrl)) {
				state = state.copyWith(
					isUploading: false,
					error: 'No server configured',
				);
				return;
			}

			final apiClient = await ref.read(apiClientProvider.future);

			// Parse CSV entries and rebuild combined CSV using buildScoutCsv
			// This ensures all records have consistent columns
			final scoutDataMaps = <Map<String, dynamic>>[];

			for (var entry in state.readyToUpload) {
				final headers = entry.csvHeaders.split(',');
				final values = entry.csvData.split(',');

				// Create a map for this record, pairing headers with values
				final recordMap = <String, dynamic>{};
				for (int i = 0; i < headers.length && i < values.length; i++) {
					recordMap[headers[i].trim()] = values[i].trim();
				}
				scoutDataMaps.add(recordMap);
			}

			if (scoutDataMaps.isEmpty) {
				state = state.copyWith(isUploading: false);
				return;
			}

			// Build combined CSV with all records, ensuring consistent column structure
			final csvContent = CsvBuilder.buildScoutCsv(scoutDataMaps);

			// Upload to backend
			await apiClient.uploadScoutData(csvContent);

			// Mark as uploaded
			final ids = state.readyToUpload.map((e) => e.id).toList();
			await db.markHistoryAsUploaded(ids);

			// Reload data - next batch should move to ready
			await _loadUploadData();

			state = state.copyWith(
				isUploading: false,
				lastUploadTime: DateTime.now(),
				error: null,
			);
		} catch (e) {
			state = state.copyWith(
				isUploading: false,
				error: 'Upload failed: $e',
			);
		}
	}

	/// Delete an entry
	Future<void> deleteEntry(int id) async {
		try {
			final db = await ref.read(databaseProvider.future);
			await db.deleteHistoryEntry(id);
			await _loadUploadData();
		} catch (e) {
			state = state.copyWith(error: 'Failed to delete entry: $e');
		}
	}

	/// Mark an uploaded entry for reupload
	Future<void> reuploadEntry(int id) async {
		try {
			final db = await ref.read(databaseProvider.future);
			await db.markHistoryForReupload(id);
			await _loadUploadData();
		} catch (e) {
			state = state.copyWith(error: 'Failed to mark for reupload: $e');
		}
	}

	/// Clear all history
	Future<void> clearAllHistory() async {
		try {
			final db = await ref.read(databaseProvider.future);
			// Only clear uploaded and failed, not pending
			for (var entry in state.history) {
				await db.deleteHistoryEntry(entry.id);
			}
			await _loadUploadData();
		} catch (e) {
			state = state.copyWith(error: 'Failed to clear history: $e');
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
			print('[ENSURE_SELECTED_EVENT] Found event on retry $i: $event');
			return event;
		}
		// Wait a bit and retry
		await Future.delayed(const Duration(milliseconds: 10));
	}
	// Even if still null, return what we have
	final finalEvent = ref.watch(selectedEventProvider);
	print('[ENSURE_SELECTED_EVENT] Final result after 50 retries: $finalEvent');
	return finalEvent;
});

final matchListProvider = FutureProvider<List<MatchModel>>((ref) async {
	// First check if we have a valid server configured
	final db = await ref.watch(databaseProvider.future);
	final config = await db.getCurrentConfig();
	print('[MATCH_LIST] Config: backendUrl=${config?.backendUrl}');
	if (!_isValidServerUrl(config?.backendUrl)) {
		// No valid server configured, return empty list
		print('[MATCH_LIST] No valid server configured, returning empty list');
		return [];
	}

	final apiClient = await ref.watch(apiClientProvider.future);
	// Use the helper provider to ensure event is loaded
	final selectedEvent = await ref.watch(_ensureSelectedEventProvider.future);
	print('[MATCH_LIST] Selected event: $selectedEvent');

	if (selectedEvent == null) {
		print('[MATCH_LIST] No event selected, returning empty list');
		return [];
	}

	try {
		final logger = Logger();
		final prefs = await ref.watch(sharedPreferencesProvider.future);

		// Create cache key specific to this event
		final cacheKey = 'match_list_csv_cache_$selectedEvent';

		// Try to load from cache first to show immediately
		List<MatchModel>? cachedMatches;
		final cachedCsv = prefs.getString(cacheKey);
		if (cachedCsv != null) {
			print('[MATCH_LIST] 📦 Loading cached match schedule for event: $selectedEvent');
			logger.i('📦 Loading cached match schedule for event: $selectedEvent');
			cachedMatches = _parseScheduleCSV(cachedCsv);
			print('[MATCH_LIST] 📦 Cached matches loaded: ${cachedMatches.length} matches');
			logger.i('📦 Cached matches loaded: ${cachedMatches.length} matches');
		}

		// Fetch fresh data from server
		print('[MATCH_LIST] 📡 Fetching fresh match schedule from server for event: $selectedEvent');
		logger.i('📡 Fetching fresh match schedule from server');
		final scheduleUrl = '/data/$selectedEvent.schedule.csv';
		final freshCsv = await apiClient.fetchMatchScheduleCsv(selectedEvent);
		print('[MATCH_LIST] Fresh CSV response: ${freshCsv?.length ?? 0} bytes');

		if (freshCsv != null && freshCsv.isNotEmpty) {
			// Save to cache
			await prefs.setString(cacheKey, freshCsv);
			print('[MATCH_LIST] 💾 Match schedule cached for event: $selectedEvent');
			logger.i('💾 Match schedule cached for event: $selectedEvent');

			// Parse fresh data
			final freshMatches = _parseScheduleCSV(freshCsv);
			print('[MATCH_LIST] ✅ Fresh match schedule: ${freshMatches.length} matches');
			logger.i('✅ Fresh match schedule: ${freshMatches.length} matches');
			return freshMatches;
		} else if (cachedMatches != null && cachedMatches.isNotEmpty) {
			// Server fetch failed, use cache
			print('[MATCH_LIST] ⚠️  Server fetch failed, using cached match schedule');
			logger.i('⚠️  Server fetch failed, using cached match schedule');
			return cachedMatches;
		} else {
			// No fresh data and no cache
			print('[MATCH_LIST] ❌ Failed to fetch matches and no cache available');
			logger.w('❌ Failed to fetch matches and no cache available');
			return [];
		}
	} catch (e) {
		print('[MATCH_LIST] Error fetching matches: $e');
		Logger().e('Failed to fetch matches: $e');
		// Try to fall back to cache
		try {
			final prefs = await ref.watch(sharedPreferencesProvider.future);
			final selectedEvent = await ref.watch(_ensureSelectedEventProvider.future);
			if (selectedEvent != null) {
				final cacheKey = 'match_list_csv_cache_$selectedEvent';
				final cachedCsv = prefs.getString(cacheKey);
				if (cachedCsv != null) {
					Logger().i('⚠️  Using cached match schedule as fallback');
					return _parseScheduleCSV(cachedCsv);
				}
			}
		} catch (cacheError) {
			Logger().e('Cache fallback failed: $cacheError');
		}
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

				case NavigationTarget.upload:
					print('[NAV_COMMAND] Navigating to UploadDataScreen');
					ref.read(navigationProvider.notifier).navigateTo(NavScreen.uploadData);
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

// ============================================================================
// SELECTED TAB INDEX
// ============================================================================

/// Manages the selected tab index (in-memory only, survives hot reload but not restarts)
class _SelectedTabNotifier extends StateNotifier<int> {
	_SelectedTabNotifier() : super(0);

	void setTabIndex(int index) {
		state = index;
	}
}

/// Provider for selected tab index - persists across hot reload only
final selectedTabIndexProvider =
	StateNotifierProvider<_SelectedTabNotifier, int>((ref) {
	return _SelectedTabNotifier();
});

// ============================================================================
// SCOUTING SESSION TIMESTAMPS
// ============================================================================

/// Tracks the original created timestamp from loaded data (if re-scouting)
class _OriginalCreatedTimestampNotifier extends StateNotifier<String?> {
	_OriginalCreatedTimestampNotifier() : super(null);

	void setFromExistingData(String createdTime) {
		state = createdTime;
	}

	void clear() {
		state = null;
	}
}

final originalCreatedProvider =
	StateNotifierProvider<_OriginalCreatedTimestampNotifier, String?>((ref) {
	return _OriginalCreatedTimestampNotifier();
});

/// Tracks when the current scouting session started (when auto tab was first loaded)
class _ScoutingSessionTimestampNotifier extends StateNotifier<String?> {
	_ScoutingSessionTimestampNotifier() : super(null);

	void initializeNewSession() {
		state = DateTime.now().toIso8601String();
	}

	void clear() {
		state = null;
	}
}

final scoutingSessionCreatedProvider =
	StateNotifierProvider<_ScoutingSessionTimestampNotifier, String?>((ref) {
	return _ScoutingSessionTimestampNotifier();
});

// ============================================================================
// LOAD EXISTING SCOUT DATA
// ============================================================================

/// Provider that loads existing scout data for the selected match when it changes
final existingScoutDataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
	print('[PROVIDER_EXEC] existingScoutDataProvider started');
	final selectedMatch = ref.watch(selectedMatchProvider);
	final selectedEvent = ref.watch(selectedEventProvider);

	print('[PROVIDER_EXEC] selectedEvent=$selectedEvent, match=${selectedMatch.match}, team=${selectedMatch.team}');

	if (selectedMatch.match == null || selectedMatch.team == null || selectedEvent == null) {
		print('[PROVIDER_EXEC] Missing parameters, returning null');
		return null;
	}

	print('[SCOUT_LOAD] existingScoutDataProvider starting for event=$selectedEvent, match=${selectedMatch.match}, team=${selectedMatch.team}');

	try {
		final db = await ref.watch(databaseProvider.future);
		print('[SCOUT_LOAD] Database ready, calling getMatchData()...');
		var data = await db.getMatchData(selectedEvent, selectedMatch.match!, selectedMatch.team!);
		print('[SCOUT_LOAD] getMatchData returned: ${data != null ? "DATA FOUND" : "null"}');
		if (data != null) {
			print('[SCOUT_LOAD] 📦 Using local data (not from cache)');
			final csv = data.csvHeaders + '\n' + data.csvData;
			final parsed = csvToArrayOfMaps(csv);
			print('[SCOUT_LOAD] Parsed local data: ${parsed.isNotEmpty ? parsed.first.toString() : "EMPTY"}');
			return parsed.isNotEmpty ? parsed.first : null;
		}

		// If no local data, try to fetch from server CSV cache
		if (data == null) {
			print('[SCOUT_LOAD] No local data, checking server CSV cache...');
			final sharedPrefs = await ref.watch(sharedPreferencesProvider.future);
			final cacheKey = 'scouting_csv_cache_$selectedEvent';
			final cachedCsv = sharedPrefs.getString(cacheKey);
			print('[SCOUT_LOAD] DEBUG: cachedCsv = ${cachedCsv != null ? "LENGTH=${cachedCsv.length}" : "NULL"}');

			if (cachedCsv != null && cachedCsv.isNotEmpty) {
				print('[SCOUT_LOAD] ENTERING CSV PARSE BLOCK');
				print('[SCOUT_LOAD] DEBUG: Entering CSV cache block, cachedCsv length = ${cachedCsv.length}');
				try {
					print('[SCOUT_LOAD] Found server CSV in cache (${cachedCsv.length} chars), parsing...');
					final List<Map<String, dynamic>> scoutingData = csvToArrayOfMaps(cachedCsv);
					print('[SCOUT_LOAD] ✅ CSV parsed successfully: ${scoutingData.length} entries');

					if (scoutingData.isEmpty) {
						print('[SCOUT_LOAD] CSV is empty after parsing!');
						return null;
					}

					print('[SCOUT_LOAD] Searching for match=${selectedMatch.match}, team=${selectedMatch.team}');
					// Find matching entry in server CSV
					for (final entry in scoutingData) {
						final csvMatch = entry['match']?.toString();
						final csvTeam = entry['team']?.toString();
						if (csvMatch == selectedMatch.match && csvTeam == selectedMatch.team) {
							print('[SCOUT_LOAD] ✅ FOUND match in CSV!');
							return entry;
						}
					}
					print('[SCOUT_LOAD] ✗ Match not found in CSV entries');
				} catch (e, st) {
					print('[SCOUT_LOAD] ❌ ERROR in CSV parsing: $e');
					print('[SCOUT_LOAD] Stack: $st');
				}
			} else {
				print('[SCOUT_LOAD] ❌ No CSV cache or empty');
			}
		}

		if (data == null) {
			print('[SCOUT_LOAD] No data found locally or on server');
			return null;
		}

		// Parse using csvToArrayOfMaps which handles unescaping
		// Create a mini CSV with headers + single data row
		final csv = data.csvHeaders + '\n' + data.csvData;
		final parsed = csvToArrayOfMaps(csv);

		if (parsed.isEmpty) {
			return null;
		}

		return parsed.first;
	} catch (e) {
		Logger().e('Error loading existing scout data: $e');
		return null;
	}
});

// CONNECTIVITY (SIMPLIFIED - TODO: Fix)
