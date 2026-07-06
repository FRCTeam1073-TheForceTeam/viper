import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/scouting_data_provider.dart';
import '../../providers/undo_coordinator.dart';
import '../../widgets/artifact_preset_checkbox.dart';
import '../../../../providers/app_providers.dart';
import '../../../../providers/locale_provider.dart';
import '../../../../providers/floating_popup_provider.dart';
import '../../../../services/localization.dart';
import '../../../../constants/colors.dart';
import '../../../../widgets/checkbox_button.dart';
import '../../../../widgets/counter_button_row.dart';
import '../../../../widgets/popup_floater.dart';
import '../../../../models/field_descriptor.dart';

class AutoTab extends ConsumerStatefulWidget {
	final String eventId;
	final String? matchNumber;
	final String? teamNumber;
	final DateTime? matchStartTime;
	final void Function(DateTime) onStartMatch;

	const AutoTab({
		Key? key,
		required this.eventId,
		required this.matchNumber,
		required this.teamNumber,
		this.matchStartTime,
		required this.onStartMatch,
	}) : super(key: key);

	@override
	ConsumerState<AutoTab> createState() => _AutoTabState();
}

class _AutoTabState extends ConsumerState<AutoTab> {
	late GlobalKey<State<StatefulWidget>> _undoButtonKey;

	String _translate(String key, {Map<String, String>? variables}) {
		final locale = ref.read(selectedLocaleProvider);
		return AppLocalizations.translate(key, locale: locale, variables: variables);
	}

	@override
	void initState() {
		super.initState();
		_undoButtonKey = GlobalKey();

		// Register translations for this tab
		AppLocalizations.addI18n({
			'auto_leave': {
				'en': 'Left the starting line during auto',
				'es': 'Salió de la línea de salida durante el auto',
				'pt': 'Saiu da linha de partida durante o modo automático',
				'fr': 'A quitté la ligne de départ pendant l\'auto',
				'zh_tw': '自動運行期間離開起始線',
				'he': 'עזב את קו ההתחלה במהלך האוטומטי',
				'tr': 'Otomatik sırasında başlangıç çizgisinden ayrıldı',
			},
			'use_preset': {
				'en': 'Use preset:',
				'es': 'Usar preestablecido:',
				'pt': 'Usar predefinição:',
				'fr': 'Utilisation du préréglage :',
				'zh_tw': '使用預設位置：',
				'he': 'השתמש בהגדרה מוגדרת מראש:',
				'tr': 'Ön Ayarı Kullan:',
			},
			'in_goal': {
				'en': 'In goal:',
				'es': 'En la meta:',
				'pt': 'No gol:',
				'fr': 'Dans le but :',
				'zh_tw': '在目標位置：',
				'he': 'בתוך השער:',
				'tr': 'Kalede:',
			},
			'in_depot': {
				'en': 'In depot:',
				'es': 'En el depósito:',
				'pt': 'No depósito:',
				'fr': 'Au dépôt :',
				'zh_tw': '在倉庫位置：',
				'he': 'בתוך המחסן:',
				'tr': 'Depoda:',
			},
			'opened_gate': {
				'en': 'Opened gate:',
				'es': 'Puerta abierta:',
				'pt': 'Portão aberto:',
				'fr': 'Porte ouverte :',
				'zh_tw': '大門打開：',
				'he': 'שער פתוח:',
				'tr': 'Kapı Açıldı:',
			},
			'proceed_tele_button': {
				'en': 'Teleop »',
				'es': 'Teleop »',
				'pt': 'Teleop »',
				'fr': 'Téléop »',
				'zh_tw': '遠程 »',
				'he': 'טלאופ »',
				'tr': 'Tele-op »',
			},
			'undo': {
				'en': 'Undo',
				'es': 'Deshacer',
				'pt': 'Desfazer',
				'fr': 'Annuler',
				'zh_tw': '撤銷',
				'he': 'בטל',
				'tr': 'Geri Al',
			},
		});
	}

	void _startMatchIfNeeded() {
		if (widget.matchStartTime == null) {
			widget.onStartMatch(DateTime.now());
			ref.read(scoutingDataProvider.notifier).syncStartTime(DateTime.now());
		}
	}

