import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'server_config_screen.dart';
import '../widgets/viper_menu_button.dart';
import '../widgets/instant_tab_bar_view.dart';
import '../providers/app_providers.dart';
import '../providers/locale_provider.dart';
import '../providers/match_timer_provider.dart';
import '../providers/pre_match_provider.dart';
import '../providers/timeline_provider.dart';
import '../seasons/season_registry.dart';
import '../seasons/season_module.dart';
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
	SeasonModule? _seasonModule;

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

		// Resolve season module based on event
		_seasonModule = seasonModuleFor(widget.selectedEvent.season);

		// Always start on pre-match tab (index 0) when screen loads
		// This ensures we don't show the wrong tab when switching matches
		final initialTabIndex = 0;

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
			'season_not_implemented': {
				'en': 'Scouting for this season is not available in the mobile app',
				'es': 'El scouting para esta temporada no está disponible en la aplicación móvil',
				'pt': 'O scouting para esta temporada não está disponível no aplicativo móvel',
				'fr': 'Le repérage pour cette saison n\'est pas disponible dans l\'application mobile',
				'zh_tw': '此應用程式不支援此季節的偵察',
				'he': 'סקאוטינג לעונה זו אינו זמין באפליקציה הנייד',
				'tr': 'Bu sezon için izcilik mobil uygulamada mevcut değildir',
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
		final module = _seasonModule;

		if (module == null) {
			return const SizedBox(); // Should not happen if build() gate works
		}

		switch (tabIndex) {
			case 0:
				return module.buildPreMatchTab(
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
				return module.buildAutoTab(
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
				return module.buildTeleopTab(
					eventId: widget.selectedEvent.eventId,
					matchNumber: selectedMatch.match,
					teamNumber: selectedMatch.team,
				);
			case 3:
				return module.buildEndGameTab(
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
		// Watch locale to trigger rebuild when language changes
		ref.watch(selectedLocaleProvider);
		final syncState = ref.watch(syncStateProvider);
		final selectedBot = ref.watch(selectedBotPositionProvider);
		final selectedTabIndex = ref.watch(selectedTabIndexProvider);

		// Load existing scout data when match changes
		final selectedMatch = ref.watch(selectedMatchProvider);
		final selectedEvent = ref.watch(selectedEventProvider);
		// Use ref.listen() instead of watch() to avoid continuous rebuilds
		ref.listen(existingScoutDataProvider, (previous, next) {
			next.when(
				data: (matchData) {
					if (matchData != null) {
						_tabController.index = 0;
						ref.read(selectedTabIndexProvider.notifier).setTabIndex(0);
						// Delay provider modification until after widget tree is built
						WidgetsBinding.instance.addPostFrameCallback((_) {

							// Preserve original created timestamp from previous scouting session
							if (matchData['created'] != null) {
								ref.read(originalCreatedProvider.notifier).setFromExistingData(matchData['created'] as String);
							}
							// Initialize session start time to now
							ref.read(scoutingSessionCreatedProvider.notifier).initializeNewSession();

							// Load all scouting data providers via the season module
							_seasonModule?.loadMatchData(ref, matchData);

							// Load timeline and set match timer to last event's timestamp
							if (matchData['timeline'] != null && (matchData['timeline'] as String).isNotEmpty) {
								final timelineEvents = TimelineEvent.parseTimeline(matchData['timeline'] as String);
								ref.read(timelineProvider.notifier).setTimeline(timelineEvents);

								if (timelineEvents.isNotEmpty) {
									final lastEventSeconds = timelineEvents.last.timeSeconds;
									// Calculate when the match should have started to reach this time
									final matchStartTime = DateTime.now().subtract(Duration(seconds: lastEventSeconds));
									ref.read(matchTimerProvider.notifier).setStartTime(matchStartTime);
								}
							} else {
							}
						});
					} else if (matchData == null) {
						// No existing data - initialize a new session and reset all scouting data
						WidgetsBinding.instance.addPostFrameCallback((_) {
							ref.read(originalCreatedProvider.notifier).clear();
							ref.read(scoutingSessionCreatedProvider.notifier).initializeNewSession();
							_seasonModule?.resetMatchData(ref);
							// Navigate to pre-match tab
							_tabController.animateTo(0);
						});
					}
				},
				loading: () {
				},
				error: (err, st) {
				},
			);
		});

		final existingData = ref.watch(existingScoutDataProvider);
		final currentMatchKey = '${selectedEvent}_${selectedMatch.match}_${selectedMatch.team}';

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

		// Gate: check if the selected event's season is supported
		if (_seasonModule == null) {
			return Scaffold(
				appBar: AppBar(
					title: Text(widget.selectedEvent.name),
					elevation: 0,
					automaticallyImplyLeading: false,
					actions: [
						ViperMenuButton(),
					],
				),
				body: Center(
					child: Padding(
						padding: const EdgeInsets.all(16),
						child: Column(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Text(
									_translate('season_not_implemented'),
									textAlign: TextAlign.center,
									style: Theme.of(context).textTheme.titleLarge,
								),
								const SizedBox(height: 24),
								ElevatedButton(
									onPressed: () async {
										await ref.read(navigationCommandProvider.notifier).navigateTo(NavigationTarget.event);
									},
									child: Text(_translate('select_event')),
								),
							],
						),
					),
				),
			);
		}

		return Scaffold(
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
													autoPeriodMs: _seasonModule!.autoPeriodMs,
													autoGapMs: _seasonModule!.autoGapMs,
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
								child: InstantTabBarView(
									controller: _tabController,
									physics: const NeverScrollableScrollPhysics(),
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
		);
	}
}
