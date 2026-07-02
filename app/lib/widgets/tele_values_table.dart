import 'package:flutter/material.dart';
import '../../services/localization.dart';

/// A table showing readonly counter values for the teleop period
/// Displays all tele counters in simple 2-column layout: Count | Description
class TeleValuesTable extends StatelessWidget {
	/// Movement counters (alliance ↔ neutral)
	final int trenchDepotAllianceToNeutral;
	final int bumpDepotAllianceToNeutral;
	final int bumpOutpostAllianceToNeutral;
	final int trenchOutpostAllianceToNeutral;
	final int trenchDepotNeutralToAlliance;
	final int bumpDepotNeutralToAlliance;
	final int bumpOutpostNeutralToAlliance;
	final int trenchOutpostNeutralToAlliance;

	/// Movement counters (neutral ↔ opponent)
	final int trenchOutpostNeutralToOpponent;
	final int bumpOutpostNeutralToOpponent;
	final int bumpDepotNeutralToOpponent;
	final int trenchDepotNeutralToOpponent;
	final int trenchOutpostOpponentToNeutral;
	final int bumpOutpostOpponentToNeutral;
	final int bumpDepotOpponentToNeutral;
	final int trenchDepotOpponentToNeutral;

	/// Fuel counters
	final int fuelScore;
	final int fuelAllianceDump;
	final int fuelOutpost;
	final int fuelNeutralAlliancePass;
	final int fuelOpponentNeutralPass;
	final int fuelOpponentAlliancePass;

	/// Zone times
	final int allianceTime;
	final int neutralTime;
	final int opponentTime;

	const TeleValuesTable({
		super.key,
		this.trenchDepotAllianceToNeutral = 0,
		this.bumpDepotAllianceToNeutral = 0,
		this.bumpOutpostAllianceToNeutral = 0,
		this.trenchOutpostAllianceToNeutral = 0,
		this.trenchDepotNeutralToAlliance = 0,
		this.bumpDepotNeutralToAlliance = 0,
		this.bumpOutpostNeutralToAlliance = 0,
		this.trenchOutpostNeutralToAlliance = 0,
		this.trenchOutpostNeutralToOpponent = 0,
		this.bumpOutpostNeutralToOpponent = 0,
		this.bumpDepotNeutralToOpponent = 0,
		this.trenchDepotNeutralToOpponent = 0,
		this.trenchOutpostOpponentToNeutral = 0,
		this.bumpOutpostOpponentToNeutral = 0,
		this.bumpDepotOpponentToNeutral = 0,
		this.trenchDepotOpponentToNeutral = 0,
		this.fuelScore = 0,
		this.fuelAllianceDump = 0,
		this.fuelOutpost = 0,
		this.fuelNeutralAlliancePass = 0,
		this.fuelOpponentNeutralPass = 0,
		this.fuelOpponentAlliancePass = 0,
		this.allianceTime = 0,
		this.neutralTime = 0,
		this.opponentTime = 0,
	});

	String _translate(String key) {
		return AppLocalizations.translate(key, variables: {});
	}

	/// Build all rows: 25 counter rows
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
			// Fuel scores
			_buildRow(fuelScore, 'fuel_score'),
			_buildRow(fuelAllianceDump, 'fuel_alliance_dump'),
			_buildRow(fuelOutpost, 'fuel_outpost'),
			_buildRow(fuelNeutralAlliancePass, 'fuel_neutral_pass'),
			_buildRow(fuelOpponentAlliancePass, 'fuel_opponent_alliance_pass'),
			_buildRow(fuelOpponentNeutralPass, 'fuel_opponent_neutral_pass'),
			// Movement: Alliance ↔ Neutral
			_buildRow(trenchDepotAllianceToNeutral, 'trench_depot_alliance_to_neutral'),
			_buildRow(bumpDepotAllianceToNeutral, 'bump_depot_alliance_to_neutral'),
			_buildRow(bumpOutpostAllianceToNeutral, 'bump_outpost_alliance_to_neutral'),
			_buildRow(trenchOutpostAllianceToNeutral, 'trench_outpost_alliance_to_neutral'),
			_buildRow(trenchDepotNeutralToAlliance, 'trench_depot_neutral_to_alliance'),
			_buildRow(bumpDepotNeutralToAlliance, 'bump_depot_neutral_to_alliance'),
			_buildRow(bumpOutpostNeutralToAlliance, 'bump_outpost_neutral_to_alliance'),
			_buildRow(trenchOutpostNeutralToAlliance, 'trench_outpost_neutral_to_alliance'),
			// Movement: Neutral ↔ Opponent
			_buildRow(trenchOutpostNeutralToOpponent, 'trench_outpost_neutral_to_opponent'),
			_buildRow(bumpOutpostNeutralToOpponent, 'bump_outpost_neutral_to_opponent'),
			_buildRow(bumpDepotNeutralToOpponent, 'bump_depot_neutral_to_opponent'),
			_buildRow(trenchDepotNeutralToOpponent, 'trench_depot_neutral_to_opponent'),
			_buildRow(trenchOutpostOpponentToNeutral, 'trench_outpost_opponent_to_neutral'),
			_buildRow(bumpOutpostOpponentToNeutral, 'bump_outpost_opponent_to_neutral'),
			_buildRow(bumpDepotOpponentToNeutral, 'bump_depot_opponent_to_neutral'),
			_buildRow(trenchDepotOpponentToNeutral, 'trench_depot_opponent_to_neutral'),
			// Zone times
			_buildRow(allianceTime, 'alliance_time'),
			_buildRow(neutralTime, 'neutral_time'),
			_buildRow(opponentTime, 'opponent_time'),
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
