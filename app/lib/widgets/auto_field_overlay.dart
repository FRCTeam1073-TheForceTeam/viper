import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../providers/field_side_provider.dart';
import '../../providers/scouting_data_provider.dart';
import '../../providers/zone_buttons_provider.dart';
import '../../providers/button_position_provider.dart';
import '../../constants/colors.dart';
import '../models/field_button.dart';
import '../models/field_descriptor.dart';
import '../models/map_data_model.dart';
import 'checkbox_button.dart';

/// Zone change buttons for auto phase
final autoZoneChangeButtons = <FieldButton>[
	// ============ ALLIANCE → NEUTRAL (Exit to Neutral) ============
	FieldButton(
		field: 'auto_trench_depot_alliance_to_neutral',
		label: 'Depot Trench to Neutral',
		rightPercent: 26.0,
		bottomPercent: 5.0,
		imagePath: 'assets/images/arrow-left.png',
		zone: 'alliance',
		widthPercent: 7.0,
		aspectRatio: 1.0,
		descriptor: FieldDescriptor(
			name: 'auto_trench_depot_alliance_to_neutral',
			autoValuesTableDescription: 'trench_depot_alliance_to_neutral',
		),
	),
	FieldButton(
		field: 'auto_bump_depot_alliance_to_neutral',
		label: 'Depot Bump to Neutral',
		rightPercent: 26.0,
		bottomPercent: 21.0,
		imagePath: 'assets/images/arrow-left.png',
		zone: 'alliance',
		widthPercent: 7.0,
		aspectRatio: 1.0,
		descriptor: FieldDescriptor(
			name: 'auto_bump_depot_alliance_to_neutral',
			autoValuesTableDescription: 'bump_depot_alliance_to_neutral',
		),
	),
	FieldButton(
		field: 'auto_bump_outpost_alliance_to_neutral',
		label: 'Outpost Bump to Neutral',
		rightPercent: 26.0,
		topPercent: 21.0,
		imagePath: 'assets/images/arrow-left.png',
		zone: 'alliance',
		widthPercent: 7.0,
		aspectRatio: 1.0,
		descriptor: FieldDescriptor(
			name: 'auto_bump_outpost_alliance_to_neutral',
			autoValuesTableDescription: 'bump_outpost_alliance_to_neutral',
		),
	),
	FieldButton(
		field: 'auto_trench_outpost_alliance_to_neutral',
		label: 'Outpost Trench to Neutral',
		rightPercent: 26.0,
		topPercent: 5.0,
		imagePath: 'assets/images/arrow-left.png',
		zone: 'alliance',
		widthPercent: 7.0,
		aspectRatio: 1.0,
		descriptor: FieldDescriptor(
			name: 'auto_trench_outpost_alliance_to_neutral',
			autoValuesTableDescription: 'trench_outpost_alliance_to_neutral',
		),
	),

	// ============ NEUTRAL → ALLIANCE (Entry from Neutral) ============
	FieldButton(
		field: 'auto_trench_depot_neutral_to_alliance',
		label: 'Depot Trench to Alliance',
		rightPercent: 26.0,
		bottomPercent: 5.0,
		imagePath: 'assets/images/arrow-right.png',
		zone: 'neutral',
		widthPercent: 7.0,
		aspectRatio: 1.0,
		descriptor: FieldDescriptor(
			name: 'auto_trench_depot_neutral_to_alliance',
			autoValuesTableDescription: 'trench_depot_neutral_to_alliance',
		),
	),
	FieldButton(
		field: 'auto_bump_depot_neutral_to_alliance',
		label: 'Depot Bump to Alliance',
		rightPercent: 26.0,
		bottomPercent: 21.0,
		imagePath: 'assets/images/arrow-right.png',
		zone: 'neutral',
		widthPercent: 7.0,
		aspectRatio: 1.0,
		descriptor: FieldDescriptor(
			name: 'auto_bump_depot_neutral_to_alliance',
			autoValuesTableDescription: 'bump_depot_neutral_to_alliance',
		),
	),
	FieldButton(
		field: 'auto_bump_outpost_neutral_to_alliance',
		label: 'Outpost Bump to Alliance',
		rightPercent: 26.0,
		topPercent: 21.0,
		imagePath: 'assets/images/arrow-right.png',
		zone: 'neutral',
		widthPercent: 7.0,
		aspectRatio: 1.0,
		descriptor: FieldDescriptor(
			name: 'auto_bump_outpost_neutral_to_alliance',
			autoValuesTableDescription: 'bump_outpost_neutral_to_alliance',
		),
	),
	FieldButton(
		field: 'auto_trench_outpost_neutral_to_alliance',
		label: 'Outpost Trench to Alliance',
		rightPercent: 26.0,
		topPercent: 5.0,
		imagePath: 'assets/images/arrow-right.png',
		zone: 'neutral',
		widthPercent: 7.0,
		aspectRatio: 1.0,
		descriptor: FieldDescriptor(
			name: 'auto_trench_outpost_neutral_to_alliance',
			autoValuesTableDescription: 'trench_outpost_neutral_to_alliance',
		),
	),
];

