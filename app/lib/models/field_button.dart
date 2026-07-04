import 'package:flutter/foundation.dart';
import 'field_descriptor.dart';
import 'map_data_model.dart' show MapDataModel;

/// Data class representing a positioned button on the field
/// Uses CSS-like percentage positioning for responsive field display
@immutable
class FieldButton {
	/// Field counter name 
	final String field;

	/// Display label for the button
	final String label;

	/// Right position as percentage of field width (0-100)
	/// Use for positioning from the right edge (alliance/neutral buttons typically)
	final double rightPercent;

	/// Left position as percentage of field width (0-100)
	/// Use for positioning from the left edge (opponent zone buttons)
	final double? leftPercent;

	/// Bottom position as percentage of field height (0-100)
	/// Use when positioning from bottom
	final double? bottomPercent;

	/// Top position as percentage of field height (0-100)
	/// Use when positioning from top (if bottomPercent is null)
	final double? topPercent;

	/// Path to button image asset
	final String imagePath;

	/// Zone where this button is visible ('alliance', 'neutral', or 'opponent')
	final String zone;

	/// Button width as percentage of field width (for sizing)
	final double widthPercent;

	/// Button aspect ratio (default 1:1 square)
	final double aspectRatio;

	/// Field descriptor defining this button's data field (optional)
	final FieldDescriptor? descriptor;

	FieldButton({
		required this.field,
		required this.label,
		this.rightPercent = 0.0,
		this.leftPercent,
		this.bottomPercent,
		this.topPercent,
		required this.imagePath,
		required this.zone,
		this.widthPercent = 7.0,
		this.aspectRatio = 1.0,
		this.descriptor,
		MapDataModel? model,
	}) : assert(bottomPercent != null || topPercent != null) {
		if (model != null && descriptor != null) {
			model.registerDescriptor(descriptor!);
		}
	}

	@override
	String toString() =>
			'FieldButton(field: $field, label: $label, zone: $zone, '
			'right: $rightPercent%, bottom: $bottomPercent%, top: $topPercent%)';
}
