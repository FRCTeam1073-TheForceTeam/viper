import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../data/database/scout_database.dart';
import '../../providers/app_providers.dart';
import '../../services/scout_data_helper.dart';

class EndGameTab extends ConsumerStatefulWidget {
	final String eventId;
	final String? matchNumber;
	final String? teamNumber;

	const EndGameTab({
		Key? key,
		required this.eventId,
		required this.matchNumber,
		required this.teamNumber,
	}) : super(key: key);

	@override
	ConsumerState<EndGameTab> createState() => _EndGameTabState();
}

class _EndGameTabState extends ConsumerState<EndGameTab> {
	String? _climbMethod;
	int _damageState = 0;
	String? _defenseRating;
	String? _defenseImpact;

	bool _shootOnMove = false;
	bool _shootWhileCollecting = false;
	bool _climbing = false;

	late TextEditingController _shootingMissesController;
	late TextEditingController _scouterNameController;
	late TextEditingController _commentsController;
	bool _reviewRequest = false;
	ScoutData? _currentScout;

	@override
	void initState() {
		super.initState();
		_shootingMissesController = TextEditingController();
		_scouterNameController = TextEditingController();
		_commentsController = TextEditingController();
		_loadScout();
	}

	@override
	void dispose() {
		_shootingMissesController.dispose();
		_scouterNameController.dispose();
		_commentsController.dispose();
		super.dispose();
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
					_climbMethod = scout.climbMethod;
					_damageState = scout.damageState ?? 0;
					_defenseRating = scout.defenseRating;
					_defenseImpact = scout.defenseImpact;
					_shootOnMove = scout.shootOnMove;
					_shootWhileCollecting = scout.shootWhileCollecting;
					_climbing = scout.climbing;
					_shootingMissesController.text = (scout.shootingMissesRange ?? 0).toString();
					_scouterNameController.text = scout.scouterName ?? '';
					_commentsController.text = scout.comments ?? '';
					_reviewRequest = scout.reviewRequest;
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
						climbMethod: Value(_climbMethod),
						damageState: Value(_damageState),
						defenseRating: Value(_defenseRating),
						defenseImpact: Value(_defenseImpact),
						shootOnMove: _shootOnMove,
						shootWhileCollecting: _shootWhileCollecting,
						climbing: _climbing,
						shootingMissesRange: Value(int.tryParse(_shootingMissesController.text)),
						scouterName: Value(_scouterNameController.text),
						comments: Value(_commentsController.text),
						reviewRequest: _reviewRequest,
						updatedAt: now,
					)
				: ScoutDataHelper.createNewScout(
						event: widget.eventId,
						match: widget.matchNumber!,
						team: widget.teamNumber!,
					).copyWith(
						climbMethod: Value(_climbMethod),
						damageState: Value(_damageState),
						defenseRating: Value(_defenseRating),
						defenseImpact: Value(_defenseImpact),
						shootOnMove: _shootOnMove,
						shootWhileCollecting: _shootWhileCollecting,
						climbing: _climbing,
						shootingMissesRange: Value(int.tryParse(_shootingMissesController.text)),
						scouterName: Value(_scouterNameController.text),
						comments: Value(_commentsController.text),
						reviewRequest: _reviewRequest,
					);

		await db.upsertScout(scout);
		setState(() => _currentScout = scout);

		if (mounted) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('End Game data saved')),
			);
		}
	}

	@override
	Widget build(BuildContext context) {
		final climbMethods = ['Rungs', 'Uprights', 'Flip', 'No Climb'];
		final defenseRatings = ['Good', 'Bad', 'Great'];
		final defenseImpacts = ['Slowed', 'Unaffected', 'Turned tables'];

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
										'Robot Capabilities',
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 12),
									CheckboxListTile(
										title: const Text('Shoot on Move'),
										value: _shootOnMove,
										onChanged: (value) {
											setState(() => _shootOnMove = value ?? false);
										},
										contentPadding: EdgeInsets.zero,
									),
									CheckboxListTile(
										title: const Text('Shoot While Collecting'),
										value: _shootWhileCollecting,
										onChanged: (value) {
											setState(() => _shootWhileCollecting = value ?? false);
										},
										contentPadding: EdgeInsets.zero,
									),
									CheckboxListTile(
										title: const Text('Climbing'),
										value: _climbing,
										onChanged: (value) {
											setState(() => _climbing = value ?? false);
										},
										contentPadding: EdgeInsets.zero,
									),
								],
							),
						),
					),
					const SizedBox(height: 16),
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										'Climb Method',
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 12),
									Wrap(
										spacing: 8,
										runSpacing: 8,
										children: climbMethods.map((method) {
											final isSelected = _climbMethod == method;
											return FilterChip(
												label: Text(method),
												selected: isSelected,
												onSelected: (selected) {
													setState(() {
														_climbMethod = selected ? method : null;
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
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										'Damage State (0-100%)',
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 16),
									Slider(
										value: _damageState.toDouble(),
										min: 0,
										max: 100,
										divisions: 10,
										label: '$_damageState%',
										onChanged: (value) {
											setState(() => _damageState = value.toInt());
										},
									),
									Center(
										child: Text(
											'Damage: $_damageState%',
											style: Theme.of(context).textTheme.bodyLarge,
										),
									),
								],
							),
						),
					),
					const SizedBox(height: 16),
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										'Defense Rating',
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 12),
									Wrap(
										spacing: 8,
										runSpacing: 8,
										children: defenseRatings.map((rating) {
											final isSelected = _defenseRating == rating;
											return FilterChip(
												label: Text(rating),
												selected: isSelected,
												onSelected: (selected) {
													setState(() {
														_defenseRating = selected ? rating : null;
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
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										'Defense Impact',
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 12),
									Wrap(
										spacing: 8,
										runSpacing: 8,
										children: defenseImpacts.map((impact) {
											final isSelected = _defenseImpact == impact;
											return FilterChip(
												label: Text(impact),
												selected: isSelected,
												onSelected: (selected) {
													setState(() {
														_defenseImpact = selected ? impact : null;
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
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										'Shooting Misses Range',
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 12),
									TextFormField(
										controller: _shootingMissesController,
										decoration: const InputDecoration(
											labelText: 'Misses',
											border: OutlineInputBorder(),
										),
										keyboardType: TextInputType.number,
									),
								],
							),
						),
					),
					const SizedBox(height: 16),
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										'Scouter Info',
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 12),
									CheckboxListTile(
										title: const Text('Request Review'),
										subtitle: const Text('Fall asleep? Watch the wrong robot? Press the wrong button?'),
										value: _reviewRequest,
										onChanged: (value) {
											setState(() => _reviewRequest = value ?? false);
										},
										contentPadding: EdgeInsets.zero,
									),
									const SizedBox(height: 12),
									TextFormField(
										controller: _scouterNameController,
										decoration: const InputDecoration(
											labelText: 'Scouter Name',
											border: OutlineInputBorder(),
										),
										maxLength: 32,
									),
									const SizedBox(height: 12),
									TextFormField(
										controller: _commentsController,
										decoration: const InputDecoration(
											labelText: 'Comments',
											border: OutlineInputBorder(),
										),
										maxLines: 5,
										minLines: 3,
									),
								],
							),
						),
					),
					const SizedBox(height: 16),
					ElevatedButton.icon(
						onPressed: _saveTab,
						icon: const Icon(Icons.save),
						label: const Text('Save End Game'),
					),
				],
			),
		);
	}
}
