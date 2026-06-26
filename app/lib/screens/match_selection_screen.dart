import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../providers/app_providers.dart';
import '../widgets/viper_menu_button.dart';
import '../utils/match_name_converter.dart';

class MatchSelectionScreen extends ConsumerStatefulWidget {
	final Function(String matchNumber, String teamNumber) onMatchSelected;
	final String? botPosition;

	const MatchSelectionScreen({
		Key? key,
		required this.onMatchSelected,
		this.botPosition,
	}) : super(key: key);

	@override
	ConsumerState<MatchSelectionScreen> createState() => _MatchSelectionScreenState();
}

class _MatchSelectionScreenState extends ConsumerState<MatchSelectionScreen> {
	late ScrollController _scrollController;
	late GlobalKey _scrollTargetKey;
	bool _hasScrolled = false;
	int _lastFirstUnscoutedIndex = -1;
	int _scrollRetries = 0;
	static const _maxScrollRetries = 15;

	@override
	void initState() {
		super.initState();
		_scrollController = ScrollController();
		_scrollTargetKey = GlobalKey();
	}

	@override
	void dispose() {
		_scrollController.dispose();
		super.dispose();
	}

	@override
	void didUpdateWidget(covariant MatchSelectionScreen oldWidget) {
		super.didUpdateWidget(oldWidget);
		// Reset scroll when widget updates (e.g., bot position changes)
		_hasScrolled = false;
		_scrollRetries = 0;
	}

	void _performScroll(int scrollTargetIndex, int firstUnscoutedIndex) {
		if (_hasScrolled || scrollTargetIndex < 0) return;

		if (_scrollTargetKey.currentContext != null) {
			final renderBox = _scrollTargetKey.currentContext!.findRenderObject() as RenderBox?;
			if (renderBox != null) {
				// Calculate exact scroll offset using measured item height
				final itemHeight = renderBox.size.height;
				final correctOffset = (scrollTargetIndex * itemHeight).toDouble();

				// Scroll to exact position using measured height
				_scrollController.animateTo(
					correctOffset,
					duration: const Duration(milliseconds: 300),
					curve: Curves.easeInOut,
				);
				_hasScrolled = true;
				_scrollRetries = 0;
			} else {
				// RenderBox not found, retry
				_scrollRetries++;
				SchedulerBinding.instance.scheduleFrameCallback((_) {
					_performScroll(scrollTargetIndex, firstUnscoutedIndex);
				});
			}
		} else if (_scrollRetries == 0) {
			// First retry: jump to approximate position to force item to render
			// Use 50px estimated height since we'll measure on next retry
			final approxItemHeight = 50.0;
			final approxOffset = (scrollTargetIndex * approxItemHeight).toDouble();
			_scrollController.jumpTo(approxOffset);
			_scrollRetries++;
			SchedulerBinding.instance.scheduleFrameCallback((_) {
				_performScroll(scrollTargetIndex, firstUnscoutedIndex);
			});
		} else if (_scrollRetries < _maxScrollRetries) {
			_scrollRetries++;
			SchedulerBinding.instance.scheduleFrameCallback((_) {
				_performScroll(scrollTargetIndex, firstUnscoutedIndex);
			});
		} else {
			_hasScrolled = true;
		}
	}

