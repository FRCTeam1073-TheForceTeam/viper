import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../providers/app_providers.dart';
import '../providers/field_side_provider.dart';
import '../providers/locale_provider.dart';
import '../services/localization.dart';
import '../widgets/viper_menu_button.dart';
import '../seasons/season_registry.dart';
import '../data/api/viper_api_client.dart';

class BotSelectionScreen extends ConsumerStatefulWidget {
	final String? eventId;
	final Function(String) onBotSelected;

	const BotSelectionScreen({
		Key? key,
		this.eventId,
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

	/// Get the field image asset path based on the event's season
	String _getFieldImageAsset() {
		if (widget.eventId == null || widget.eventId!.isEmpty) {
			return seasonModuleFor(defaultSeason)?.fieldImageAsset ?? 'assets/2026/images/field.png';
		}
		final season = EventModel.seasonFromEventId(widget.eventId!);
		return seasonModuleFor(season)?.fieldImageAsset ?? seasonModuleFor(defaultSeason)!.fieldImageAsset;
	}

	/// Get the bot positions for this event's season
	List<String> _getBotPositions() {
		if (widget.eventId == null || widget.eventId!.isEmpty) {
			return seasonModuleFor(defaultSeason)?.botPositions ?? const ['R1', 'R2', 'R3', 'B1', 'B2', 'B3'];
		}
		final season = EventModel.seasonFromEventId(widget.eventId!);
		return seasonModuleFor(season)?.botPositions ?? seasonModuleFor(defaultSeason)!.botPositions;
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

	bool _isFtcSeason(String? season) {
		return season != null && season.contains('-');
	}

	Widget _buildFieldLayout({
		required bool isRotated,
		required List<String> positions,
		required String? selectedPosition,
	}) {
		// For FTC (seasons like 2025-26), swap sides: Blue on left, Red on right
		// For FRC (seasons like 2026), keep as-is: Red on left, Blue on right
		final isFtc = _isFtcSeason(
			widget.eventId != null
				? EventModel.seasonFromEventId(widget.eventId!)
				: seasonModuleFor(defaultSeason)?.season
		);

		return LayoutBuilder(
			builder: (context, constraints) {
				// Calculate field image height based on available width
				// Field aspect ratio is 1.875:1 (30:16)
				final fieldWidth = constraints.maxWidth - 80 - 16 - 80 - 16; // account for buttons and spacing
				final fieldHeight = (fieldWidth / 1.875) * 0.92; // reduce by 8% to account for button padding

				if (isRotated) {
					if (isFtc) {
						return Row(
							mainAxisAlignment: MainAxisAlignment.center,
							crossAxisAlignment: CrossAxisAlignment.center,
							children: [
								// Red team on left (FTC rotated)
								SizedBox(
									width: 80,
									height: fieldHeight,
									child: Column(
										children: [
											if (positions.contains('R1')) Expanded(child: _buildPositionButton('R1', true, selectedPosition)),
											if (positions.contains('R1') && positions.contains('R2')) const SizedBox(height: 4),
											if (positions.contains('R2')) Expanded(child: _buildPositionButton('R2', true, selectedPosition)),
											if (positions.contains('R2') && positions.contains('R3')) const SizedBox(height: 4),
											if (positions.contains('R3')) Expanded(child: _buildPositionButton('R3', true, selectedPosition)),
										],
									),
								),
								const SizedBox(width: 16),
								// Field image - expands to fill
								Expanded(
									child: GestureDetector(
										onTap: _toggleOrientation,
										child: Image.asset(
											_getFieldImageAsset(),
											fit: BoxFit.contain,
										),
									),
								),
								const SizedBox(width: 16),
								// Blue team on right (FTC rotated)
								SizedBox(
									width: 80,
									height: fieldHeight,
									child: Column(
										children: [
											if (positions.contains('B3')) Expanded(child: _buildPositionButton('B3', false, selectedPosition)),
											if (positions.contains('B3') && positions.contains('B2')) const SizedBox(height: 4),
											if (positions.contains('B2')) Expanded(child: _buildPositionButton('B2', false, selectedPosition)),
											if (positions.contains('B2') && positions.contains('B1')) const SizedBox(height: 4),
											if (positions.contains('B1')) Expanded(child: _buildPositionButton('B1', false, selectedPosition)),
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
								// Blue team on left (FRC rotated)
								SizedBox(
									width: 80,
									height: fieldHeight,
									child: Column(
										children: [
											if (positions.contains('B1')) Expanded(child: _buildPositionButton('B1', false, selectedPosition)),
											if (positions.contains('B1') && positions.contains('B2')) const SizedBox(height: 4),
											if (positions.contains('B2')) Expanded(child: _buildPositionButton('B2', false, selectedPosition)),
											if (positions.contains('B2') && positions.contains('B3')) const SizedBox(height: 4),
											if (positions.contains('B3')) Expanded(child: _buildPositionButton('B3', false, selectedPosition)),
										],
									),
								),
								const SizedBox(width: 16),
								// Field image - expands to fill
								Expanded(
									child: GestureDetector(
										onTap: _toggleOrientation,
										child: Image.asset(
											_getFieldImageAsset(),
											fit: BoxFit.contain,
										),
									),
								),
								const SizedBox(width: 16),
								// Red team on right (FRC rotated)
								SizedBox(
									width: 80,
									height: fieldHeight,
									child: Column(
										children: [
											if (positions.contains('R3')) Expanded(child: _buildPositionButton('R3', true, selectedPosition)),
											if (positions.contains('R3') && positions.contains('R2')) const SizedBox(height: 4),
											if (positions.contains('R2')) Expanded(child: _buildPositionButton('R2', true, selectedPosition)),
											if (positions.contains('R2') && positions.contains('R1')) const SizedBox(height: 4),
											if (positions.contains('R1')) Expanded(child: _buildPositionButton('R1', true, selectedPosition)),
										],
									),
								),
							],
						);
					}
				} else {
					if (isFtc) {
						return Row(
							mainAxisAlignment: MainAxisAlignment.center,
							crossAxisAlignment: CrossAxisAlignment.center,
							children: [
								// Blue team on left (FTC normal)
								SizedBox(
									width: 80,
									height: fieldHeight,
									child: Column(
										children: [
											if (positions.contains('B1')) Expanded(child: _buildPositionButton('B1', false, selectedPosition)),
											if (positions.contains('B1') && positions.contains('B2')) const SizedBox(height: 4),
											if (positions.contains('B2')) Expanded(child: _buildPositionButton('B2', false, selectedPosition)),
											if (positions.contains('B2') && positions.contains('B3')) const SizedBox(height: 4),
											if (positions.contains('B3')) Expanded(child: _buildPositionButton('B3', false, selectedPosition)),
										],
									),
								),
								const SizedBox(width: 16),
								// Field image - expands to fill
								Expanded(
									child: Transform.rotate(
										angle: pi, // 180° in radians
										child: GestureDetector(
											onTap: _toggleOrientation,
											child: Image.asset(
												_getFieldImageAsset(),
												fit: BoxFit.contain,
											),
										),
									),
								),
								const SizedBox(width: 16),
								// Red team on right (FTC normal)
								SizedBox(
									width: 80,
									height: fieldHeight,
									child: Column(
										children: [
											if (positions.contains('R3')) Expanded(child: _buildPositionButton('R3', true, selectedPosition)),
											if (positions.contains('R3') && positions.contains('R2')) const SizedBox(height: 4),
											if (positions.contains('R2')) Expanded(child: _buildPositionButton('R2', true, selectedPosition)),
											if (positions.contains('R2') && positions.contains('R1')) const SizedBox(height: 4),
											if (positions.contains('R1')) Expanded(child: _buildPositionButton('R1', true, selectedPosition)),
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
								// Red team on left (FRC normal)
								SizedBox(
									width: 80,
									height: fieldHeight,
									child: Column(
										children: [
											if (positions.contains('R1')) Expanded(child: _buildPositionButton('R1', true, selectedPosition)),
											if (positions.contains('R1') && positions.contains('R2')) const SizedBox(height: 4),
											if (positions.contains('R2')) Expanded(child: _buildPositionButton('R2', true, selectedPosition)),
											if (positions.contains('R2') && positions.contains('R3')) const SizedBox(height: 4),
											if (positions.contains('R3')) Expanded(child: _buildPositionButton('R3', true, selectedPosition)),
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
												_getFieldImageAsset(),
												fit: BoxFit.contain,
											),
										),
									),
								),
								const SizedBox(width: 16),
								// Blue team on right (FRC normal)
								SizedBox(
									width: 80,
									height: fieldHeight,
									child: Column(
										children: [
											if (positions.contains('B3')) Expanded(child: _buildPositionButton('B3', false, selectedPosition)),
											if (positions.contains('B3') && positions.contains('B2')) const SizedBox(height: 4),
											if (positions.contains('B2')) Expanded(child: _buildPositionButton('B2', false, selectedPosition)),
											if (positions.contains('B2') && positions.contains('B1')) const SizedBox(height: 4),
											if (positions.contains('B1')) Expanded(child: _buildPositionButton('B1', false, selectedPosition)),
										],
									),
								),
							],
						);
					}
				}
			},
		);
	}

	@override
	Widget build(BuildContext context) {
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
									child: _buildFieldLayout(isRotated: false, positions: _getBotPositions(), selectedPosition: selectedPosition),
								),
								// Second orientation (rotated)
								Padding(
									padding: const EdgeInsets.all(16.0),
									child: _buildFieldLayout(isRotated: true, positions: _getBotPositions().reversed.toList(), selectedPosition: selectedPosition),
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
