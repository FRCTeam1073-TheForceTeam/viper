import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/scout_database.dart';
import '../../providers/app_providers.dart';
import '../../services/form_validation.dart';
import '../../services/scout_data_helper.dart';

class ScouterInfoTab extends ConsumerStatefulWidget {
  final String eventId;
  final String? matchNumber;
  final String? teamNumber;
  final Function(String) onTeamChanged;
  final Function(String) onMatchChanged;

  const ScouterInfoTab({
    Key? key,
    required this.eventId,
    required this.matchNumber,
    required this.teamNumber,
    required this.onTeamChanged,
    required this.onMatchChanged,
  }) : super(key: key);

  @override
  ConsumerState<ScouterInfoTab> createState() => _ScouterInfoTabState();
}

class _ScouterInfoTabState extends ConsumerState<ScouterInfoTab> {
  late final TextEditingController _matchController;
  late final TextEditingController _teamController;
  late final TextEditingController _scouterNameController;
  late final TextEditingController _commentsController;

  bool _reviewRequest = false;
  ScoutData? _currentScout;

  @override
  void initState() {
    super.initState();
    _matchController = TextEditingController();
    _teamController = TextEditingController();
    _scouterNameController = TextEditingController();
    _commentsController = TextEditingController();
    _loadExistingScout();
  }

  @override
  void dispose() {
    _matchController.dispose();
    _teamController.dispose();
    _scouterNameController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingScout() async {
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
          _matchController.text = scout.match;
          _teamController.text = scout.team;
          _scouterNameController.text = scout.scouterName ?? '';
          _commentsController.text = scout.comments ?? '';
          _reviewRequest = scout.reviewRequest;
        });
      }
    }
  }

  Future<void> _saveScout() async {
    final matchError = FormValidation.validateMatchNumber(_matchController.text);
    final teamError = FormValidation.validateTeamNumber(_teamController.text);
    final scouterError = FormValidation.validateScouterName(_scouterNameController.text);
    final commentsError = FormValidation.validateComments(_commentsController.text);

    if (matchError != null) {
      _showError(matchError);
      return;
    }
    if (teamError != null) {
      _showError(teamError);
      return;
    }
    if (scouterError != null) {
      _showError(scouterError);
      return;
    }
    if (commentsError != null) {
      _showError(commentsError);
      return;
    }

    widget.onMatchChanged(_matchController.text);
    widget.onTeamChanged(_teamController.text);

    final db = await ref.read(databaseProvider.future);
    final now = DateTime.now();

    final scoutData = ScoutData(
      event: widget.eventId,
      match: _matchController.text,
      team: _teamController.text,
      scouterName: _scouterNameController.text,
      comments: _commentsController.text,
      reviewRequest: _reviewRequest,
      createdAt: _currentScout?.createdAt ?? now,
      updatedAt: now,
      synced: false,
      startingPosition: _currentScout?.startingPosition,
      noShow: _currentScout?.noShow ?? false,
      autoFuelAlliance: _currentScout?.autoFuelAlliance,
      autoFuelNeutral: _currentScout?.autoFuelNeutral,
      autoFuelOpponent: _currentScout?.autoFuelOpponent,
      autoFuelDepot: _currentScout?.autoFuelDepot,
      autoFuelOutpost: _currentScout?.autoFuelOutpost,
      autoClimbLevel: _currentScout?.autoClimbLevel,
      teleopFuelAlliance: _currentScout?.teleopFuelAlliance,
      teleopFuelNeutral: _currentScout?.teleopFuelNeutral,
      teleopFuelOpponent: _currentScout?.teleopFuelOpponent,
      teleopClimbLevel: _currentScout?.teleopClimbLevel,
      teleopAlliancePasses: _currentScout?.teleopAlliancePasses,
      teleopOpponentPasses: _currentScout?.teleopOpponentPasses,
      teleopZoneInteractions: _currentScout?.teleopZoneInteractions,
      climbPosition: _currentScout?.climbPosition,
      climbMethod: _currentScout?.climbMethod,
      shootOnMove: _currentScout?.shootOnMove ?? false,
      shootWhileCollecting: _currentScout?.shootWhileCollecting ?? false,
      climbing: _currentScout?.climbing ?? false,
      fuelStrategy: _currentScout?.fuelStrategy,
      shootingLocations: _currentScout?.shootingLocations,
      damageState: _currentScout?.damageState,
      defenseRating: _currentScout?.defenseRating,
      defenseMethods: _currentScout?.defenseMethods,
      defenseImpact: _currentScout?.defenseImpact,
      shootingMissesRange: _currentScout?.shootingMissesRange,
      syncedAt: _currentScout?.syncedAt,
    );

    await db.upsertScout(scoutData);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scout data saved')),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
                    'Match & Team',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _matchController,
                          decoration: const InputDecoration(
                            labelText: 'Match #',
                            hintText: 'e.g., qm1',
                            border: OutlineInputBorder(),
                          ),
                          validator: FormValidation.validateMatchNumber,
                          onChanged: widget.onMatchChanged,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _teamController,
                          decoration: const InputDecoration(
                            labelText: 'Team #',
                            hintText: 'e.g., 3654',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: FormValidation.validateTeamNumber,
                          onChanged: widget.onTeamChanged,
                        ),
                      ),
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
                    'Scouter Info',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _scouterNameController,
                    decoration: const InputDecoration(
                      labelText: 'Scouter Name',
                      hintText: 'Your name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _commentsController,
                    decoration: const InputDecoration(
                      labelText: 'Comments',
                      hintText: 'Additional notes...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: _reviewRequest,
                    onChanged: (value) {
                      setState(() => _reviewRequest = value ?? false);
                    },
                    title: const Text('Request review'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_currentScout != null) ...[
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Entry Info',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Created: ${_formatDateTime(_currentScout!.createdAt)}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      'Modified: ${_formatDateTime(_currentScout!.updatedAt)}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    if (_currentScout!.syncedAt != null)
                      Text(
                        'Synced: ${_formatDateTime(_currentScout!.syncedAt!)}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          ElevatedButton.icon(
            onPressed: _saveScout,
            icon: const Icon(Icons.save),
            label: const Text('Save Scout Entry'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
