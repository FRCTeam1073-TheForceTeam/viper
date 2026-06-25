import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../services/localization.dart';
import '../screens/server_config_screen.dart';
import '../screens/event_picker_screen.dart';
import '../screens/match_selection_screen.dart';
import '../screens/bot_selection_screen.dart';

class ViperMenuButton extends ConsumerWidget {
	final VoidCallback? onChangeEvent;
	final VoidCallback? onChangeBotPosition;
	final VoidCallback? onChangeMatch;
	final VoidCallback? onChangeServer;
	final VoidCallback? onSync;
	final bool isSyncing;
	final int pendingCount;

	const ViperMenuButton({
		Key? key,
		this.onChangeEvent,
		this.onChangeBotPosition,
		this.onChangeMatch,
		this.onChangeServer,
		this.onSync,
		this.isSyncing = false,
		this.pendingCount = 0,
	}) : super(key: key);

	void _registerTranslations() {
		AppLocalizations.addI18n({
			'change_match': {
				'en': 'Change Match',
				'es': 'Cambiar partido',
				'pt': 'Alterar Partida',
				'fr': 'Changer Match',
				'zh_tw': '更改比賽',
				'he': 'שנה משחק',
				'tr': 'Maçı Değiştir',
			},
			'change_robot_position': {
				'en': 'Change Robot',
				'es': 'Cambiar posición del robot',
				'pt': 'Alterar Robot',
				'fr': 'Changer le Robot',
				'zh_tw': '更改機器人',
				'he': 'שנה רובוט',
				'tr': 'Robotu Değiştir',
			},
			'change_event': {
				'en': 'Change Event',
				'es': 'Cambiar evento',
				'pt': 'Alterar Evento',
				'fr': 'Changer Événement',
				'zh_tw': '更改活動',
				'he': 'שנה אירוע',
				'tr': 'Etkinliği Değiştir',
			},
			'change_server': {
				'en': 'Change Server',
				'es': 'Cambiar servidor',
				'pt': 'Alterar Servidor',
				'fr': 'Changer le Serveur',
				'zh_tw': '更改伺服器',
				'he': 'שנה שרת',
				'tr': 'Sunucuyu Değiştir',
			},
			'manual_sync': {
				'en': 'Manual Sync',
				'es': 'Sincronización manual',
				'pt': 'Sincronização Manual',
				'fr': 'Synchronisation Manuelle',
				'zh_tw': '手動同步',
				'he': 'סנכרון ידני',
				'tr': 'Manuel Senkronizasyon',
			},
			'language': {
				'en': 'Language',
				'es': 'Idioma',
				'pt': 'Idioma',
				'fr': 'Langue',
				'zh_tw': '語言',
				'he': 'שפה',
				'tr': 'Dil',
			},
		});
	}

	void _showMenu(BuildContext context) {
		_registerTranslations();
		showModalBottomSheet(
			context: context,
			builder: (context) => _MenuContent(
				onChangeEvent: onChangeEvent,
				onChangeBotPosition: onChangeBotPosition,
				onChangeMatch: onChangeMatch,
				onChangeServer: onChangeServer,
				onSync: onSync,
				isSyncing: isSyncing,
				pendingCount: pendingCount,
			),
		);
	}

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		// Always show if we have any callback, since onChangeServer and onChangeMatch
		// are always rendered (may have null callbacks but still need to show menu)
		if (onChangeEvent == null &&
			onChangeBotPosition == null &&
			onChangeMatch == null &&
			onChangeServer == null &&
			onSync == null) {
			return SizedBox.shrink();
		}

		return IconButton(
			icon: const Icon(Icons.more_vert),
			onPressed: () => _showMenu(context),
		);
	}
}

class _MenuContent extends ConsumerWidget {
	final VoidCallback? onChangeEvent;
	final VoidCallback? onChangeBotPosition;
	final VoidCallback? onChangeMatch;
	final VoidCallback? onChangeServer;
	final VoidCallback? onSync;
	final bool isSyncing;
	final int pendingCount;

	const _MenuContent({
		this.onChangeEvent,
		this.onChangeBotPosition,
		this.onChangeMatch,
		this.onChangeServer,
		this.onSync,
		this.isSyncing = false,
		this.pendingCount = 0,
	});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		// Watch locale to rebuild when language changes
		final locale = ref.watch(selectedLocaleProvider);

		// Helper to get translated text
		String t(String key) => AppLocalizations.translate(key, locale: locale);

