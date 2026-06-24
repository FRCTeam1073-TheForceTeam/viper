import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../data/database/scout_database.dart';
import '../../providers/app_providers.dart';
import '../../services/scout_data_helper.dart';

class TeleopTab extends ConsumerStatefulWidget {
  final String eventId;
  final String? matchNumber;
  final String? teamNumber;

  const TeleopTab({
    Key? key,
    required this.eventId,
    required this.matchNumber,
    required this.teamNumber,
  }) : super(key: key);

  @override
  ConsumerState<TeleopTab> createState() => _TeleopTabState();
}

class _TeleopTabState extends ConsumerState<TeleopTab> {
  late TextEditingController _fuelAllianceController;
  late TextEditingController _fuelNeutralController;
  late TextEditingController _fuelOpponentController;
  late TextEditingController _alliancePassesController;
  late TextEditingController _opponentPassesController;

  int _climbLevel = 0;
  ScoutData? _currentScout;

  @override
  void initState() {
    super.initState();
    _fuelAllianceController = TextEditingController();
    _fuelNeutralController = TextEditingController();
    _fuelOpponentController = TextEditingController();
    _alliancePassesController = TextEditingController();
    _opponentPassesController = TextEditingController();
    _loadScout();
  }

  @override
  void dispose() {
    _fuelAllianceController.dispose();
    _fuelNeutralController.dispose();
    _fuelOpponentController.dispose();
    _alliancePassesController.dispose();
    _opponentPassesController.dispose();
    super.dispose();
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
          _fuelAllianceController.text = (scout.teleopFuelAlliance ?? 0).toString();
          _fuelNeutralController.text = (scout.teleopFuelNeutral ?? 0).toString();
          _fuelOpponentController.text = (scout.teleopFuelOpponent ?? 0).toString();
          _alliancePassesController.text = (scout.teleopAlliancePasses ?? 0).toString();
          _opponentPassesController.text = (scout.teleopOpponentPasses ?? 0).toString();
          _climbLevel = scout.teleopClimbLevel ?? 0;
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
            teleopFuelAlliance: Value(int.tryParse(_fuelAllianceController.text)),
            teleopFuelNeutral: Value(int.tryParse(_fuelNeutralController.text)),
            teleopFuelOpponent: Value(int.tryParse(_fuelOpponentController.text)),
            teleopAlliancePasses: Value(int.tryParse(_alliancePassesController.text)),
            teleopOpponentPasses: Value(int.tryParse(_opponentPassesController.text)),
            teleopClimbLevel: Value(_climbLevel),
            updatedAt: now,
          )
        : ScoutDataHelper.createNewScout(
            event: widget.eventId,
            match: widget.matchNumber!,
            team: widget.teamNumber!,
          ).copyWith(
            teleopFuelAlliance: Value(int.tryParse(_fuelAllianceController.text)),
            teleopFuelNeutral: Value(int.tryParse(_fuelNeutralController.text)),
            teleopFuelOpponent: Value(int.tryParse(_fuelOpponentController.text)),
            teleopAlliancePasses: Value(int.tryParse(_alliancePassesController.text)),
            teleopOpponentPasses: Value(int.tryParse(_opponentPassesController.text)),
            teleopClimbLevel: Value(_climbLevel),
          );

    await db.upsertScout(scout);
    setState(() => _currentScout = scout);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teleop data saved')),
      );
    }
  }

  Widget _buildFuelInput(String label, TextEditingController controller) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    'Fuel Scoring',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildFuelInput('Alliance', _fuelAllianceController),
                      const SizedBox(width: 8),
                      _buildFuelInput('Neutral', _fuelNeutralController),
                      const SizedBox(width: 8),
                      _buildFuelInput('Opponent', _fuelOpponentController),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fuel Passes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildFuelInput('Alliance', _alliancePassesController),
                      const SizedBox(width: 8),
                      _buildFuelInput('Opponent', _opponentPassesController),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Climb Level (0-3)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _climbLevel.toDouble(),
                    min: 0,
                    max: 3,
                    divisions: 3,
                    label: '$_climbLevel',
                    onChanged: (value) {
                      setState(() => _climbLevel = value.toInt());
                    },
                  ),
                  Center(
                    child: Text(
                      'Level: $_climbLevel',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _saveTab,
            icon: const Icon(Icons.save),
            label: const Text('Save Teleop'),
          ),
        ],
      ),
    );
  }
}
