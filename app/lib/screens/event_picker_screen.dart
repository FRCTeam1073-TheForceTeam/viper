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

	void _showManualEventEntryDialog(BuildContext context, WidgetRef ref) {
		final TextEditingController eventIdController = TextEditingController();
		final GlobalKey<FormState> formKey = GlobalKey<FormState>();

		showDialog(
			context: context,
			builder: (context) => AlertDialog(
				title: const Text('Enter Event ID'),
				content: Form(
					key: formKey,
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							TextFormField(
								controller: eventIdController,
								decoration: InputDecoration(
									labelText: 'Event ID',
									hintText: 'e.g., 2024flbr',
									helperText: 'Format: 20XX followed by alphanumeric characters',
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(8),
									),
								),
								validator: (value) {
									if (value == null || value.isEmpty) {
										return 'Event ID is required';
									}

									// Validate format: /^20[0-9]{2}[a-zA-Z0-9\-]+$/
									final regex = RegExp(r'^20[0-9]{2}[a-zA-Z0-9\-]+$');
									if (!regex.hasMatch(value)) {
										return 'Invalid format. Use: 20XX followed by letters/numbers/hyphens';
									}

									return null;
								},
								textCapitalization: TextCapitalization.none,
							),
						],
					),
				),
				actions: [
					TextButton(
						onPressed: () {
							Navigator.pop(context);
						},
						child: const Text('Cancel'),
					),
					ElevatedButton(
						onPressed: () async {
							if (formKey.currentState!.validate()) {
								final eventId = eventIdController.text.trim();
								Navigator.pop(context);

								// Set the selected event
								try {
									await ref.read(selectedEventProvider.notifier)
											.setSelectedEvent(eventId);

									if (onEventSelected != null) {
										onEventSelected!(eventId);
									}
								} catch (e) {
									if (context.mounted) {
										ScaffoldMessenger.of(context).showSnackBar(
											SnackBar(content: Text('Error: $e')),
										);
									}
								}
							}
						},
						child: const Text('Use Event'),
					),
				],
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
					// Always show the list view - it will be empty if there are no events
					// The "Add Event Manually" button appears at the bottom
					return ListView.builder(
						itemCount: events.length + 1, // +1 for manual entry button
						itemBuilder: (context, index) {
							// Last item is the manual entry button
							if (index == events.length) {
								return Padding(
									padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
									child: ElevatedButton.icon(
										onPressed: () {
											_showManualEventEntryDialog(context, ref);
										},
										icon: const Icon(Icons.add),
										label: const Text('Add Event Manually'),
									),
								);
							}

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
								Icons.warning_outlined,
								size: 64,
								color: Colors.amber[600],
							),
							const SizedBox(height: 16),
							Text(
								'No Server Connection',
								style: Theme.of(context).textTheme.headlineSmall,
							),
							const SizedBox(height: 8),
							Padding(
								padding: const EdgeInsets.symmetric(horizontal: 24),
								child: Text(
									'Unable to connect to the server.\nYou can still enter an event ID manually.',
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
									ElevatedButton.icon(
										onPressed: () {
											_showManualEventEntryDialog(context, ref);
										},
										icon: const Icon(Icons.add),
										label: const Text('Add Manually'),
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
