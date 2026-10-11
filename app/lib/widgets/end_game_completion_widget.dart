import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../providers/app_providers.dart';
import '../services/localization.dart';
import '../widgets/descriptor_text_field.dart';
import '../widgets/descriptor_text_area.dart';
import '../widgets/checkbox_button.dart';
import '../widgets/fieldset_legend.dart';
import '../models/field_descriptor.dart';
import '../constants/colors.dart';

/// End-game completion widget with scouter name, comments, and action buttons.
/// Handles finishing up end game scouting with review request, name, comments, and save/upload options.
/// Registers its own i18n translations.
class EndGameCompletionWidget extends ConsumerStatefulWidget {
	final dynamic scoutingDataProvider;
	final VoidCallback? onNextMatch;
	final VoidCallback? onUpload;
	final VoidCallback? onQRCode;
	final String? featuredButton; // 'next', 'upload', 'qr', or null for equal buttons

	const EndGameCompletionWidget({
		super.key,
		required this.scoutingDataProvider,
		this.onNextMatch,
		this.onUpload,
		this.onQRCode,
		this.featuredButton,
	});

	@override
	ConsumerState<EndGameCompletionWidget> createState() => _EndGameCompletionWidgetState();
}

class _EndGameCompletionWidgetState extends ConsumerState<EndGameCompletionWidget> {
	String _translate(String key) {
		final locale = ref.read(selectedLocaleProvider);
		return AppLocalizations.translate(key, locale: locale);
	}

	@override
	void initState() {
		super.initState();
		AppLocalizations.addI18n({
			'review_requested_button': {
				'en': 'Request Review',
				'es': 'Solicitar Revisión',
				'pt': 'Solicitar Revisão',
				'fr': 'Demander Examen',
				'zh_tw': '要求審查',
				'he': 'בקש סקירה',
				'tr': 'İnceleme İsteyin',
			},
			'review_requested_legend': {
				'en': 'Fall asleep? Watch the wrong robot? Press the wrong button?',
				'es': 'Este equipo solicitó revisión',
				'pt': 'Adormeceu? Assistiu ao robô errado? Pressionou o botão errado?',
				'fr': 'Vous vous êtes endormi ? Vous avez regardé le mauvais robot ? Vous avez appuyé sur le mauvais bouton ?',
				'zh_tw': '睡著了？看錯機器人？按錯按鈕了？',
				'he': 'נרדמת? צפה ברובוט הלא נכון? לחץ על הכפתור הלא נכון?',
				'tr': 'Uyudun mu? Yanlış robotu mu izliyorsun? Yanlış düğmeye mi bastınız?',
			},
			'scouter_name_question': {
				'en': 'Name:',
				'es': '¿Cuál es tu nombre?',
				'pt': 'Nome:',
				'fr': 'Nom :',
				'zh_tw': '姓名：',
				'he': 'שֵׁם:',
				'tr': 'Ad:',
			},
			'scouter_name_placeholder': {
				'en': 'Scouter Team, First name, Last initial, Eg. 1234 Pat Q',
				'es': 'Tu nombre...',
				'pt': 'Equipe do Scouter, Primeiro nome, Inicial do último, Ex.: 1234 Pat Q',
				'fr': 'Équipe du recruteur, Prénom, Initiale du nom, ex.: 1234 Pat Q',
				'zh_tw': '童子軍隊伍，名字，姓氏首字母，例如。 1234 還',
				'he': 'צוות צופים, שם פרטי, ראשי תיבות אחרון, למשל. 1234 Pat Q',
				'tr': 'Scouter Takımı, Adı, Soyadı, Örn. 1234 Pat Q',
			},
			'comments_question': {
				'en': 'Comments:',
				'es': '¿Comentarios?',
				'pt': 'Comentários:',
				'fr': 'Commentaires :',
				'zh_tw': '評論：',
				'he': 'הערות:',
				'tr': 'Yorumlar:',
			},
			'comments_placeholder': {
				'en': 'Comments',
				'es': 'Comentarios...',
				'pt': 'Comentários',
				'fr': 'Commentaires',
				'zh_tw': '評論',
				'he': 'הערות',
				'tr': 'Yorumlar',
			},
			'save_data_question': {
				'en': 'Save data:',
				'es': 'Guardar datos:',
				'pt': 'Salvar dados:',
				'fr': 'Sauvegarder les données :',
				'zh_tw': '儲存資料：',
				'he': 'שמור נתונים:',
				'tr': 'Verileri Kaydet:',
			},
			'next_match_button': {
				'en': 'Next Match',
				'es': 'Siguiente partida',
				'pt': 'Próxima partida',
				'fr': 'Prochain match',
				'zh_tw': '下一場比賽',
				'he': 'הקבוצה הבאה',
				'tr': 'Sonraki Maç',
			},
			'upload_data_button': {
				'en': 'Upload Data',
				'es': 'Cargar datos',
				'pt': 'Carregar dados',
				'fr': 'Télécharger les données',
				'zh_tw': '上傳數據',
				'he': 'העלה נתונים',
				'tr': 'Verileri Yükle',
			},
			'qr_code_button': {
				'en': 'QR Code',
				'es': 'Código QR',
				'pt': 'Código QR',
				'fr': 'Code QR',
				'zh_tw': '二維碼',
				'he': 'קוד QR',
				'tr': 'QR Kodu',
			},
		});
	}