		return Padding(
			padding: const EdgeInsets.all(16),
			child: Column(
				mainAxisSize: MainAxisSize.min,
				children: [
					ElevatedButton.icon(
						icon: const Icon(Icons.storage),
						label: Text(t('change_server')),
						onPressed: () {
							Navigator.pop(context);
							WidgetsBinding.instance.addPostFrameCallback((_) {
								Navigator.push(
									context,
									MaterialPageRoute(
										builder: (context) => ServerConfigScreen(
											onServerConfigured: (_) {
												Navigator.pop(context);
											},
										),
									),
								);
							});
						},
					),
					Padding(
						padding: const EdgeInsets.only(top: 8),
						child: ElevatedButton.icon(
							icon: const Icon(Icons.event),
							label: Text(t('change_event')),
							onPressed: () {
								Navigator.pop(context);
								WidgetsBinding.instance.addPostFrameCallback((_) {
									Navigator.pushAndRemoveUntil(
										context,
										MaterialPageRoute(
											builder: (context) => EventPickerScreen(
												onEventSelected: (event) {
													onChangeEvent?.call();
													Navigator.pop(context);
												},
											),
										),
										(route) => false,
									);
								});
							},
						),
					),
					Padding(
						padding: const EdgeInsets.only(top: 8),
						child: ElevatedButton.icon(
							icon: const Icon(Icons.sports),
							label: Text(t('change_match')),
							onPressed: () {
								Navigator.pop(context);
								WidgetsBinding.instance.addPostFrameCallback((_) {
									Navigator.push(
										context,
										MaterialPageRoute(
											builder: (context) => MatchSelectionScreen(
												onMatchSelected: (matchNum, teamNum) {
													onChangeMatch?.call();
													Navigator.pop(context);
												},
											),
										),
									);
								});
							},
						),
					),
					if (onChangeBotPosition != null)
						Padding(
							padding: const EdgeInsets.only(top: 8),
							child: ElevatedButton.icon(
								icon: const Icon(Icons.sports_esports),
								label: Text(t('change_robot_position')),
								onPressed: () {
									Navigator.pop(context);
									WidgetsBinding.instance.addPostFrameCallback((_) {
										Navigator.push(
											context,
											MaterialPageRoute(
												builder: (context) => BotSelectionScreen(
													onBotSelected: (bot) {
														onChangeBotPosition?.call();
														Navigator.pop(context);
													},
												),
											),
										);
									});
								},
							),
						)
					else
						SizedBox.shrink(),
					if (onSync != null)
						Padding(
							padding: const EdgeInsets.only(top: 8),
							child: ElevatedButton.icon(
								icon: const Icon(Icons.sync),
								label: Text(t('manual_sync')),
								onPressed: () {
									Navigator.pop(context);
									onSync?.call();
								},
							),
						)
					else
						SizedBox.shrink(),
					Padding(
						padding: const EdgeInsets.only(top: 16),
						child: _LanguageSelector(onLanguageChanged: () {
							Navigator.pop(context);
						}),
					),
				],
			),
		);
	}
}

class _LanguageSelector extends ConsumerStatefulWidget {
	final VoidCallback onLanguageChanged;

	const _LanguageSelector({Key? key, required this.onLanguageChanged})
		: super(key: key);

	@override
	ConsumerState<_LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends ConsumerState<_LanguageSelector> {
	bool _expanded = false;

	@override
	Widget build(BuildContext context) {
		// Watch locale to rebuild when language changes
		final locale = ref.watch(selectedLocaleProvider);

		// Helper to get translated text
		String t(String key) => AppLocalizations.translate(key, locale: locale);

		return Column(
			mainAxisSize: MainAxisSize.min,
			crossAxisAlignment: CrossAxisAlignment.stretch,
			children: [
				ElevatedButton.icon(
					icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
					label: Text(t('language')),
					onPressed: () {
						setState(() => _expanded = !_expanded);
					},
				),
				if (_expanded)
					Padding(
						padding: const EdgeInsets.only(top: 8),
						child: Wrap(
							spacing: 4,
							runSpacing: 4,
							children: supportedLanguages.entries.map((entry) {
								return FilterChip(
									label: Text(entry.value),
									onSelected: (_) {
										ref
											.read(selectedLocaleProvider.notifier)
											.setLanguage(entry.key);
										widget.onLanguageChanged();
									},
								);
							}).toList(),
						),
					),
			],
		);
	}
}
