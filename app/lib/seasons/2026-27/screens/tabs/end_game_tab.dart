import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/scouting_data_provider.dart';
import '../../strings.dart';
import '../../../../providers/app_providers.dart';
import '../../../../providers/pre_match_provider.dart';
import '../../../../providers/timeline_provider.dart';
import '../../../../providers/locale_provider.dart';
import '../../../../services/csv_builder.dart';
import '../../../../widgets/checkbox_button.dart';
import '../../../../widgets/end_game_completion_widget.dart';
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
	@override
	void initState() {
		super.initState();
		registerSeasonStrings();
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
					CheckboxButton(
						descriptor: FieldDescriptor(name: 'end_park', uiLabelKey: 'end_park'),
						provider: scoutingDataProvider,
					),
					CheckboxButton(
						descriptor: FieldDescriptor(name: 'robot_disabled', uiLabelKey: 'robot_disabled'),
						provider: scoutingDataProvider,
					),
					const SizedBox(height: 16),
					EndGameCompletionWidget(
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
