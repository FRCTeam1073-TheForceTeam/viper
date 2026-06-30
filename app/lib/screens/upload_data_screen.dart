import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/scout_database.dart';
import '../providers/app_providers.dart';
import '../services/localization.dart';
import '../providers/locale_provider.dart';
import '../constants/colors.dart';
import '../widgets/viper_menu_button.dart';

class UploadDataScreen extends ConsumerStatefulWidget {
	const UploadDataScreen({Key? key}) : super(key: key);

	@override
	ConsumerState<UploadDataScreen> createState() => _UploadDataScreenState();
}

class _UploadDataScreenState extends ConsumerState<UploadDataScreen> {
	bool _initialized = false;

	void _registerTranslations() {
		AppLocalizations.addI18n({
			'upload_data': {
				'en': 'Upload Data',
				'es': 'Cargar datos',
				'pt': 'Enviar dados',
				'fr': 'Télécharger les données',
				'zh_tw': '上傳數據',
				'he': 'העלה נתונים',
				'tr': 'Veri Yükle',
			},
			'ready_to_upload': {
				'en': 'Ready to Upload',
				'es': 'Listo para cargar',
				'pt': 'Pronto para enviar',
				'fr': 'Prêt à télécharger',
				'zh_tw': '準備上傳',
				'he': 'מוכן להעלאה',
				'tr': 'Yüklemeye Hazır',
			},
			'upload_later': {
				'en': 'Upload Later',
				'es': 'Cargar más tarde',
				'pt': 'Enviar mais tarde',
				'fr': 'Télécharger plus tard',
				'zh_tw': '稍後上傳',
				'he': 'העלה מאוחר יותר',
				'tr': 'Daha Sonra Yükle',
			},
			'history': {
				'en': 'History',
				'es': 'Historial',
				'pt': 'Histórico',
				'fr': 'Historique',
				'zh_tw': '歷史記錄',
				'he': 'היסטוריה',
				'tr': 'Geçmiş',
			},
			'no_data': {
				'en': 'No data',
				'es': 'Sin datos',
				'pt': 'Sem dados',
				'fr': 'Pas de données',
				'zh_tw': '沒有數據',
				'he': 'אין נתונים',
				'tr': 'Veri yok',
			},
			'upload_all': {
				'en': 'Upload All',
				'es': 'Cargar todo',
				'pt': 'Enviar tudo',
				'fr': 'Tout télécharger',
				'zh_tw': '上傳全部',
				'he': 'העלה הכל',
				'tr': 'Tümünü Yükle',
			},
			'uploading': {
				'en': 'Uploading...',
				'es': 'Cargando...',
				'pt': 'Enviando...',
				'fr': 'Téléchargement...',
				'zh_tw': '上傳中...',
				'he': 'מעלה...',
				'tr': 'Yükleniyor...',
			},
			'clear_history': {
				'en': 'Clear History',
				'es': 'Limpiar historial',
				'pt': 'Limpar histórico',
				'fr': 'Effacer l\'historique',
				'zh_tw': '清除歷史記錄',
				'he': 'נקה היסטוריה',
				'tr': 'Geçmişi Temizle',
			},
			'delete': {
				'en': 'Delete',
				'es': 'Eliminar',
				'pt': 'Excluir',
				'fr': 'Supprimer',
				'zh_tw': '刪除',
				'he': 'מחק',
				'tr': 'Sil',
			},
			'reupload': {
				'en': 'Reupload',
				'es': 'Recargar',
				'pt': 'Reenviar',
				'fr': 'Télécharger à nouveau',
				'zh_tw': '重新上傳',
				'he': 'העלה מחדש',
				'tr': 'Yeniden Yükle',
			},
		});
	}

