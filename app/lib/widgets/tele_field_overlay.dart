import 'package:flutter/material.dart';
import 'dart:math';
import '../../providers/field_side_provider.dart';
import '../../constants/colors.dart';
import '../data/field_button_definitions.dart';

/// Widget that displays the field with positioned buttons for robot movement interactions during teleop
/// Supports three zones: alliance, neutral, and opponent
class TeleFieldOverlay extends StatelessWidget {
	/// Called when a movement button is tapped
	/// Parameters: field (movement counter name), action (label)
	final Function(String field, String action) onMovementTapped;

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
	Widget build(BuildContext context) {
		// Determine if field should be rotated based on field side
		final isBlueTeam = botPosition?.startsWith('B') ?? false;
		final shouldRotate = fieldSide == FieldSide.left;

		// Button positioning depends only on team color
		final swapButtonSides = isBlueTeam;

		// Team color for UI elements
		final teamColor = isBlueTeam ? AppColors.blueTeamColor : AppColors.redTeamColor;

		// Use LayoutBuilder to get actual available width
		return LayoutBuilder(
			builder: (context, constraints) {
				// Calculate field dimensions maintaining 1.875:1 aspect ratio
				final maxWidth = fieldWidth ?? constraints.maxWidth;
				final fieldHeight = maxWidth / 1.875;

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

								// Positioned movement buttons - filtered by active zone
								...teleFieldButtonDefinitions
									.where((btn) => btn.zone == activeZone)
									.map((btn) => _buildMovementButton(
										maxWidth,
										fieldHeight,
										btn,
										shouldRotate,
										swapButtonSides,
									)),

								// Fuel target overlays per zone
								// Alliance zone fuel targets
								if (activeZone == 'alliance') ...[
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
									_buildFuelTarget(
										maxWidth,
										fieldHeight,
										label: 'Alliance Dump',
										rightPercent: 13.0,
										bottomPercent: 7.0,
										targetName: 'allianceDump',
										isActive: activeFuelTarget == 'allianceDump',
										onTap: () => onFuelTargetTapped?.call('allianceDump'),
										shouldRotate: shouldRotate,
										swapButtonSides: swapButtonSides,
									),
									_buildFuelTarget(
										maxWidth,
										fieldHeight,
										label: 'Outpost',
										rightPercent: 0.0,
										topPercent: 6.0,
										targetName: 'outpost',
										isActive: activeFuelTarget == 'outpost',
										onTap: () => onFuelTargetTapped?.call('outpost'),
										shouldRotate: shouldRotate,
										swapButtonSides: swapButtonSides,
									),
								],
								// Neutral zone fuel target
								if (activeZone == 'neutral')
									_buildFuelTarget(
										maxWidth,
										fieldHeight,
										label: 'Neutral Pass',
										rightPercent: 13.0,
										bottomPercent: 7.0,
										targetName: 'neutralAlliancePass',
										isActive: activeFuelTarget == 'neutralAlliancePass',
										onTap: () => onFuelTargetTapped?.call('neutralAlliancePass'),
										shouldRotate: shouldRotate,
										swapButtonSides: swapButtonSides,
									),
								// Opponent zone fuel targets
								if (activeZone == 'opponent') ...[
									_buildFuelTarget(
										maxWidth,
										fieldHeight,
										label: 'Opponent Alliance Pass',
										rightPercent: 13.0,
										bottomPercent: 7.0,
										targetName: 'opponentAlliancePass',
										isActive: activeFuelTarget == 'opponentAlliancePass',
										onTap: () => onFuelTargetTapped?.call('opponentAlliancePass'),
										shouldRotate: shouldRotate,
										swapButtonSides: swapButtonSides,
									),
									_buildFuelTarget(
										maxWidth,
										fieldHeight,
										label: 'Opponent Neutral Pass',
										rightPercent: 46.5,
										bottomPercent: 7.0,
										targetName: 'opponentNeutralPass',
										isActive: activeFuelTarget == 'opponentNeutralPass',
										onTap: () => onFuelTargetTapped?.call('opponentNeutralPass'),
										shouldRotate: shouldRotate,
										swapButtonSides: swapButtonSides,
									),
								],

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
		bool swapButtonSides,
	) {
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
				left: swapButtonSides ? null : leftFromLeftPercent,
				right: swapButtonSides ? leftFromLeftPercent : null,
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

		// Handle rightPercent (alliance/neutral buttons)
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
}
