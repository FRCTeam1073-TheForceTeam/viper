import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/localization.dart';
import '../providers/scouting_data_provider.dart';
import '../models/field_descriptor.dart';

/// A table showing readonly counter values for the auto period
/// Displays 12 counters in simple 2-column layout: Count | Description
class AutoValuesTable extends ConsumerWidget {
	const AutoValuesTable({super.key});

	String _translate(String key) {
		return AppLocalizations.translate(key, variables: {});
	}


	/// Build all rows: header plus rows grouped by autoValuesTableHeading
	List<TableRow> _buildRows(ScoutingData scoutingData) {
		final displayFields = scoutingData.descriptors
			.where((d) => d.autoValuesTableHeading != null || d.autoCountersTableDescription != null)
			.toList();

		// Group by heading (only fields with autoValuesTableHeading)
		final groupedByHeading = <String, List<FieldDescriptor>>{};
		final descriptionFields = <FieldDescriptor>[];

		for (final desc in displayFields) {
			if (desc.autoValuesTableHeading != null) {
				groupedByHeading.putIfAbsent(desc.autoValuesTableHeading!, () => []).add(desc);
			} else if (desc.autoCountersTableDescription != null) {
				descriptionFields.add(desc);
			}
		}

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
			// Data rows grouped by heading
			...groupedByHeading.entries.expand((entry) {
				final descriptors = entry.value;
				return descriptors.map((desc) => _buildRow(
					scoutingData.getFieldValue(desc.name).asInt(),
					desc.uiLabel,
				));
			}),
			// Zone change fields (ungrouped)
			...descriptionFields.map((desc) => _buildRow(
				scoutingData.getFieldValue(desc.name).asInt(),
				desc.uiLabel,
			)),
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
