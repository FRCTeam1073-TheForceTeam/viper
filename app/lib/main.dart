import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/server_config_screen.dart';
import 'screens/event_picker_screen.dart';
import 'screens/scouting_app_screen.dart';
import 'providers/app_providers.dart';
import 'data/api/viper_api_client.dart';

void main() {
	runApp(
		const ProviderScope(
			child: ViperScoutApp(),
		),
	);
}

class ViperScoutApp extends StatelessWidget {
	const ViperScoutApp({Key? key}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Viper Scout FRC',
			theme: ThemeData(
				useMaterial3: true,
				colorScheme: ColorScheme.fromSeed(
					seedColor: Colors.blue,
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
	bool _checking = true;
	EventModel? _selectedEvent;

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
					});
				},
			);
		}

		// Show scouting app with selected event
		return _selectedEvent != null
				? ScoutingAppScreen(selectedEvent: _selectedEvent!)
				: const Scaffold(
						body: Center(
							child: Text('Error loading event'),
						),
					);
	}
}
