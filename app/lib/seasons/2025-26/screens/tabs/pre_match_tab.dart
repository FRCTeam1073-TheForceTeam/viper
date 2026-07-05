import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/scouting_data_provider.dart';
import '../../../../providers/locale_provider.dart';
import '../../../../services/localization.dart';
import '../../../../widgets/checkbox_button.dart';
import '../../../../widgets/radio_button_group.dart';
import '../../../../models/field_descriptor.dart';

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

		// Register translations for this tab
		AppLocalizations.addI18n({
			'starting_position': {
				'en': 'Starting Position:',
				'es': 'Posición inicial:',
				'pt': 'Posição Inicial:',
				'fr': 'Position de départ :',
				'zh_tw': '起始位置：',
				'he': 'עמדת התחלה:',
				'tr': 'Başlangıç ​​Pozisyonu:',
			},
			'at_goal': {
				'en': 'At Goal',
				'es': 'En la meta',
				'pt': 'No Gol',
				'fr': 'Au but',
				'zh_tw': '在目標位置',
				'he': 'בשער',
				'tr': 'Kalede',
			},
			'near_audience': {
				'en': 'Near Audience',
				'es': 'Cerca del público',
				'pt': 'Perto do Público',
				'fr': 'Près du public',
				'zh_tw': '靠近觀眾',
				'he': 'ליד הקהל',
				'tr': 'Seyirci Yakınında',
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
			'proceed_auto_button': {
				'en': 'Auto »',
				'es': 'Auto »',
				'pt': 'Auto »',
				'fr': 'Auto »',
				'zh_tw': '自動 »',
				'he': 'אוטו »',
				'tr': 'Otomatik »',
			},
		});
	}

	@override
	Widget build(BuildContext context) {
		ref.watch(selectedLocaleProvider);

		return SingleChildScrollView(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [
					CheckboxButton(
						descriptor: FieldDescriptor(name: 'no_show', uiLabelKey: 'no_show'),
						provider: scoutingDataProvider,
					),
					const SizedBox(height: 16),
					Text(
						_translate('starting_position'),
						style: Theme.of(context).textTheme.titleMedium,
					),
					const SizedBox(height: 12),
					RadioButtonGroup.forField(
						descriptor: FieldDescriptor(name: 'auto_start'),
						ref: ref,
						provider: scoutingDataProvider,
						options: [
							RadioButtonOption(value: 'goal', labelKey: 'at_goal'),
							RadioButtonOption(value: '1', labelKey: 'near_audience'),
						],
					),
					const SizedBox(height: 24),
					FilledButton(
						onPressed: widget.onProceedToAuto,
						child: Text(_translate('proceed_auto_button')),
					),
				],
			),
		);
	}
}
