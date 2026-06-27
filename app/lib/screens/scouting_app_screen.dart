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
	int _selectedTabIndex = 0;
	String? _matchNumber;
	String? _teamNumber;
	late TabController _tabController;

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

		// Initialize TabController with 4 tabs
		_tabController = TabController(length: 4, vsync: this);

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
		final isBlueTeam = selectedBot?.startsWith('B') ?? false;
		final teamColor = isBlueTeam ? AppColors.blueTeamColor : AppColors.redTeamColor;

		return DefaultTabController(
			length: 4,
			initialIndex: _selectedTabIndex,
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
										Expanded(
											flex: 1,
											child: Container(), // Left spacer for centering
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
													onSync: () {
														ref.read(syncStateProvider.notifier).syncScoutData();
													},
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
