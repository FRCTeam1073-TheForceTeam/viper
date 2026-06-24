import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'server_config_screen.dart';
import 'tabs/scouter_info_tab.dart';
import 'tabs/pre_match_tab.dart';
import 'tabs/auto_tab.dart';
import 'tabs/teleop_tab.dart';
import 'tabs/end_game_tab.dart';
import '../../providers/app_providers.dart';
import '../../data/api/viper_api_client.dart';

class ScoutingAppScreen extends ConsumerStatefulWidget {
  final EventModel selectedEvent;

  const ScoutingAppScreen({
    Key? key,
    required this.selectedEvent,
  }) : super(key: key);

  @override
  ConsumerState<ScoutingAppScreen> createState() => _ScoutingAppScreenState();
}

class _ScoutingAppScreenState extends ConsumerState<ScoutingAppScreen> {
  int _selectedTabIndex = 0;
  String? _matchNumber;
  String? _teamNumber;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      ScouterInfoTab(
        eventId: widget.selectedEvent.eventId,
        matchNumber: _matchNumber,
        teamNumber: _teamNumber,
        onTeamChanged: (team) => setState(() => _teamNumber = team),
        onMatchChanged: (match) => setState(() => _matchNumber = match),
      ),
      PreMatchTab(
        eventId: widget.selectedEvent.eventId,
        matchNumber: _matchNumber,
        teamNumber: _teamNumber,
      ),
      AutoTab(
        eventId: widget.selectedEvent.eventId,
        matchNumber: _matchNumber,
        teamNumber: _teamNumber,
      ),
      TeleopTab(
        eventId: widget.selectedEvent.eventId,
        matchNumber: _matchNumber,
        teamNumber: _teamNumber,
      ),
      EndGameTab(
        eventId: widget.selectedEvent.eventId,
        matchNumber: _matchNumber,
        teamNumber: _teamNumber,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.selectedEvent.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            if (_matchNumber != null && _teamNumber != null)
              Text(
                'Match $_matchNumber • Team $_teamNumber',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
          ],
        ),
        actions: [
          if (syncState.isSyncing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  syncState.pendingCount > 0
                      ? '${syncState.pendingCount} pending'
                      : 'Synced',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: syncState.pendingCount > 0
                        ? Colors.orange
                        : Colors.white,
                  ),
                ),
              ),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                _showSettingsSheet(context, ref);
              } else if (value == 'sync') {
                ref.read(syncStateProvider.notifier).syncScoutData();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'sync',
                child: Text('Manual Sync'),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings'),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() => _selectedTabIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Pre-Match',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flash_on),
            label: 'Auto',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset),
            label: 'Teleop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'End Game',
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServerConfigScreen(
                      onServerConfigured: (_) {
                        ref.invalidate(apiClientProvider);
                        ref.invalidate(eventListProvider);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
              child: const Text('Change Server'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(selectedEventProvider.notifier).setSelectedEvent('');
                // Force reload
              },
              child: const Text('Change Event'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(syncStateProvider.notifier).syncScoutData();
              },
              child: const Text('Sync Now'),
            ),
          ],
        ),
      ),
    );
  }
}
