import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'server_config_screen.dart';
import 'tabs/pre_match_tab.dart';
import 'tabs/auto_tab.dart';
import 'tabs/teleop_tab.dart';
import 'tabs/end_game_tab.dart';
import '../widgets/viper_menu_button.dart';
import '../../providers/app_providers.dart';
import '../../data/api/viper_api_client.dart';

class ScoutingAppScreen extends ConsumerStatefulWidget {
	final EventModel selectedEvent;
	final String? prefilledMatch;
	final String? prefilledTeam;
	final VoidCallback? onChangeEvent;
	final VoidCallback? onChangeBotPosition;
	final VoidCallback? onChangeMatch;

	const ScoutingAppScreen({
		Key? key,
		required this.selectedEvent,
		this.prefilledMatch,
		this.prefilledTeam,
		this.onChangeEvent,
		this.onChangeBotPosition,
		this.onChangeMatch,
	}) : super(key: key);

	@override
	ConsumerState<ScoutingAppScreen> createState() => _ScoutingAppScreenState();
}

class _ScoutingAppScreenState extends ConsumerState<ScoutingAppScreen> {
	int _selectedTabIndex = 0;
	String? _matchNumber;
	String? _teamNumber;

	late final List<Widget> _tabs;

	@override
	void initState() {
		super.initState();
		// Use prefilled values if provided
		_matchNumber = widget.prefilledMatch;
		_teamNumber = widget.prefilledTeam;

		_tabs = [
			PreMatchTab(
				eventId: widget.selectedEvent.eventId,
				matchNumber: _matchNumber,
				teamNumber: _teamNumber,
			),
			AutoTab(
				eventId: widget.selectedEvent.eventId,
				matchNumber: _matchNumber,
				teamNumber: _teamNumber,
			),
			TeleopTab(
				eventId: widget.selectedEvent.eventId,
				matchNumber: _matchNumber,
				teamNumber: _teamNumber,
			),
			EndGameTab(
				eventId: widget.selectedEvent.eventId,
				matchNumber: _matchNumber,
				teamNumber: _teamNumber,
			),
		];
	}

	@override
	Widget build(BuildContext context) {
		final syncState = ref.watch(syncStateProvider);
		final selectedBot = ref.watch(selectedBotPositionProvider);

		return Scaffold(
			appBar: AppBar(
				title: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					mainAxisSize: MainAxisSize.min,
					children: [
						Text(
							widget.selectedEvent.name,
							style: Theme.of(context).textTheme.titleMedium?.copyWith(
								color: Colors.white,
							),
						),
						if (_matchNumber != null && _teamNumber != null)
							Text(
								'Match $_matchNumber • Team $_teamNumber${selectedBot != null ? ' • Pos: $selectedBot' : ''}',
								style: Theme.of(context).textTheme.labelSmall?.copyWith(
									color: Colors.white70,
								),
							),
					],
				),
				actions: [
					ViperMenuButton(
						onChangeEvent: widget.onChangeEvent,
						onChangeBotPosition: widget.onChangeBotPosition,
						onChangeMatch: widget.onChangeMatch,
						onChangeServer: () {
							Navigator.push(
								context,
								MaterialPageRoute(
									builder: (context) => ServerConfigScreen(
										onServerConfigured: (_) {
											ref.invalidate(apiClientProvider);
											ref.invalidate(eventListProvider);
											Navigator.pop(context);
										},
									),
								),
							);
						},
						onSync: () {
							ref.read(syncStateProvider.notifier).syncScoutData();
						},
						isSyncing: syncState.isSyncing,
						pendingCount: syncState.pendingCount,
					),
					if (syncState.isSyncing)
						const Padding(
							padding: EdgeInsets.all(12),
							child: SizedBox(
								width: 20,
								height: 20,
								child: CircularProgressIndicator(
									strokeWidth: 2,
									valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
								),
							),
						)
					else
						Padding(
							padding: const EdgeInsets.all(12),
							child: Center(
								child: Text(
									syncState.pendingCount > 0
											? '${syncState.pendingCount} pending'
											: 'Synced',
									style: Theme.of(context).textTheme.labelSmall?.copyWith(
										color: syncState.pendingCount > 0
												? Colors.orange
												: Colors.white,
									),
								),
							),
						),
				],
			),
			body: IndexedStack(
				index: _selectedTabIndex,
				children: _tabs,
			),
			bottomNavigationBar: BottomNavigationBar(
				currentIndex: _selectedTabIndex,
				onTap: (index) {
					setState(() => _selectedTabIndex = index);
				},
				type: BottomNavigationBarType.fixed,
				items: const [
					BottomNavigationBarItem(
						icon: Icon(Icons.edit),
						label: 'Pre-Match',
					),
					BottomNavigationBarItem(
						icon: Icon(Icons.flash_on),
						label: 'Auto',
					),
					BottomNavigationBarItem(
						icon: Icon(Icons.videogame_asset),
						label: 'Teleop',
					),
					BottomNavigationBarItem(
						icon: Icon(Icons.trending_up),
						label: 'End Game',
					),
				],
			),
		);
	}
}
