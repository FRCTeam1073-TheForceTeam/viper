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
					if (matches.isEmpty) {
						return const Center(
							child: Text('No matches available'),
						);
					}

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
								itemCount: visibleMatches.length,
								itemBuilder: (context, index) {
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
