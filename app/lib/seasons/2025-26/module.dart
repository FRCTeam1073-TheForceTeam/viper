import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../season_module.dart';
import '../../providers/pre_match_provider.dart';
import 'providers/scouting_data_provider.dart';
import 'screens/tabs/pre_match_tab.dart';
import 'screens/tabs/auto_tab.dart';
import 'screens/tabs/teleop_tab.dart';
import 'screens/tabs/end_game_tab.dart';

class SeasonFtc202526Module implements SeasonModule {
	@override
	String get season => '2025-26';

	@override
	String get fieldImageAsset => 'assets/2025-26/images/field.png';

	@override
	int get autoPeriodMs => 30000;

	@override
	int get autoGapMs => 5000;

	@override
	List<String> get botPositions => const ['R1', 'R2', 'B1', 'B2'];

	@override
	Widget buildPreMatchTab({
		required String eventId,
		required String eventName,
		String? botPosition,
		required String? matchNumber,
		required String? teamNumber,
		required VoidCallback onProceedToAuto,
	}) {
		return PreMatchTab(
			eventId: eventId,
			eventName: eventName,
			botPosition: botPosition,
			matchNumber: matchNumber,
			teamNumber: teamNumber,
			onProceedToAuto: onProceedToAuto,
		);
	}

	@override
	Widget buildAutoTab({
		required String eventId,
		required String? matchNumber,
		required String? teamNumber,
		DateTime? matchStartTime,
		required void Function(DateTime) onStartMatch,
		required VoidCallback onProceedToTele,
	}) {
		return AutoTab(
			eventId: eventId,
			matchNumber: matchNumber,
			teamNumber: teamNumber,
			matchStartTime: matchStartTime,
			onStartMatch: onStartMatch,
			onProceedToTele: onProceedToTele,
		);
	}

	@override
	Widget buildTeleopTab({
		required String eventId,
		required String? matchNumber,
		required String? teamNumber,
		required VoidCallback onProceedToEndGame,
	}) {
		return TeleopTab(
			eventId: eventId,
			matchNumber: matchNumber,
			teamNumber: teamNumber,
			onProceedToEndGame: onProceedToEndGame,
		);
	}

	@override
	Widget buildEndGameTab({
		required String eventId,
		required String? matchNumber,
		required String? teamNumber,
		required VoidCallback onNextMatch,
	}) {
		return EndGameTab(
			eventId: eventId,
			matchNumber: matchNumber,
			teamNumber: teamNumber,
			onNextMatch: onNextMatch,
		);
	}

	@override
	void loadMatchData(WidgetRef ref, Map<String, dynamic> serverData) {
		ref.read(preMatchProvider.notifier).loadFromData(serverData);
		ref.read(scoutingDataProvider.notifier).loadFromServerData(serverData);
	}

	@override
	void resetMatchData(WidgetRef ref) {
		ref.read(preMatchProvider.notifier).reset();
		ref.read(scoutingDataProvider.notifier).reset();
	}
}