/// Fuel target overlays for auto phase zones
final autoFuelTargets = <FieldButton>[
	// Alliance zone targets
	FieldButton(
		field: 'auto_fuel_target_hub',
		label: 'Hub Target',
		rightPercent: 26.0,
		topPercent: 42.0,
		imagePath: 'assets/images/fuel-target.png',
		zone: 'alliance',
		widthPercent: 5.0,
		aspectRatio: 1.0,
		descriptor: FieldDescriptor(name: 'auto_fuel_score', autoValuesTableDescription: 'fuel_score'),
	),
	// Neutral zone target
	FieldButton(
		field: 'auto_fuel_target_alliance_pass',
		label: 'Alliance Pass',
		rightPercent: 13.0,
		bottomPercent: 7.0,
		imagePath: 'assets/images/fuel-target.png',
		zone: 'neutral',
		widthPercent: 5.0,
		aspectRatio: 1.0,
		descriptor: FieldDescriptor(name: 'auto_fuel_neutral_alliance_pass', autoValuesTableDescription: 'fuel_neutral_alliance_pass'),
	),
];

/// Widget that displays the field with positioned buttons for robot movement interactions
/// Buttons use CSS-like percentage positioning and are zone-aware (alliance/neutral)
class AutoFieldOverlay extends ConsumerWidget {
	/// Called when a movement button is tapped
	/// Parameters: field (movement counter name), action (label), globalOffset (tap position on screen)
	final Function(String field, String action, Offset globalOffset) onMovementTapped;

	/// Current field side (red/blue) - determines field rotation
	final FieldSide fieldSide;

	/// Current active zone ('alliance' or 'neutral')
	/// Determines which buttons are visible
	final String activeZone;

	/// Optional custom field width (defaults to available space)
	final double? fieldWidth;

	/// Collection state: depot collected
	final bool collectDepot;

	/// Collection state: outpost collected
	final bool collectOutpost;

	/// Model for registering descriptors
	final MapDataModel? model;

	/// Callback to record an action (field, value)
	final Function(String field, int value)? onRecordAction;

	/// Climb level (0-1)
	final int climbLevel;

	/// Called when climb selector is tapped to increment level
	final Function()? onClimbToggled;

	/// Called when Start Auto button is tapped
	final Function()? onStartAutoTapped;

	/// Whether to show the Start Auto button (false after match starts)
	final bool showStartButton;

	/// Text label for Start Auto button (must be translated by caller)
	final String startAutoButtonLabel;

	/// Robot position (bot position like 'R1', 'B1', etc.)
	/// Used to determine if field should be rotated based on team color
	final String? botPosition;

	/// Current active fuel target ('hub' or 'alliancePass')
	final String activeFuelTarget;

	/// Called when a fuel target is tapped
	/// Parameters: targetName ('hub' or 'alliancePass')
	final Function(String targetName)? onFuelTargetTapped;

