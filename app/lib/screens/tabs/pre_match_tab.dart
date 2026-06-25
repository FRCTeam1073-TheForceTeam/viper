import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../data/database/scout_database.dart';
import '../../providers/app_providers.dart';
import '../../services/scout_data_helper.dart';
import '../../services/localization.dart';

class PreMatchTab extends ConsumerStatefulWidget {
	final String eventId;
	final String? matchNumber;
	final String? teamNumber;

	const PreMatchTab({
		Key? key,
		required this.eventId,
		required this.matchNumber,
		required this.teamNumber,
	}) : super(key: key);

	@override
	ConsumerState<PreMatchTab> createState() => _PreMatchTabState();
}

class _PreMatchTabState extends ConsumerState<PreMatchTab> {
	String? _selectedPosition;
	bool _noShow = false;
	ScoutData? _currentScout;

	@override
	void initState() {
		super.initState();

		// Register translations on demand when this tab is first loaded
		AppLocalizations.addI18n({
			'no_show': {
				'en': 'No Show',
				'es': 'No',
				'pt': 'Sem presença',
				'fr': 'Non présent',
				'zh_tw': '沒有出席',
				'he': 'אין הופעה',
				'tr': 'Gösterilmedi',
			},
			'starting_position': {
				'en': 'Starting Position',
				'es': 'Posición inicial',
				'pt': 'Posição inicial',
				'fr': 'Position de départ',
				'zh_tw': '起始位置',
				'he': 'מיקום ההתחלה',
				'tr': 'Başlangıç Pozisyonu',
			},
		});

		_loadScout();
	}

	Future<void> _loadScout() async {
		if (widget.matchNumber != null && widget.teamNumber != null) {
			final db = await ref.read(databaseProvider.future);
			final scout = await db.getScout(
				widget.eventId,
				widget.matchNumber!,
				widget.teamNumber!,
			);
			if (scout != null) {
				setState(() {
					_currentScout = scout;
					_selectedPosition = scout.startingPosition;
					_noShow = scout.noShow;
				});
			}
		}
	}

	Future<void> _saveTab() async {
		if (widget.matchNumber == null || widget.teamNumber == null) return;

		final db = await ref.read(databaseProvider.future);
		final existing = _currentScout ?? await db.getScout(
			widget.eventId,
			widget.matchNumber!,
			widget.teamNumber!,
		);

		final now = DateTime.now();
		final scout = existing != null
				? existing.copyWith(
						startingPosition: Value(_selectedPosition),
						noShow: _noShow,
						updatedAt: now,
					)
				: ScoutDataHelper.createNewScout(
						event: widget.eventId,
						match: widget.matchNumber!,
						team: widget.teamNumber!,
					).copyWith(
						startingPosition: Value(_selectedPosition),
						noShow: _noShow,
					);

		await db.upsertScout(scout);
		setState(() => _currentScout = scout);

		if (mounted) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('Pre-Match data saved')),
			);
		}
	}

	@override
	Widget build(BuildContext context) {
		// Get the selected bot position to determine team color (blue or red)
		final botPosition = ref.watch(selectedBotPositionProvider);
		final isBlueTeam = botPosition?.startsWith('B') ?? false;

		return SingleChildScrollView(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										context.t('starting_position'),
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 16),
									// Starting position interactive area (clickable/draggable)
									_StartingPositionArea(
										selectedPosition: _selectedPosition,
										isBlueTeam: isBlueTeam,
										onPositionChanged: (newPosition) {
											print('💾 Saving starting position: $newPosition');
											setState(() => _selectedPosition = newPosition);
										},
									),
								],
							),
						),
					),
					const SizedBox(height: 16),
					SizedBox(
						width: double.infinity,
						child: FilledButton(
							style: FilledButton.styleFrom(
								backgroundColor: _noShow
									? const Color(0xFF77DD77) // --button-selected-bg-color
									: const Color(0xFFBBBBBB), // --button-bg-color
								foregroundColor: const Color(0xFF333333), // --button-fg-color
								padding: const EdgeInsets.symmetric(vertical: 16),
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(8),
								),
							),
							onPressed: () {
								setState(() => _noShow = !_noShow);
							},
							child: Text(
								context.t('no_show'),
								style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
							),
						),
					),
					const SizedBox(height: 16),
					ElevatedButton.icon(
						onPressed: _saveTab,
						icon: const Icon(Icons.save),
						label: const Text('Save Pre-Match'),
					),
				],
			),
		);
	}
}

/// Interactive starting position area widget (mimics web app's click-to-position behavior)
class _StartingPositionArea extends StatefulWidget {
	final String? selectedPosition;
	final bool isBlueTeam;
	final Function(String) onPositionChanged;

	const _StartingPositionArea({
		required this.selectedPosition,
		required this.isBlueTeam,
		required this.onPositionChanged,
	});

	@override
	State<_StartingPositionArea> createState() => _StartingPositionAreaState();
}

class _StartingPositionAreaState extends State<_StartingPositionArea> {
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

		print('   Percentages: px=${pxRaw.toStringAsFixed(1)}% → $px%, py=${pyRaw.toStringAsFixed(1)}% → $py%');
		
		return '${px}x${py}';
	}

	@override
	Widget build(BuildContext context) {
		final parsedPos = _parsePosition(widget.selectedPosition);
		final imagePath = widget.isBlueTeam
			? 'assets/images/start-area-blue.png'
			: 'assets/images/start-area-red.png';

		return GestureDetector(
			onTapDown: (details) {
				// Start area dimensions match web app CSS: 8.4em width, 25em height
				// Approximate pixel dimensions for a reasonable UI size
				final size = Size(84, 250);
				final newPos = _getTapPosition(details, size);
				
				// Debug output
				print('🎯 Starting Position Tap:');
				print('   Raw coordinates: dx=${details.localPosition.dx.toStringAsFixed(1)}, dy=${details.localPosition.dy.toStringAsFixed(1)}');
				print('   Container size: ${size.width.toStringAsFixed(0)} x ${size.height.toStringAsFixed(0)} px');
				print('   ✅ New position: $newPos');
				
				widget.onPositionChanged(newPos);
			},
			child: Container(
				width: 84,
				height: 250,
				decoration: BoxDecoration(
					border: Border.all(color: Colors.grey, width: 2),
				),
				child: Stack(
					children: [
						// Start area background image
						Image.asset(
							imagePath,
							fit: BoxFit.fill,
							width: 84,
							height: 250,
						),
						// Robot position indicator (small square overlay)
						if (parsedPos != null)
							Positioned(
								left: (parsedPos.$1 / 100) * 84 - 12.5,
								top: (parsedPos.$2 / 100) * 250 - 12.5,
								child: Container(
									width: 25,
									height: 25,
									decoration: BoxDecoration(
										border: Border.all(
											color: widget.isBlueTeam ? Colors.blue : Colors.red,
											width: 3,
										),
										color: Colors.grey[600],
										borderRadius: BorderRadius.circular(3),
									),
								),
							),
					],
				),
			),
		);
	}
}
