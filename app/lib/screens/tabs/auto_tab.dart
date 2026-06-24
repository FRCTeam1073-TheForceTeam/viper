import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../data/database/scout_database.dart';
import '../../providers/app_providers.dart';
import '../../services/scout_data_helper.dart';

class AutoTab extends ConsumerStatefulWidget {
  final String eventId;
  final String? matchNumber;
  final String? teamNumber;

  const AutoTab({
    Key? key,
    required this.eventId,
    required this.matchNumber,
    required this.teamNumber,
  }) : super(key: key);

  @override
  ConsumerState<AutoTab> createState() => _AutoTabState();
}

class _AutoTabState extends ConsumerState<AutoTab> {
  late TextEditingController _fuelAllianceController;
  late TextEditingController _fuelNeutralController;
  late TextEditingController _fuelOpponentController;
  late TextEditingController _fuelDepotController;
  late TextEditingController _fuelOutpostController;
  
  int _climbLevel = 0;
  ScoutData? _currentScout;

  @override
  void initState() {
    super.initState();
    _fuelAllianceController = TextEditingController();
    _fuelNeutralController = TextEditingController();
    _fuelOpponentController = TextEditingController();
    _fuelDepotController = TextEditingController();
    _fuelOutpostController = TextEditingController();
    _loadScout();
  }

  @override
  void dispose() {
    _fuelAllianceController.dispose();
    _fuelNeutralController.dispose();
    _fuelOpponentController.dispose();
    _fuelDepotController.dispose();
    _fuelOutpostController.dispose();
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
          _fuelAllianceController.text = (scout.autoFuelAlliance ?? 0).toString();
          _fuelNeutralController.text = (scout.autoFuelNeutral ?? 0).toString();
          _fuelOpponentController.text = (scout.autoFuelOpponent ?? 0).toString();
          _fuelDepotController.text = (scout.autoFuelDepot ?? 0).toString();
          _fuelOutpostController.text = (scout.autoFuelOutpost ?? 0).toString();
          _climbLevel = scout.autoClimbLevel ?? 0;
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
            autoFuelAlliance: Value(int.tryParse(_fuelAllianceController.text)),
            autoFuelNeutral: Value(int.tryParse(_fuelNeutralController.text)),
            autoFuelOpponent: Value(int.tryParse(_fuelOpponentController.text)),
            autoFuelDepot: Value(int.tryParse(_fuelDepotController.text)),
            autoFuelOutpost: Value(int.tryParse(_fuelOutpostController.text)),
            autoClimbLevel: Value(_climbLevel),
            updatedAt: now,
          )
        : ScoutDataHelper.createNewScout(
            event: widget.eventId,
            match: widget.matchNumber!,
            team: widget.teamNumber!,
          ).copyWith(
            autoFuelAlliance: Value(int.tryParse(_fuelAllianceController.text)),
            autoFuelNeutral: Value(int.tryParse(_fuelNeutralController.text)),
            autoFuelOpponent: Value(int.tryParse(_fuelOpponentController.text)),
            autoFuelDepot: Value(int.tryParse(_fuelDepotController.text)),
            autoFuelOutpost: Value(int.tryParse(_fuelOutpostController.text)),
            autoClimbLevel: Value(_climbLevel),
          );

    await db.upsertScout(scout);
    setState(() => _currentScout = scout);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Auto data saved')),
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFuelInput('Depot', _fuelDepotController),
                      const SizedBox(width: 8),
                      _buildFuelInput('Outpost', _fuelOutpostController),
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
                    'Climb Level (0-1)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _climbLevel.toDouble(),
                    min: 0,
                    max: 1,
                    divisions: 1,
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
            label: const Text('Save Auto'),
          ),
        ],
      ),
    );
  }
}
