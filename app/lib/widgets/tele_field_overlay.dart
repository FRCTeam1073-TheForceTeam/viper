import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../providers/field_side_provider.dart';
import '../../providers/floating_popup_provider.dart';
import '../../providers/zone_buttons_provider.dart';
import '../../providers/button_position_provider.dart';
import '../../constants/colors.dart';
import '../models/field_button.dart';
import '../models/field_descriptor.dart';

/// Zone change buttons for tele phase
final teleZoneChangeButtons = <FieldButton>[
	// ============ ALLIANCE → NEUTRAL (Exit to Neutral) ============
	FieldButton(
		field: 'tele_trench_depot_alliance_to_neutral',
		label: 'Depot Trench to Neutral',
		rightPercent: 26.0,
		bottomPercent: 5.0,
		imagePath: 'assets/images/arrow-left.png',
		zone: 'alliance',
		widthPercent: 7.0,
		aspectRatio: 1.0,
		descriptor: FieldDescriptor(
			name: 'tele_trench_depot_alliance_to_neutral',
			teleValuesTableDescription: 'trench_depot_alliance_to_neutral',
		),
	),
	FieldButton(
		field: 'tele_bump_depot_alliance_to_neutral',
		label: 'Depot Bump to Neutral',
		rightPercent: 26.0,
		bottomPercent: 21.0,
		imagePath: 'assets/images/arrow-left.png',
		zone: 'alliance',
		descriptor: FieldDescriptor(name: 'tele_bump_depot_alliance_to_neutral', teleValuesTableDescription: 'bump_depot_alliance_to_neutral'),
	),
	FieldButton(
		field: 'tele_bump_outpost_alliance_to_neutral',
		label: 'Outpost Bump to Neutral',
		rightPercent: 26.0,
		topPercent: 21.0,
		imagePath: 'assets/images/arrow-left.png',
		zone: 'alliance',
		descriptor: FieldDescriptor(name: 'tele_bump_outpost_alliance_to_neutral', teleValuesTableDescription: 'bump_outpost_alliance_to_neutral'),
	),
	FieldButton(
		field: 'tele_trench_outpost_alliance_to_neutral',
		label: 'Outpost Trench to Neutral',
		rightPercent: 26.0,
		topPercent: 5.0,
		imagePath: 'assets/images/arrow-left.png',
		zone: 'alliance',
		descriptor: FieldDescriptor(name: 'tele_trench_outpost_alliance_to_neutral', teleValuesTableDescription: 'trench_outpost_alliance_to_neutral'),
	),

	// ============ NEUTRAL → ALLIANCE (Entry from Neutral) ============
	FieldButton(
		field: 'tele_trench_depot_neutral_to_alliance',
		label: 'Depot Trench to Alliance',
		rightPercent: 26.0,
		bottomPercent: 5.0,
		imagePath: 'assets/images/arrow-right.png',
		zone: 'neutral',
		descriptor: FieldDescriptor(name: 'tele_trench_depot_neutral_to_alliance', teleValuesTableDescription: 'trench_depot_neutral_to_alliance'),
	),
	FieldButton(
		field: 'tele_bump_depot_neutral_to_alliance',
		label: 'Depot Bump to Alliance',
		rightPercent: 26.0,
		bottomPercent: 21.0,
		imagePath: 'assets/images/arrow-right.png',
		zone: 'neutral',
		descriptor: FieldDescriptor(name: 'tele_bump_depot_neutral_to_alliance', teleValuesTableDescription: 'bump_depot_neutral_to_alliance'),
	),
	FieldButton(
		field: 'tele_bump_outpost_neutral_to_alliance',
		label: 'Outpost Bump to Alliance',
		rightPercent: 26.0,
		topPercent: 21.0,
		imagePath: 'assets/images/arrow-right.png',
		zone: 'neutral',
		descriptor: FieldDescriptor(name: 'tele_bump_outpost_neutral_to_alliance', teleValuesTableDescription: 'bump_outpost_neutral_to_alliance'),
	),
	FieldButton(
		field: 'tele_trench_outpost_neutral_to_alliance',
		label: 'Outpost Trench to Alliance',
		rightPercent: 26.0,
		topPercent: 5.0,
		imagePath: 'assets/images/arrow-right.png',
		zone: 'neutral',
		descriptor: FieldDescriptor(name: 'tele_trench_outpost_neutral_to_alliance', teleValuesTableDescription: 'trench_outpost_neutral_to_alliance'),
	),

	// ============ NEUTRAL → OPPONENT (Exit to Opponent) ============
	FieldButton(
		field: 'tele_trench_outpost_neutral_to_opponent',
		label: 'Outpost Trench to Opponent',
		leftPercent: 26.0,
		bottomPercent: 5.0,
		imagePath: 'assets/images/arrow-left.png',
		zone: 'neutral',
		descriptor: FieldDescriptor(name: 'tele_trench_outpost_neutral_to_opponent', teleValuesTableDescription: 'trench_outpost_neutral_to_opponent'),
	),
	FieldButton(
		field: 'tele_bump_outpost_neutral_to_opponent',
		label: 'Outpost Bump to Opponent',
		leftPercent: 26.0,
		bottomPercent: 21.0,
		imagePath: 'assets/images/arrow-left.png',
		zone: 'neutral',
		descriptor: FieldDescriptor(name: 'tele_bump_outpost_neutral_to_opponent', teleValuesTableDescription: 'bump_outpost_neutral_to_opponent'),
	),
	FieldButton(
		field: 'tele_bump_depot_neutral_to_opponent',
		label: 'Depot Bump to Opponent',
		leftPercent: 26.0,
		topPercent: 21.0,
		imagePath: 'assets/images/arrow-left.png',
		zone: 'neutral',
		descriptor: FieldDescriptor(name: 'tele_bump_depot_neutral_to_opponent', teleValuesTableDescription: 'bump_depot_neutral_to_opponent'),
	),
	FieldButton(
		field: 'tele_trench_depot_neutral_to_opponent',
		label: 'Depot Trench to Opponent',
		leftPercent: 26.0,
		topPercent: 5.0,
		imagePath: 'assets/images/arrow-left.png',
		zone: 'neutral',
		descriptor: FieldDescriptor(name: 'tele_trench_depot_neutral_to_opponent', teleValuesTableDescription: 'trench_depot_neutral_to_opponent'),
	),

	// ============ OPPONENT → NEUTRAL (Entry from Opponent) ============
	FieldButton(
		field: 'tele_trench_outpost_opponent_to_neutral',
		label: 'Outpost Trench to Neutral',
		leftPercent: 26.0,
		bottomPercent: 5.0,
		imagePath: 'assets/images/arrow-right.png',
		zone: 'opponent',
		descriptor: FieldDescriptor(name: 'tele_trench_outpost_opponent_to_neutral', teleValuesTableDescription: 'trench_outpost_opponent_to_neutral'),
	),
	FieldButton(
		field: 'tele_bump_outpost_opponent_to_neutral',
		label: 'Outpost Bump to Neutral',
		leftPercent: 26.0,
		bottomPercent: 21.0,
		imagePath: 'assets/images/arrow-right.png',
		zone: 'opponent',
		descriptor: FieldDescriptor(name: 'tele_bump_outpost_opponent_to_neutral', teleValuesTableDescription: 'bump_outpost_opponent_to_neutral'),
	),
	FieldButton(
		field: 'tele_bump_depot_opponent_to_neutral',
		label: 'Depot Bump to Neutral',
		leftPercent: 26.0,
		topPercent: 21.0,
		imagePath: 'assets/images/arrow-right.png',
		zone: 'opponent',
		descriptor: FieldDescriptor(name: 'tele_bump_depot_opponent_to_neutral', teleValuesTableDescription: 'bump_depot_opponent_to_neutral'),
	),
	FieldButton(
		field: 'tele_trench_depot_opponent_to_neutral',
		label: 'Depot Trench to Neutral',
		leftPercent: 26.0,
		topPercent: 5.0,
		imagePath: 'assets/images/arrow-right.png',
		zone: 'opponent',
		descriptor: FieldDescriptor(name: 'tele_trench_depot_opponent_to_neutral', teleValuesTableDescription: 'trench_depot_opponent_to_neutral'),
	),
];

