import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';

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

	@override
	void initState() {
		super.initState();
		_shootingMissesController = TextEditingController();
		_scouterNameController = TextEditingController();
		_commentsController = TextEditingController();
	}

	@override
	void deactivate() {
		super.deactivate();
	}

	@override
	void dispose() {
		_shootingMissesController.dispose();
		_scouterNameController.dispose();
		_commentsController.dispose();
		super.dispose();
	}

	@override
	void didChangeDependencies() {
		super.didChangeDependencies();
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
				],
			),
		);
	}
}
