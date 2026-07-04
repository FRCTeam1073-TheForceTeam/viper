import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/localization.dart';
import '../providers/scouting_data_provider.dart';

/// A table showing readonly counter values for the teleop period
/// Displays all tele counters in simple 2-column layout: Count | Description
class TeleValuesTable extends ConsumerWidget {
	const TeleValuesTable({super.key});

	String _translate(String key) {
		return AppLocalizations.translate(key, variables: {});
	}

	int _getValue(ScoutingData data, String fieldName) {
		return data.getFieldValue('tele_$fieldName').asInt();
	}

	/// Build all rows: 25 counter rows
	List<TableRow> _buildRows(ScoutingData scoutingData) {
		return [
			// Header row
			TableRow(
				decoration: const BoxDecoration(
					color: Color(0xFF555555),
				),
				children: [
					Padding(
						padding: const EdgeInsets.all(8),
						child: Text(
							'Count',
							style: const TextStyle(
								color: Color(0xFFDDDDDD),
								fontWeight: FontWeight.bold,
								fontSize: 12,
							),
						),
					),
					Padding(
						padding: const EdgeInsets.all(8),
						child: Text(
							'Description',
							style: const TextStyle(
								color: Color(0xFFDDDDDD),
								fontWeight: FontWeight.bold,
								fontSize: 12,
							),
						),
					),
				],
			),
			// Fuel scores
			_buildRow(_getValue(scoutingData, 'fuel_score'), 'fuel_score'),
			_buildRow(_getValue(scoutingData, 'fuel_alliance_dump'), 'fuel_alliance_dump'),
			_buildRow(_getValue(scoutingData, 'fuel_outpost'), 'fuel_outpost'),
			_buildRow(_getValue(scoutingData, 'fuel_neutral_alliance_pass'), 'fuel_neutral_pass'),
			_buildRow(_getValue(scoutingData, 'fuel_opponent_alliance_pass'), 'fuel_opponent_alliance_pass'),
			_buildRow(_getValue(scoutingData, 'fuel_opponent_neutral_pass'), 'fuel_opponent_neutral_pass'),
			// Movement: Alliance ↔ Neutral
			_buildRow(_getValue(scoutingData, 'trench_depot_alliance_to_neutral'), 'trench_depot_alliance_to_neutral'),
			_buildRow(_getValue(scoutingData, 'bump_depot_alliance_to_neutral'), 'bump_depot_alliance_to_neutral'),
			_buildRow(_getValue(scoutingData, 'bump_outpost_alliance_to_neutral'), 'bump_outpost_alliance_to_neutral'),
			_buildRow(_getValue(scoutingData, 'trench_outpost_alliance_to_neutral'), 'trench_outpost_alliance_to_neutral'),
			_buildRow(_getValue(scoutingData, 'trench_depot_neutral_to_alliance'), 'trench_depot_neutral_to_alliance'),
			_buildRow(_getValue(scoutingData, 'bump_depot_neutral_to_alliance'), 'bump_depot_neutral_to_alliance'),
			_buildRow(_getValue(scoutingData, 'bump_outpost_neutral_to_alliance'), 'bump_outpost_neutral_to_alliance'),
			_buildRow(_getValue(scoutingData, 'trench_outpost_neutral_to_alliance'), 'trench_outpost_neutral_to_alliance'),
			// Movement: Neutral ↔ Opponent
			_buildRow(_getValue(scoutingData, 'trench_outpost_neutral_to_opponent'), 'trench_outpost_neutral_to_opponent'),
			_buildRow(_getValue(scoutingData, 'bump_outpost_neutral_to_opponent'), 'bump_outpost_neutral_to_opponent'),
			_buildRow(_getValue(scoutingData, 'bump_depot_neutral_to_opponent'), 'bump_depot_neutral_to_opponent'),
			_buildRow(_getValue(scoutingData, 'trench_depot_neutral_to_opponent'), 'trench_depot_neutral_to_opponent'),
			_buildRow(_getValue(scoutingData, 'trench_outpost_opponent_to_neutral'), 'trench_outpost_opponent_to_neutral'),
			_buildRow(_getValue(scoutingData, 'bump_outpost_opponent_to_neutral'), 'bump_outpost_opponent_to_neutral'),
			_buildRow(_getValue(scoutingData, 'bump_depot_opponent_to_neutral'), 'bump_depot_opponent_to_neutral'),
			_buildRow(_getValue(scoutingData, 'trench_depot_opponent_to_neutral'), 'trench_depot_opponent_to_neutral'),
			// Zone times
			_buildRow(_getValue(scoutingData, 'alliance_time'), 'alliance_time'),
			_buildRow(_getValue(scoutingData, 'neutral_time'), 'neutral_time'),
			_buildRow(_getValue(scoutingData, 'opponent_time'), 'opponent_time'),
		];
	}

	/// Build a single data row
	TableRow _buildRow(int count, String labelKey) {
		return TableRow(
			decoration: const BoxDecoration(
				border: Border(
					bottom: BorderSide(
						color: Color(0xFF666666),
						width: 1,
					),
				),
			),
			children: [
				Padding(
					padding: const EdgeInsets.all(8),
					child: Text(
						count.toString(),
						style: const TextStyle(
							color: Color(0xFFDDDDDD),
							fontSize: 12,
							textBaseline: TextBaseline.alphabetic,
						),
						textAlign: TextAlign.right,
					),
				),
				Padding(
					padding: const EdgeInsets.all(8),
					child: Text(
						_translate(labelKey),
						style: const TextStyle(
							color: Color(0xFFDDDDDD),
							fontSize: 12,
						),
					),
				),
			],
		);
	}

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final scoutingData = ref.watch(scoutingDataProvider);

		return Container(
			margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
			decoration: const BoxDecoration(
				border: Border(
					top: BorderSide(color: Color(0xFF666666), width: 1),
					bottom: BorderSide(color: Color(0xFF666666), width: 1),
					left: BorderSide(color: Color(0xFF666666), width: 1),
					right: BorderSide(color: Color(0xFF666666), width: 1),
				),
			),
			child: Table(
				border: TableBorder.symmetric(
					inside: const BorderSide(
						color: Color(0xFF666666),
						width: 1,
					),
				),
				columnWidths: const {
					0: FlexColumnWidth(1),
					1: FlexColumnWidth(2),
				},
				children: _buildRows(scoutingData),
			),
		);
	}
}
