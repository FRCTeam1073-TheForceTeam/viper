import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../providers/app_providers.dart';
import '../widgets/viper_menu_button.dart';

class MatchSelectionScreen extends ConsumerWidget {
	final Function(String matchNumber, String teamNumber) onMatchSelected;
	final String? botPosition;
	final VoidCallback? onChangeEvent;
	final VoidCallback? onChangeBotPosition;

	const MatchSelectionScreen({
		Key? key,
		required this.onMatchSelected,
		this.botPosition,
		this.onChangeEvent,
		this.onChangeBotPosition,
	}) : super(key: key);

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final matchesAsync = ref.watch(matchListProvider);

		return Scaffold(
			appBar: AppBar(
				title: const Text('Select Match'),
				centerTitle: true,
				elevation: 0,
				actions: [
					ViperMenuButton(
						onChangeEvent: onChangeEvent,
						onChangeBotPosition: onChangeBotPosition,
					),
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

							return ListView.builder(
								itemCount: matches.length,
								itemBuilder: (context, index) {
									final match = matches[index];
									final team = botPosition != null
											? match.getTeamForPosition(botPosition!)
											: null;

									if (team == null || team.isEmpty) {
										return const SizedBox.shrink();
									}

									// Mark as scouted if:
									// 1. It's explicitly in scoutedMatches, OR
									// 2. It's before or equal to the last scouted match
									final isScouted = scoutedMatchSet.contains(match.matchNumber) ||
										(lastScoutedMatch != null &&
											matches.indexWhere((m) => m.matchNumber == match.matchNumber) <=
											matches.indexWhere((m) => m.matchNumber == lastScoutedMatch));

									// Determine team color (R1-R3 = red, B1-B3 = blue)
									final isRedTeam = botPosition?.startsWith('R') ?? false;
									final teamBgColor = isRedTeam ? AppColors.redTeamColor : AppColors.blueTeamColor;

									return ListTile(
										title: Text('Match ${match.matchNumber}'),
										subtitle: Text('Team $team'),
										tileColor: isScouted ? AppColors.lowlightBgColor : teamBgColor,
										textColor: isScouted ? AppColors.highlightFgColor : AppColors.mainFgColor,
										trailing: isScouted
												? const Icon(Icons.check_circle, color: AppColors.highlightFgColor)
												: null,
										onTap: () {
											onMatchSelected(match.matchNumber, team);
										},
									);
								},
							);
						},
						loading: () => const Center(
							child: CircularProgressIndicator(),
						),
						error: (error, stack) => ListView.builder(
							itemCount: matches.length,
							itemBuilder: (context, index) {
								final match = matches[index];
								final team = botPosition != null
										? match.getTeamForPosition(botPosition!)
										: null;

								if (team == null || team.isEmpty) {
									return const SizedBox.shrink();
								}

								// Determine team color (R1-R3 = red, B1-B3 = blue)
								final isRedTeam = botPosition?.startsWith('R') ?? false;
								final teamBgColor = isRedTeam ? AppColors.redTeamColor : AppColors.blueTeamColor;

								return ListTile(
									title: Text('Match ${match.matchNumber}'),
									subtitle: Text('Team $team'),
									tileColor: teamBgColor,
									textColor: AppColors.mainFgColor,
									onTap: () {
										onMatchSelected(match.matchNumber, team);
									},
								);
							},
						),
					);
				},
				loading: () => const Center(
					child: CircularProgressIndicator(),
				),
				error: (error, stack) => Center(
					child: Text('Error loading matches: $error'),
				),
			),
		);
	}
}
