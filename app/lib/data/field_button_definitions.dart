import 'package:flutter/foundation.dart';

/// Data class representing a positioned button on the field
/// Uses CSS-like percentage positioning for responsive field display
@immutable
class FieldButton {
	/// Field counter name (e.g., 'auto_trench_depot_alliance_to_neutral')
	final String field;

	/// Display label for the button
	final String label;

	/// Right position as percentage of field width (0-100)
	/// Use for positioning from the right edge
	final double rightPercent;

	/// Bottom position as percentage of field height (0-100)
	/// Use when positioning from bottom
	final double? bottomPercent;

	/// Top position as percentage of field height (0-100)
	/// Use when positioning from top (if bottomPercent is null)
	final double? topPercent;

	/// Path to button image asset
	final String imagePath;

	/// Zone where this button is visible ('alliance' or 'neutral')
	final String zone;

	/// Button width as percentage of field width (for sizing)
	final double widthPercent;

	/// Button aspect ratio (default 1:1 square)
	final double aspectRatio;

	const FieldButton({
		required this.field,
		required this.label,
		required this.rightPercent,
		this.bottomPercent,
		this.topPercent,
		required this.imagePath,
		required this.zone,
		this.widthPercent = 7.0,
		this.aspectRatio = 1.0,
	}) : assert(bottomPercent != null || topPercent != null);

	@override
	String toString() =>
			'FieldButton(field: $field, label: $label, zone: $zone, '
			'right: $rightPercent%, bottom: $bottomPercent%, top: $topPercent%)';
}

/// Button definitions for the 2026 FRC game field
/// Based on web app CSS positioning: www/2026/scout.html
///
/// Layout: Field is 1.875:1 aspect ratio
/// - 8 movement buttons total
/// - 4 Alliance→Neutral (exit, arrow-left, at right:26%)
/// - 4 Neutral→Alliance (entry, arrow-right, at right:26%)
/// - Zone toggles at bottom (left:3%, right:3%, bottom:3%)
/// - Climb selector at top-right (right:3%, top:40%)
final List<FieldButton> fieldButtonDefinitions = [
	// ============ ALLIANCE → NEUTRAL (Exit to Neutral) ============
	// Arrow buttons positioned at right:26% from right edge
	FieldButton(
		field: 'auto_trench_depot_alliance_to_neutral',
		label: 'Depot Trench to Neutral',
		rightPercent: 26.0,
		bottomPercent: 5.0,
		imagePath: 'assets/images/arrow-left.png',
		zone: 'alliance',
	),
	FieldButton(
		field: 'auto_bump_depot_alliance_to_neutral',
		label: 'Depot Bump to Neutral',
		rightPercent: 26.0,
		bottomPercent: 21.0,
		imagePath: 'assets/images/arrow-left.png',
		zone: 'alliance',
	),
	FieldButton(
		field: 'auto_bump_outpost_alliance_to_neutral',
		label: 'Outpost Bump to Neutral',
		rightPercent: 26.0,
		topPercent: 21.0,
		imagePath: 'assets/images/arrow-left.png',
		zone: 'alliance',
	),
	FieldButton(
		field: 'auto_trench_outpost_alliance_to_neutral',
		label: 'Outpost Trench to Neutral',
		rightPercent: 26.0,
		topPercent: 5.0,
		imagePath: 'assets/images/arrow-left.png',
		zone: 'alliance',
	),

	// ============ NEUTRAL → ALLIANCE (Entry from Neutral) ============
	// Arrow buttons positioned at right:26% from right edge (mirror layout)
	FieldButton(
		field: 'auto_trench_depot_neutral_to_alliance',
		label: 'Depot Trench to Alliance',
		rightPercent: 26.0,
		bottomPercent: 5.0,
		imagePath: 'assets/images/arrow-right.png',
		zone: 'neutral',
	),
	FieldButton(
		field: 'auto_bump_depot_neutral_to_alliance',
		label: 'Depot Bump to Alliance',
		rightPercent: 26.0,
		bottomPercent: 21.0,
		imagePath: 'assets/images/arrow-right.png',
		zone: 'neutral',
	),
	FieldButton(
		field: 'auto_bump_outpost_neutral_to_alliance',
		label: 'Outpost Bump to Alliance',
		rightPercent: 26.0,
		topPercent: 21.0,
		imagePath: 'assets/images/arrow-right.png',
		zone: 'neutral',
	),
	FieldButton(
		field: 'auto_trench_outpost_neutral_to_alliance',
		label: 'Outpost Trench to Alliance',
		rightPercent: 26.0,
		topPercent: 5.0,
		imagePath: 'assets/images/arrow-right.png',
		zone: 'neutral',
	),
];