	@override
	Widget build(BuildContext context) {
		_registerTranslations();
		final locale = ref.watch(selectedLocaleProvider);
		String t(String key) => AppLocalizations.translate(key, locale: locale);

		final uploadState = ref.watch(uploadPageStateProvider);

		// Initialize on first build
		if (!_initialized) {
			_initialized = true;
			WidgetsBinding.instance.addPostFrameCallback((_) {
				print('[UPLOAD_DATA_SCREEN] Initializing upload page');
				ref.read(uploadPageStateProvider.notifier).initializeUploadPage();
			});
		}

		final syncState = ref.watch(syncStateProvider);

		return WillPopScope(
			onWillPop: () async {
				// Navigate back to scouting
				ref.read(navigationProvider.notifier).navigateTo(NavScreen.scouting);
				return false;
			},
			child: Scaffold(
				appBar: AppBar(
					title: Text(t('upload_data')),
					centerTitle: true,
					automaticallyImplyLeading: false,
					actions: [
						ViperMenuButton(
							isSyncing: syncState.isSyncing,
							pendingCount: syncState.pendingCount,
						),
					],
				),
				body: SingleChildScrollView(
					child: Padding(
						padding: const EdgeInsets.all(16),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.stretch,
							children: [
								// Upload All button
								ElevatedButton.icon(
									icon: uploadState.isUploading
										? const SizedBox(
											width: 20,
											height: 20,
											child: CircularProgressIndicator(strokeWidth: 2),
										)
										: const Icon(Icons.cloud_upload),
									label: Text(
										uploadState.isUploading
											? t('uploading')
											: t('upload_all'),
									),
									onPressed: uploadState.isUploading ||
											(uploadState.readyToUpload.isEmpty &&
												uploadState.uploadLater.isEmpty)
										? null
										: () {
											ref
												.read(uploadPageStateProvider.notifier)
												.uploadReadyEntries();
										},
								),

								// Error message
								if (uploadState.error != null)
									Padding(
										padding: const EdgeInsets.only(top: 16),
										child: Container(
											padding: const EdgeInsets.all(12),
											decoration: BoxDecoration(
												color: Colors.red.shade100,
												borderRadius: BorderRadius.circular(8),
												border: Border.all(color: Colors.red),
											),
											child: Text(
												uploadState.error!,
												style: TextStyle(color: Colors.red.shade900),
											),
										),
									),

								// Ready to Upload section
								Padding(
									padding: const EdgeInsets.only(top: 24),
									child: _UploadSection(
										title: t('ready_to_upload'),
										entries: uploadState.readyToUpload,
										showDelete: true,
										showReupload: false,
										onDelete: (id) {
											ref
												.read(uploadPageStateProvider.notifier)
												.deleteEntry(id);
										},
										onReupload: (_) {},
										locale: locale,
									),
								),

								// Upload Later section
								if (uploadState.uploadLater.isNotEmpty)
									Padding(
										padding: const EdgeInsets.only(top: 24),
										child: _UploadSection(
											title: t('upload_later'),
											entries: uploadState.uploadLater,
											showDelete: true,
											showReupload: false,
											onDelete: (id) {
												ref
													.read(uploadPageStateProvider.notifier)
													.deleteEntry(id);
											},
											onReupload: (_) {},
											locale: locale,
										),
									),

								// History section
								if (uploadState.history.isNotEmpty)
									Padding(
										padding: const EdgeInsets.only(top: 24),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Row(
													mainAxisAlignment:
														MainAxisAlignment.spaceBetween,
													children: [
														Text(
															t('history'),
															style: Theme.of(context)
																	.textTheme
																	.titleMedium
																	?.copyWith(
																fontWeight: FontWeight.bold,
															),
														),
														ElevatedButton.icon(
															icon: const Icon(Icons.delete_outline,
																	size: 16),
															label: Text(t('clear_history')),
															onPressed: () {
																ref
																	.read(uploadPageStateProvider
																		.notifier)
																	.clearAllHistory();
															},
														),
													],
												),
												Padding(
													padding: const EdgeInsets.only(top: 12),
													child: _UploadSection(
														title: '',
														entries: uploadState.history,
														showDelete: true,
														showReupload: uploadState.history
																.any((h) =>
																	h.uploadStatus ==
																	'uploaded')
															? true
															: false,
														onDelete: (id) {
															ref
																.read(uploadPageStateProvider
																	.notifier)
																.deleteEntry(id);
														},
														onReupload: (id) {
															ref
																.read(uploadPageStateProvider
																	.notifier)
																.reuploadEntry(id);
														},
														locale: locale,
													),
												),
											],
										),
									),

								// Empty state message
								if (uploadState.readyToUpload.isEmpty &&
									uploadState.uploadLater.isEmpty &&
									uploadState.history.isEmpty)
									Padding(
										padding: const EdgeInsets.only(top: 48),
										child: Center(
											child: Text(
												t('no_data'),
												style: Theme.of(context).textTheme.titleMedium,
											),
										),
									),
							],
						),
					),
				),
			),
		);
	}
}

