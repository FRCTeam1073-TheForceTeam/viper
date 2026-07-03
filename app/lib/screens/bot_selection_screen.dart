import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../providers/app_providers.dart';
import '../providers/field_side_provider.dart';
import '../providers/locale_provider.dart';
import '../services/localization.dart';
import '../widgets/viper_menu_button.dart';

class BotSelectionScreen extends ConsumerStatefulWidget {
	final Function(String) onBotSelected;

	const BotSelectionScreen({
		Key? key,
		required this.onBotSelected,
	}) : super(key: key);

	@override
	ConsumerState<BotSelectionScreen> createState() => _BotSelectionScreenState();
}

class _BotSelectionScreenState extends ConsumerState<BotSelectionScreen> {
	late PageController _pageController;

	/// Helper to get translated text with current provider locale
	String _translate(String key) {
		final locale = ref.read(selectedLocaleProvider);
		return AppLocalizations.translate(key, locale: locale);
	}

	@override
	void initState() {
		super.initState();

		// Register translations
		AppLocalizations.addI18n({
			'select_robot_position': {
				'en': 'Select Robot Position',
				'es': 'Seleccionar posición del robot',
				'pt': 'Selecionar posição do robô',
				'fr': 'Sélectionner la position du robot',
				'zh_tw': '選擇機器人位置',
				'he': 'בחר מיקום רובוט',
				'tr': 'Robot Konumunu Seçin',
			},
			'swipe_field_orientation': {
				'en': 'Swipe left/right to change field orientation',
				'es': 'Desliza izquierda/derecha para cambiar la orientación del campo',
				'pt': 'Deslize para a esquerda/direita para alterar a orientação do campo',
				'fr': 'Glissez vers la gauche/droite pour changer l\'orientation du terrain',
				'zh_tw': '向左/右滑動以更改場地方向',
				'he': 'סוט שמאלה/ימינה כדי לשנות את כיוון התחום',
				'tr': 'Alan yönünü değiştirmek için sola/sağa kaydırın',
			},
		});

		// Initialize page controller with the stored field side preference
		// Page 0 = left field, Page 1 = right field
		final fieldSide = ref.read(selectedFieldSideProvider);
		final initialPage = fieldSide == FieldSide.right ? 1 : 0;
		_pageController = PageController(initialPage: initialPage);
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
		// Update the field side provider when orientation changes
		// Page 0 = left field, Page 1 = right field
		final newFieldSide = nextPage == 0 ? FieldSide.left : FieldSide.right;
		ref.read(selectedFieldSideProvider.notifier).setFieldSide(newFieldSide);
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

		return LayoutBuilder(
			builder: (context, constraints) {
				// Calculate field image height based on available width
				// Field aspect ratio is 1.875:1 (30:16)
				final fieldWidth = constraints.maxWidth - 80 - 16 - 80 - 16; // account for buttons and spacing
				final fieldHeight = (fieldWidth / 1.875) * 0.92; // reduce by 8% to account for button padding

				if (isRotated) {
					return Row(
						mainAxisAlignment: MainAxisAlignment.center,
						crossAxisAlignment: CrossAxisAlignment.center,
						children: [
							// Blue team on left
							SizedBox(
								width: 80,
								height: fieldHeight,
								child: Column(
									children: [
										Expanded(child: _buildPositionButton('B1', false, selectedPosition)),
										const SizedBox(height: 4),
										Expanded(child: _buildPositionButton('B2', false, selectedPosition)),
										const SizedBox(height: 4),
										Expanded(child: _buildPositionButton('B3', false, selectedPosition)),
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
								height: fieldHeight,
								child: Column(
									children: [
										Expanded(child: _buildPositionButton('R3', true, selectedPosition)),
										const SizedBox(height: 4),
										Expanded(child: _buildPositionButton('R2', true, selectedPosition)),
										const SizedBox(height: 4),
										Expanded(child: _buildPositionButton('R1', true, selectedPosition)),
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
								height: fieldHeight,
								child: Column(
									children: [
										Expanded(child: _buildPositionButton('R1', true, selectedPosition)),
										const SizedBox(height: 4),
										Expanded(child: _buildPositionButton('R2', true, selectedPosition)),
										const SizedBox(height: 4),
										Expanded(child: _buildPositionButton('R3', true, selectedPosition)),
									],
								),
							),
							const SizedBox(width: 16),
							// Field image - expands to fill (rotated for orientRight)
							Expanded(
								child: Transform.rotate(
									angle: pi, // 180° in radians
									child: GestureDetector(
										onTap: _toggleOrientation,
										child: Image.asset(
											'assets/images/field.png',
											fit: BoxFit.contain,
										),
									),
								),
							),
							const SizedBox(width: 16),
							// Blue team on right
							SizedBox(
								width: 80,
								height: fieldHeight,
								child: Column(
									children: [
										Expanded(child: _buildPositionButton('B3', false, selectedPosition)),
										const SizedBox(height: 4),
										Expanded(child: _buildPositionButton('B2', false, selectedPosition)),
										const SizedBox(height: 4),
										Expanded(child: _buildPositionButton('B1', false, selectedPosition)),
									],
								),
							),
						],
					);
				}
			},
		);
	}

	@override
	Widget build(BuildContext context) {
		print('[SCREEN_BUILD] BotSelectionScreen.build() called');
		// Watch locale to trigger rebuild when language changes
		ref.watch(selectedLocaleProvider);
		final selectedPosition = ref.watch(selectedBotPositionProvider);
		final selectedEventId = ref.watch(selectedEventProvider);
		final events = ref.watch(eventListProvider);

		// Find the event name from the event list
		String? eventName;
		if (selectedEventId != null) {
			try {
				eventName = events.firstWhere((e) => e.eventId == selectedEventId).name;
			} catch (e) {
				eventName = null;
			}
		}

		return Scaffold(
			appBar: AppBar(
				title: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					mainAxisSize: MainAxisSize.min,
					children: [
						if (eventName != null)
							Text(
								eventName!,
								style: Theme.of(context).textTheme.titleMedium?.copyWith(
									color: Colors.white,
								),
							),
						Text(
							_translate('select_robot_position'),
							style: Theme.of(context).textTheme.labelLarge?.copyWith(
								color: Colors.white70,
							),
						),
					],
				),
				elevation: 0,
				actions: [
					ViperMenuButton(),
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
							_translate('swipe_field_orientation'),
							style: Theme.of(context).textTheme.bodySmall,
							textAlign: TextAlign.center,
						),
					),
				],
			),
		);
	}
}
