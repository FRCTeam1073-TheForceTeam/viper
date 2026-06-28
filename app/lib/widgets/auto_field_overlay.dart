import 'package:flutter/material.dart';
import '../../providers/field_side_provider.dart';
import '../data/field_button_definitions.dart';

/// Widget that displays the field with positioned buttons for robot movement interactions
/// Buttons use CSS-like percentage positioning and are zone-aware (alliance/neutral)
class AutoFieldOverlay extends StatefulWidget {
	/// Called when a movement button is tapped
	/// Parameters: field (movement counter name), action (label)
	final Function(String field, String action) onMovementTapped;

	/// Called when zone toggle buttons are tapped
	/// Parameters: zone ('alliance' or 'neutral')
	final Function(String zone)? onZoneToggled;

	/// Called when collection checkboxes are tapped
	/// Parameters: type ('depot' or 'outpost')
	final Function(String type)? onCollectionToggled;

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

	const AutoFieldOverlay({
		Key? key,
		required this.onMovementTapped,
		this.onZoneToggled,
		this.onCollectionToggled,
		this.fieldSide = FieldSide.left,
		this.activeZone = 'alliance',
		this.fieldWidth,
		this.collectDepot = false,
		this.collectOutpost = false,
		this.climbLevel = 0,
		this.onClimbToggled,
	}) : super(key: key);

	@override
	State<AutoFieldOverlay> createState() => _AutoFieldOverlayState();
}

class _AutoFieldOverlayState extends State<AutoFieldOverlay> {
	@override
	Widget build(BuildContext context) {
		// Calculate field dimensions maintaining 1.875:1 aspect ratio (field.png)
		final maxWidth = widget.fieldWidth ?? (MediaQuery.of(context).size.width - 32);
		final fieldHeight = maxWidth / 1.875; // 16:30 aspect ratio

		return Container(
			width: maxWidth,
			height: fieldHeight,
			margin: const EdgeInsets.symmetric(vertical: 8),
			child: Stack(
				children: [
					// Field background image
					Container(
						width: maxWidth,
						height: fieldHeight,
						decoration: BoxDecoration(
							image: DecorationImage(
								image: AssetImage(
									widget.fieldSide == FieldSide.left
										? 'assets/images/field.png'
										: 'assets/images/field-rotated.png',
								),
								fit: BoxFit.cover,
							),
							borderRadius: BorderRadius.circular(4),
						),
					),

					// Positioned movement buttons - filtered by active zone
					...fieldButtonDefinitions
						.where((btn) => btn.zone == widget.activeZone)
						.map((btn) => _buildMovementButton(
							maxWidth,
							fieldHeight,
							btn,
						)),

					// Zone toggle buttons at bottom
					_buildZoneToggleButton(
						maxWidth,
						fieldHeight,
						label: '→ Neutral',
						leftPercent: 3.0,
						bottomPercent: 3.0,
						isActive: widget.activeZone == 'alliance',
						onTap: () => widget.onZoneToggled?.call('neutral'),
					),
					_buildZoneToggleButton(
						maxWidth,
						fieldHeight,
						label: '← Alliance',
						rightPercent: 3.0,
						bottomPercent: 3.0,
						isActive: widget.activeZone == 'neutral',
						onTap: () => widget.onZoneToggled?.call('alliance'),
					),

					// Fuel target overlays (top-center area)
					_buildFuelTarget(
						maxWidth,
						fieldHeight,
						label: 'Hub Target',
						leftPercent: 35.0,
						topPercent: 8.0,
						imagePath: 'assets/images/fuel-target.png',
					),
					_buildFuelTarget(
						maxWidth,
						fieldHeight,
						label: 'Alliance Pass',
						rightPercent: 35.0,
						topPercent: 8.0,
						imagePath: 'assets/images/fuel-target-active.png',
					),

					// Collection checkboxes (near fuel targets)
					_buildCollectionCheckbox(
						maxWidth,
						fieldHeight,
						label: 'Depot',
						leftPercent: 5.0,
						topPercent: 8.0,
						isChecked: widget.collectDepot,
						onTap: () => widget.onCollectionToggled?.call('depot'),
					),
					_buildCollectionCheckbox(
						maxWidth,
						fieldHeight,
						label: 'Outpost',
						rightPercent: 5.0,
						topPercent: 8.0,
						isChecked: widget.collectOutpost,
						onTap: () => widget.onCollectionToggled?.call('outpost'),
					),

					// Quick-add fuel buttons will be placed below the field (not overlayed)

					// Climb selector overlay (top-right)
					_buildClimbSelector(
						maxWidth,
						fieldHeight,
						climbLevel: widget.climbLevel,
						onTap: () => widget.onClimbToggled?.call(),
						teamColor: widget.fieldSide == FieldSide.left
							? Colors.red.shade700
							: Colors.blue.shade700,
					),
				],
			),
		);
	}