	@override
	Widget build(BuildContext context) {
		ref.watch(selectedLocaleProvider);
		final scoutingData = ref.watch(scoutingDataProvider);
		final botPosition = ref.watch(selectedBotPositionProvider);
		final isBlueTeam = botPosition?.startsWith('B') ?? false;

		return Stack(
			children: [
				SingleChildScrollView(
					padding: const EdgeInsets.all(16),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							FilledButton(
								key: _undoButtonKey,
								onPressed: () => undoLastAction(ref, context, _undoButtonKey),
								style: FilledButton.styleFrom(
									backgroundColor: AppColors.buttonBgColor,
									foregroundColor: AppColors.buttonFgColor,
								),
								child: Text(_translate('undo')),
							),
							const SizedBox(height: 16),
							CheckboxButton(
								descriptor: FieldDescriptor(name: 'auto_leave', uiLabelKey: 'auto_leave'),
								provider: scoutingDataProvider,
							),
							const SizedBox(height: 16),
							Text(_translate('use_preset'), style: Theme.of(context).textTheme.titleSmall),
							const SizedBox(height: 12),
							ArtifactPresetCheckbox(
								fieldName: 'auto_preset_4',
								icons: const [ArtifactColor.green, ArtifactColor.purple, ArtifactColor.purple],
								direction: Axis.horizontal,
								mirrorForBlue: true,
								isBlueTeam: isBlueTeam,
								provider: scoutingDataProvider,
								onTap: _startMatchIfNeeded,
							),
							ArtifactPresetCheckbox(
								fieldName: 'auto_preset_3',
								icons: const [ArtifactColor.purple, ArtifactColor.green, ArtifactColor.purple],
								direction: Axis.horizontal,
								mirrorForBlue: false,
								isBlueTeam: isBlueTeam,
								provider: scoutingDataProvider,
								onTap: _startMatchIfNeeded,
							),
							ArtifactPresetCheckbox(
								fieldName: 'auto_preset_2',
								icons: const [ArtifactColor.purple, ArtifactColor.purple, ArtifactColor.green],
								direction: Axis.horizontal,
								mirrorForBlue: true,
								isBlueTeam: isBlueTeam,
								provider: scoutingDataProvider,
								onTap: _startMatchIfNeeded,
							),
							ArtifactPresetCheckbox(
								fieldName: 'auto_preset_1',
								icons: const [ArtifactColor.purple, ArtifactColor.green, ArtifactColor.purple],
								direction: Axis.vertical,
								mirrorForBlue: false,
								isBlueTeam: isBlueTeam,
								provider: scoutingDataProvider,
								onTap: _startMatchIfNeeded,
							),
							const SizedBox(height: 16),
							CounterButtonRow(
								labelKey: 'in_goal',
								value: scoutingData.getFieldValue('auto_goal').asInt(),
								amounts: const [1, 2, 3],
								onAmountTapped: (amount, globalPos) {
									_startMatchIfNeeded();
									ref.read(scoutingDataProvider.notifier).recordAutoAction(field: 'auto_goal', value: amount);
									final stackBox = context.findRenderObject() as RenderBox?;
									if (stackBox != null) {
										final rel = globalPos - stackBox.localToGlobal(Offset.zero);
										ref.read(floatingPopupProvider.notifier).addPopup('+$amount', rel.dx, rel.dy);
									}
								},
							),
							CounterButtonRow(
								labelKey: 'in_depot',
								value: scoutingData.getFieldValue('auto_depot').asInt(),
								amounts: const [1, 2, 3],
								onAmountTapped: (amount, globalPos) {
									_startMatchIfNeeded();
									ref.read(scoutingDataProvider.notifier).recordAutoAction(field: 'auto_depot', value: amount);
									final stackBox = context.findRenderObject() as RenderBox?;
									if (stackBox != null) {
										final rel = globalPos - stackBox.localToGlobal(Offset.zero);
										ref.read(floatingPopupProvider.notifier).addPopup('+$amount', rel.dx, rel.dy);
									}
								},
							),
							CounterButtonRow(
								labelKey: 'opened_gate',
								value: scoutingData.getFieldValue('auto_gate').asInt(),
								amounts: const [1],
								onAmountTapped: (amount, globalPos) {
									_startMatchIfNeeded();
									ref.read(scoutingDataProvider.notifier).recordAutoAction(field: 'auto_gate', value: amount);
									final stackBox = context.findRenderObject() as RenderBox?;
									if (stackBox != null) {
										final rel = globalPos - stackBox.localToGlobal(Offset.zero);
										ref.read(floatingPopupProvider.notifier).addPopup('+$amount', rel.dx, rel.dy);
									}
								},
							),
							const SizedBox(height: 24),
							FilledButton(
								style: FilledButton.styleFrom(
									backgroundColor: AppColors.buttonBgColor,
									foregroundColor: AppColors.buttonFgColor,
								),
								onPressed: () {}, // wired by scouting_app_screen.dart
								child: Text(_translate('proceed_tele_button')),
							),
						],
					),
				),
				// PopupFloater stack for floating numbers
				PopupFloaterWidget(),
			],
		);
	}
}

/// Simple popup floater for the +N animations
class PopupFloaterWidget extends ConsumerWidget {
	const PopupFloaterWidget({super.key});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final floatingPopups = ref.watch(floatingPopupProvider);

		return Stack(
			children: floatingPopups.map((popup) {
				return PopupFloater(
					text: popup.text,
					initialX: popup.initialX,
					initialY: popup.initialY,
					onAnimationComplete: () {
						ref.read(floatingPopupProvider.notifier).removePopup(popup.id);
					},
				);
			}).toList(),
		);
	}
}
