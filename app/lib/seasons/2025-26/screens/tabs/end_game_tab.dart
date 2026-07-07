import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/scouting_data_provider.dart';
import '../../../../providers/app_providers.dart';
import '../../../../providers/pre_match_provider.dart';
import '../../../../providers/timeline_provider.dart';
import '../../../../providers/locale_provider.dart';
import '../../../../services/localization.dart';
import '../../../../services/csv_builder.dart';
import '../../../../widgets/checkbox_button.dart';
import '../../../../widgets/radio_button_group.dart';
import '../../../../widgets/end_game_data_section.dart';
import '../../../../widgets/fieldset_legend.dart';
import '../../../../models/field_descriptor.dart';

class EndGameTab extends ConsumerStatefulWidget {
	final String eventId;
	final String? matchNumber;
	final String? teamNumber;
	final VoidCallback? onNextMatch;

	const EndGameTab({
		super.key,
		required this.eventId,
		required this.matchNumber,
		required this.teamNumber,
		this.onNextMatch,
	});

	@override
	ConsumerState<EndGameTab> createState() => _EndGameTabState();
}

class _EndGameTabState extends ConsumerState<EndGameTab> {
	String _translate(String key) {
		final locale = ref.read(selectedLocaleProvider);
		return AppLocalizations.translate(key, locale: locale);
	}

	@override
	void initState() {
		super.initState();

		// Register FTC-specific end-game translations (season-specific only)
		AppLocalizations.addI18n({
			'returned_base': {
				'en': 'Returned to base:',
				'es': 'Regresó a la base:',
				'pt': 'Retornou à base:',
				'fr': 'Retour à la base :',
				'zh_tw': '返回基地：',
				'he': 'חזר לבסיס:',
				'tr': 'Üsse Döndü:',
			},
			'returned_base_partially': {
				'en': 'Partially',
				'es': 'Parcialmente',
				'pt': 'Parcialmente',
				'fr': 'Partiellement',
				'zh_tw': '部分返回',
				'he': 'חלקית',
				'tr': 'Kısmen',
			},
			'returned_base_alone': {
				'en': 'Fully (other robot not fully-in)',
				'es': 'Completamente (otro robot no está completamente dentro)',
				'pt': 'Totalmente (outro robô não está totalmente dentro)',
				'fr': 'Complètement (autre robot non complètement à l\'intérieur)',
				'zh_tw': '完全返回（其他機器人未完全進入）',
				'he': 'במלואו (רובוט אחר לא בפנים במלואו)',
				'tr': 'Tamamen (diğer robot tamamen içeride değil)',
			},
			'returned_base_under': {
				'en': 'Fully and underneath fully-in robot',
				'es': 'Completamente y debajo del robot completamente dentro',
				'pt': 'Totalmente e abaixo do robô totalmente dentro',
				'fr': 'Complètement et sous le robot complètement à l\'intérieur',
				'zh_tw': '完全返回，且位於機器人下方',
				'he': 'בפנים במלואו ומתחת לרובוט בפנים במלואו',
				'tr': 'Tamamen ve tamamen içerideki robotun altında',
			},
			'returned_base_above': {
				'en': 'Fully and above fully-in robot',
				'es': 'Completamente y encima del robot completamente dentro',
				'pt': 'Totalmente e acima do robô totalmente dentro',
				'fr': 'Complètement et au-dessus du robot complètement à l\'intérieur',
				'zh_tw': '完全返回，且位於機器人上方',
				'he': 'בפנים במלואו ומעליו',
				'tr': 'Tamamen ve tamamente içerideki robotun üstünde',
			},
			'during_auto': {
				'en': 'During auto:',
				'es': 'Durante el auto:',
				'pt': 'Durante o modo automático:',
				'fr': 'Pendant l\'auto :',
				'zh_tw': '自動運行期間：',
				'he': 'במהלך אוטומטי:',
				'tr': 'Otomatik sırasında:',
			},
			'during_auto_obelisk': {
				'en': 'Scanned obelisk, created patterns matching motif',
				'es': 'Escaneo de obelisco, patrones creados que coinciden con el motivo',
				'pt': 'Escaneou o obelisco, criou padrões que correspondem ao motivo',
				'fr': 'Obélisque scanné, motifs correspondant au motif créés',
				'zh_tw': '掃描方尖碑，創造與圖案相符的圖案',
				'he': 'סרק אובליסק, יצר תבניות התואמות מוטיב',
				'tr': 'Dikilitaş tarandı, motifle eşleşen desenler oluşturuldu',
			},
			'during_auto_purple': {
				'en': 'Used only purple classified artifacts',
				'es': 'Solo utilizó artefactos clasificados como púrpura',
				'pt': 'Utilizou apenas artefatos classificados em roxo',
				'fr': 'Utilisation exclusive d\'artefacts classés violets',
				'zh_tw': '僅使用紫色分類文物',
				'he': 'השתמש רק בחפצים מסווגים סגולים',
				'tr': 'Sadece mor sınıflandırılmış eserler kullanıldı',
			},
			'during_auto_took_turns': {
				'en': 'Avoided simultaneous goal shooting during classification',
				'es': 'Evitó tiros simultáneos a la porteria durante la clasificación',
				'pt': 'Evitou chutes a gol simultâneos durante a classificação',
				'fr': 'Évitement de tirs simultanés au but pendant la classification',
				'zh_tw': '分類過程中避免同時射擊目標',
				'he': 'נמנע מקליעה בו זמנית לשער במהלך הסיווג',
				'tr': 'Sınıflandırma sırasında eş zamanlı kale atışlarından kaçınıldı',
			},
			'during_tele': {
				'en': 'During teleop:',
				'es': 'Durante tele:',
				'pt': 'Durante o teleoperador:',
				'fr': 'Pendant la téléopération :',
				'zh_tw': '遙控運轉期間：',
				'he': 'במהלך טלאופ:',
				'tr': 'Teleop sırasında:',
			},
			'during_tele_patterns': {
				'en': 'Created patterns matching motif',
				'es': 'Patrones creados que coinciden con el motivo',
				'pt': 'Criou padrões que correspondem ao motivo',
				'fr': 'Motifs correspondant au motif créés',
				'zh_tw': '創建與圖案相符的圖案',
				'he': 'יצר תבניות התואמות מוטיב',
				'tr': 'Motifle eşleşen desenler oluşturuldu',
			},
		});
	}

