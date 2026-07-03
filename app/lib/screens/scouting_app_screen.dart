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
import '../providers/match_timer_provider.dart';
import '../providers/pre_match_provider.dart';
import '../providers/auto_tab_controller.dart';
import '../providers/tele_tab_controller.dart';
import '../providers/end_game_provider.dart';
import '../providers/timeline_provider.dart';
import '../data/api/viper_api_client.dart';
import '../services/localization.dart';
import '../widgets/match_timer.dart';
import '../constants/colors.dart';

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

class _ScoutingAppScreenState extends ConsumerState<ScoutingAppScreen> with TickerProviderStateMixin {
	String? _matchNumber;
	String? _teamNumber;
	late TabController _tabController;
	DateTime? _matchStartTime;
	String? _lastLoadedMatchKey;

	String _translate(String key) {
		final locale = ref.read(selectedLocaleProvider);
		return AppLocalizations.translate(key, locale: locale);
	}

	Widget _buildStyledTab(String labelKey) {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 12),
			child: Tab(text: _translate(labelKey)),
		);
	}

	@override
	void initState() {
		super.initState();

		// Get initial tab index from provider
		final initialTabIndex = ref.read(selectedTabIndexProvider);

		// Initialize TabController with 4 tabs
		_tabController = TabController(length: 4, vsync: this, initialIndex: initialTabIndex);

		// Listen for tab changes and save to provider
		_tabController.addListener(() {
			ref.read(selectedTabIndexProvider.notifier).setTabIndex(_tabController.index);
		});

		// Register translations on demand when this screen is first loaded
		AppLocalizations.addI18n({
			'pre_match_tab': {
				'en': 'Pre',
				'es': 'Previo',
				'pt': 'Pré',
				'fr': 'Avant',
				'zh_tw': '賽前',
				'he': 'לפני',
				'tr': 'Öncesi',
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
			'tele_tab': {
				'en': 'Tele',
				'es': 'Tele',
				'pt': 'Tele',
				'fr': 'Tele',
				'zh_tw': '遠程',
				'he': 'טלה',
				'tr': 'Tele',
			},
			'end_game_tab': {
				'en': 'End',
				'es': 'Final',
				'pt': 'Fim',
				'fr': 'Fin',
				'zh_tw': '結束',
				'he': 'סוף',
				'tr': 'Son',
			},
		});

		// Use prefilled values if provided
		_matchNumber = widget.prefilledMatch;
		_teamNumber = widget.prefilledTeam;
	}

	@override
	void dispose() {
		_tabController.dispose();
		super.dispose();
	}

	Widget _buildTabContent(WidgetRef ref, int tabIndex) {
		final botPosition = ref.watch(selectedBotPositionProvider);
		final selectedMatch = ref.watch(selectedMatchProvider);

		switch (tabIndex) {
			case 0:
				return PreMatchTab(
					eventId: widget.selectedEvent.eventId,
					eventName: widget.selectedEvent.name,
					botPosition: botPosition,
					matchNumber: selectedMatch.match,
					teamNumber: selectedMatch.team,
					onProceedToAuto: () {
						_tabController.animateTo(1);
					},
				);
			case 1:
				return AutoTab(
					eventId: widget.selectedEvent.eventId,
					matchNumber: selectedMatch.match,
					teamNumber: selectedMatch.team,
					matchStartTime: _matchStartTime,
					onStartMatch: (startTime) {
						setState(() => _matchStartTime = startTime);
						// Also set the shared match timer provider
						ref.read(matchTimerProvider.notifier).setStartTime(startTime);
					},
				);
			case 2:
				return TeleopTab(
					eventId: widget.selectedEvent.eventId,
					matchNumber: selectedMatch.match,
					teamNumber: selectedMatch.team,
				);
			case 3:
				return EndGameTab(
					eventId: widget.selectedEvent.eventId,
					matchNumber: selectedMatch.match,
					teamNumber: selectedMatch.team,
					onNextMatch: () {
						_tabController.animateTo(0);
					},
				);
			default:
				return const SizedBox();
		}
	}

	@override
	Widget build(BuildContext context) {
		print('[SCREEN_BUILD] ScoutingAppScreen.build() called');
		// Watch locale to trigger rebuild when language changes
		ref.watch(selectedLocaleProvider);
		final syncState = ref.watch(syncStateProvider);
		final selectedBot = ref.watch(selectedBotPositionProvider);
		final selectedTabIndex = ref.watch(selectedTabIndexProvider);

		// Load existing scout data when match changes
		final selectedMatch = ref.watch(selectedMatchProvider);
		final selectedEvent = ref.watch(selectedEventProvider);
		print('[SCREEN_BUILD] Watching existingScoutDataProvider, selectedEvent=$selectedEvent, selectedMatch=${selectedMatch.match}');
		final existingData = ref.watch(existingScoutDataProvider);
		final currentMatchKey = '${selectedEvent}_${selectedMatch.match}_${selectedMatch.team}';
		print('[SCREEN_BUILD] currentMatchKey=$currentMatchKey, existingData=${existingData.when(data: (d) => d != null ? "HAS DATA" : "NULL", loading: () => "LOADING", error: (e, st) => "ERROR")}');

		// Only load data if we're loading a different match than before
		if (currentMatchKey != _lastLoadedMatchKey) {
			_lastLoadedMatchKey = currentMatchKey;
			// Invalidate the provider to force it to re-execute with new match parameters
			print('[SCREEN_BUILD] Match changed, invalidating existingScoutDataProvider');
			ref.invalidate(existingScoutDataProvider);
			// Re-watch the provider to get the fresh data
			final freshData = ref.watch(existingScoutDataProvider);
			freshData.whenData((data) {
				if (data != null) {
					print('[SCOUT_LOAD] ✅ Existing data found, loading providers...');
					// Delay provider modification until after widget tree is built
					WidgetsBinding.instance.addPostFrameCallback((_) {
						// Preserve original created timestamp from previous scouting session
						if (data['created'] != null) {
							print('[SCOUT_LOAD] Setting original created time: ${data['created']}');
							ref.read(originalCreatedProvider.notifier).setFromExistingData(data['created'] as String);
						}
						// Initialize session start time to now
						ref.read(scoutingSessionCreatedProvider.notifier).initializeNewSession();

						// Load all scouting data providers
						print('[SCOUT_LOAD] Loading pre-match data...');
						ref.read(preMatchProvider.notifier).loadFromData(data);

						print('[SCOUT_LOAD] Loading auto tab data...');
						ref.read(autoTabControllerProvider.notifier).loadFromData(data, isFirstLoad: true);

						print('[SCOUT_LOAD] Loading tele tab data...');
						ref.read(teleTabControllerProvider.notifier).loadFromData(data, isFirstLoad: true);

						print('[SCOUT_LOAD] Loading end-game data...');
						ref.read(endGameProvider.notifier).loadFromData(data);

						// Load timeline and set match timer to last event's timestamp
						print('[SCOUT_LOAD] Loading timeline...');
						if (data['timeline'] != null && (data['timeline'] as String).isNotEmpty) {
							final timelineEvents = TimelineEvent.parseTimeline(data['timeline'] as String);
							print('[SCOUT_LOAD] Loaded ${timelineEvents.length} timeline events into provider');
							ref.read(timelineProvider.notifier).setTimeline(timelineEvents);

							if (timelineEvents.isNotEmpty) {
								final lastEventSeconds = timelineEvents.last.timeSeconds;
								print('[SCOUT_LOAD] Timeline last event at ${lastEventSeconds}s, setting match timer...');
								// Calculate when the match should have started to reach this time
								final matchStartTime = DateTime.now().subtract(Duration(seconds: lastEventSeconds));
								ref.read(matchTimerProvider.notifier).setStartTime(matchStartTime);
							}
						} else {
							print('[SCOUT_LOAD] No timeline data in CSV');
						}
						print('[SCOUT_LOAD] ✅ All data loaded successfully');
					});
				} else {
					print('[SCOUT_LOAD] ✅ No existing data found, starting fresh');
					// No existing data - initialize a new session and reset all scouting data
					WidgetsBinding.instance.addPostFrameCallback((_) {
						print('[SCOUT_LOAD] Resetting all providers for fresh scouting session');
						ref.read(originalCreatedProvider.notifier).clear();
						ref.read(scoutingSessionCreatedProvider.notifier).initializeNewSession();
						ref.read(preMatchProvider.notifier).reset();
						ref.read(autoTabControllerProvider.notifier).reset();
						ref.read(teleTabControllerProvider.notifier).reset();
						ref.read(endGameProvider.notifier).reset();
						// Navigate to pre-match tab
						print('[SCOUT_LOAD] Navigating to pre-match tab');
						_tabController.animateTo(0);
					});
				}
			});
		}

		// Watch matchTimerProvider to get shared match start time
		final matchStartTime = ref.watch(matchTimerProvider);
		if (matchStartTime != _matchStartTime) {
			WidgetsBinding.instance.addPostFrameCallback((_) {
				if (mounted) {
					setState(() => _matchStartTime = matchStartTime);
				}
			});
		}

		final isBlueTeam = selectedBot?.startsWith('B') ?? false;
		final teamColor = isBlueTeam ? AppColors.blueTeamColor : AppColors.redTeamColor;

		return DefaultTabController(
			length: 4,
			initialIndex: selectedTabIndex,
			child: Scaffold(
				body: CustomScrollView(
					slivers: [
						SliverAppBar(
							backgroundColor: AppColors.mainBgColor,
							elevation: 0,
							floating: true,
							snap: true,
							toolbarHeight: 0,
							automaticallyImplyLeading: false,
							title: const SizedBox.shrink(),
							bottom: PreferredSize(
								preferredSize: const Size.fromHeight(56),
								child: Row(
									children: [
										// Left area: timer (always visible)
										Expanded(
											flex: 1,
											child: Padding(
												padding: const EdgeInsets.only(left: 16),
												child: MatchTimer(
													startTime: _matchStartTime,
													onAutoEnded: () {
														// Auto period ended, automatically proceed to tele tab
														// But only if currently on auto tab
														if (_tabController.index == 1) {
															_tabController.animateTo(2);
														}
													},
												),
											),
										),
										TabBar(
											controller: _tabController,
											isScrollable: true,
											indicator: BoxDecoration(
												color: teamColor,
												borderRadius: const BorderRadius.only(
													topLeft: Radius.circular(6),
													topRight: Radius.circular(6),
												),
												border: Border(
													top: BorderSide(color: AppColors.mainBorderColor, width: 1),
													left: BorderSide(color: AppColors.mainBorderColor, width: 1),
													right: BorderSide(color: AppColors.mainBorderColor, width: 1),
												),
											),
											indicatorSize: TabBarIndicatorSize.tab,
											indicatorPadding: const EdgeInsets.all(1),
											labelColor: AppColors.mainFgColor,
											unselectedLabelColor: AppColors.mainFgColor,
											labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
											unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
											dividerColor: Colors.transparent,
											labelPadding: const EdgeInsets.symmetric(horizontal: 2),
											tabs: [
												_buildStyledTab('pre_match_tab'),
												_buildStyledTab('auto_tab'),
												_buildStyledTab('tele_tab'),
												_buildStyledTab('end_game_tab'),
											],
										),
										Expanded(
											flex: 1,
											child: Container(), // Right spacer for centering
										),
										SizedBox(
											width: 72,
											child: Center(
												child: ViperMenuButton(
													isSyncing: syncState.isSyncing,
													pendingCount: syncState.pendingCount,
												),
											),
										),
										if (syncState.isSyncing)
											const SizedBox(
												width: 48,
												child: Center(
													child: SizedBox(
														width: 20,
														height: 20,
														child: CircularProgressIndicator(
															strokeWidth: 2,
															valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
														),
													),
												),
											),
									],
								),
							),
						),
						SliverFillRemaining(
							child: Container(
								margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
								decoration: BoxDecoration(
									border: Border(
										top: BorderSide(color: AppColors.mainBorderColor, width: 1),
										left: BorderSide(color: AppColors.mainBorderColor, width: 1),
										right: BorderSide(color: AppColors.mainBorderColor, width: 1),
										bottom: BorderSide(color: AppColors.mainBorderColor, width: 1),
									),
								),
								child: TabBarView(
									controller: _tabController,
									children: [
										_buildTabContent(ref, 0),
										_buildTabContent(ref, 1),
										_buildTabContent(ref, 2),
										_buildTabContent(ref, 3),
									],
								),
							),
						),
					],
				),
			),
		);
	}
}