class _UploadSection extends StatefulWidget {
	final String title;
	final List<UploadHistoryData> entries;
	final bool showDelete;
	final bool showReupload;
	final Function(int) onDelete;
	final Function(int) onReupload;
	final Locale locale;

	const _UploadSection({
		required this.title,
		required this.entries,
		required this.showDelete,
		required this.showReupload,
		required this.onDelete,
		required this.onReupload,
		required this.locale,
	});

	@override
	State<_UploadSection> createState() => _UploadSectionState();
}

class _UploadSectionState extends State<_UploadSection> {
	bool _expanded = true;

	@override
	Widget build(BuildContext context) {
		String t(String key) => AppLocalizations.translate(key, locale: widget.locale);

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				if (widget.title.isNotEmpty)
					GestureDetector(
						onTap: () => setState(() => _expanded = !_expanded),
						child: Container(
							padding: const EdgeInsets.symmetric(vertical: 12),
							child: Row(
								children: [
									Icon(_expanded ? Icons.expand_less : Icons.expand_more),
									const SizedBox(width: 8),
									Text(
										widget.title,
										style:
											Theme.of(context).textTheme.titleMedium?.copyWith(
											fontWeight: FontWeight.bold,
										),
									),
									const SizedBox(width: 8),
									Container(
										padding: const EdgeInsets.symmetric(
											horizontal: 8,
											vertical: 2,
										),
										decoration: BoxDecoration(
											color: Colors.blue.shade100,
											borderRadius: BorderRadius.circular(12),
										),
										child: Text(
											'${widget.entries.length}',
											style: TextStyle(
												fontSize: 12,
												color: Colors.blue.shade900,
												fontWeight: FontWeight.bold,
											),
										),
									),
								],
							),
						),
					),
				if (_expanded)
					...widget.entries.map((entry) {
						return Padding(
							padding: const EdgeInsets.symmetric(vertical: 8),
							child: _UploadEntryCard(
								entry: entry,
								showDelete: widget.showDelete,
								showReupload: widget.showReupload &&
									entry.uploadStatus == 'uploaded',
								onDelete: () => widget.onDelete(entry.id),
								onReupload: () => widget.onReupload(entry.id),
								locale: widget.locale,
							),
						);
					}).toList(),
			],
		);
	}
}

class _UploadEntryCard extends StatefulWidget {
	final UploadHistoryData entry;
	final bool showDelete;
	final bool showReupload;
	final VoidCallback onDelete;
	final VoidCallback onReupload;
	final Locale locale;

	const _UploadEntryCard({
		required this.entry,
		required this.showDelete,
		required this.showReupload,
		required this.onDelete,
		required this.onReupload,
		required this.locale,
	});

	@override
	State<_UploadEntryCard> createState() => _UploadEntryCardState();
}

class _UploadEntryCardState extends State<_UploadEntryCard> {
	late ScrollController _horizontalScrollController;

	@override
	void initState() {
		super.initState();
		_horizontalScrollController = ScrollController();
	}

	@override
	void dispose() {
		_horizontalScrollController.dispose();
		super.dispose();
	}

