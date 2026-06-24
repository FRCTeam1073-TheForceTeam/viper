import 'package:flutter/material.dart';

class BotSelectionScreen extends StatefulWidget {
	final Function(String) onBotSelected;

	const BotSelectionScreen({
		Key? key,
		required this.onBotSelected,
	}) : super(key: key);

	@override
	State<BotSelectionScreen> createState() => _BotSelectionScreenState();
}

class _BotSelectionScreenState extends State<BotSelectionScreen> {
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

	Widget _buildPositionButton(String position, bool isRed) {
		return ElevatedButton(
			style: ElevatedButton.styleFrom(
				backgroundColor: isRed ? Colors.red[700] : Colors.blue[700],
				foregroundColor: Colors.white,
				padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
				textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(8),
				),
			),
			onPressed: () => widget.onBotSelected(position),
			child: Text(position),
		);
	}

	Widget _buildFieldLayout({
		required bool isRotated,
		required List<String> positions,
	}) {
		// Create the layout based on field orientation
		// orientLeft: R1 R2 R3 on left (red), B3 B2 B1 on right (blue)
		// orientRight: B1 B2 B3 on left (blue), R3 R2 R1 on right (red)
		
		if (isRotated) {
			return Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceEvenly,
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							// Blue team on left
							Column(
								mainAxisSize: MainAxisSize.min,
								children: [
									_buildPositionButton('B1', false),
									const SizedBox(height: 16),
									_buildPositionButton('B2', false),
									const SizedBox(height: 16),
									_buildPositionButton('B3', false),
								],
							),
							// Field image placeholder
							Container(
								width: 120,
								height: 120,
								decoration: BoxDecoration(
									border: Border.all(color: Colors.grey),
									borderRadius: BorderRadius.circular(8),
								),
								child: const Icon(Icons.sports_soccer, size: 60, color: Colors.grey),
							),
							// Red team on right
							Column(
								mainAxisSize: MainAxisSize.min,
								children: [
									_buildPositionButton('R3', true),
									const SizedBox(height: 16),
									_buildPositionButton('R2', true),
									const SizedBox(height: 16),
									_buildPositionButton('R1', true),
								],
							),
						],
					),
				],
			);
		} else {
			return Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceEvenly,
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							// Red team on left
							Column(
								mainAxisSize: MainAxisSize.min,
								children: [
									_buildPositionButton('R1', true),
									const SizedBox(height: 16),
									_buildPositionButton('R2', true),
									const SizedBox(height: 16),
									_buildPositionButton('R3', true),
								],
							),
							// Field image placeholder
							Container(
								width: 120,
								height: 120,
								decoration: BoxDecoration(
									border: Border.all(color: Colors.grey),
									borderRadius: BorderRadius.circular(8),
								),
								child: const Icon(Icons.sports_soccer, size: 60, color: Colors.grey),
							),
							// Blue team on right
							Column(
								mainAxisSize: MainAxisSize.min,
								children: [
									_buildPositionButton('B3', false),
									const SizedBox(height: 16),
									_buildPositionButton('B2', false),
									const SizedBox(height: 16),
									_buildPositionButton('B1', false),
								],
							),
						],
					),
				],
			);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Select Robot Position'),
				centerTitle: true,
				elevation: 0,
			),
			body: Column(
				children: [
					// Page indicator
					Padding(
						padding: const EdgeInsets.all(16.0),
						child: Row(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Container(
									width: 12,
									height: 12,
									decoration: BoxDecoration(
										shape: BoxShape.circle,
										color: Colors.blue[700],
									),
								),
								const SizedBox(width: 8),
								Container(
									width: 12,
									height: 12,
									decoration: const BoxDecoration(
										shape: BoxShape.circle,
										color: Colors.grey,
									),
								),
							],
						),
					),
					// PageView for field orientations
					Expanded(
						child: PageView(
							controller: _pageController,
							children: [
								// First orientation (normal)
								Padding(
									padding: const EdgeInsets.all(16.0),
									child: _buildFieldLayout(isRotated: false, positions: const ['R1', 'R2', 'R3', 'B1', 'B2', 'B3']),
								),
								// Second orientation (rotated)
								Padding(
									padding: const EdgeInsets.all(16.0),
									child: _buildFieldLayout(isRotated: true, positions: const ['B1', 'B2', 'B3', 'R1', 'R2', 'R3']),
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
