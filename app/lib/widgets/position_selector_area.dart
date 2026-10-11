import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/field_descriptor.dart';
import '../providers/field_side_provider.dart';
import '../providers/global_scouting_data.dart';

/// Reusable position selector widget for field areas (starting position, climb positions, etc)
/// Allows selecting a 2D position on a field image by tapping
class PositionSelectorArea extends StatefulWidget {
	final String? selectedPosition;
	final bool isBlueTeam;
	final FieldSide fieldSide;
	final String fieldName;
	final String blueImagePath;
	final String redImagePath;
	final double width;
	final double height;
	final double markerSize;
	final bool multiSelect;
	final Function(String) onPositionChanged;

	const PositionSelectorArea({
		super.key,
		required this.selectedPosition,
		required this.isBlueTeam,
		required this.fieldSide,
		required this.fieldName,
		required this.blueImagePath,
		required this.redImagePath,
		required this.width,
		required this.height,
		this.markerSize = 25,
		this.multiSelect = false,
		required this.onPositionChanged,
	});

	static Widget forField({
		required FieldDescriptor descriptor,
		required dynamic provider,
		required dynamic ref,
		required bool isBlueTeam,
		required FieldSide fieldSide,
		required String blueImagePath,
		required String redImagePath,
		required double width,
		required double height,
		double markerSize = 25,
		bool multiSelect = false,
	}) {
		// Get current value from global model
		final model = getGlobalScoutingData();
		if (model == null) {
			return SizedBox(width: width, height: height, child: const Center(child: CircularProgressIndicator()));
		}

		final selectedPosition = model.getFieldValue(descriptor.name).asString();

		final positionWidget = PositionSelectorArea(
			selectedPosition: selectedPosition,
			isBlueTeam: isBlueTeam,
			fieldSide: fieldSide,
			fieldName: descriptor.name,
			blueImagePath: blueImagePath,
			redImagePath: redImagePath,
			width: width,
			height: height,
			markerSize: markerSize,
			multiSelect: multiSelect,
			onPositionChanged: (newPosition) {
				final updated = model.updateField(descriptor.name, newPosition);
				ref.read(provider.notifier).update(updated);
			},
		);

		// Wrap in SizedBox to constrain dimensions
		return SizedBox(
			width: width,
			height: height,
			child: positionWidget,
		);
	}

	@override
	State<PositionSelectorArea> createState() => _PositionSelectorAreaState();
}

class _PositionSelectorAreaState extends State<PositionSelectorArea> {
	/// Parse "XxY" format (e.g., "50x50") to (x%, y%) tuple
	static (int, int)? _parsePosition(String? pos) {
		if (pos == null) return null;
		final parts = pos.split('x');
		if (parts.length != 2) return null;
		final x = int.tryParse(parts[0]);
		final y = int.tryParse(parts[1]);
		return (x != null && y != null) ? (x, y) : null;
	}

	/// Convert tap position to "XxY" format based on container dimensions
	String _getTapPosition(TapDownDetails details, Size containerSize) {
		final dx = details.localPosition.dx;
		final dy = details.localPosition.dy;

		// Calculate percentages (clamped 1-99)
		final pxRaw = (dx / containerSize.width) * 100;
		final pyRaw = (dy / containerSize.height) * 100;
		int px = pxRaw.round().clamp(1, 99);
		int py = pyRaw.round().clamp(1, 99);

		return '${px}x$py';
	}

	@override
	Widget build(BuildContext context) {
		// Parse positions - single or multiple
		final positions = <(int, int)>[];
		if (widget.multiSelect) {
			final posStrings = (widget.selectedPosition ?? '').split(' ').where((p) => p.isNotEmpty);
			for (var pos in posStrings) {
				final parsed = _parsePosition(pos);
				if (parsed != null) positions.add(parsed);
			}
		} else {
			final parsedPos = _parsePosition(widget.selectedPosition);
			if (parsedPos != null) positions.add(parsedPos);
		}

		// Apply 180° rotation based on team color and field side
		// Blue team on right field → rotate 180
		// Red team on left field → rotate 180
		final shouldRotate =
				(widget.isBlueTeam && widget.fieldSide == FieldSide.right) ||
				(!widget.isBlueTeam && widget.fieldSide == FieldSide.left);

		return Transform.rotate(
			angle: shouldRotate ? pi : 0, // 180° in radians
			child: GestureDetector(
				onTapDown: (details) {
					final size = Size(widget.width, widget.height);
					final newPos = _getTapPosition(details, size);
					if (widget.multiSelect) {
						// Append to existing positions
						final currentValue = widget.selectedPosition?.isEmpty ?? true ? '' : widget.selectedPosition!;
						final newValue = currentValue.isEmpty ? newPos : '$currentValue $newPos';
						widget.onPositionChanged(newValue);
					} else {
						// Single select: replace
						widget.onPositionChanged(newPos);
					}
				},
				child: Container(
					width: widget.width,
					height: widget.height,
					decoration: BoxDecoration(
						border: Border.all(color: Colors.grey, width: 2),
					),
					child: Stack(
						children: [
							// Background image
							Image.asset(
								widget.isBlueTeam ? widget.blueImagePath : widget.redImagePath,
								fit: BoxFit.fill,
								width: widget.width,
								height: widget.height,
							),
							// Position markers (single or multiple)
							...positions.map((pos) {
								return Positioned(
									left: (pos.$1 / 100) * widget.width - (widget.markerSize / 2),
									top: (pos.$2 / 100) * widget.height - (widget.markerSize / 2),
									child: Container(
										width: widget.markerSize,
										height: widget.markerSize,
										decoration: BoxDecoration(
											border: Border.all(
												color: widget.isBlueTeam
														? AppColors.blueTeamColor
														: AppColors.redTeamColor,
												width: 3,
											),
											color: Colors.grey[600],
											borderRadius: BorderRadius.circular(3),
										),
									),
								);
							}),
						],
					),
				),
			),
		);
	}
}