/// Fuel target overlays for tele phase zones
final teleFuelTargets = <FieldButton>[
	// Alliance zone targets
	FieldButton(
		field: 'tele_fuel_target_hub',
		label: 'Hub Target',
		rightPercent: 26.0,
		topPercent: 42.0,
		imagePath: 'assets/images/fuel-target.png',
		zone: 'alliance',
		widthPercent: 5.0,
		aspectRatio: 1.0,
		descriptor: FieldDescriptor(name: 'tele_fuel_score', teleValuesTableDescription: 'fuel_score'),
	),
	FieldButton(
		field: 'tele_fuel_target_alliance_dump',
		label: 'Alliance Dump',
		rightPercent: 13.0,
		bottomPercent: 7.0,
		imagePath: 'assets/images/fuel-target.png',
		zone: 'alliance',
		widthPercent: 5.0,
		aspectRatio: 1.0,
		descriptor: FieldDescriptor(name: 'tele_fuel_alliance_dump', teleValuesTableDescription: 'fuel_alliance_dump'),
	),
	FieldButton(
		field: 'tele_fuel_target_outpost',
		label: 'Outpost',
		rightPercent: 0.0,
		topPercent: 6.0,
		imagePath: 'assets/images/fuel-target.png',
		zone: 'alliance',
		widthPercent: 5.0,
		aspectRatio: 1.0,
		descriptor: FieldDescriptor(name: 'tele_fuel_outpost', teleValuesTableDescription: 'fuel_outpost'),
	),
	// Neutral zone target
	FieldButton(
		field: 'tele_fuel_target_neutral_pass',
		label: 'Neutral Pass',
		rightPercent: 13.0,
		bottomPercent: 7.0,
		imagePath: 'assets/images/fuel-target.png',
		zone: 'neutral',
		widthPercent: 5.0,
		aspectRatio: 1.0,
		descriptor: FieldDescriptor(name: 'tele_fuel_neutral_alliance_pass', teleValuesTableDescription: 'fuel_neutral_alliance_pass'),
	),
	// Opponent zone targets
	FieldButton(
		field: 'tele_fuel_target_opponent_alliance_pass',
		label: 'Opponent Alliance Pass',
		rightPercent: 13.0,
		bottomPercent: 7.0,
		imagePath: 'assets/images/fuel-target.png',
		zone: 'opponent',
		widthPercent: 5.0,
		aspectRatio: 1.0,
		descriptor: FieldDescriptor(name: 'tele_fuel_opponent_alliance_pass', teleValuesTableDescription: 'fuel_opponent_alliance_pass'),
	),
	FieldButton(
		field: 'tele_fuel_target_opponent_neutral_pass',
		label: 'Opponent Neutral Pass',
		rightPercent: 46.5,
		bottomPercent: 7.0,
		imagePath: 'assets/images/fuel-target.png',
		zone: 'opponent',
		widthPercent: 5.0,
		aspectRatio: 1.0,
		descriptor: FieldDescriptor(name: 'tele_fuel_opponent_neutral_pass', teleValuesTableDescription: 'fuel_opponent_neutral_pass'),
	),
];