	@override
	Widget build(BuildContext context) {
		ref.watch(selectedLocaleProvider);
		final localJsVariables = ref.watch(localJsVariablesProvider);

		return localJsVariables.when(
			data: (variables) {
				final showReviewRequest = variables['showReviewRequest'] as bool? ?? true;
				final showComments = variables['showScoutingComments'] as bool? ?? false;

				return Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						// Review requested checkbox with legend on border (conditional)
						if (showReviewRequest)
							Column(
								children: [
									FieldsetLegend(
										legendKey: 'review_requested_legend',
										child: Row(
											mainAxisSize: MainAxisSize.min,
											children: [
												CheckboxButton(
													descriptor: FieldDescriptor(name: 'review_requested', uiLabelKey: 'review_requested_button'),
													provider: widget.scoutingDataProvider,
												),
											],
										),
									),
									const SizedBox(height: 24),
								],
							),

						// Scouter name
						FieldsetLegend(
							legendKey: 'scouter_name_question',
							child: DescriptorTextField.forField(
								descriptor: FieldDescriptor(name: 'scouter', uiLabelKey: 'scouter_name_placeholder'),
								ref: ref,
								provider: widget.scoutingDataProvider,
								maxLength: 32,
							),
						),
						const SizedBox(height: 24),

						// Comments (conditional)
						if (showComments)
							Column(
								children: [
									FieldsetLegend(
										legendKey: 'comments_question',
										child: DescriptorTextArea.forField(
											descriptor: FieldDescriptor(name: 'comments', uiLabelKey: 'comments_placeholder'),
											ref: ref,
											provider: widget.scoutingDataProvider,
											minLines: 3,
											maxLines: 5,
										),
									),
									const SizedBox(height: 24),
								],
							),

						// Save data buttons
						FieldsetLegend(
							legendKey: 'save_data_question',
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.center,
								children: [
									// Featured button
									if (widget.featuredButton == 'next' && widget.onNextMatch != null)
										SizedBox(
											height: 60,
											child: FilledButton(
												style: FilledButton.styleFrom(
													backgroundColor: AppColors.buttonBgColor,
													foregroundColor: AppColors.buttonFgColor,
													padding: const EdgeInsets.symmetric(horizontal: 96),
													shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
												),
												onPressed: widget.onNextMatch,
												child: Text(_translate('next_match_button'), style: const TextStyle(fontSize: 20)),
											),
										)
									else if (widget.featuredButton == 'upload' && widget.onUpload != null)
										SizedBox(
											height: 60,
											child: FilledButton(
												style: FilledButton.styleFrom(
													backgroundColor: AppColors.buttonBgColor,
													foregroundColor: AppColors.buttonFgColor,
													padding: const EdgeInsets.symmetric(horizontal: 96),
													shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
												),
												onPressed: widget.onUpload,
												child: Text(_translate('upload_data_button'), style: const TextStyle(fontSize: 20)),
											),
										)
									else if (widget.featuredButton == 'qr' && widget.onQRCode != null)
										SizedBox(
											height: 60,
											child: FilledButton(
												style: FilledButton.styleFrom(
													backgroundColor: AppColors.buttonBgColor,
													foregroundColor: AppColors.buttonFgColor,
													padding: const EdgeInsets.symmetric(horizontal: 96),
													shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
												),
												onPressed: widget.onQRCode,
												child: Text(_translate('qr_code_button'), style: const TextStyle(fontSize: 20)),
											),
										),
									if (widget.featuredButton != null) const SizedBox(height: 12),
									// Other buttons (smaller)
									Row(
										mainAxisAlignment: MainAxisAlignment.center,
										children: [
											if (widget.featuredButton != 'next' && widget.onNextMatch != null)
												FilledButton(
														style: FilledButton.styleFrom(
															backgroundColor: AppColors.buttonBgColor,
															foregroundColor: AppColors.buttonFgColor,
															shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
														),
														onPressed: widget.onNextMatch,
														child: Text(_translate('next_match_button')),
													),
											if (widget.featuredButton != 'next' && widget.onNextMatch != null) const SizedBox(width: 8),
											if (widget.featuredButton != 'upload' && widget.onUpload != null)
												FilledButton(
														style: FilledButton.styleFrom(
															backgroundColor: AppColors.buttonBgColor,
															foregroundColor: AppColors.buttonFgColor,
															shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
														),
														onPressed: widget.onUpload,
														child: Text(_translate('upload_data_button')),
													),
											if (widget.featuredButton != 'upload' && widget.onUpload != null) const SizedBox(width: 8),
											if (widget.featuredButton != 'qr' && widget.onQRCode != null)
												FilledButton(
														style: FilledButton.styleFrom(
															backgroundColor: AppColors.buttonBgColor,
															foregroundColor: AppColors.buttonFgColor,
															shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
														),
														onPressed: widget.onQRCode,
														child: Text(_translate('qr_code_button')),
													),
										],
									),
								],
							),
						),
					],
				);
			},
			loading: () => const SizedBox.shrink(),
			error: (_, _) => const SizedBox.shrink(),
		);
	}
}
