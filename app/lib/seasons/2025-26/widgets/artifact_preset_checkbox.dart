import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/colors.dart';
import '../../../providers/global_scouting_data.dart';
import '../providers/scouting_data_provider.dart';

enum ArtifactColor { green, purple }

/// Bespoke checkbox for FTC's 4 artifact presets, each with 3 stacked/inline icons
/// Renders a mirrored icon row for blue team (blue-rev CSS equivalent)
class ArtifactPresetCheckbox extends ConsumerStatefulWidget {
	final String fieldName; // 'auto_preset_1'..'auto_preset_4'
	final List<ArtifactColor> icons; // ordered per layout
	final Axis direction; // Axis.vertical or Axis.horizontal
	final bool mirrorForBlue; // true for preset_4, preset_2
	final bool isBlueTeam;
	final dynamic provider;
	final VoidCallback? onTap; // optional callback for match-start logic

	const ArtifactPresetCheckbox({
		super.key,
		required this.fieldName,
		required this.icons,
		required this.direction,
		required this.mirrorForBlue,
		required this.isBlueTeam,
		required this.provider,
		this.onTap,
	});

	@override
	ConsumerState<ArtifactPresetCheckbox> createState() =>
		_ArtifactPresetCheckboxState();
}

class _ArtifactPresetCheckboxState extends ConsumerState<ArtifactPresetCheckbox> {
	late bool _isChecked;

	@override
	void initState() {
		super.initState();
		final model = getGlobalScoutingData();
		final storageValue = model?.values[widget.fieldName] as String?;
		_isChecked = storageValue == '1';
	}

	void _onPressed() {
		widget.onTap?.call();
		setState(() {
			_isChecked = !_isChecked;
		});
		final model = getGlobalScoutingData();
		if (model != null) {
			final updated = model.updateField(widget.fieldName, _isChecked ? 1 : 0);
			ref.read(widget.provider.notifier).update(updated);
		}
		// Notify scouting data of auto-tab interaction if in auto phase
		if (widget.fieldName.startsWith('auto_preset')) {
			ref.read(scoutingDataProvider.notifier).notifyAutoTouch(widget.fieldName);
		}
	}

	@override
	Widget build(BuildContext context) {
		final iconRow = widget.direction == Axis.vertical
			? Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: _buildIconList(),
			)
			: Row(
				mainAxisAlignment: MainAxisAlignment.center,
				children: _buildIconList(),
			);

		final content = widget.mirrorForBlue && widget.isBlueTeam
			? Transform.flip(flipX: true, child: iconRow)
			: iconRow;

		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
			child: GestureDetector(
				onTap: _onPressed,
				child: Container(
					decoration: BoxDecoration(
						borderRadius: BorderRadius.circular(8),
						color: _isChecked
							? AppColors.buttonSelectedBgColor
							: AppColors.buttonBgColor,
					),
					padding: const EdgeInsets.all(8),
					child: content,
				),
			),
		);
	}

	List<Widget> _buildIconList() {
		final icons = widget.icons
			.map((color) => Padding(
				padding: const EdgeInsets.all(4),
				child: Image.asset(
					color == ArtifactColor.green
						? 'assets/2025-26/images/artifact-green.png'
						: 'assets/2025-26/images/artifact-purple.png',
					width: 32,
					height: 32,
				),
			))
			.toList();

		// Add spacing between icons for vertical layout
		if (widget.direction == Axis.vertical) {
			final spaced = <Widget>[];
			for (int i = 0; i < icons.length; i++) {
				spaced.add(icons[i]);
				if (i < icons.length - 1) {
					spaced.add(const SizedBox(height: 4));
				}
			}
			return spaced;
		}
		return icons;
	}
}