/// Widget that displays the field with positioned buttons for robot movement interactions during teleop
/// Supports three zones: alliance, neutral, and opponent
class TeleFieldOverlay extends ConsumerWidget {
	/// Called when a movement button is tapped
	/// Parameters: field (movement counter name), action (label), globalOffset (tap position on screen)
	final Function(String field, String action, Offset globalOffset) onMovementTapped;

	/// Current field side (red/blue) - determines field rotation
	final FieldSide fieldSide;

	/// Current active zone ('alliance', 'neutral', or 'opponent')
	/// Determines which buttons are visible
	final String activeZone;

	/// Optional custom field width (defaults to available space)
	final double? fieldWidth;

	/// Climb level (0-3)
	final int climbLevel;

	/// Called when climb selector is tapped to increment level (max 3)
	final Function()? onClimbTapped;

	/// Robot position (bot position like 'R1', 'B1', etc.)
	/// Used to determine if field should be rotated based on team color
	final String? botPosition;

	/// Current active fuel target
	final String activeFuelTarget;

	/// Called when a fuel target is tapped
	/// Parameters: targetName
	final Function(String targetName)? onFuelTargetTapped;

	const TeleFieldOverlay({
		Key? key,
		required this.onMovementTapped,
		this.fieldSide = FieldSide.left,
		this.activeZone = 'alliance',
		this.fieldWidth,
		this.climbLevel = 0,
		this.onClimbTapped,
		this.botPosition,
		this.activeFuelTarget = 'hub',
		this.onFuelTargetTapped,
	}) : super(key: key);

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		// Pre-register all button GlobalKeys upfront so undo popups can find them even if off-screen
		for (final btn in teleZoneChangeButtons) {
			ref.read(uiElementKeysProvider.notifier).getOrCreateKey(btn.field);
		}
		for (final target in teleFuelTargets) {
			final registryFieldName = target.descriptor?.name ?? target.field;
			ref.read(uiElementKeysProvider.notifier).getOrCreateKey(registryFieldName);
		}