	/// Convert CSV headers and data to key=value format
	String _formatAsKeyValue(String headers, String data) {
		final headerList = headers.split(',');
		final dataList = data.split(',');

		final pairs = <String>[];
		for (int i = 0; i < headerList.length && i < dataList.length; i++) {
			final header = headerList[i].trim();
			final value = dataList[i].trim();
			pairs.add('$header=$value');
		}

		return pairs.join('\n');
	}

	@override
	Widget build(BuildContext context) {
		String t(String key) => AppLocalizations.translate(key, locale: widget.locale);

		// Parse CSV data to extract team and match info
		// Format: team,match,... from csvData
		final dataParts = widget.entry.csvData.split(',');
		final team = dataParts.isNotEmpty ? dataParts[0] : '?';
		final match = dataParts.length > 1 ? dataParts[1] : '?';

		// Format date
		final dateStr = widget.entry.createdAt.toString().split('.')[0];

		final statusColor = widget.entry.uploadStatus == 'uploaded'
			? Colors.green
			: widget.entry.uploadStatus == 'failed'
				? Colors.red
				: Colors.orange;

		return Card(
			child: Padding(
				padding: const EdgeInsets.all(12),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Row(
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
							children: [
								Expanded(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(
												'${t('team')}: $team',
												style: Theme.of(context).textTheme.bodyMedium,
											),
											Padding(
												padding: const EdgeInsets.only(top: 4),
												child: Text(
													'${t('match')}: $match',
													style: Theme.of(context).textTheme.bodyMedium,
												),
											),
											Padding(
												padding: const EdgeInsets.only(top: 4),
												child: Text(
													dateStr,
													style: Theme.of(context)
														.textTheme
														.bodySmall
														?.copyWith(
													color: Colors.grey,
												),
												),
											),
										],
									),
								),
								Padding(
									padding: const EdgeInsets.only(left: 8),
									child: Container(
										padding: const EdgeInsets.symmetric(
											horizontal: 8,
											vertical: 4,
										),
										decoration: BoxDecoration(
											color: statusColor.withOpacity(0.2),
											borderRadius: BorderRadius.circular(4),
										),
										child: Text(
											widget.entry.uploadStatus,
											style: TextStyle(
												fontSize: 12,
												color: statusColor,
												fontWeight: FontWeight.bold,
											),
										),
									),
								),
							],
						),
						if (widget.showDelete || widget.showReupload)
							Padding(
								padding: const EdgeInsets.only(top: 12),
								child: Row(
									mainAxisAlignment: MainAxisAlignment.end,
									children: [
										if (widget.showReupload)
											Padding(
												padding: const EdgeInsets.only(right: 8),
												child: ElevatedButton.icon(
													icon: const Icon(Icons.refresh, size: 16),
													label: Text(t('reupload')),
													onPressed: widget.onReupload,
												),
											),
										if (widget.showDelete)
											ElevatedButton.icon(
												icon: const Icon(Icons.delete_outline, size: 16),
												label: Text(t('delete')),
												onPressed: widget.onDelete,
												style: ElevatedButton.styleFrom(
													foregroundColor: Colors.red,
												),
											),
									],
								),
							),
						// Display full data as key-value pairs
						Padding(
							padding: const EdgeInsets.only(top: 12),
							child: Container(
								width: double.infinity,
								padding: const EdgeInsets.all(8),
								decoration: BoxDecoration(
									color: AppColors.mainBgColor,
									borderRadius: BorderRadius.circular(4),
									border: Border.all(color: AppColors.mainBorderColor),
								),
								child: Scrollbar(
									controller: _horizontalScrollController,
									thumbVisibility: true,
									child: SingleChildScrollView(
										scrollDirection: Axis.horizontal,
										controller: _horizontalScrollController,
										child: SelectableText(
											_formatAsKeyValue(widget.entry.csvHeaders, widget.entry.csvData),
											style: const TextStyle(
												fontFamily: 'monospace',
												fontSize: 12,
												color: AppColors.mainFgColor,
												height: 1.4,
											),
										),
									),
								),
							),
						),
					],
				),
			),
		);
	}
}
