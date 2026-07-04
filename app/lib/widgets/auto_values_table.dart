import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/localization.dart';
import '../../providers/scouting_data_provider.dart';

/// A table showing readonly counter values for the auto period
/// Displays 12 counters in simple 2-column layout: Count | Description
class AutoValuesTable extends ConsumerWidget {
	const AutoValuesTable({super.key});

	String _translate(String key) {
		return AppLocalizations.translate(key, variables: {});
	}

	int _getValue(ScoutingData data, String fieldName) {
		return data.getFieldValue('auto_$fieldName').asInt();
	}

	/// Build all rows: 12 counter rows
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
			// Fuel Score
			_buildRow(_getValue(scoutingData, 'fuel_score'), 'fuel_score'),
			// Fuel Neutral Pass
			_buildRow(_getValue(scoutingData, 'fuel_neutral_alliance_pass'), 'fuel_neutral_alliance_pass'),
			// Trench Depot A→N
			_buildRow(_getValue(scoutingData, 'trench_depot_alliance_to_neutral'), 'trench_depot_alliance_to_neutral'),
			// Bump Depot A→N
			_buildRow(_getValue(scoutingData, 'bump_depot_alliance_to_neutral'), 'bump_depot_alliance_to_neutral'),
			// Bump Outpost A→N
			_buildRow(_getValue(scoutingData, 'bump_outpost_alliance_to_neutral'), 'bump_outpost_alliance_to_neutral'),
			// Trench Outpost A→N
			_buildRow(_getValue(scoutingData, 'trench_outpost_alliance_to_neutral'), 'trench_outpost_alliance_to_neutral'),
			// Trench Depot N→A
			_buildRow(_getValue(scoutingData, 'trench_depot_neutral_to_alliance'), 'trench_depot_neutral_to_alliance'),
			// Bump Depot N→A
			_buildRow(_getValue(scoutingData, 'bump_depot_neutral_to_alliance'), 'bump_depot_neutral_to_alliance'),
			// Bump Outpost N→A
			_buildRow(_getValue(scoutingData, 'bump_outpost_neutral_to_alliance'), 'bump_outpost_neutral_to_alliance'),
			// Trench Outpost N→A
			_buildRow(_getValue(scoutingData, 'trench_outpost_neutral_to_alliance'), 'trench_outpost_neutral_to_alliance'),
			// Alliance Time
			_buildRow(_getValue(scoutingData, 'alliance_time'), 'alliance_time'),
			// Neutral Time
			_buildRow(_getValue(scoutingData, 'neutral_time'), 'neutral_time'),
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
