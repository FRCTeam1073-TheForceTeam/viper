import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../services/localization.dart';

/// Widget that displays all 12 movement counters in a collapsible table
/// Users can view and adjust counter values
class AutoCountersTable extends StatefulWidget {
	/// Called when a counter is incremented/decremented
	final Function(String field, int delta) onCounterChanged;

	/// Current counter values
	final Map<String, int> counters;

	/// Locale for translations
	final String locale;

	/// Team color for styling (red or blue)
	final Color teamColor;

	const AutoCountersTable({
		Key? key,
		required this.onCounterChanged,
		this.counters = const {},
		this.locale = 'en',
		this.teamColor = AppColors.blueTeamColor,
	}) : super(key: key);

	@override
	State<AutoCountersTable> createState() => _AutoCountersTableState();
}

class _AutoCountersTableState extends State<AutoCountersTable> {
	bool _expanded = false;

	String _translate(String key) {
		return AppLocalizations.translate(key, variables: {});
	}

	@override
	Widget build(BuildContext context) {
		return Container(
			margin: const EdgeInsets.all(8),
			decoration: BoxDecoration(
				border: Border.all(color: widget.teamColor.withOpacity(0.3)),
				borderRadius: BorderRadius.circular(8),
				color: Colors.grey.shade900.withOpacity(0.3),
			),
			child: Column(
				children: [
					// Header (collapsible)
					Material(
						color: widget.teamColor.withOpacity(0.15),
						child: InkWell(
							onTap: () {
								setState(() => _expanded = !_expanded);
							},
							child: Padding(
								padding: const EdgeInsets.all(12),
								child: Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										Text(
											_translate('field_interactions'),
											style: TextStyle(
												fontSize: 14,
												fontWeight: FontWeight.bold,
												color: widget.teamColor,
											),
										),
										Icon(
											_expanded
												? Icons.expand_less
												: Icons.expand_more,
											color: widget.teamColor,
										),
									],
								),
							),
						),
					),

					// Expanded content
					if (_expanded)
						Container(
							padding: const EdgeInsets.all(8),
							child: Column(
								children: [
									_buildCounterRow(
										'auto_trench_depot_alliance_to_neutral',
										'trench_depot_alliance_to_neutral',
									),
									_buildCounterRow(
										'auto_bump_depot_alliance_to_neutral',
										'bump_depot_alliance_to_neutral',
									),
									_buildCounterRow(
										'auto_bump_outpost_alliance_to_neutral',
										'bump_outpost_alliance_to_neutral',
									),
									_buildCounterRow(
										'auto_trench_outpost_alliance_to_neutral',
										'trench_outpost_alliance_to_neutral',
									),
									const Divider(height: 1),
									_buildCounterRow(
										'auto_trench_depot_neutral_to_alliance',
										'trench_depot_neutral_to_alliance',
									),
									_buildCounterRow(
										'auto_bump_depot_neutral_to_alliance',
										'bump_depot_neutral_to_alliance',
									),
									_buildCounterRow(
										'auto_bump_outpost_neutral_to_alliance',
										'bump_outpost_neutral_to_alliance',
									),
									_buildCounterRow(
										'auto_trench_outpost_neutral_to_alliance',
										'trench_outpost_neutral_to_alliance',
									),
								],
							),
						),
				],
			),
		);
	}

	/// Build a single counter row with +/- buttons
	Widget _buildCounterRow(String fieldKey, String labelKey) {
		final value = widget.counters[fieldKey] ?? 0;

		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 8),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: [
					// Label
					Expanded(
						child: Text(
							_translate(labelKey),
							style: const TextStyle(fontSize: 12),
						),
					),

					// Counter controls
					Container(
						decoration: BoxDecoration(
							border: Border.all(color: Colors.grey.shade300),
							borderRadius: BorderRadius.circular(4),
						),
						child: Row(
							children: [
								// Minus button
								SizedBox(
									width: 36,
									height: 36,
									child: Material(
										color: Colors.grey.shade100,
										child: InkWell(
											onTap: value > 0
												? () => widget.onCounterChanged(fieldKey, -1)
												: null,
											child: const Icon(Icons.remove, size: 18),
										),
									),
								),

								// Counter value
								Container(
									width: 50,
									alignment: Alignment.center,
									child: Text(
										value.toString(),
										style: const TextStyle(
											fontWeight: FontWeight.bold,
											fontSize: 14,
										),
									),
								),

								// Plus button
								SizedBox(
									width: 36,
									height: 36,
									child: Material(
										color: Colors.blue.shade50,
										child: InkWell(
											onTap: () => widget.onCounterChanged(fieldKey, 1),
											child: Icon(
												Icons.add,
												size: 18,
												color: Colors.blue.shade700,
											),
										),
									),
								),
							],
						),
					),
				],
			),
		);
	}
}
