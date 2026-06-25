import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/viper_api_client.dart';
import '../../providers/app_providers.dart';
import '../../widgets/viper_menu_button.dart';
import 'server_config_screen.dart';

class EventPickerScreen extends ConsumerWidget {
	final Function(EventModel) onEventSelected;

	const EventPickerScreen({
		Key? key,
		required this.onEventSelected,
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
		final eventListAsync = ref.watch(eventListProvider);

		return Scaffold(
			appBar: AppBar(
				title: const Text('Select Event'),
				elevation: 0,
				actions: [
					ViperMenuButton(
						onChangeServer: () {
							WidgetsBinding.instance.addPostFrameCallback((_) {
								_showServerConfigModal(context, ref);
							});
						},
						onSync: () {
							ref.refresh(eventListProvider);
						},
					),
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
								onTap: () {
									ref.read(selectedEventProvider.notifier)
											.setSelectedEvent(event.eventId);
									onEventSelected(event);
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

class EventListTile extends StatelessWidget {
	final EventModel event;
	final VoidCallback onTap;

	const EventListTile({
		Key? key,
		required this.event,
		required this.onTap,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return Card(
			margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
			child: ListTile(
				onTap: onTap,
				title: Text(event.name),
				subtitle: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						if (event.location != null) ...[
							const SizedBox(height: 4),
							Text(event.location!),
						],
						const SizedBox(height: 4),
						Text(
							_formatDateRange(event.startDate, event.endDate),
							style: Theme.of(context).textTheme.labelSmall?.copyWith(
								color: Colors.grey[600],
							),
						),
					],
				),
				trailing: const Icon(Icons.arrow_forward),
			),
		);
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
