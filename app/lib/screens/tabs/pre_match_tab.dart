import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../providers/app_providers.dart';
import '../../providers/locale_provider.dart';
import '../../providers/field_side_provider.dart';
import '../../providers/scouting_data_provider.dart';
import '../../services/localization.dart';
import '../../constants/colors.dart';
import '../../utils/match_name_converter.dart';
import '../../widgets/checkbox_button.dart';
import '../../widgets/position_selector_area.dart';
import '../../models/field_descriptor.dart';
import '../../models/map_data_model.dart';

class PreMatchTab extends ConsumerStatefulWidget {
	final String eventId;
	final String? matchNumber;
	final String? teamNumber;
	final String eventName;
	final String? botPosition;
	final VoidCallback? onProceedToAuto;

	const PreMatchTab({
		Key? key,
		required this.eventId,
		required this.matchNumber,
		required this.teamNumber,
		required this.eventName,
		this.botPosition,
		this.onProceedToAuto,
	}) : super(key: key);

	@override
	ConsumerState<PreMatchTab> createState() => _PreMatchTabState();
}

class _PreMatchTabState extends ConsumerState<PreMatchTab> {

	String _translate(String key, {Map<String, String>? variables}) {
		final locale = ref.read(selectedLocaleProvider);
		return AppLocalizations.translate(key, locale: locale, variables: variables);
	}