	void _showManualMatchEntryDialog(BuildContext context, WidgetRef ref) {
		final TextEditingController matchNumberController = TextEditingController();
		final TextEditingController teamNumberController = TextEditingController();
		final GlobalKey<FormState> formKey = GlobalKey<FormState>();
		String selectedMatchType = 'qm'; // Default to qualification

		const matchTypes = {
			'pm': 'Practice',
			'qm': 'Qualification',
			'qf': 'Quarter-final',
			'sf': 'Semi-final',
			'1p': 'Playoff Round 1',
			'2p': 'Playoff Round 2',
			'3p': 'Playoff Round 3',
			'4p': 'Playoff Round 4',
			'5p': 'Playoff Round 5',
			'f': 'Final',
		};

		showDialog(
			context: context,
			builder: (context) => StatefulBuilder(
				builder: (context, setState) => AlertDialog(
					title: const Text('Enter Match'),
					content: Form(
						key: formKey,
						child: Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								DropdownButtonFormField<String>(
									value: selectedMatchType,
									decoration: InputDecoration(
										labelText: 'Match Type',
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(8),
										),
									),
									onChanged: (value) {
										if (value != null) {
											setState(() => selectedMatchType = value);
										}
									},
									items: matchTypes.entries
										.map((e) => DropdownMenuItem(
											value: e.key,
											child: Text(e.value),
										))
									.toList(),
								),
								const SizedBox(height: 12),
								TextFormField(
									controller: matchNumberController,
									decoration: InputDecoration(
										labelText: 'Match Number',
										hintText: 'e.g., 5',
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(8),
										),
									),
									keyboardType: TextInputType.number,
									validator: (value) {
										if (value == null || value.isEmpty) {
											return 'Match number is required';
										}
										if (int.tryParse(value) == null) {
											return 'Must be a valid number';
										}
										return null;
									},
								),
								const SizedBox(height: 12),
								TextFormField(
									controller: teamNumberController,
									decoration: InputDecoration(
										labelText: 'Team Number',
										hintText: 'e.g., 2058',
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(8),
										),
									),
									keyboardType: TextInputType.number,
									validator: (value) {
										if (value == null || value.isEmpty) {
											return 'Team number is required';
										}
										if (int.tryParse(value) == null) {
											return 'Must be a valid number';
										}
										return null;
									},
								),
							],
						),
					),
					actions: [
						TextButton(
							onPressed: () {
								Navigator.pop(context);
							},
							child: const Text('Cancel'),
						),
						ElevatedButton(
							onPressed: () async {
								if (formKey.currentState!.validate()) {
									final matchNumber = matchNumberController.text.trim();
									final teamNumber = teamNumberController.text.trim();
									final matchId = '$selectedMatchType$matchNumber';
									Navigator.pop(context);

									try {
										widget.onMatchSelected(matchId, teamNumber);
									} catch (e) {
										if (context.mounted) {
											ScaffoldMessenger.of(context).showSnackBar(
												SnackBar(content: Text('Error: $e')),
											);
										}
									}
								}
							},
							child: const Text('Use Match'),
						),
					],
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		print('[SCREEN_BUILD] MatchSelectionScreen.build() called');
		final matchesAsync = ref.watch(matchListProvider);

		return Scaffold(
			appBar: AppBar(
				title: const Text('Select Match'),
				centerTitle: true,
				elevation: 0,
				automaticallyImplyLeading: false,
				actions: [
					ViperMenuButton(),
				],
			),
			body: matchesAsync.when(
				data: (matches) {
					return ref.watch(scoutedMatchesProvider).when(
						data: (scoutedMatchSet) {
							// Find the last (most recent) scouted match
							String? lastScoutedMatch;
							for (int i = matches.length - 1; i >= 0; i--) {
								if (scoutedMatchSet.contains(matches[i].matchNumber)) {
									lastScoutedMatch = matches[i].matchNumber;
									break;
								}
							}

							// Filter to only visible items (those with a team for this bot position)
							final visibleMatches = <(int arrayIndex, dynamic match)>[];
							for (int i = 0; i < matches.length; i++) {
								final match = matches[i];
								final team = widget.botPosition != null
										? match.getTeamForPosition(widget.botPosition!)
										: null;
								if (team != null && team.isNotEmpty) {
									visibleMatches.add((i, match));
								}
							}

							// Find first unscouted in visible list
							int firstUnscoutedIndex = -1;
							for (int i = 0; i < visibleMatches.length; i++) {
								final match = visibleMatches[i].$2;
								final isScouted = scoutedMatchSet.contains(match.matchNumber) ||
									(lastScoutedMatch != null &&
										matches.indexWhere((m) => m.matchNumber == match.matchNumber) <=
										matches.indexWhere((m) => m.matchNumber == lastScoutedMatch));
								if (!isScouted) {
									firstUnscoutedIndex = i;
									break;
								}
							}

							// Calculate scroll target (2 items before first unscouted)
							final scrollTargetIndex = firstUnscoutedIndex == -1
								? 0
								: (firstUnscoutedIndex - 2).clamp(0, visibleMatches.length - 1);

							// Reset scroll state if first unscouted changed
							if (firstUnscoutedIndex != _lastFirstUnscoutedIndex) {
								_hasScrolled = false;
								_scrollRetries = 0;
								_lastFirstUnscoutedIndex = firstUnscoutedIndex;
							}

							// Schedule scroll after frame is painted
							SchedulerBinding.instance.scheduleFrameCallback((_) {
								_performScroll(scrollTargetIndex, firstUnscoutedIndex);
							});

							return ListView.builder(
								controller: _scrollController,
							itemCount: visibleMatches.length + 1,
							itemBuilder: (context, index) {
								// Manual entry button at the bottom
								if (index == visibleMatches.length) {
									return Padding(
										padding: const EdgeInsets.all(16.0),
										child: ElevatedButton.icon(
											onPressed: () => _showManualMatchEntryDialog(context, ref),
											icon: const Icon(Icons.add),
											label: const Text('Add Match Manually'),
										),
									);
								}
									final match = visibleMatches[index].$2;
									final team = widget.botPosition != null
											? match.getTeamForPosition(widget.botPosition!)
											: null;

									// Mark as scouted if:
									// 1. It's explicitly in scoutedMatches, OR
									// 2. It's before or equal to the last scouted match
									final isScouted = scoutedMatchSet.contains(match.matchNumber) ||
										(lastScoutedMatch != null &&
											matches.indexWhere((m) => m.matchNumber == match.matchNumber) <=
											matches.indexWhere((m) => m.matchNumber == lastScoutedMatch));

									// Determine team color (R1-R3 = red, B1-B3 = blue)
									final isRedTeam = widget.botPosition?.startsWith('R') ?? false;
									final teamBgColor = isRedTeam ? AppColors.redTeamColor : AppColors.blueTeamColor;

									// When scouted, show dark background with green text
									final tileColor = isScouted ? AppColors.lowlightBgColor : AppColors.mainBgColor;
									final textColor = isScouted ? AppColors.highlightFgColor : AppColors.mainFgColor;

									return ListTile(
										key: index == scrollTargetIndex ? _scrollTargetKey : null,
										onTap: () {
											widget.onMatchSelected(match.matchNumber, team!);
										},
										tileColor: tileColor,
										leading: Container(
											padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
											decoration: BoxDecoration(
												color: isScouted ? AppColors.lowlightBgColor : teamBgColor,
												borderRadius: BorderRadius.circular(4),
											),
											child: Text(
												team!,
												style: TextStyle(
													color: textColor,
													fontWeight: FontWeight.bold,
												),
											),
										),
										title: Text(
											getShortMatchName(match.matchNumber),
											style: TextStyle(color: textColor),
										),
									);
								},
							);
						},
						loading: () => const Center(
							child: CircularProgressIndicator(),
						),
						error: (error, stack) => const Center(
							child: Text('Error loading scouted matches'),
						),
					);
				},
				loading: () => const Center(
					child: CircularProgressIndicator(),
				),
				error: (error, stack) => const Center(
					child: Text('Error loading matches'),
				),
			),
		);
	}
}