	/// Build a single movement button using percentage positioning
	Widget _buildMovementButton(
		double fieldWidth,
		double fieldHeight,
		FieldButton button,
	) {
		// Calculate pixel position from percentage
		final rightPixels = button.rightPercent * fieldWidth / 100;
		final topPixels = button.topPercent != null
			? button.topPercent! * fieldHeight / 100
			: null;
		final bottomPixels = button.bottomPercent != null
			? button.bottomPercent! * fieldHeight / 100
			: null;

		// Button dimensions
		final buttonWidth = button.widthPercent * fieldWidth / 100;
		final buttonHeight = buttonWidth * button.aspectRatio;

		return Positioned(
			right: rightPixels - (buttonWidth / 2),
			top: topPixels != null ? topPixels - (buttonHeight / 2) : null,
			bottom: bottomPixels != null ? bottomPixels - (buttonHeight / 2) : null,
			child: GestureDetector(
				onTap: () => widget.onMovementTapped(button.field, button.label),
				child: Tooltip(
					message: button.label,
					child: Container(
						width: buttonWidth,
						height: buttonHeight,
						decoration: BoxDecoration(
							borderRadius: BorderRadius.circular(buttonWidth * 0.1),
							boxShadow: [
								BoxShadow(
									color: Colors.black.withValues(alpha: 0.4),
									blurRadius: 4,
									offset: const Offset(0, 2),
								),
							],
						),
						child: Image.asset(
							button.imagePath,
							fit: BoxFit.contain,
						),
					),
				),
			),
		);
	}

	/// Build a zone toggle button
	Widget _buildZoneToggleButton(
		double fieldWidth,
		double fieldHeight, {
		required String label,
		double? leftPercent,
		double? rightPercent,
		required double bottomPercent,
		required bool isActive,
		required VoidCallback onTap,
	}) {
		final buttonWidth = 7.0 * fieldWidth / 100;
		final buttonHeight = buttonWidth;

		return Positioned(
			left: leftPercent != null ? leftPercent * fieldWidth / 100 : null,
			right: rightPercent != null ? rightPercent * fieldWidth / 100 : null,
			bottom: bottomPercent * fieldHeight / 100,
			child: GestureDetector(
				onTap: onTap,
				child: Container(
					width: buttonWidth,
					height: buttonHeight,
					decoration: BoxDecoration(
						borderRadius: BorderRadius.circular(buttonWidth * 0.1),
						color: isActive
							? Colors.green.shade700.withValues(alpha: 0.9)
							: Colors.grey.shade400.withValues(alpha: 0.7),
						border: Border.all(
							color: Colors.white,
							width: 2,
						),
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
							label,
							textAlign: TextAlign.center,
							style: TextStyle(
								color: Colors.white,
								fontSize: buttonWidth * 0.25,
								fontWeight: FontWeight.bold,
							),
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
		required double topPercent,
		required String imagePath,
	}) {
		final size = 5.0 * fieldWidth / 100;

		return Positioned(
			left: leftPercent != null ? leftPercent * fieldWidth / 100 : null,
			right: rightPercent != null ? rightPercent * fieldWidth / 100 : null,
			top: topPercent * fieldHeight / 100,
			child: Tooltip(
				message: label,
				child: Container(
					width: size,
					height: size,
					decoration: BoxDecoration(
						borderRadius: BorderRadius.circular(size * 0.1),
						boxShadow: [
							BoxShadow(
								color: Colors.black.withValues(alpha: 0.3),
								blurRadius: 2,
								offset: const Offset(0, 1),
							),
						],
					),
					child: Image.asset(
						imagePath,
						fit: BoxFit.contain,
					),
				),
			),
		);
	}

	/// Build a collection checkbox overlay
	Widget _buildCollectionCheckbox(
		double fieldWidth,
		double fieldHeight, {
		required String label,
		double? leftPercent,
		double? rightPercent,
		required double topPercent,
		required bool isChecked,
		required VoidCallback onTap,
	}) {
		final size = 4.0 * fieldWidth / 100;

		return Positioned(
			left: leftPercent != null ? leftPercent * fieldWidth / 100 : null,
			right: rightPercent != null ? rightPercent * fieldWidth / 100 : null,
			top: topPercent * fieldHeight / 100,
			child: GestureDetector(
				onTap: onTap,
				child: Container(
					width: size,
					height: size,
					decoration: BoxDecoration(
						borderRadius: BorderRadius.circular(size * 0.15),
						color: isChecked
							? Colors.green.shade700.withValues(alpha: 0.85)
							: Colors.grey.shade300.withValues(alpha: 0.6),
						border: Border.all(
							color: Colors.white,
							width: 1.5,
						),
						boxShadow: [
							BoxShadow(
								color: Colors.black.withValues(alpha: 0.3),
								blurRadius: 2,
								offset: const Offset(0, 1),
							),
						],
					),
					child: isChecked
						? Icon(
							Icons.check,
							color: Colors.white,
							size: size * 0.6,
						)
						: null,
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
	}) {
		final size = 8.0 * fieldWidth / 100;
		final fontSize = size * 0.6;

		return Positioned(
			right: 3.0 * fieldWidth / 100,
			top: 40.0 * fieldHeight / 100 - (size / 2),
			child: GestureDetector(
				onTap: onTap,
				child: Container(
					width: size,
					height: size,
					decoration: BoxDecoration(
						borderRadius: BorderRadius.circular(size * 0.15),
						color: Colors.black54.withValues(alpha: 0.7),
						border: Border.all(
							color: teamColor,
							width: 3,
						),
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
								color: Colors.white,
								fontSize: fontSize,
								fontWeight: FontWeight.bold,
							),
						),
					),
				),
			),
		);
	}
}