	const AutoFieldOverlay({
		Key? key,
		required this.onMovementTapped,
		this.fieldSide = FieldSide.left,
		this.activeZone = 'alliance',
		this.fieldWidth,
		this.collectDepot = false,
		this.collectOutpost = false,
		this.climbLevel = 0,
		this.onClimbToggled,
		this.onStartAutoTapped,
		this.showStartButton = true,
		this.startAutoButtonLabel = '',
		this.botPosition,
		this.activeFuelTarget = 'hub',
		this.onFuelTargetTapped,
		this.model,
		this.onRecordAction,
	}) : super(key: key);

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		// Pre-register all button GlobalKeys upfront so undo popups can find them even if off-screen
		for (final btn in autoZoneChangeButtons) {
			ref.read(uiElementKeysProvider.notifier).getOrCreateKey(btn.field);
		}
		for (final target in autoFuelTargets) {
			final registryFieldName = target.descriptor?.name ?? target.field;
			ref.read(uiElementKeysProvider.notifier).getOrCreateKey(registryFieldName);
		}

		// Determine if field should be rotated based on field side
		final isBlueTeam = botPosition?.startsWith('B') ?? false;
		final shouldRotate = fieldSide == FieldSide.left;

		// Button positioning depends only on team color
		// Buttons are inside the rotated container, so they stay on the team's side
		final swapButtonSides = isBlueTeam;

		// Debug overlay build state
		print('[AUTO_FIELD_OVERLAY] Building: botPosition=$botPosition, fieldSide=$fieldSide, activeZone=$activeZone, swapButtonSides=$swapButtonSides, shouldRotate=$shouldRotate');


		// Team color for UI elements - use globally defined app colors
		final teamColor = isBlueTeam ? AppColors.blueTeamColor : AppColors.redTeamColor;

