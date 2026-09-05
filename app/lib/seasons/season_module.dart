import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class SeasonModule {
	/// Season identifier: '2026' (FRC) or '2025-26' (FTC), matching EventModel.season
	String get season;

	/// Path to the field diagram asset for bot position selection
	/// e.g. 'assets/2026/images/field.png'
	String get fieldImageAsset;

	/// Autonomous period length in milliseconds, before the gap to teleop
	int get autoPeriodMs;

	/// Gap between autonomous ending and teleop being controllable, in milliseconds
	int get autoGapMs;

	/// Alliance position codes shown on the bot-selection screen for this season's robots-per-alliance count
	List<String> get botPositions;

	// Tab builders — signatures match the existing tab widget constructors
	Widget buildPreMatchTab({
		required String eventId,
		required String eventName,
		String? botPosition,
		required String? matchNumber,
		required String? teamNumber,
		required VoidCallback onProceedToAuto,
	});

	Widget buildAutoTab({
		required String eventId,
		required String? matchNumber,
		required String? teamNumber,
		DateTime? matchStartTime,
		required void Function(DateTime) onStartMatch,
		required VoidCallback onProceedToTele,
	});

	Widget buildTeleopTab({
		required String eventId,
		required String? matchNumber,
		required String? teamNumber,
		required VoidCallback onProceedToEndGame,
	});

	Widget buildEndGameTab({
		required String eventId,
		required String? matchNumber,
		required String? teamNumber,
		required VoidCallback onNextMatch,
	});

	/// Load match data from server into season-specific providers
	void loadMatchData(WidgetRef ref, Map<String, dynamic> serverData);

	/// Reset season-specific providers for a new match
	void resetMatchData(WidgetRef ref);
}
