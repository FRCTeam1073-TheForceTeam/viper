import 'package:flutter/material.dart';
import 'dart:math';
import '../../providers/field_side_provider.dart';
import '../../constants/colors.dart';
import '../data/field_button_definitions.dart';

/// Widget that displays the field with positioned buttons for robot movement interactions
/// Buttons use CSS-like percentage positioning and are zone-aware (alliance/neutral)
class AutoFieldOverlay extends StatelessWidget {
	/// Called when a movement button is tapped
	/// Parameters: field (movement counter name), action (label)
	final Function(String field, String action) onMovementTapped;

	/// Called when collection checkboxes are tapped
	/// Parameters: type ('depot' or 'outpost'), newValue (toggled boolean state)
	final Function(String type, bool newValue)? onCollectionToggled;

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

	/// Climb level (0 or 1)
	final int climbLevel;

	/// Called when climb selector is tapped to toggle level
	final Function()? onClimbToggled;

	/// Called when Start Auto button is tapped
	final Function()? onStartAutoTapped;

	/// Whether to show the Start Auto button (false after match starts)
	final bool showStartButton;

	/// Text label for Start Auto button (should be translated)
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
		this.onCollectionToggled,
		this.fieldSide = FieldSide.left,
		this.activeZone = 'alliance',
		this.fieldWidth,
		this.collectDepot = false,
		this.collectOutpost = false,
		this.climbLevel = 0,
		this.onClimbToggled,
		this.onStartAutoTapped,
		this.showStartButton = true,
		this.startAutoButtonLabel = 'Start Auto',
		this.botPosition,
		this.activeFuelTarget = 'hub',
		this.onFuelTargetTapped,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		// Determine if field should be rotated based on field side
		final isBlueTeam = botPosition?.startsWith('B') ?? false;
		final shouldRotate = fieldSide == FieldSide.left;

		// Button positioning depends only on team color
		// Buttons are inside the rotated container, so they stay on the team's side
		final swapButtonSides = isBlueTeam;

		print('🔵 AutoFieldOverlay: botPosition=$botPosition, fieldSide=${fieldSide.name}, shouldRotate=$shouldRotate, swapButtonSides=$swapButtonSides');


		// Team color for UI elements - use globally defined app colors
		final teamColor = isBlueTeam ? AppColors.blueTeamColor : AppColors.redTeamColor;