		// Use LayoutBuilder to get actual available width (respects parent padding/constraints)
		return LayoutBuilder(
			builder: (context, constraints) {
				// Calculate field dimensions maintaining 1.875:1 aspect ratio (field.png)
				final maxWidth = fieldWidth ?? constraints.maxWidth;
				final fieldHeight = maxWidth / 1.875; // 16:30 aspect ratio

				// Register button positions for undo popup placement
				_registerButtonPositions(ref, maxWidth, fieldHeight, activeZone, swapButtonSides, shouldRotate);

				return Transform.rotate(
					angle: shouldRotate ? pi : 0,
					child: Container(
						width: maxWidth,
						height: fieldHeight,
						padding: const EdgeInsets.symmetric(vertical: 8),
						child: Stack(
							clipBehavior: Clip.none, // Allow positioned children to overflow
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
											fit: BoxFit.contain, // Use contain instead of cover to avoid clipping
										),
										borderRadius: BorderRadius.circular(4),
									),
								),

								// Positioned movement buttons - render all but only show active zone
								...autoZoneChangeButtons
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
								...(autoFuelTargets
									.map((target) {
										final registryFieldName = target.descriptor?.name ?? target.field;
										final targetKey = ref.read(uiElementKeysProvider.notifier).getOrCreateKey(registryFieldName);

										const targetNameMap = {
											'auto_fuel_target_hub': 'hub',
											'auto_fuel_target_alliance_pass': 'alliancePass',
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

								// Zone indicators (only active zone is shown)
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

									// Collection checkboxes
									_buildCollectionCheckbox(
										maxWidth,
										fieldHeight,
										ref,
										descriptor: FieldDescriptor(
											name: 'auto_collect_depot',
											uiLabelKey: 'collect_from_depot',
											imagePath: 'assets/images/fuel-collect.png',
										),
										rightPercent: 2.0,
										bottomPercent: 22.0,
										isChecked: collectDepot,
										shouldRotate: shouldRotate,
										swapButtonSides: swapButtonSides,
									),
									_buildCollectionCheckbox(
										maxWidth,
										fieldHeight,
										ref,
										descriptor: FieldDescriptor(
											name: 'auto_collect_outpost',
											uiLabelKey: 'collect_from_outpost',
											imagePath: 'assets/images/fuel-collect.png',
										),
										rightPercent: 0.0,
										topPercent: 7.0,
										isChecked: collectOutpost,
										shouldRotate: shouldRotate,
										swapButtonSides: swapButtonSides,
									),

									// Climb selector
									_buildClimbSelector(
										maxWidth,
										fieldHeight,
										climbLevel: climbLevel,
										onTap: () => onClimbToggled?.call(),
										teamColor: fieldSide == FieldSide.left
											? Colors.red.shade700
											: Colors.blue.shade700,
										shouldRotate: shouldRotate,
										swapButtonSides: swapButtonSides,
									),

									// Start Auto button (only show if match hasn't started)
									if (showStartButton)
										_buildStartAutoButton(maxWidth, fieldHeight, shouldRotate, swapButtonSides),
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
		// Button dimensions
		final buttonWidth = button.widthPercent * fieldWidth / 100;
		final buttonHeight = buttonWidth * button.aspectRatio;

		// Position: swap left/right and top/bottom edges with same percentages when needed
		final rightPixels = button.rightPercent * fieldWidth / 100;
		final leftPixels = button.rightPercent * fieldWidth / 100;
		final leftFromLeftPercent = button.leftPercent != null ? button.leftPercent! * fieldWidth / 100 : null;
		final topPixels = button.topPercent != null ? button.topPercent! * fieldHeight / 100 : null;
		final bottomPixels = button.bottomPercent != null ? button.bottomPercent! * fieldHeight / 100 : null;
		final bottomFromTopPixels = button.topPercent != null ? button.topPercent! * fieldHeight / 100 : null;
		final topFromBottomPixels = button.bottomPercent != null ? button.bottomPercent! * fieldHeight / 100 : null;

		// Swap arrow images when swapping button sides
		final imagePath = swapButtonSides
			? button.imagePath.replaceAll('arrow-left.png', 'TEMP').replaceAll('arrow-right.png', 'arrow-left.png').replaceAll('TEMP', 'arrow-right.png')
			: button.imagePath;

		// Handle leftPercent (opponent zone buttons)
		if (button.leftPercent != null) {
			return Positioned(
				key: buttonKey,
				left: swapButtonSides ? null : leftFromLeftPercent,
				right: swapButtonSides ? leftFromLeftPercent : null,
				top: swapButtonSides ? bottomFromTopPixels : topPixels,
				bottom: swapButtonSides ? topFromBottomPixels : bottomPixels,
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

		// Calculate positions - swap edges with same percentages when rotating
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
			top: swapButtonSides ? swappedBottomPx : topPx,
			bottom: swapButtonSides ? swappedTopPx : bottomPx,
			child: GestureDetector(
				onTap: () {
					print('FUEL TARGET TAPPED: ${target.label}');
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

	Widget _buildCollectionCheckbox(
		double fieldWidth,
		double fieldHeight,
		WidgetRef ref, {
		required FieldDescriptor descriptor,
		required double rightPercent,
		double? topPercent,
		double? bottomPercent,
		required bool isChecked,
		required bool shouldRotate,
		required bool swapButtonSides,
	}) {
		final buttonSize = 7.0 * fieldWidth / 100;
		final rightPx = rightPercent * fieldWidth / 100;
		final leftPx = rightPercent * fieldWidth / 100;
		final topPx = topPercent != null ? topPercent * fieldHeight / 100 : null;
		final bottomPx = bottomPercent != null ? bottomPercent * fieldHeight / 100 : null;
		final bottomFromTopPx = topPercent != null ? topPercent * fieldHeight / 100 : null;
		final topFromBottomPx = bottomPercent != null ? bottomPercent * fieldHeight / 100 : null;

		final scaledDescriptor = FieldDescriptor(
			name: descriptor.name,
			uiLabelKey: descriptor.uiLabelKey,
			descriptionLabelKey: descriptor.descriptionLabelKey,
			imagePath: descriptor.imagePath,
			width: buttonSize,
			height: buttonSize,
			teleValuesTableDescription: descriptor.teleValuesTableDescription,
			autoValuesTableDescription: descriptor.autoValuesTableDescription,
			value: '', // Force new instance, prevents caching to use updated width/height
		);

		return Positioned(
			right: swapButtonSides ? null : rightPx,
			left: swapButtonSides ? leftPx : null,
			top: swapButtonSides ? topFromBottomPx : topPx,
			bottom: swapButtonSides ? bottomFromTopPx : bottomPx,
			child: Transform.rotate(
				angle: shouldRotate ? pi : 0,
				child: CheckboxButton(
					descriptor: scaledDescriptor,

					provider: scoutingDataProvider,
					padding: EdgeInsets.zero,
					margin: EdgeInsets.zero,
				),
			),
		);
	}

	/// Build Start Auto button overlay
	/// Positioned at 9% from right edge, 15% from top (appears on left after rotation)
	Widget _buildStartAutoButton(
		double fieldWidth,
		double fieldHeight,
		bool shouldRotate,
		bool swapButtonSides,
	) {
		final buttonSize = 10.0 * fieldWidth / 100;
		final padding = buttonSize * 0.2;
		final edgePx = 9.0 * fieldWidth / 100;
		final topPx = 15.0 * fieldHeight / 100;

		return Positioned(
			right: edgePx,
			top: topPx,
			child: GestureDetector(
				onTap: () => onStartAutoTapped?.call(),
				child: Transform.rotate(
					angle: shouldRotate ? pi : 0,
					child: Container(
						padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 4),
						decoration: BoxDecoration(
							borderRadius: BorderRadius.circular(buttonSize * 0.15),
							color: AppColors.buttonBgColor,
							boxShadow: [
								BoxShadow(
									color: Colors.black.withValues(alpha: 0.4),
									blurRadius: 4,
									offset: const Offset(0, 2),
								),
							],
						),
						child: Center(
							child: Text(
								startAutoButtonLabel,
								textAlign: TextAlign.center,
								style: TextStyle(
									color: AppColors.buttonFgColor,
									fontSize: buttonSize * 0.3,
									fontWeight: FontWeight.bold,
								),
							),
						),
					),
				),
			),
		);
	}

	/// Build a zone indicator overlay
	/// Shows robot position in the current zone (alliance or neutral)
	Widget _buildZoneIndicator(
		double fieldWidth,
		double fieldHeight, {
		required double rightPercent,
		required double topPercent,
		required bool shouldRotate,
		required bool swapButtonSides,
		required Color teamColor,
	}) {
		final size = 7.0 * fieldWidth / 100;

		final rightPx = rightPercent * fieldWidth / 100;
		final leftPx = rightPercent * fieldWidth / 100;
		final topPx = topPercent * fieldHeight / 100;
		final bottomPx = topPercent * fieldHeight / 100;

		return Positioned(
			right: swapButtonSides ? null : rightPx,
			left: swapButtonSides ? leftPx : null,
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
	/// Displays current climb level (0 or 1) with team color border
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
		for (final btn in autoZoneChangeButtons) {
			if (btn.zone != activeZone) continue;

			final buttonWidth = btn.widthPercent * fieldWidth / 100;
			final buttonHeight = buttonWidth * btn.aspectRatio;

			double centerX, centerY;

			final topPx = btn.topPercent != null ? btn.topPercent! * fieldHeight / 100 : null;
			final bottomPx = btn.bottomPercent != null ? btn.bottomPercent! * fieldHeight / 100 : null;

			if (btn.leftPercent != null) {
				final leftPx = btn.leftPercent! * fieldWidth / 100;
				centerX = swapButtonSides ? (fieldWidth - leftPx - buttonWidth / 2) : (leftPx + buttonWidth / 2);
				// For leftPercent buttons, when swapped the Positioned widget uses:
				// top: topPercent, bottom: bottomPercent (normal interpretation, no swap)
				centerY = topPx != null ? topPx + buttonHeight / 2 : (bottomPx != null ? fieldHeight - bottomPx - buttonHeight / 2 : fieldHeight / 2);
			} else {
				final rightPx = btn.rightPercent * fieldWidth / 100;
				centerX = swapButtonSides ? (rightPx + buttonWidth / 2) : (fieldWidth - rightPx - buttonWidth / 2);
				// For rightPercent buttons, when swapped the Positioned widget uses:
				// top: bottomPercent, bottom: topPercent (swapped!)
				if (swapButtonSides) {
					centerY = bottomPx != null ? (bottomPx + buttonHeight / 2) : (topPx != null ? fieldHeight - topPx - buttonHeight / 2 : fieldHeight / 2);
				} else {
					centerY = topPx != null ? topPx + buttonHeight / 2 : (bottomPx != null ? fieldHeight - bottomPx - buttonHeight / 2 : fieldHeight / 2);
				}
			}

			positions[btn.field] = Offset(centerX, centerY);
		}

		// Calculate fuel target positions
		for (final target in autoFuelTargets) {
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