	@override
	void initState() {
		super.initState();

		// Register translations on demand when this tab is first loaded
		AppLocalizations.addI18n({
			'scouting_heading': {
				'en': '_EVENTNAME_, _POS_, _MATCHNAME_, Team _TEAMNUM_',
				'es': 'Exploración',
				'pt': '_EVENTNAME_, _POS_, _MATCHNAME_, Equipe _TEAMNUM_',
				'fr': '_EVENTNAME_, _POS_, _MATCHNAME_, Équipe _TEAMNUM_',
				'zh_tw': '_EVENTNAME_、_POS_、_MATCHNAME_、隊伍 _TEAMNUM_',
				'he': '_EVENTNAME_, _POS_, _MATCHNAME_, צוות _TEAMNUM_',
				'tr': '_EVENTNAME_, _POS_, _MATCHNAME_, Takım _TEAMNUM_',
			},
			'no_show': {
				'en': 'No Show',
				'es': 'No',
				'pt': 'Sem presença',
				'fr': 'Non présent',
				'zh_tw': '沒有出席',
				'he': 'אין הופעה',
				'tr': 'Gösterilmedi',
			},
			'starting_position': {
				'en': 'Click team _TEAMNUM_\'s starting position.',
				'es': 'Haz clic en la posición de inicio del equipo _TEAMNUM_.',
				'pt': 'Clique na posição inicial da equipe _TEAMNUM_.',
				'fr': 'Cliquez sur la position de départ de l\'équipe _TEAMNUM_.',
				'zh_tw': '點選隊伍_TEAMNUM_的起始位置。',
				'he': 'לחץ על עמדת ההתחלה של צוות _TEAMNUM_.',
				'tr': 'Takım _TEAMNUM_\'un başlangıç ​​pozisyonuna tıklayın.',
			},
			'proceed_auto_button': {
				'en': 'Auto »',
				'es': 'Auto »',
				'pt': 'Auto »',
				'fr': 'Auto »',
				'zh_tw': '自動 »',
				'he': 'אוטו »',
				'tr': 'Otomatik »',
			},
			'pre_match_data_saved': {
				'en': 'Pre-Match data saved',
				'es': 'Datos previos al partido guardados',
				'pt': 'Dados pré-jogo salvos',
				'fr': 'Données pré-match sauvegardées',
				'zh_tw': '賽前資料已保存',
				'he': 'נתונים לפני המשחק נשמרו',
				'tr': 'Maç öncesi veriler kaydedildi',
			},
			'instructions': {
				'en': 'Full Instructions',
				'es': 'Instrucciones completas',
				'pt': 'Instruções completas',
				'fr': 'Instructions complètes',
				'zh_tw': '完整說明',
				'he': 'הוראות מלאות',
				'tr': 'Tam Talimatlar',
			},
			'brief_instructions': {
				'en': 'Record robot actions by clicking corresponding buttons. Icons show what action each button performs.',
				'es': 'Registra las acciones del robot haciendo clic en los botones correspondientes. Los iconos muestran qué acción realiza cada botón.',
				'pt': 'Registre as ações do robô clicando nos botões correspondentes. Os ícones mostram qual ação cada botão executa.',
				'fr': 'Enregistrez les actions du robot en cliquant sur les boutons correspondants. Les icônes montrent l\'action que chaque bouton effectue.',
				'zh_tw': '通過點擊相應的按鈕記錄機器人的操作。圖標顯示每個按鈕執行的操作。',
				'he': 'הקלט פעולות רובוט על ידי לחיצה על כפתורים המתאימים. הסמלים מראים איזו פעולה כל כפתור מבצע.',
				'tr': 'İlgili düğmeleri tıklayarak robot eylemlerini kaydedin. Simgeler her düğmenin hangi eylemi gerçekleştirdiğini gösterir.',
			},
			'close': {
				'en': 'Close',
				'es': 'Cerrar',
				'pt': 'Fechar',
				'fr': 'Fermer',
				'zh_tw': '關閉',
				'he': 'סגור',
				'tr': 'Kapat',
			},
			'full_instructions': {
				'en': 'Scouting Instructions\n\nWatch your robot and record its actions by clicking on the corresponding buttons. The icons used for actions show what each button performs.\n\nSwitch to teleop when auto ends - the button will flash red and blue to remind you.\n\nUse the buttons at the bottom to save your data when done.',
				'es': 'Instrucciones de exploración\n\nMira tu robot y registra sus acciones haciendo clic en los botones correspondientes. Los iconos utilizados para las acciones muestran lo que realiza cada botón.\n\nCambia a teleop cuando termina auto: el botón parpadeará en rojo y azul para recordarte.\n\nUtiliza los botones en la parte inferior para guardar tus datos cuando termines.',
				'pt': 'Instruções de Scouting\n\nAssista seu robô e registre suas ações clicando nos botões correspondentes. Os ícones usados para ações mostram o que cada botão executa.\n\nMude para teleop quando auto terminar - o botão piscará em vermelho e azul para lembrá-lo.\n\nUse os botões na parte inferior para salvar seus dados quando terminar.',
				'fr': 'Instructions de Scouting\n\nRegardez votre robot et enregistrez ses actions en cliquant sur les boutons correspondants. Les icônes utilisées pour les actions montrent ce que chaque bouton effectue.\n\nPassez à la téléop lorsque l\'auto se termine - le bouton clignotera en rouge et bleu pour vous le rappeler.\n\nUtilisez les boutons en bas pour enregistrer vos données lorsque vous avez terminé.',
				'zh_tw': '偵查說明\n\n觀看您的機器人並通過點擊相應的按鈕記錄其動作。用於操作的圖標顯示每個按鈕執行的操作。\n\n當自動結束時切換到遙控 - 按鈕將閃爍紅色和藍色以提醒您。\n\n完成後使用底部的按鈕保存您的數據。',
				'he': 'הוראות סקאוטינג\n\nצפו ברובוט שלכם ותעדו את פעולותיו על ידי לחיצה על הכפתורים המתאימים. הסמלים המשמשים לפעולות מראים מה כל כפתור מבצע.\n\nעברו לטלאופ כאשר אוטו מסתיים - הכפתור יהבהב באדום וכחול כדי להזכיר לכם.\n\nהשתמשו בכפתורים בתחתית כדי לשמור את הנתונים שלכם לאחר שסיימתם.',
				'tr': 'Scouting Talimatları\n\nRobotunuzu izleyin ve ilgili düğmeleri tıklayarak eylemlerini kaydedin. Eylemler için kullanılan simgeler her düğmenin ne yaptığını gösterir.\n\nOtomatik bittiğinde teleop\'a geçin - düğme sizi hatırlatmak için kırmızı ve maviye yanıp sönecektir.\n\nBittikten sonra verilerinizi kaydetmek için alttaki düğmeleri kullanın.',
			},
		});
	}

