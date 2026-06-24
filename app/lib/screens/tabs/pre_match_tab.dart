import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../data/database/scout_database.dart';
import '../../providers/app_providers.dart';
import '../../services/scout_data_helper.dart';

class PreMatchTab extends ConsumerStatefulWidget {
	final String eventId;
	final String? matchNumber;
	final String? teamNumber;

	const PreMatchTab({
		Key? key,
		required this.eventId,
		required this.matchNumber,
		required this.teamNumber,
	}) : super(key: key);

	@override
	ConsumerState<PreMatchTab> createState() => _PreMatchTabState();
}

class _PreMatchTabState extends ConsumerState<PreMatchTab> {
	String? _selectedPosition;
	bool _noShow = false;
	ScoutData? _currentScout;

	@override
	void initState() {
		super.initState();
		_loadScout();
	}

	Future<void> _loadScout() async {
		if (widget.matchNumber != null && widget.teamNumber != null) {
			final db = await ref.read(databaseProvider.future);
			final scout = await db.getScout(
				widget.eventId,
				widget.matchNumber!,
				widget.teamNumber!,
			);
			if (scout != null) {
				setState(() {
					_currentScout = scout;
					_selectedPosition = scout.startingPosition;
					_noShow = scout.noShow;
				});
			}
		}
	}

	Future<void> _saveTab() async {
		if (widget.matchNumber == null || widget.teamNumber == null) return;

		final db = await ref.read(databaseProvider.future);
		final existing = _currentScout ?? await db.getScout(
			widget.eventId,
			widget.matchNumber!,
			widget.teamNumber!,
		);

		final now = DateTime.now();
		final scout = existing != null
				? existing.copyWith(
						startingPosition: Value(_selectedPosition),
						noShow: _noShow,
						updatedAt: now,
					)
				: ScoutDataHelper.createNewScout(
						event: widget.eventId,
						match: widget.matchNumber!,
						team: widget.teamNumber!,
					).copyWith(
						startingPosition: Value(_selectedPosition),
						noShow: _noShow,
					);

		await db.upsertScout(scout);
		setState(() => _currentScout = scout);

		if (mounted) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('Pre-Match data saved')),
			);
		}
	}

	@override
	Widget build(BuildContext context) {
		final positions = [
			'Alliance 1',
			'Alliance 2',
			'Neutral',
			'Opponent 1',
			'Opponent 2',
		];

		return SingleChildScrollView(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										'Starting Position',
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 16),
									Wrap(
										spacing: 8,
										runSpacing: 8,
										children: positions.map((pos) {
											final isSelected = _selectedPosition == pos;
											return FilterChip(
												label: Text(pos),
												selected: isSelected,
												onSelected: (selected) {
													setState(() {
														_selectedPosition = selected ? pos : null;
													});
												},
											);
										}).toList(),
									),
								],
							),
						),
					),
					const SizedBox(height: 16),
					Card(
						child: CheckboxListTile(
							title: const Text('No Show'),
							subtitle: const Text('Robot did not show up for match'),
							value: _noShow,
							onChanged: (value) {
								setState(() => _noShow = value ?? false);
							},
						),
					),
					const SizedBox(height: 16),
					ElevatedButton.icon(
						onPressed: _saveTab,
						icon: const Icon(Icons.save),
						label: const Text('Save Pre-Match'),
					),
				],
			),
		);
	}
}
