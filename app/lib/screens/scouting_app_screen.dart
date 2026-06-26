import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'server_config_screen.dart';
import 'tabs/pre_match_tab.dart';
import 'tabs/auto_tab.dart';
import 'tabs/teleop_tab.dart';
import 'tabs/end_game_tab.dart';
import '../widgets/viper_menu_button.dart';
import '../providers/app_providers.dart';
import '../providers/locale_provider.dart';
import '../data/api/viper_api_client.dart';
import '../services/localization.dart';

class ScoutingAppScreen extends ConsumerStatefulWidget {
	final EventModel selectedEvent;
	final String? prefilledMatch;
	final String? prefilledTeam;

	const ScoutingAppScreen({
		Key? key,
		required this.selectedEvent,
		this.prefilledMatch,
		this.prefilledTeam,
	}) : super(key: key);

	@override
	ConsumerState<ScoutingAppScreen> createState() => _ScoutingAppScreenState();
}

class _ScoutingAppScreenState extends ConsumerState<ScoutingAppScreen> {
	int _selectedTabIndex = 0;
	String? _matchNumber;
	String? _teamNumber;

	late final List<Widget> _tabs;

	String _translate(String key) {
		final locale = ref.read(selectedLocaleProvider);
		return AppLocalizations.translate(key, locale: locale);
	}

	@override
	void initState() {
		super.initState();
		
		// Register translations on demand when this screen is first loaded
		AppLocalizations.addI18n({
			'pre_match_tab': {
				'en': 'Pre-Match',
				'es': 'Previo al partido',
				'pt': 'Pré-jogo',
				'fr': 'Avant match',
				'zh_tw': '賽前',
				'he': 'לפני המשחק',
				'tr': 'Maç Öncesi',
			},
			'auto_tab': {
				'en': 'Auto',
				'es': 'Auto',
				'pt': 'Auto',
				'fr': 'Auto',
				'zh_tw': '自動',
				'he': 'אוטו',
				'tr': 'Otomatik',
			},
			'teleop_tab': {
				'en': 'Teleop',
				'es': 'Teleoperado',
				'pt': 'Teleoperado',
				'fr': 'Téléopération',
				'zh_tw': '遠程操作',
				'he': 'טלאופ',
				'tr': 'Teleop',
			},
			'end_game_tab': {
				'en': 'End Game',
				'es': 'Final',
				'pt': 'Endgame',
				'fr': 'Fin du match',
				'zh_tw': '賽末',
				'he': 'סיום המשחק',
				'tr': 'Oyun Sonu',
			},
		});
		
		// Use prefilled values if provided
		_matchNumber = widget.prefilledMatch;
		_teamNumber = widget.prefilledTeam;

		_tabs = [
			PreMatchTab(
				eventId: widget.selectedEvent.eventId,
				matchNumber: _matchNumber,
				teamNumber: _teamNumber,
				onProceedToAuto: () {
					setState(() => _selectedTabIndex = 1);
				},
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
		print('[SCREEN_BUILD] ScoutingAppScreen.build() called');
		// Watch locale to trigger rebuild when language changes
		ref.watch(selectedLocaleProvider);
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
				items: [
					BottomNavigationBarItem(
						icon: const Icon(Icons.edit),
						label: _translate('pre_match_tab'),
					),
					BottomNavigationBarItem(
						icon: const Icon(Icons.flash_on),
						label: _translate('auto_tab'),
					),
					BottomNavigationBarItem(
						icon: const Icon(Icons.videogame_asset),
						label: _translate('teleop_tab'),
					),
					BottomNavigationBarItem(
						icon: const Icon(Icons.trending_up),
						label: _translate('end_game_tab'),
					),
				],
			),
		);
	}
}
