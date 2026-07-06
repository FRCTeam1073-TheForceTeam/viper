import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../services/localization.dart';
import '../widgets/descriptor_text_field.dart';
import '../widgets/descriptor_text_area.dart';
import '../widgets/checkbox_button.dart';
import '../models/field_descriptor.dart';

/// Evergreen end-game data section with scouter name, comments, and save buttons.
/// Registers its own i18n translations.
class EndGameDataSection extends ConsumerStatefulWidget {
	final dynamic scoutingDataProvider;
	final VoidCallback? onNextMatch;
	final VoidCallback? onUpload;
	final VoidCallback? onQRCode;
	final String? featuredButton; // 'next', 'upload', 'qr', or null for equal buttons

	const EndGameDataSection({
		Key? key,
		required this.scoutingDataProvider,
		this.onNextMatch,
		this.onUpload,
		this.onQRCode,
		this.featuredButton,
	}) : super(key: key);

	@override
	ConsumerState<EndGameDataSection> createState() => _EndGameDataSectionState();
}

class _EndGameDataSectionState extends ConsumerState<EndGameDataSection> {
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
			'scouter_name_question': {
				'en': 'Scouter Name',
				'es': 'Nombre del explorador',
				'pt': 'Nome do Explorador',
				'fr': 'Nom de l\'éclaireur',
				'zh_tw': '偵查員名稱',
				'he': 'שם סקאוטר',
				'tr': 'İzci Adı',
			},
			'comments_question': {
				'en': 'Comments',
				'es': 'Comentarios',
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

		return Column(
			crossAxisAlignment: CrossAxisAlignment.stretch,
			children: [
				// Review requested checkbox, scouter name, and comments
				Card(
					child: Padding(
						padding: const EdgeInsets.all(16),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								CheckboxButton(
									descriptor: FieldDescriptor(name: 'review_requested', uiLabelKey: 'review_requested_button'),
									provider: widget.scoutingDataProvider,
								),
								const SizedBox(height: 16),
								DescriptorTextField.forField(
									descriptor: FieldDescriptor(name: 'scouter', uiLabelKey: 'scouter_name_question'),
									ref: ref,
									provider: widget.scoutingDataProvider,
									maxLength: 32,
								),
								const SizedBox(height: 16),
								DescriptorTextArea.forField(
									descriptor: FieldDescriptor(name: 'comments', uiLabelKey: 'comments_question'),
									ref: ref,
									provider: widget.scoutingDataProvider,
									minLines: 3,
									maxLines: 5,
								),
							],
						),
					),
				),
				const SizedBox(height: 24),

				// Save data buttons
				Card(
					child: Padding(
						padding: const EdgeInsets.all(16),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.stretch,
							children: [
								Text(
									_translate('save_data_question'),
									style: Theme.of(context).textTheme.titleMedium,
								),
								const SizedBox(height: 16),
								// Featured button
								if (widget.featuredButton == 'next' && widget.onNextMatch != null)
									FilledButton(
										onPressed: widget.onNextMatch,
										child: Text(_translate('next_match_button')),
									)
								else if (widget.featuredButton == 'upload' && widget.onUpload != null)
									FilledButton(
										onPressed: widget.onUpload,
										child: Text(_translate('upload_data_button')),
									)
								else if (widget.featuredButton == 'qr' && widget.onQRCode != null)
									FilledButton(
										onPressed: widget.onQRCode,
										child: Text(_translate('qr_code_button')),
									),
								if (widget.featuredButton != null) const SizedBox(height: 12),
								// Other buttons (smaller)
								Row(
									children: [
										if (widget.featuredButton != 'next' && widget.onNextMatch != null)
											Expanded(
												child: OutlinedButton(
													onPressed: widget.onNextMatch,
													child: Text(_translate('next_match_button')),
												),
											),
										if (widget.featuredButton != 'next' && widget.onNextMatch != null) const SizedBox(width: 8),
										if (widget.featuredButton != 'upload' && widget.onUpload != null)
											Expanded(
												child: OutlinedButton(
													onPressed: widget.onUpload,
													child: Text(_translate('upload_data_button')),
												),
											),
										if (widget.featuredButton != 'upload' && widget.onUpload != null) const SizedBox(width: 8),
										if (widget.featuredButton != 'qr' && widget.onQRCode != null)
											Expanded(
												child: OutlinedButton(
													onPressed: widget.onQRCode,
													child: Text(_translate('qr_code_button')),
												),
											),
									],
								),
							],
						),
					),
				),
			],
		);
	}
}
