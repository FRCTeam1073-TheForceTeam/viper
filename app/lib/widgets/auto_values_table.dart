import 'package:flutter/material.dart';
import '../../services/localization.dart';

/// A table showing readonly counter values for the auto period
/// Displays 12 counters in simple 2-column layout: Count | Description
class AutoValuesTable extends StatelessWidget {
	/// Current counter values
	final int trenchDepotAllianceToNeutral;
	final int bumpDepotAllianceToNeutral;
	final int bumpOutpostAllianceToNeutral;
	final int trenchOutpostAllianceToNeutral;
	final int trenchDepotNeutralToAlliance;
	final int bumpDepotNeutralToAlliance;
	final int bumpOutpostNeutralToAlliance;
	final int trenchOutpostNeutralToAlliance;
	final int fuelScore;
	final int fuelNeutralAlliancePass;
	final int allianceTime;
	final int neutralTime;

	const AutoValuesTable({
		super.key,
		this.trenchDepotAllianceToNeutral = 0,
		this.bumpDepotAllianceToNeutral = 0,
		this.bumpOutpostAllianceToNeutral = 0,
		this.trenchOutpostAllianceToNeutral = 0,
		this.trenchDepotNeutralToAlliance = 0,
		this.bumpDepotNeutralToAlliance = 0,
		this.bumpOutpostNeutralToAlliance = 0,
		this.trenchOutpostNeutralToAlliance = 0,
		this.fuelScore = 0,
		this.fuelNeutralAlliancePass = 0,
		this.allianceTime = 0,
		this.neutralTime = 0,
	});

	String _translate(String key) {
		return AppLocalizations.translate(key, variables: {});
	}

	/// Build all rows: 12 counter rows
	List<TableRow> _buildRows() {
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
			_buildRow(fuelScore, 'auto_fuel_score'),
			// Fuel Neutral Pass
			_buildRow(fuelNeutralAlliancePass, 'auto_fuel_neutral_pass'),
			// Trench Depot A→N
			_buildRow(trenchDepotAllianceToNeutral, 'auto_trench_depot'),
			// Bump Depot A→N
			_buildRow(bumpDepotAllianceToNeutral, 'auto_bump_depot'),
			// Bump Outpost A→N
			_buildRow(bumpOutpostAllianceToNeutral, 'auto_bump_outpost'),
			// Trench Outpost A→N
			_buildRow(trenchOutpostAllianceToNeutral, 'auto_trench_outpost'),
			// Trench Depot N→A
			_buildRow(trenchDepotNeutralToAlliance, 'auto_trench_depot'),
			// Bump Depot N→A
			_buildRow(bumpDepotNeutralToAlliance, 'auto_bump_depot'),
			// Bump Outpost N→A
			_buildRow(bumpOutpostNeutralToAlliance, 'auto_bump_outpost'),
			// Trench Outpost N→A
			_buildRow(trenchOutpostNeutralToAlliance, 'auto_trench_outpost'),
			// Alliance Time
			_buildRow(allianceTime, 'auto_alliance_time'),
			// Neutral Time
			_buildRow(neutralTime, 'auto_neutral_time'),
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
	Widget build(BuildContext context) {
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
				children: _buildRows(),
			),
		);
	}
}