		// Determine if field should be rotated based on field side
		final isBlueTeam = botPosition?.startsWith('B') ?? false;
		final shouldRotate = fieldSide == FieldSide.left;

		// Button positioning depends only on team color
		final swapButtonSides = isBlueTeam;

		// Debug overlay build state
		print('[TELE_FIELD_OVERLAY] Building: botPosition=$botPosition, fieldSide=$fieldSide, activeZone=$activeZone, swapButtonSides=$swapButtonSides, shouldRotate=$shouldRotate');

		// Team color for UI elements
		final teamColor = isBlueTeam ? AppColors.blueTeamColor : AppColors.redTeamColor;

		// Use LayoutBuilder to get actual available width
		return LayoutBuilder(
			builder: (context, constraints) {
				// Calculate field dimensions maintaining 1.875:1 aspect ratio
				final maxWidth = fieldWidth ?? constraints.maxWidth;
				final fieldHeight = maxWidth / 1.875;

				// Register button positions for undo popup placement
				_registerButtonPositions(ref, maxWidth, fieldHeight, activeZone, swapButtonSides, shouldRotate);

				return Transform.rotate(
					angle: shouldRotate ? pi : 0,
					child: Container(
						width: maxWidth,
						height: fieldHeight,
						padding: const EdgeInsets.symmetric(vertical: 8),
						child: Stack(
							clipBehavior: Clip.none,
							children: [
								// Field background image
								Container(
									width: maxWidth,
									height: fieldHeight,
									decoration: BoxDecoration(
										image: DecorationImage(
											image: AssetImage(
												fieldSide == FieldSide.left
													? 'assets/images/field.png'
													: 'assets/images/field-rotated.png',
											),
											fit: BoxFit.contain,
										),
										borderRadius: BorderRadius.circular(4),
									),
								),

								// Positioned movement buttons - render all but only show active zone
								...teleZoneChangeButtons
									.map((btn) {
										final buttonKey = ref.read(uiElementKeysProvider.notifier).getOrCreateKey(btn.field);
										final isVisible = btn.zone == activeZone;
										return Visibility(
											visible: isVisible,
											maintainSize: false,
											maintainAnimation: false,
											maintainState: false,
											child: _buildMovementButton(
												maxWidth,
												fieldHeight,
												btn,
												shouldRotate,
												swapButtonSides,
												buttonKey: buttonKey,
											),
										);
									}),

								// Fuel target overlays - render all but only show active zone
								...(teleFuelTargets
									.map((target) {
										final registryFieldName = target.descriptor?.name ?? target.field;
										final targetKey = ref.read(uiElementKeysProvider.notifier).getOrCreateKey(registryFieldName);

										const targetNameMap = {
											'tele_fuel_target_hub': 'hub',
											'tele_fuel_target_alliance_dump': 'allianceDump',
											'tele_fuel_target_outpost': 'outpost',
											'tele_fuel_target_neutral_pass': 'neutralAlliancePass',
											'tele_fuel_target_opponent_alliance_pass': 'opponentAlliancePass',
											'tele_fuel_target_opponent_neutral_pass': 'opponentNeutralPass',
										};
										final targetName = targetNameMap[target.field] ?? '';
										final isActive = activeFuelTarget == targetName;
										final isVisible = target.zone == activeZone;
										return Visibility(
											visible: isVisible,
											maintainSize: false,
											maintainAnimation: false,
											maintainState: false,
											child: _buildFuelTarget(
												maxWidth,
												fieldHeight,
												target,
												isActive: isActive,
												onTap: () => onFuelTargetTapped?.call(targetName),
												shouldRotate: shouldRotate,
												swapButtonSides: swapButtonSides,
												targetKey: targetKey,
											),
										);
									}).toList()),


								// Zone indicators
								if (activeZone == 'alliance')
									_buildZoneIndicator(
										maxWidth,
										fieldHeight,
										rightPercent: 13.0,
										topPercent: 43.0,
										shouldRotate: shouldRotate,
										swapButtonSides: swapButtonSides,
										teamColor: teamColor,
									),
								if (activeZone == 'neutral')
									_buildZoneIndicator(
										maxWidth,
										fieldHeight,
										rightPercent: 46.5,
										topPercent: 43.0,
										shouldRotate: shouldRotate,
										swapButtonSides: swapButtonSides,
										teamColor: teamColor,
									),
								if (activeZone == 'opponent')
									_buildZoneIndicator(
										maxWidth,
										fieldHeight,
										leftPercent: 13.0,
										topPercent: 43.0,
										shouldRotate: shouldRotate,
										swapButtonSides: swapButtonSides,
										teamColor: teamColor,
									),

								// Climb selector
								_buildClimbSelector(
									maxWidth,
									fieldHeight,
									climbLevel: climbLevel,
									onTap: () => onClimbTapped?.call(),
									teamColor: fieldSide == FieldSide.left
										? Colors.red.shade700
										: Colors.blue.shade700,
									shouldRotate: shouldRotate,
									swapButtonSides: swapButtonSides,
								),
							],
						),
					),
				);
			},
		);
	}

	/// Build a single movement button using percentage positioning
	Widget _buildMovementButton(
		double fieldWidth,
		double fieldHeight,
		FieldButton button,
		bool shouldRotate,
		bool swapButtonSides, {
		GlobalKey? buttonKey,
	}) {
		final buttonWidth = button.widthPercent * fieldWidth / 100;
		final buttonHeight = buttonWidth * button.aspectRatio;

		final rightPixels = button.rightPercent * fieldWidth / 100;
		final leftPixels = button.rightPercent * fieldWidth / 100;
		final leftFromLeftPercent = button.leftPercent != null ? button.leftPercent! * fieldWidth / 100 : null;
		final topPixels = button.topPercent != null ? button.topPercent! * fieldHeight / 100 : null;
		final bottomPixels = button.bottomPercent != null ? button.bottomPercent! * fieldHeight / 100 : null;
		final bottomFromTopPixels = button.topPercent != null ? button.topPercent! * fieldHeight / 100 : null;
		final topFromBottomPixels = button.bottomPercent != null ? button.bottomPercent! * fieldHeight / 100 : null;

		final imagePath = swapButtonSides
			? button.imagePath.replaceAll('arrow-left.png', 'TEMP').replaceAll('arrow-right.png', 'arrow-left.png').replaceAll('TEMP', 'arrow-right.png')
			: button.imagePath;

		// Handle leftPercent (opponent zone buttons)
		if (button.leftPercent != null) {
			return Positioned(
				key: buttonKey,
				left: swapButtonSides ? null : leftFromLeftPercent,
				right: swapButtonSides ? leftFromLeftPercent : null,
				top: swapButtonSides ? topFromBottomPixels : topPixels,
				bottom: swapButtonSides ? bottomFromTopPixels : bottomPixels,
				child: GestureDetector(
					onTapDown: (details) => onMovementTapped(button.field, button.label, details.globalPosition),
					child: Tooltip(
						message: button.label,
						child: Container(
							width: buttonWidth,
							height: buttonHeight,
							decoration: BoxDecoration(
								borderRadius: BorderRadius.circular(buttonWidth * 0.1),
								color: AppColors.buttonBgColor,
								boxShadow: [
									BoxShadow(
										color: Colors.black.withValues(alpha: 0.4),
										blurRadius: 4,
										offset: const Offset(0, 2),
									),
								],
							),
							child: Image.asset(
								imagePath,
								fit: BoxFit.contain,
							),
						),
					),
				),
			);
		}

		// Handle rightPercent (alliance/neutral buttons)
		return Positioned(
			key: buttonKey,
			right: swapButtonSides ? null : rightPixels,
			left: swapButtonSides ? leftPixels : null,
			top: swapButtonSides ? topFromBottomPixels : topPixels,
			bottom: swapButtonSides ? bottomFromTopPixels : bottomPixels,
			child: GestureDetector(
				onTapDown: (details) => onMovementTapped(button.field, button.label, details.globalPosition),
				child: Tooltip(
					message: button.label,
					child: Container(
						width: buttonWidth,
						height: buttonHeight,
						decoration: BoxDecoration(
							borderRadius: BorderRadius.circular(buttonWidth * 0.1),
							color: AppColors.buttonBgColor,
							boxShadow: [
								BoxShadow(
									color: Colors.black.withValues(alpha: 0.4),
									blurRadius: 4,
									offset: const Offset(0, 2),
								),
							],
						),
						child: Image.asset(
							imagePath,
							fit: BoxFit.contain,
						),
					),
				),
			),
		);
	}

	/// Build a fuel target image overlay
	Widget _buildFuelTarget(
		double fieldWidth,
		double fieldHeight,
		FieldButton target, {
		required bool isActive,
		required VoidCallback onTap,
		required bool shouldRotate,
		required bool swapButtonSides,
		GlobalKey? targetKey,
	}) {
		final size = target.widthPercent * fieldWidth / 100;
		final imagePath = isActive
			? 'assets/images/fuel-target-active.png'
			: target.imagePath;

		final leftPercent = target.leftPercent;
		final rightPercent = target.rightPercent;
		final topPercent = target.topPercent;
		final bottomPercent = target.bottomPercent;

		final leftPx = leftPercent != null ? leftPercent * fieldWidth / 100 : null;
		final rightPx = rightPercent != null ? rightPercent * fieldWidth / 100 : null;
		final swappedRightPx = leftPercent != null ? leftPercent * fieldWidth / 100 : null;
		final swappedLeftPx = rightPercent != null ? rightPercent * fieldWidth / 100 : null;
		final topPx = topPercent != null ? topPercent * fieldHeight / 100 : null;
		final bottomPx = bottomPercent != null ? bottomPercent * fieldHeight / 100 : null;
		final swappedBottomPx = topPercent != null ? topPercent * fieldHeight / 100 : null;
		final swappedTopPx = bottomPercent != null ? bottomPercent * fieldHeight / 100 : null;

		return Positioned(
			key: targetKey,
			left: swapButtonSides ? swappedLeftPx : leftPx,
			right: swapButtonSides ? swappedRightPx : rightPx,
			top: swapButtonSides ? swappedTopPx : topPx,
			bottom: swapButtonSides ? swappedBottomPx : bottomPx,
			child: GestureDetector(
				onTap: () {
					print('TELE FUEL TARGET TAPPED: ${target.label}');
					onTap();
				},
				child: Transform.rotate(
					angle: shouldRotate ? pi : 0,
					child: Tooltip(
						message: target.label,
						child: Container(
							width: size,
							height: size,
							child: Image.asset(
								imagePath,
								fit: BoxFit.contain,
							),
						),
					),
				),
			),
		);
	}

	/// Build a zone indicator overlay
	Widget _buildZoneIndicator(
		double fieldWidth,
		double fieldHeight, {
		double? leftPercent,
		double? rightPercent,
		required double topPercent,
		required bool shouldRotate,
		required bool swapButtonSides,
		required Color teamColor,
	}) {
		final size = 7.0 * fieldWidth / 100;

		final leftPx = leftPercent != null ? leftPercent * fieldWidth / 100 : null;
		final rightPx = rightPercent != null ? rightPercent * fieldWidth / 100 : null;
		final swappedLeftPx = rightPercent != null ? rightPercent * fieldWidth / 100 : null;
		final swappedRightPx = leftPercent != null ? leftPercent * fieldWidth / 100 : null;
		final topPx = topPercent * fieldHeight / 100;
		final bottomPx = topPercent * fieldHeight / 100;

		return Positioned(
			left: swapButtonSides ? swappedLeftPx : leftPx,
			right: swapButtonSides ? swappedRightPx : rightPx,
			top: swapButtonSides ? bottomPx : topPx,
			child: Transform.rotate(
				angle: shouldRotate ? pi : 0,
				child: Container(
					width: size,
					height: size,
					decoration: BoxDecoration(
						border: Border.all(
							color: teamColor,
							width: size * 0.12,
						),
						color: AppColors.buttonBgColor,
						boxShadow: [
							BoxShadow(
								color: Colors.black.withValues(alpha: 0.4),
								blurRadius: 4,
								offset: const Offset(0, 2),
							),
						],
					),
				),
			),
		);
	}

	/// Build a climb selector overlay
	Widget _buildClimbSelector(
		double fieldWidth,
		double fieldHeight, {
		required int climbLevel,
		required VoidCallback onTap,
		required Color teamColor,
		required bool shouldRotate,
		required bool swapButtonSides,
	}) {
		final size = 8.0 * fieldWidth / 100;
		final fontSize = size * 0.6;

		final rightPx = 3.0 * fieldWidth / 100;
		final leftPx = 3.0 * fieldWidth / 100;
		final topPx = 40.0 * fieldHeight / 100;
		final bottomPx = 40.0 * fieldHeight / 100;

		return Positioned(
			right: swapButtonSides ? null : rightPx,
			left: swapButtonSides ? leftPx : null,
			top: swapButtonSides ? bottomPx : topPx,
			child: GestureDetector(
				onTap: onTap,
				child: Transform.rotate(
					angle: shouldRotate ? pi : 0,
					child: Container(
						width: size,
						height: size,
						decoration: BoxDecoration(
							borderRadius: BorderRadius.circular(size * 0.15),
							color: AppColors.buttonBgColor,
							boxShadow: [
								BoxShadow(
									color: Colors.black.withValues(alpha: 0.5),
									blurRadius: 6,
									offset: const Offset(0, 3),
								),
							],
						),
						child: Center(
							child: Text(
								climbLevel.toString(),
								style: TextStyle(
									color: AppColors.buttonFgColor,
									fontSize: fontSize,
									fontWeight: FontWeight.bold,
								),
							),
						),
					),
				),
			),
		);
	}

	/// Register button positions for undo popup placement
	void _registerButtonPositions(
		WidgetRef ref,
		double fieldWidth,
		double fieldHeight,
		String activeZone,
		bool swapButtonSides,
		bool shouldRotate,
	) {
		final positionProvider = ref.read(buttonPositionProvider.notifier);
		final positions = <String, Offset>{};

		// Calculate movement button positions
		for (final btn in teleZoneChangeButtons) {
			if (btn.zone != activeZone) continue;

			final buttonWidth = btn.widthPercent * fieldWidth / 100;
			final buttonHeight = buttonWidth * btn.aspectRatio;

			double centerX, centerY;

			final topPx = btn.topPercent != null ? btn.topPercent! * fieldHeight / 100 : null;
			final bottomPx = btn.bottomPercent != null ? btn.bottomPercent! * fieldHeight / 100 : null;

			if (btn.leftPercent != null) {
				final leftPx = btn.leftPercent! * fieldWidth / 100;
				centerX = swapButtonSides ? (fieldWidth - leftPx - buttonWidth / 2) : (leftPx + buttonWidth / 2);
				// For leftPercent buttons: top: topPercent, bottom: bottomPercent (no swap even when swapButtonSides)
				centerY = topPx != null ? topPx + buttonHeight / 2 : (bottomPx != null ? fieldHeight - bottomPx - buttonHeight / 2 : fieldHeight / 2);
			} else {
				final rightPx = btn.rightPercent * fieldWidth / 100;
				centerX = swapButtonSides ? (rightPx + buttonWidth / 2) : (fieldWidth - rightPx - buttonWidth / 2);
				// For rightPercent buttons: top: topPercent, bottom: bottomPercent (NO swap in tele!)
				centerY = topPx != null ? topPx + buttonHeight / 2 : (bottomPx != null ? fieldHeight - bottomPx - buttonHeight / 2 : fieldHeight / 2);
			}

			positions[btn.field] = Offset(centerX, centerY);
		}

		// Calculate fuel target positions
		for (final target in teleFuelTargets) {
			if (target.zone != activeZone) continue;

			final size = target.widthPercent * fieldWidth / 100;

			final leftPercent = target.leftPercent;
			final rightPercent = target.rightPercent;
			final topPercent = target.topPercent;
			final bottomPercent = target.bottomPercent;

			final leftPx = leftPercent != null ? leftPercent * fieldWidth / 100 : null;
			final rightPx = rightPercent != null ? rightPercent * fieldWidth / 100 : null;
			final topPx = topPercent != null ? topPercent * fieldHeight / 100 : null;
			final bottomPx = bottomPercent != null ? bottomPercent * fieldHeight / 100 : null;

			double centerX = fieldWidth / 2;
			double centerY = fieldHeight / 2;

			if (swapButtonSides) {
				if (leftPx != null) centerX = fieldWidth - leftPx - size / 2;
				if (rightPx != null) centerX = rightPx + size / 2;
				if (bottomPx != null) centerY = topPx != null ? topPx + size / 2 : fieldHeight / 2;
				if (topPx != null) centerY = bottomPx != null ? fieldHeight - bottomPx - size / 2 : fieldHeight / 2;
			} else {
				if (leftPx != null) centerX = leftPx + size / 2;
				if (rightPx != null) centerX = fieldWidth - rightPx - size / 2;
				if (topPx != null) centerY = topPx + size / 2;
				if (bottomPx != null) centerY = fieldHeight - bottomPx - size / 2;
			}

			final registryFieldName = target.descriptor?.name ?? target.field;
			positions[registryFieldName] = Offset(centerX, centerY);
		}

		// When field is rotated 180 degrees, transform coordinates to account for rotation
		if (shouldRotate) {
			final rotatedPositions = <String, Offset>{};
			for (final entry in positions.entries) {
				final pos = entry.value;
				// 180-degree rotation: (x, y) -> (fieldWidth - x, fieldHeight - y)
				rotatedPositions[entry.key] = Offset(fieldWidth - pos.dx, fieldHeight - pos.dy);
			}
			positionProvider.setButtonPositions(rotatedPositions);
		} else {
			positionProvider.setButtonPositions(positions);
		}
	}
}
