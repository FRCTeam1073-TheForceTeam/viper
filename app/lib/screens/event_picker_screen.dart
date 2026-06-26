import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/viper_api_client.dart';
import '../../providers/app_providers.dart';
import '../../widgets/viper_menu_button.dart';
import 'server_config_screen.dart';

class EventPickerScreen extends ConsumerWidget {
	final Function(String)? onEventSelected;

	const EventPickerScreen({
		Key? key,
		this.onEventSelected,
	}) : super(key: key);

	void _showServerConfigModal(BuildContext context, WidgetRef ref) {
		showModalBottomSheet(
			context: context,
			isScrollControlled: true,
			builder: (context) => ServerConfigScreen(
				onServerConfigured: (url) {
					Navigator.pop(context);
					// Invalidate both providers to force refresh with new credentials
					ref.invalidate(eventListProvider);
					ref.refresh(eventListProvider);
				},
			),
		);
	}

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		print('[SCREEN_BUILD] EventPickerScreen.build() called');
		final eventListAsync = ref.watch(eventListProvider);

		return Scaffold(
			appBar: AppBar(
				title: const Text('Select Event'),
				elevation: 0,
				automaticallyImplyLeading: false,
				actions: [
					ViperMenuButton(),
				],
			),
			body: eventListAsync.when(
				data: (events) {
					if (events.isEmpty) {
						return Center(
							child: Column(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									Icon(
										Icons.event_note,
										size: 64,
										color: Colors.grey[400],
									),
									const SizedBox(height: 16),
									Text(
										'No events found',
										style: Theme.of(context).textTheme.headlineSmall,
									),
									const SizedBox(height: 8),
									Text(
										'Try changing the server URL in settings',
										style: Theme.of(context).textTheme.bodyMedium?.copyWith(
											color: Colors.grey[600],
										),
									),
								],
							),
						);
					}

					return ListView.builder(
						itemCount: events.length,
						itemBuilder: (context, index) {
							final event = events[index];
							return EventListTile(
								event: event,
								onTap: () async {
									print('[EVENT_PICKER] EventListTile.onTap called for ${event.eventId}');
									print('[EVENT_PICKER] Calling setSelectedEvent...');
									await ref.read(selectedEventProvider.notifier)
											.setSelectedEvent(event.eventId);
									print('[EVENT_PICKER] setSelectedEvent completed');
									// Call the callback if provided
									if (onEventSelected != null) {
										print('[EVENT_PICKER] Calling onEventSelected callback');
										onEventSelected!(event.eventId);
									}
								},
							);
						},
					);
				},
				loading: () => const Center(
					child: CircularProgressIndicator(),
				),
				error: (error, stack) => Center(
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Icon(
								Icons.error_outline,
								size: 64,
								color: Colors.red[300],
							),
							const SizedBox(height: 16),
							Text(
								'Failed to load events',
								style: Theme.of(context).textTheme.headlineSmall,
							),
							const SizedBox(height: 8),
							Padding(
								padding: const EdgeInsets.symmetric(horizontal: 24),
								child: Text(
									error.toString(),
									textAlign: TextAlign.center,
									style: Theme.of(context).textTheme.bodyMedium?.copyWith(
										color: Colors.grey[600],
									),
								),
							),
							const SizedBox(height: 24),
							Row(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									ElevatedButton.icon(
										onPressed: () {
											_showServerConfigModal(context, ref);
										},
										icon: const Icon(Icons.settings),
										label: const Text('Change Server'),
									),
									const SizedBox(width: 12),
									ElevatedButton(
										onPressed: () {
											ref.refresh(eventListProvider);
										},
										child: const Text('Retry'),
									),
								],
							),
						],
					),
				),
			),
		);
	}
}

class EventListTile extends StatefulWidget {
	final EventModel event;
	final Future<void> Function() onTap;

	const EventListTile({
		Key? key,
		required this.event,
		required this.onTap,
	}) : super(key: key);

	@override
	State<EventListTile> createState() => _EventListTileState();
}

class _EventListTileState extends State<EventListTile> {
	bool _isLoading = false;

	@override
	Widget build(BuildContext context) {
		print('[EVENT_LIST_TILE] build() called, _isLoading=$_isLoading');
		return Card(
			margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
			child: ListTile(
				onTap: _isLoading ? null : _handleTap,
				enabled: !_isLoading,
				title: Text(widget.event.name),
				subtitle: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						if (widget.event.location != null) ...[
							const SizedBox(height: 4),
							Text(widget.event.location!),
						],
						const SizedBox(height: 4),
						Text(
							_formatDateRange(widget.event.startDate, widget.event.endDate),
							style: Theme.of(context).textTheme.labelSmall?.copyWith(
								color: Colors.grey[600],
							),
						),
					],
				),
				trailing: _isLoading
					? const SizedBox(
						width: 24,
						height: 24,
						child: CircularProgressIndicator(strokeWidth: 2),
					)
					: const Icon(Icons.arrow_forward),
			),
		);
	}

	Future<void> _handleTap() async {
		print('[EVENT_LIST_TILE] _handleTap() called');
		setState(() {
			print('[EVENT_LIST_TILE] setState _isLoading = true');
			_isLoading = true;
		});
		try {
			print('[EVENT_LIST_TILE] Awaiting widget.onTap()...');
			await widget.onTap();
			print('[EVENT_LIST_TILE] widget.onTap() completed');
		} finally {
			if (mounted) {
				print('[EVENT_LIST_TILE] setState _isLoading = false');
				setState(() => _isLoading = false);
			} else {
				print('[EVENT_LIST_TILE] Widget already unmounted, skipping setState');
			}
		}
	}

	String _formatDateRange(DateTime? start, DateTime? end) {
		if (start == null && end == null) {
			return 'Date TBD';
		}

		final startStr = start != null ? _formatDate(start) : '?';
		final endStr = end != null ? _formatDate(end) : '?';

		return '$startStr - $endStr';
	}

	String _formatDate(DateTime date) {
		return '${date.month}/${date.day}/${date.year}';
	}
}
