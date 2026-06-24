import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../providers/app_providers.dart';
import '../widgets/viper_menu_button.dart';

class BotSelectionScreen extends ConsumerStatefulWidget {
	final Function(String) onBotSelected;
	final VoidCallback? onChangeEvent;

	const BotSelectionScreen({
		Key? key,
		required this.onBotSelected,
		this.onChangeEvent,
	}) : super(key: key);

	@override
	ConsumerState<BotSelectionScreen> createState() => _BotSelectionScreenState();
}

class _BotSelectionScreenState extends ConsumerState<BotSelectionScreen> {
	late PageController _pageController;

	@override
	void initState() {
		super.initState();
		_pageController = PageController();
	}

	@override
	void dispose() {
		_pageController.dispose();
		super.dispose();
	}

	void _toggleOrientation() {
		final nextPage = _pageController.page == 0 ? 1 : 0;
		_pageController.animateToPage(
			nextPage.toInt(),
			duration: const Duration(milliseconds: 300),
			curve: Curves.easeInOut,
		);
	}

	Widget _buildPositionButton(String position, bool isRed, String? selectedPosition) {
		final isSelected = position == selectedPosition;
		return ElevatedButton(
			style: ElevatedButton.styleFrom(
				backgroundColor: isSelected ? AppColors.highlightBgColor : (isRed ? AppColors.redTeamColor : AppColors.blueTeamColor),
				foregroundColor: isSelected ? AppColors.mainFgColor : Colors.white,
				padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
				textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(8),
					side: isSelected
						? const BorderSide(color: AppColors.highlightBgColor, width: 2)
						: BorderSide.none,
				),
			),
			onPressed: () => widget.onBotSelected(position),
			child: Text(position),
		);
	}

	Widget _buildFieldLayout({
		required bool isRotated,
		required List<String> positions,
		required String? selectedPosition,
	}) {
		// Create the layout based on field orientation
		// orientLeft: R1 R2 R3 on left (red), B3 B2 B1 on right (blue)
		// orientRight: B1 B2 B3 on left (blue), R3 R2 R1 on right (red)

		if (isRotated) {
			return Row(
				mainAxisAlignment: MainAxisAlignment.center,
				crossAxisAlignment: CrossAxisAlignment.center,
				children: [
					// Blue team on left
					SizedBox(
						width: 80,
						child: Column(
								mainAxisAlignment: MainAxisAlignment.spaceEvenly,
							children: [
								_buildPositionButton('B1', false, selectedPosition),
								const SizedBox(height: 16),
								_buildPositionButton('B2', false, selectedPosition),
								const SizedBox(height: 16),
								_buildPositionButton('B3', false, selectedPosition),
							],
						),
					),
					const SizedBox(width: 16),
					// Field image - expands to fill
					Expanded(
						child: GestureDetector(
							onTap: _toggleOrientation,
							child: Image.asset(
								'assets/images/field.png',
								fit: BoxFit.contain,
							),
						),
					),
					const SizedBox(width: 16),
					// Red team on right
					SizedBox(
						width: 80,
						child: Column(
								mainAxisAlignment: MainAxisAlignment.spaceEvenly,
							children: [
								_buildPositionButton('R3', true, selectedPosition),
								const SizedBox(height: 16),
								_buildPositionButton('R2', true, selectedPosition),
								const SizedBox(height: 16),
								_buildPositionButton('R1', true, selectedPosition),
							],
						),
					),
				],
			);
		} else {
			return Row(
				mainAxisAlignment: MainAxisAlignment.center,
				crossAxisAlignment: CrossAxisAlignment.center,
				children: [
					// Red team on left
					SizedBox(
						width: 80,
						child: Column(
								mainAxisAlignment: MainAxisAlignment.spaceEvenly,
							children: [
								_buildPositionButton('R1', true, selectedPosition),
								const SizedBox(height: 16),
								_buildPositionButton('R2', true, selectedPosition),
								const SizedBox(height: 16),
								_buildPositionButton('R3', true, selectedPosition),
							],
						),
					),
					const SizedBox(width: 16),
					// Field image - expands to fill
					Expanded(
						child: GestureDetector(
							onTap: _toggleOrientation,
							child: Image.asset(
								'assets/images/field.png',
								fit: BoxFit.contain,
							),
						),
					),
					const SizedBox(width: 16),
					// Blue team on right
					SizedBox(
						width: 80,
						child: Column(
								mainAxisAlignment: MainAxisAlignment.spaceEvenly,
							children: [
								_buildPositionButton('B3', false, selectedPosition),
								const SizedBox(height: 16),
								_buildPositionButton('B2', false, selectedPosition),
								const SizedBox(height: 16),
								_buildPositionButton('B1', false, selectedPosition),
							],
						),
					),
				],
			);
		}
	}

	@override
	Widget build(BuildContext context) {
		final selectedPosition = ref.watch(selectedBotPositionProvider);

		return Scaffold(
			appBar: AppBar(
				title: const Text('Select Robot Position'),
				centerTitle: true,
				elevation: 0,
				actions: [
					ViperMenuButton(
						onChangeEvent: widget.onChangeEvent,
					),
				],
			),
			body: Column(
				children: [
					// PageView for field orientations
					Expanded(
						child: PageView(
							controller: _pageController,
							children: [
								// First orientation (normal)
								Padding(
									padding: const EdgeInsets.all(16.0),
									child: _buildFieldLayout(isRotated: false, positions: const ['R1', 'R2', 'R3', 'B1', 'B2', 'B3'], selectedPosition: selectedPosition),
								),
								// Second orientation (rotated)
								Padding(
									padding: const EdgeInsets.all(16.0),
									child: _buildFieldLayout(isRotated: true, positions: const ['B1', 'B2', 'B3', 'R1', 'R2', 'R3'], selectedPosition: selectedPosition),
								),
							],
						),
					),
					// Navigation instructions
					Padding(
						padding: const EdgeInsets.all(16.0),
						child: Text(
							'Swipe left/right to change field orientation',
							style: Theme.of(context).textTheme.bodySmall,
							textAlign: TextAlign.center,
						),
					),
				],
			),
		);
	}
}
