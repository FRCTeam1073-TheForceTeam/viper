import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../providers/app_providers.dart';
import '../services/localization.dart';

class ViperMenuButton extends ConsumerWidget {
	final bool isSyncing;
	final int pendingCount;

	const ViperMenuButton({
		Key? key,
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
			'upload_data': {
				'en': 'Upload Data',
				'es': 'Cargar datos',
				'pt': 'Enviar dados',
				'fr': 'Télécharger les données',
				'zh_tw': '上傳數據',
				'he': 'העלה נתונים',
				'tr': 'Veri Yükle',
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
				isSyncing: isSyncing,
				pendingCount: pendingCount,
			),
		);
	}

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		return IconButton(
			icon: const Icon(Icons.menu),
			onPressed: () => _showMenu(context),
		);
	}
}

class _MenuContent extends ConsumerWidget {
	final bool isSyncing;
	final int pendingCount;

	const _MenuContent({
		this.isSyncing = false,
		this.pendingCount = 0,
	});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		// Watch locale to rebuild when language changes
		final locale = ref.watch(selectedLocaleProvider);

		// Helper to get translated text
		String t(String key) => AppLocalizations.translate(key, locale: locale);

		// Get the navigation provider
		final navigateTo = (NavigationTarget target) =>
			ref.read(navigationCommandProvider.notifier).navigateTo(target);

		return Padding(
			padding: const EdgeInsets.all(16),
			child: Column(
				mainAxisSize: MainAxisSize.min,
				children: [
					// Always show these navigation options
					ElevatedButton.icon(
						icon: const Icon(Icons.storage),
						label: Text(t('change_server')),
						onPressed: () {
							print('[KEBAB_MENU] ✓ Change Server clicked');
							Navigator.pop(context);
							print('[KEBAB_MENU] → Calling navigateTo(server)');
							navigateTo(NavigationTarget.server);
						},
					),
					Padding(
						padding: const EdgeInsets.only(top: 8),
						child: ElevatedButton.icon(
							icon: const Icon(Icons.event),
							label: Text(t('change_event')),
							onPressed: () {
								print('[KEBAB_MENU] ✓ Change Event clicked');
								Navigator.pop(context);
								print('[KEBAB_MENU] → Calling navigateTo(event)');
								navigateTo(NavigationTarget.event);
							},
						),
					),
					Padding(
						padding: const EdgeInsets.only(top: 8),
						child: ElevatedButton.icon(
							icon: const Icon(Icons.sports_esports),
							label: Text(t('change_robot_position')),
							onPressed: () {
								print('[KEBAB_MENU] ✓ Change Robot Position clicked');
								Navigator.pop(context);
								print('[KEBAB_MENU] → Calling navigateTo(botSelection)');
								navigateTo(NavigationTarget.botSelection);
							},
						),
					),
					Padding(
						padding: const EdgeInsets.only(top: 8),
						child: ElevatedButton.icon(
							icon: const Icon(Icons.sports),
							label: Text(t('change_match')),
							onPressed: () {
								print('[KEBAB_MENU] ✓ Change Match clicked');
								Navigator.pop(context);
								print('[KEBAB_MENU] → Calling navigateTo(match)');
								navigateTo(NavigationTarget.match);
							},
						),
					),
					Padding(
						padding: const EdgeInsets.only(top: 8),
						child: ElevatedButton.icon(
							icon: const Icon(Icons.cloud_upload),
							label: Text(t('upload_data')),
							onPressed: () {
								print('[KEBAB_MENU] ✓ Upload Data clicked');
								Navigator.pop(context);
								print('[KEBAB_MENU] → Calling navigateTo(upload)');
								navigateTo(NavigationTarget.upload);
							},
						),
					),
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
