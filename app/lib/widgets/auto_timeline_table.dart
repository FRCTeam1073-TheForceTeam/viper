import 'package:flutter/material.dart';
import '../../providers/auto_tab_controller.dart';
import '../../services/localization.dart';

/// Widget that displays the timeline of actions performed during auto
class AutoTimelineTable extends StatelessWidget {
	/// List of timeline events to display
	final List<TimelineEvent> events;

	const AutoTimelineTable({
		super.key,
		required this.events,
	});

	String _translate(String key) {
		return AppLocalizations.translate(key, variables: {});
	}

	/// Format time in seconds to MM:SS format
	String _formatTime(int seconds) {
		final minutes = seconds ~/ 60;
		final secs = seconds % 60;
		return '$minutes:${secs.toString().padLeft(2, '0')}';
	}

	/// Build all rows including header
	List<TableRow> _buildRows() {
		final rows = <TableRow>[];

		// Header row
		rows.add(
			TableRow(
				decoration: const BoxDecoration(
					color: Color(0xFF555555),
				),
				children: [
					Padding(
						padding: const EdgeInsets.all(8),
						child: Text(
							_translate('timeline_time_header'),
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
							_translate('timeline_action_header'),
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
							_translate('timeline_value_header'),
							style: const TextStyle(
								color: Color(0xFFDDDDDD),
								fontWeight: FontWeight.bold,
								fontSize: 12,
							),
						),
					),
				],
			),
		);

		// Data rows
		for (final event in events) {
			rows.add(
				TableRow(
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
								_formatTime(event.timeSeconds),
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
								event.action,
								style: const TextStyle(
									color: Color(0xFFDDDDDD),
									fontSize: 12,
								),
							),
						),
						Padding(
							padding: const EdgeInsets.all(8),
							child: Text(
								event.value,
								style: const TextStyle(
									color: Color(0xFFDDDDDD),
									fontSize: 12,
								),
							),
						),
					],
				),
			);
		}

		return rows;
	}

	@override
	Widget build(BuildContext context) {
		if (events.isEmpty) {
			return Container(
				margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
				padding: const EdgeInsets.all(16),
				decoration: const BoxDecoration(
					border: Border(
						top: BorderSide(color: Color(0xFF666666), width: 1),
						bottom: BorderSide(color: Color(0xFF666666), width: 1),
						left: BorderSide(color: Color(0xFF666666), width: 1),
						right: BorderSide(color: Color(0xFF666666), width: 1),
					),
				),
				child: Text(
					_translate('timeline_empty'),
					style: const TextStyle(
						color: Color(0xFFDDDDDD),
						fontStyle: FontStyle.italic,
						fontSize: 12,
					),
				),
			);
		}

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
					0: FixedColumnWidth(60),
					1: FlexColumnWidth(2),
					2: FlexColumnWidth(1),
				},
				children: _buildRows(),
			),
		);
	}
}
