import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' show Value;
import 'screens/server_config_screen.dart';
import 'screens/event_picker_screen.dart';
import 'screens/bot_selection_screen.dart';
import 'screens/match_selection_screen.dart';
import 'screens/scouting_app_screen.dart';
import 'providers/app_providers.dart';
import 'providers/locale_provider.dart';
import 'data/api/viper_api_client.dart';
import 'constants/colors.dart';
import 'services/localization.dart';

late SharedPreferences _sharedPrefs;

/// Helper to validate server URLs
bool _isValidServerUrl(String? url) {
	if (url == null || url.isEmpty) return false;
	// Reject bare protocols or just slashes
	if (url == 'https://' || url == 'http://' || url == '/') return false;
	// URL should have something after the protocol or hostname
	final trimmed = url.trim();
	if (trimmed.isEmpty) return false;
	return true;
}

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	_sharedPrefs = await SharedPreferences.getInstance();

	runApp(
		const ProviderScope(
			child: ViperScoutApp(),
		),
	);
}

class ViperScoutApp extends ConsumerWidget {
	const ViperScoutApp({Key? key}) : super(key: key);

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final locale = ref.watch(selectedLocaleProvider);

		return MaterialApp(
			title: 'Viper Scout FRC',
			debugShowCheckedModeBanner: false,
			locale: locale,
			theme: ThemeData(
				useMaterial3: true,
				scaffoldBackgroundColor: AppColors.mainBgColor,
				colorScheme: ColorScheme.fromSeed(
					seedColor: Colors.blue,
					brightness: Brightness.dark,
					surface: AppColors.mainBgColor,
					onSurface: AppColors.mainFgColor,
					background: AppColors.mainBgColor,
					onBackground: AppColors.mainFgColor,
				),
				textTheme: const TextTheme(
					bodyLarge: TextStyle(color: AppColors.mainFgColor),
					bodyMedium: TextStyle(color: AppColors.mainFgColor),
					bodySmall: TextStyle(color: AppColors.mainFgColor),
					headlineLarge: TextStyle(color: AppColors.mainFgColor),
					headlineMedium: TextStyle(color: AppColors.mainFgColor),
					headlineSmall: TextStyle(color: AppColors.mainFgColor),
					titleLarge: TextStyle(color: AppColors.mainFgColor),
					titleMedium: TextStyle(color: AppColors.mainFgColor),
					titleSmall: TextStyle(color: AppColors.mainFgColor),
					labelLarge: TextStyle(color: AppColors.mainFgColor),
					labelMedium: TextStyle(color: AppColors.mainFgColor),
					labelSmall: TextStyle(color: AppColors.mainFgColor),
					displayLarge: TextStyle(color: AppColors.mainFgColor),
					displayMedium: TextStyle(color: AppColors.mainFgColor),
					displaySmall: TextStyle(color: AppColors.mainFgColor),
				),
				appBarTheme: const AppBarTheme(
					backgroundColor: AppColors.sectionBgColor,
					foregroundColor: AppColors.mainFgColor,
					elevation: 0,
				),
			),
			home: const _HomeRouter(),
		);
	}
}

/// Simple consumer widget that renders based on app state
class _HomeRouter extends ConsumerWidget {
	const _HomeRouter({Key? key}) : super(key: key);

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		// Listen to app state changes and update navigation accordingly
		// IMPORTANT: Only auto-navigate during startup (appInitialized == false)
		// After startup, user controls navigation - app state changes don't force navigation
		ref.listen(appStateProvider, (previous, next) {
			next.whenData((appState) {
				final isInitialized = ref.read(appInitializedProvider);
				print('[HOME_ROUTER] App state listener: $appState (initialized: $isInitialized)');

				// Only auto-navigate during initialization
				if (isInitialized) {
					// After initialization, app state changes don't trigger navigation
					// User controls where they go - respect their choices
					print('[HOME_ROUTER] Already initialized - skipping auto-navigation');
					return;
				}

				// During initialization, navigate based on app state
				bool navigated = false;
				switch (appState) {
					case AppState.checkingConfig:
						// Don't navigate yet
						break;
					case AppState.needsServer:
						print('[HOME_ROUTER] Navigating to server config');
						ref.read(navigationProvider.notifier).navigateTo(NavScreen.server);
						navigated = true;
					case AppState.needsEvent:
						print('[HOME_ROUTER] Navigating to event picker');
						ref.read(navigationProvider.notifier).navigateTo(NavScreen.eventPicker);
						navigated = true;
					case AppState.needsBotSelection:
						print('[HOME_ROUTER] Navigating to bot selection');
						ref.read(navigationProvider.notifier).navigateTo(NavScreen.botSelection);
						navigated = true;
					default:
						print('[HOME_ROUTER] Navigating to match selection (default)');
						ref.read(navigationProvider.notifier).navigateTo(NavScreen.matchSelection);
						navigated = true;
				}

				// Mark initialized once we've determined the initial page to show
				if (navigated) {
					print('[HOME_ROUTER] ✅ Initialization complete - disabling auto-navigation');
					ref.read(appInitializedProvider.notifier).markInitialized();
				}
			});
		});

