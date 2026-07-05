import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/localization.dart';
import '../providers/scouting_data_provider.dart';
import '../../../../models/field_descriptor.dart';

/// Widget that displays all movement counters in a collapsible table
/// Loops through descriptors with teleValuesTableDescription to build rows
class TeleValuesTable extends ConsumerStatefulWidget {
	const TeleValuesTable({Key? key}) : super(key: key);

	@override
	ConsumerState<TeleValuesTable> createState() => _TeleValuesTableState();
}

class _TeleValuesTableState extends ConsumerState<TeleValuesTable> {
	bool _expanded = false;

	String _translate(String key) {
		return AppLocalizations.translate(key, variables: {});
	}

	@override
	Widget build(BuildContext context) {
		final scoutingData = ref.watch(scoutingDataProvider);
		final teamColor = Colors.blue.shade700;

		// Get all descriptors with teleValuesTableDescription
		final counterDescriptors = scoutingData.descriptors
			.where((d) => d.teleValuesTableDescription != null)
			.toList();

		// Group by heading, maintaining order of first appearance
		final groupedByHeading = <String, List<FieldDescriptor>>{};
		for (final desc in counterDescriptors) {
			final heading = desc.teleValuesTableDescription!;
			groupedByHeading.putIfAbsent(heading, () => []).add(desc);
		}

		return Container(
			margin: const EdgeInsets.all(8),
			decoration: BoxDecoration(
				border: Border.all(color: teamColor.withOpacity(0.3)),
				borderRadius: BorderRadius.circular(8),
				color: Colors.grey.shade900.withOpacity(0.3),
			),
			child: Column(
				children: [
					// Header (collapsible)
					Material(
						color: teamColor.withOpacity(0.15),
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
												color: teamColor,
											),
										),
										Icon(
											_expanded
												? Icons.expand_less
												: Icons.expand_more,
											color: teamColor,
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
									...groupedByHeading.entries.toList().asMap().entries.expand((entry) {
										final index = entry.key;
										final descriptors = entry.value.value;
										final isLastGroup = index == groupedByHeading.length - 1;

										return [
											...descriptors.map((desc) =>
												_buildCounterRow(desc.name, desc.uiLabel)),
											if (!isLastGroup)
												const Divider(height: 1),
										];
									}),
								],
							),
						),
				],
			),
		);
	}

	/// Build a single counter row with +/- buttons
	Widget _buildCounterRow(String fieldName, String labelKey) {
		final scoutingData = ref.read(scoutingDataProvider);
		final value = scoutingData.getFieldValue(fieldName).asInt();

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
												? () {
													ref.read(scoutingDataProvider.notifier).recordTeleAction(
														field: fieldName,
														value: -1,
													);
												}
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
											onTap: () {
												ref.read(scoutingDataProvider.notifier).recordTeleAction(
													field: fieldName,
													value: 1,
												);
											},
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