		// Use LayoutBuilder to get actual available width (respects parent padding/constraints)
		return LayoutBuilder(
			builder: (context, constraints) {
				// Calculate field dimensions maintaining 1.875:1 aspect ratio (field.png)
				final maxWidth = fieldWidth ?? constraints.maxWidth;
				final fieldHeight = maxWidth / 1.875; // 16:30 aspect ratio

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

								// Positioned movement buttons - filtered by active zone
								...fieldButtonDefinitions
								.where((btn) => btn.zone == activeZone)
									.map((btn) => _buildMovementButton(
										maxWidth,
										fieldHeight,
										btn,
										shouldRotate,
										swapButtonSides,
									)),

								// Fuel target overlays
							// Hub target shows only in alliance zone
							if (activeZone == 'alliance')
								_buildFuelTarget(
									maxWidth,
									fieldHeight,
									label: 'Hub Target',
									rightPercent: 26.0,
									topPercent: 42.0,
									targetName: 'hub',
									isActive: activeFuelTarget == 'hub',
									onTap: () => onFuelTargetTapped?.call('hub'),
									shouldRotate: shouldRotate,
									swapButtonSides: swapButtonSides,
								),
							// Alliance Pass target shows only in neutral zone
							if (activeZone == 'neutral')
								_buildFuelTarget(
									maxWidth,
									fieldHeight,
									label: 'Alliance Pass',
									rightPercent: 13.0,
									bottomPercent: 7.0,
									targetName: 'alliancePass',
									isActive: activeFuelTarget == 'alliancePass',
									onTap: () => onFuelTargetTapped?.call('alliancePass'),
									shouldRotate: shouldRotate,
									swapButtonSides: swapButtonSides,
								),
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
										label: 'Depot',
										rightPercent: 2.0,
										bottomPercent: 22.0,
										isChecked: collectDepot,
										onTap: () {
											final newValue = !collectDepot;
											onCollectionToggled?.call('depot', newValue);
										},
										shouldRotate: shouldRotate,
										swapButtonSides: swapButtonSides,
									),
									_buildCollectionCheckbox(
										maxWidth,
										fieldHeight,
										label: 'Outpost',
										rightPercent: 0.0,
										topPercent: 7.0,
										isChecked: collectOutpost,
										onTap: () {
											final newValue = !collectOutpost;
											onCollectionToggled?.call('outpost', newValue);
										},
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
		bool swapButtonSides,
	) {
		// Button dimensions
		final buttonWidth = button.widthPercent * fieldWidth / 100;
		final buttonHeight = buttonWidth * button.aspectRatio;

		// Position: swap left/right and top/bottom edges with same percentages when needed
		final rightPixels = button.rightPercent * fieldWidth / 100;
		final leftPixels = button.rightPercent * fieldWidth / 100;
		final topPixels = button.topPercent != null ? button.topPercent! * fieldHeight / 100 : null;
		final bottomPixels = button.bottomPercent != null ? button.bottomPercent! * fieldHeight / 100 : null;
		final bottomFromTopPixels = button.topPercent != null ? button.topPercent! * fieldHeight / 100 : null;
		final topFromBottomPixels = button.bottomPercent != null ? button.bottomPercent! * fieldHeight / 100 : null;

		// Swap arrow images when swapping button sides
		final imagePath = swapButtonSides
			? button.imagePath.replaceAll('arrow-left.png', 'TEMP').replaceAll('arrow-right.png', 'arrow-left.png').replaceAll('TEMP', 'arrow-right.png')
			: button.imagePath;

		return Positioned(
			right: swapButtonSides ? null : rightPixels,
			left: swapButtonSides ? leftPixels : null,
			top: swapButtonSides ? bottomFromTopPixels : topPixels,
			bottom: swapButtonSides ? topFromBottomPixels : bottomPixels,
			child: GestureDetector(
				onTap: () => onMovementTapped(button.field, button.label),
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
		double fieldHeight, {
		required String label,
		double? leftPercent,
		double? rightPercent,
		double? topPercent,
		double? bottomPercent,
		required String targetName,
		required bool isActive,
		required VoidCallback onTap,
		required bool shouldRotate,
		required bool swapButtonSides,
	}) {
		final size = 5.0 * fieldWidth / 100;
		final imagePath = isActive
			? 'assets/images/fuel-target-active.png'
			: 'assets/images/fuel-target.png';

		// Calculate positions - swap edges with same percentages when rotating
		final leftPx = leftPercent != null ? leftPercent * fieldWidth / 100 : null;
		final rightPx = rightPercent != null ? rightPercent * fieldWidth / 100 : null;
		final swappedRightPx = leftPercent != null ? leftPercent * fieldWidth / 100 : null;
		final swappedLeftPx = rightPercent != null ? rightPercent * fieldWidth / 100 : null;
		final topPx = topPercent != null ? topPercent * fieldHeight / 100 : null;
		final bottomPx = bottomPercent != null ? bottomPercent * fieldHeight / 100 : null;
		final swappedBottomPx = topPercent != null ? topPercent * fieldHeight / 100 : null;
		final swappedTopPx = bottomPercent != null ? bottomPercent * fieldHeight / 100 : null;

		return Positioned(
			left: swapButtonSides ? swappedLeftPx : leftPx,
			right: swapButtonSides ? swappedRightPx : rightPx,
			top: swapButtonSides ? swappedTopPx : topPx,
			bottom: swapButtonSides ? swappedBottomPx : bottomPx,
			child: GestureDetector(
				onTap: onTap,
				child: Transform.rotate(
					angle: shouldRotate ? pi : 0,
					child: Tooltip(
						message: label,
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

	/// Build a collection checkbox overlay using fuel-collect.png image
	Widget _buildCollectionCheckbox(
		double fieldWidth,
		double fieldHeight, {
		required String label,
		required double rightPercent,
		double? topPercent,
		double? bottomPercent,
		required bool isChecked,
		required VoidCallback onTap,
		required bool shouldRotate,
		required bool swapButtonSides,
	}) {
		final size = 8.0 * fieldWidth / 100;

		final rightPx = rightPercent * fieldWidth / 100;
		final leftPx = rightPercent * fieldWidth / 100;
		final topPx = topPercent != null ? topPercent * fieldHeight / 100 : null;
		final bottomPx = bottomPercent != null ? bottomPercent * fieldHeight / 100 : null;
		final bottomFromTopPx = topPercent != null ? topPercent * fieldHeight / 100 : null;
		final topFromBottomPx = bottomPercent != null ? bottomPercent * fieldHeight / 100 : null;

		return Positioned(
			right: swapButtonSides ? null : rightPx,
			left: swapButtonSides ? leftPx : null,
			top: swapButtonSides ? bottomFromTopPx : topPx,
			bottom: swapButtonSides ? topFromBottomPx : bottomPx,
			child: GestureDetector(
				onTap: onTap,
				child: Transform.rotate(
					angle: shouldRotate ? pi : 0,
					child: Container(
						width: size,
						height: size,
						decoration: BoxDecoration(
							borderRadius: BorderRadius.circular(size * 0.15),
							color: isChecked
								? AppColors.buttonSelectedBgColor
								: AppColors.buttonBgColor,
							boxShadow: [
								BoxShadow(
									color: Colors.black.withValues(alpha: 0.3),
									blurRadius: 4,
									offset: const Offset(0, 2),
								),
							],
						),
						child: Image.asset(
							'assets/images/fuel-collect.png',
							fit: BoxFit.contain,

						),
					),
				),
			),
		);
	}

	/// Build Start Auto button overlay
	/// Positioned at left:9%, top:15% with 10% width and "Start Auto" label (matching web app)
	Widget _buildStartAutoButton(
		double fieldWidth,
		double fieldHeight,
		bool shouldRotate,
	) {
		final buttonSize = 10.0 * fieldWidth / 100;
		final padding = buttonSize * 0.2; // Padding around text content

		return Positioned(
			left: 9.0 * fieldWidth / 100,
			top: 15.0 * fieldHeight / 100,
			child: GestureDetector(
				onTap: () => onStartAutoTapped?.call(),
				child: Transform.rotate(
					angle: shouldRotate ? pi : 0,
					child: Container(
						padding: EdgeInsets.all(padding),
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
}