		// Watch navigation - this is what determines what to show
		final nav = ref.watch(navigationProvider);

		// If we don't have a navigation target yet, that means app is still initializing
		if (nav == null) {
			return const Scaffold(
				body: Center(child: CircularProgressIndicator()),
			);
		}

		print('[HOME_ROUTER] ═══════════════════════════════════════════════════════');
		print('[HOME_ROUTER] Showing screen: $nav');
		print('[HOME_ROUTER] ═══════════════════════════════════════════════════════');

		switch (nav) {
			case NavScreen.server:
				print('[HOME_ROUTER] → Loading: ServerConfigScreen');
				return ServerConfigScreen(
					onServerConfigured: (_) {
						// After server config is saved, navigate directly to event picker
						print('[HOME_ROUTER] Server configured, navigating to event picker');
						// Invalidate eventListProvider to ensure it fetches with new server config
						ref.invalidate(eventListProvider);
						ref.read(navigationProvider.notifier).navigateTo(NavScreen.eventPicker);
					},
				);
			case NavScreen.eventPicker:
				print('[HOME_ROUTER] → Loading: EventPickerScreen');
					return EventPickerScreen(
						onEventSelected: (eventId) {
							// After event selection, navigate directly to bot selection
							print('[HOME_ROUTER] Event selected, navigating to bot selection');
							ref.read(navigationProvider.notifier).navigateTo(NavScreen.botSelection);
						},
					);
			case NavScreen.botSelection:
				print('[HOME_ROUTER] → Loading: BotSelectionScreen');
				return BotSelectionScreen(
					onBotSelected: (bot) {
						ref.read(selectedBotPositionProvider.notifier).setPosition(bot);
						// After bot selection, navigate directly to match selection
						print('[HOME_ROUTER] Bot selected, navigating to match selection');
						ref.read(navigationProvider.notifier).navigateTo(NavScreen.matchSelection);
					},
				);
			case NavScreen.matchSelection:
				print('[HOME_ROUTER] → Loading: MatchSelectionScreen');
				final botPosition = ref.watch(selectedBotPositionProvider);
				return MatchSelectionScreen(
					botPosition: botPosition ?? '',
					onMatchSelected: (matchNumber, teamNumber) {
						ref.read(selectedMatchProvider.notifier).setMatch(matchNumber, teamNumber);
						// After match selection, navigate directly to scouting
						print('[HOME_ROUTER] Match selected, navigating to scouting');
						ref.read(navigationProvider.notifier).navigateTo(NavScreen.scouting);
					},
				);

			case NavScreen.scouting:
				print('[HOME_ROUTER] → Loading: ScoutingAppScreen');
				return FutureBuilder(
					future: _getSelectedEventForScouting(ref),
					builder: (context, snapshot) {
						if (snapshot.connectionState == ConnectionState.waiting) {
							return const Scaffold(body: Center(child: CircularProgressIndicator()));
						}
						if (snapshot.hasError) {
							return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
						}
						if (!snapshot.hasData) {
							return const Scaffold(body: Center(child: Text('No event selected')));
						}
						final event = snapshot.data as EventModel;
						return ScoutingAppScreen(selectedEvent: event);
					},
				);
		}
	}

	/// Fetch the currently selected event from the API
	Future<EventModel> _getSelectedEventForScouting(WidgetRef ref) async {
		final db = await ref.read(databaseProvider.future);
		final config = await db.getCurrentConfig();

		if (config?.selectedEventId == null) {
			throw Exception('No event selected');
		}

		// If no valid server is configured, return event with just the ID
		if (!_isValidServerUrl(config?.backendUrl)) {
			return EventModel(
				eventId: config!.selectedEventId!,
				name: config!.selectedEventId!,
			);
		}

		try {
			final apiClient = await ref.read(apiClientProvider.future);
			final allEvents = await apiClient.fetchEventList();

			final event = allEvents.firstWhere(
				(e) => e.eventId == config!.selectedEventId,
				orElse: () => EventModel(
					eventId: config!.selectedEventId!,
					name: config!.selectedEventId!,
				),
			);

			return event;
		} catch (e) {
			// If fetching events fails, return with just the ID
			return EventModel(
				eventId: config!.selectedEventId!,
				name: config!.selectedEventId!,
			);
		}
	}
}