	String _getInstructionsFilePath() {
		final locale = ref.read(selectedLocaleProvider);
		final languageCode = locale.languageCode;

		// Map language codes to file names
		const languageFileMap = {
			'en': 'scouting-instructions.md',
			'es': 'scouting-instructions.es.md',
			'pt': 'scouting-instructions.pt.md',
			'fr': 'scouting-instructions.fr.md',
			'zh': 'scouting-instructions.zh_tw.md',
			'he': 'scouting-instructions.he.md',
			'tr': 'scouting-instructions.tr.md',
		};

		final fileName = languageFileMap[languageCode] ?? 'scouting-instructions.md';
		return 'assets/$fileName';
	}

	void _showInstructions() {
		showDialog(
			context: context,
			builder: (context) => AlertDialog(
				title: Text(_translate('instructions')),
				content: FutureBuilder<String>(
					future: rootBundle.loadString(_getInstructionsFilePath()),
					builder: (context, snapshot) {
						if (snapshot.connectionState == ConnectionState.waiting) {
							return const Center(child: CircularProgressIndicator());
						}
						if (snapshot.hasError) {
							return Text('Error loading instructions: ${snapshot.error}');
						}

						var htmlContent = snapshot.data ?? '';

						// Extract image sizing information from HTML img tags
						final Map<String, String> imageSizes = {};
						final imgRegex = RegExp(r'<img[^>]*src="([^"]+)"[^>]*style="([^"]*)"[^>]*>');
						for (final match in imgRegex.allMatches(htmlContent)) {
							final src = match.group(1) ?? '';
							final style = match.group(2) ?? '';
							imageSizes[src] = style;
						}

						// Convert HTML img tags to markdown syntax: ![](filename.png)
						htmlContent = htmlContent.replaceAllMapped(
							RegExp(r'<img[^>]*src="([^"]+)"[^>]*>'),
							(match) => '![](${match.group(1)})'
						);

						return SingleChildScrollView(
							child: MarkdownBody(
								data: htmlContent,
								imageBuilder: (uri, title, alt) {
									final imagePath = uri.toString();
									final style = imageSizes[imagePath] ?? '';

									// Parse max-width from style, e.g., "max-width:2em" → 2em
									final maxWidthMatch = RegExp(r'max-width:\s*([^;]+)').firstMatch(style);
									final maxWidth = maxWidthMatch?.group(1) ?? '100%';

									// Convert em to logical pixels (1em ≈ 14px in Flutter default)
									double? constraintWidth;
									if (maxWidth.endsWith('em')) {
										final emValue = double.tryParse(maxWidth.replaceAll('em', ''));
										if (emValue != null) {
											constraintWidth = emValue * 14;
										}
									}

									final image = Image.asset(
										'assets/images/$imagePath',
										fit: BoxFit.contain,
									);

									if (constraintWidth != null) {
										return ConstrainedBox(
											constraints: BoxConstraints(maxWidth: constraintWidth),
											child: image,
										);
									}
									return image;
								},
								styleSheet: MarkdownStyleSheet(
									h2: Theme.of(context).textTheme.titleMedium,
									h3: Theme.of(context).textTheme.titleSmall,
									p: Theme.of(context).textTheme.bodyMedium,
									em: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
									strong: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
									listBullet: Theme.of(context).textTheme.bodyMedium,
								),
							),
						);
					},
				),
				actions: [
					TextButton(
						onPressed: () => Navigator.pop(context),
						child: Text(_translate('close')),
					),
				],
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		// Watch locale to trigger rebuild when language changes
		ref.watch(selectedLocaleProvider);
		// Get the selected bot position to determine team color (blue or red)
		final botPosition = ref.watch(selectedBotPositionProvider);
		final isBlueTeam = botPosition?.startsWith('B') ?? false;

		// Get the field side (left or right)
		final fieldSide = ref.watch(selectedFieldSideProvider);

		// Read scouting data provider (don't watch to avoid rebuilding on updates)
		final preMatchData = ref.read(scoutingDataProvider);

		// Get baseUrl for robot photo
		final apiClientAsync = ref.watch(apiClientProvider);

		return SingleChildScrollView(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [
					// Heading: Event, Bot Position, Match, Team
					if (widget.eventName.isNotEmpty || widget.botPosition != null || widget.matchNumber != null || widget.teamNumber != null)
						Container(
							color: AppColors.mainBgColor,
							padding: const EdgeInsets.all(16),
							child: Text(
								_translate('scouting_heading', variables: {
									'EVENTNAME': widget.eventName,
									'POS': widget.botPosition ?? '',
									'MATCHNAME': widget.matchNumber != null ? getShortMatchName(widget.matchNumber!) : '',
									'TEAMNUM': widget.teamNumber ?? '',
								}),
								style: Theme.of(context).textTheme.titleMedium?.copyWith(
									color: AppColors.mainFgColor,
								),
							),
						),
					const SizedBox(height: 16),
					// Two-column layout: Starting Position (left) | Instructions & Buttons (right)
					IntrinsicHeight(
						child: Row(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
							// LEFT COLUMN: Starting Position (fixed width matching image + padding)
							SizedBox(
								width: 150,
								child: Card(
									child: Padding(
										padding: const EdgeInsets.all(16),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text(
													_translate('starting_position', variables: {'TEAMNUM': widget.teamNumber ?? ''}),
													style: Theme.of(context).textTheme.titleMedium,
												),
												const SizedBox(height: 16),
												// Starting position interactive area (clickable/draggable)
												Center(
													child: PositionSelectorArea.forField(
														descriptor: FieldDescriptor(name: 'starting_position'),
														model: preMatchData,
														provider: scoutingDataProvider,
														ref: ref,
														isBlueTeam: isBlueTeam,
														fieldSide: fieldSide,
														blueImagePath: 'assets/images/start-area-blue.png',
														redImagePath: 'assets/images/start-area-red.png',
														width: 84,
														height: 250,
														markerSize: 60,
													),
												),
											],
										),
									),
								),
							),
							const SizedBox(width: 16),
							// RIGHT COLUMN: Instructions & Buttons
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.center,
									mainAxisAlignment: MainAxisAlignment.spaceEvenly,
									children: [
										// Brief Instructions
										Padding(
											padding: const EdgeInsets.only(bottom: 16),
											child: Text(
												_translate('brief_instructions'),
												style: Theme.of(context).textTheme.bodyLarge?.copyWith(
													color: AppColors.mainFgColor.withOpacity(0.7),
												),
												textAlign: TextAlign.center,
											),
										),
										// Instructions Button
										FilledButton(
											style: FilledButton.styleFrom(
												backgroundColor: AppColors.buttonBgColor,
												foregroundColor: AppColors.buttonFgColor,
												padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
												shape: RoundedRectangleBorder(
													borderRadius: BorderRadius.circular(8),
												),
											),
											onPressed: _showInstructions,
											child: Text(
												_translate('instructions'),
												style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
											),
										),
										// No Show Button
										CheckboxButton(
											descriptor: const FieldDescriptor(
												name: 'no_show',
												uiLabelKey: 'no_show',
											),
											model: preMatchData,
											provider: scoutingDataProvider,
										),
										// Proceed to Auto Button
										FilledButton(
											style: FilledButton.styleFrom(
												backgroundColor: AppColors.buttonBgColor,
												foregroundColor: AppColors.buttonFgColor,
												padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
												shape: RoundedRectangleBorder(
													borderRadius: BorderRadius.circular(8),
												),
											),
											onPressed: widget.onProceedToAuto,
											child: Text(
												_translate('proceed_auto_button'),
												style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
											),
										),
									],
								),
							),
						],
						),
					),
					const SizedBox(height: 16),
					// Robot Photo below the two-column layout
					if (widget.teamNumber != null)
						apiClientAsync.when(
							data: (apiClient) => FutureBuilder<Uint8List?>(
								future: apiClient.fetchRobotPhotoBytes(widget.eventId, widget.teamNumber!),
								builder: (context, snapshot) {
									if (snapshot.connectionState == ConnectionState.waiting) {
										return const Padding(
											padding: EdgeInsets.symmetric(vertical: 8),
											child: CircularProgressIndicator(),
										);
									}

									if (snapshot.hasError || snapshot.data == null) {
										// Error logging already handled in API client
										return const SizedBox.shrink();
									}

									return Padding(
										padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
										child: Center(
											child: LimitedBox(
												maxWidth: MediaQuery.of(context).size.width - 32,
												child: Image.memory(
													snapshot.data!,
													fit: BoxFit.contain,
												),
											),
										),
									);
								},
							),
							loading: () => const Padding(
								padding: EdgeInsets.symmetric(vertical: 8),
								child: SizedBox.shrink(),
							),
							error: (error, stack) => const SizedBox.shrink(),
						),
				],
			),
		);
	}
}