	Future<void> _saveCurrentMatch() async {
		try {
			final selectedEvent = ref.read(selectedEventProvider);
			final selectedMatch = ref.read(selectedMatchProvider);
			final db = await ref.read(databaseProvider.future);

			if (selectedEvent == null || selectedMatch.match == null || selectedMatch.team == null) {
				return;
			}

			final preMatch = ref.read(preMatchProvider);
			final scoutingData = ref.read(scoutingDataProvider);
			final timeline = ref.read(timelineProvider);

			final sessionStartTime = ref.read(scoutingSessionCreatedProvider)!;
			final originalCreatedTime = ref.read(originalCreatedProvider);
			final createdTime = originalCreatedTime ?? sessionStartTime;

			final scoutDataMap = <String, dynamic>{
				'event': selectedEvent,
				'match': selectedMatch.match,
				'team': selectedMatch.team,
				'created': createdTime,
				'modified': sessionStartTime,
			};

			scoutDataMap.addAll(preMatch.toMap());
			scoutDataMap.addAll(scoutingData.toMap());
			scoutDataMap['timeline'] = TimelineEvent.formatTimeline(timeline);

			final csv = CsvBuilder.buildScoutCsv([scoutDataMap]);
			final lines = csv.split('\n');
			if (lines.length < 2) return;

			final headers = lines[0];
			final data = lines[1];

			await db.insertUploadHistory(
				event: selectedEvent,
				match: selectedMatch.match!,
				team: selectedMatch.team!,
				csvHeaders: headers,
				csvData: data,
				status: 'pending',
			);

			ref.read(preMatchProvider.notifier).reset();
			ref.read(scoutingDataProvider.notifier).reset();
			ref.read(originalCreatedProvider.notifier).clear();
			ref.read(scoutingSessionCreatedProvider.notifier).clear();
		} catch (e) {
			// silent catch
		}
	}

	Future<void> _goToNextMatch() async {
		await _saveCurrentMatch();
		await (await SharedPreferences.getInstance()).setString('lastScoutAction', 'next');
		widget.onNextMatch?.call();
	}

	Future<void> _goToUpload() async {
		await _saveCurrentMatch();
		await (await SharedPreferences.getInstance()).setString('lastScoutAction', 'upload');
		if (mounted) {
			ref.read(navigationProvider.notifier).navigateTo(NavScreen.uploadData);
		}
	}

	Future<void> _goToQRCode() async {
		await _saveCurrentMatch();
		await (await SharedPreferences.getInstance()).setString('lastScoutAction', 'qr');
		if (mounted) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('QR Code feature coming soon')),
			);
		}
	}

	@override
	Widget build(BuildContext context) {
		ref.watch(selectedLocaleProvider);

		return SingleChildScrollView(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [
					FieldsetLegend(
						legendText: _translate('returned_base'),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								RadioButtonGroup.forField(
									descriptor: FieldDescriptor(name: 'base_return'),
									ref: ref,
									provider: scoutingDataProvider,
									options: [
										RadioButtonOption(value: 'partially', labelKey: 'returned_base_partially'),
										RadioButtonOption(value: 'alone', labelKey: 'returned_base_alone'),
										RadioButtonOption(value: 'under', labelKey: 'returned_base_under'),
										RadioButtonOption(value: 'above', labelKey: 'returned_base_above'),
									],
								),
							],
						),
					),
					const SizedBox(height: 16),
					FieldsetLegend(
						legendKey: 'during_auto',
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								RadioButtonGroup.forField(
									descriptor: FieldDescriptor(name: 'auto_patterns'),
									ref: ref,
									provider: scoutingDataProvider,
									options: [
										RadioButtonOption(value: 'obelisk', labelKey: 'during_auto_obelisk'),
										RadioButtonOption(value: 'purple', labelKey: 'during_auto_purple'),
									],
								),
								const SizedBox(height: 16),
								CheckboxButton(
									descriptor: FieldDescriptor(name: 'auto_took_turns', uiLabelKey: 'during_auto_took_turns'),
									provider: scoutingDataProvider,
								),
							],
						),
					),
					const SizedBox(height: 16),
					FieldsetLegend(
						legendKey: 'during_tele',
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								CheckboxButton(
									descriptor: FieldDescriptor(name: 'tele_patterns', uiLabelKey: 'during_tele_patterns'),
									provider: scoutingDataProvider,
								),
							],
						),
					),
					const SizedBox(height: 16),
					EndGameDataSection(
						scoutingDataProvider: scoutingDataProvider,
						onNextMatch: _goToNextMatch,
						onUpload: _goToUpload,
						onQRCode: _goToQRCode,
						featuredButton: 'next',
					),
				],
			),
		);
	}
}
