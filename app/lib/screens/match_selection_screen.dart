import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

					return ref.watch(scoutListProvider).when(
						data: (scouts) {
							// Build set of scouted match+team combinations
							final scoutedMatches = <String>{};
							for (final scout in scouts) {
								scoutedMatches.add('${scout.match}_${scout.team}');
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

									final isScouted = scoutedMatches.contains('${match.matchNumber}_$team');

									return Card(
										margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
										child: ListTile(
											title: Text('Match ${match.matchNumber}'),
											subtitle: Text('Team $team'),
											trailing: isScouted
													? const Chip(
														label: Text('Scouted'),
														backgroundColor: Colors.grey,
													)
													: null,
											tileColor: isScouted ? Colors.grey[100] : null,
											onTap: () {
												onMatchSelected(match.matchNumber, team);
											},
										),
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

								return Card(
									margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
									child: ListTile(
										title: Text('Match ${match.matchNumber}'),
										subtitle: Text('Team $team'),
										onTap: () {
											onMatchSelected(match.matchNumber, team);
										},
									),
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
