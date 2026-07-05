import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class SeasonModule {
	/// Season identifier: '2026' (FRC) or '2025-26' (FTC), matching EventModel.season
	String get season;

	/// Path to the field diagram asset for bot position selection
	/// e.g. 'assets/2026/images/field.png'
	String get fieldImageAsset;

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
	});

	Widget buildTeleopTab({
		required String eventId,
		required String? matchNumber,
		required String? teamNumber,
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
