import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class _HomeRouter extends ConsumerStatefulWidget {
	const _HomeRouter({Key? key}) : super(key: key);

	@override
	ConsumerState<_HomeRouter> createState() => _HomeRouterState();
}

class _HomeRouterState extends ConsumerState<_HomeRouter> {
	bool _serverConfigured = false;
	bool _eventSelected = false;
	bool _botSelected = false;
	bool _matchSelected = false;
	bool _checking = true;
	EventModel? _selectedEvent;
	String? _selectedMatch;
	String? _selectedTeam;

	@override
	void initState() {
		super.initState();
		_checkServerConfig();
	}

	Future<void> _checkServerConfig() async {
		// Check if server configuration exists
		final db = await ref.read(databaseProvider.future);
		final config = await db.getCurrentConfig();

		if (config?.backendUrl != null && config!.backendUrl.isNotEmpty) {
			setState(() {
				_serverConfigured = true;
			});
			// Now check event selection
			await _checkEventSelection();
		} else {
			setState(() {
				_checking = false;
			});
		}
	}

	Future<void> _checkEventSelection() async {
		// Check if event is selected and date hasn't changed
		final db = await ref.read(databaseProvider.future);
		final config = await db.getCurrentConfig();

		if (config?.selectedEventId != null) {
			final lastChangeDate = config?.lastEventChangeDate;
			final today = DateTime.now();

			// Check if date has changed (day/month/year comparison)
			final dateChanged = lastChangeDate == null ||
					lastChangeDate.year != today.year ||
					lastChangeDate.month != today.month ||
					lastChangeDate.day != today.day;

			if (!dateChanged) {
				// Load the selected event from API to get full details
				try {
					final apiClient = await ref.read(apiClientProvider.future);
					final allEvents = await apiClient.fetchEventList();
					final selectedEvent = allEvents.firstWhere(
						(e) => e.eventId == config!.selectedEventId,
						orElse: () => EventModel(
							eventId: config!.selectedEventId!,
							name: config!.selectedEventId!,
						),
					);
					setState(() {
						_selectedEvent = selectedEvent;
						_eventSelected = true;
						_checking = false;
					});
					return;
				} catch (e) {
					// Event list fetch failed - show server config screen for reconfiguration
					setState(() {
						_serverConfigured = false;
						_checking = false;
					});
					return;
				}
			}
		}

		setState(() {
			_checking = false;
		});
	}

	void _onServerConfigured(String backendUrl) {
		setState(() {
			_serverConfigured = true;
			_checking = true;
		});
		_checkEventSelection();
	}

	@override
	Widget build(BuildContext context) {
		if (_checking) {
			return const Scaffold(
				body: Center(
					child: CircularProgressIndicator(),
				),
			);
		}

		if (!_serverConfigured) {
			return ServerConfigScreen(
				onServerConfigured: _onServerConfigured,
			);
		}

		if (!_eventSelected) {
			return EventPickerScreen(
				onEventSelected: (event) {
					setState(() {
						_selectedEvent = event;
						_eventSelected = true;
						_botSelected = false; // Reset bot selection when changing events
						_matchSelected = false; // Reset match selection when changing events
					});
				},
			);
		}

		if (!_botSelected) {
			return BotSelectionScreen(
				onBotSelected: (bot) {
					ref.read(selectedBotPositionProvider.notifier).setPosition(bot);
					setState(() {
						_botSelected = true;
					});
				},
				onChangeEvent: () {
					setState(() {
						_eventSelected = false;
						_botSelected = false;
						_matchSelected = false;
						_selectedMatch = null;
						_selectedTeam = null;
					});
				},
			);
		}

		if (!_matchSelected) {
			final botPosition = ref.watch(selectedBotPositionProvider);
			return MatchSelectionScreen(
				botPosition: botPosition,
				onMatchSelected: (matchNumber, teamNumber) {
					setState(() {
						_selectedMatch = matchNumber;
						_selectedTeam = teamNumber;
						_matchSelected = true;
					});
				},
				onChangeEvent: () {
					setState(() {
						_eventSelected = false;
						_botSelected = false;
						_matchSelected = false;
						_selectedMatch = null;
						_selectedTeam = null;
					});
				},
				onChangeBotPosition: () {
					setState(() {
						_botSelected = false;
						_matchSelected = false;
						_selectedMatch = null;
						_selectedTeam = null;
					});
				},
			);
		}

		// Show scouting app with selected event, match, and team
		return _selectedEvent != null
				? ScoutingAppScreen(
					selectedEvent: _selectedEvent!,
					prefilledMatch: _selectedMatch,
					prefilledTeam: _selectedTeam,
					onChangeEvent: () {
						setState(() {
							_eventSelected = false;
							_botSelected = false;
							_matchSelected = false;
							_selectedMatch = null;
							_selectedTeam = null;
						});
					},
					onChangeBotPosition: () {
						setState(() {
							_botSelected = false;
							_matchSelected = false;
							_selectedMatch = null;
							_selectedTeam = null;
						});
					},
					onChangeMatch: () {
						setState(() {
							_matchSelected = false;
							_selectedMatch = null;
							_selectedTeam = null;
						});
					},
				)
				: const Scaffold(
					body: Center(
						child: Text('Error loading event'),
					),
					);
	}
}
