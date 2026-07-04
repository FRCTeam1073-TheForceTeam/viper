import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/viper_api_client.dart';
import '../../providers/app_providers.dart';
import '../../providers/locale_provider.dart';
import '../../services/localization.dart';
import '../../widgets/viper_menu_button.dart';
import 'server_config_screen.dart';

class EventPickerScreen extends ConsumerStatefulWidget {
	final Function(String)? onEventSelected;

	const EventPickerScreen({
		Key? key,
		this.onEventSelected,
	}) : super(key: key);

	@override
	ConsumerState<EventPickerScreen> createState() => _EventPickerScreenState();
}

class _EventPickerScreenState extends ConsumerState<EventPickerScreen> {
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
			'select_event': {
				'en': 'Select Event',
				'es': 'Seleccionar evento',
				'pt': 'Selecionar evento',
				'fr': 'Sélectionner un événement',
				'zh_tw': '選擇事件',
				'he': 'בחר אירוע',
				'tr': 'Etkinlik Seçin',
			},
			'enter_event_id': {
				'en': 'Enter Event ID',
				'es': 'Ingrese ID del evento',
				'pt': 'Insira o ID do evento',
				'fr': 'Entrez l\'ID de l\'événement',
				'zh_tw': '輸入事件 ID',
				'he': 'הזן ID אירוע',
				'tr': 'Etkinlik Kimliğini Girin',
			},
			'event_id': {
				'en': 'Event ID',
				'es': 'ID del evento',
				'pt': 'ID do evento',
				'fr': 'ID de l\'événement',
				'zh_tw': '事件 ID',
				'he': 'ID אירוע',
				'tr': 'Etkinlik Kimliği',
			},
			'event_id_example': {
				'en': 'e.g., 2024flbr',
				'es': 'p. ej., 2024flbr',
				'pt': 'p. ex., 2024flbr',
				'fr': 'p. ex., 2024flbr',
				'zh_tw': '例如 2024flbr',
				'he': 'למשל, 2024flbr',
				'tr': 'örn. 2024flbr',
			},
			'event_id_format_help': {
				'en': 'Format: 20XX followed by alphanumeric characters',
				'es': 'Formato: 20XX seguido de caracteres alfanuméricos',
				'pt': 'Formato: 20XX seguido de caracteres alfanuméricos',
				'fr': 'Format: 20XX suivi de caractères alphanumériques',
				'zh_tw': '格式：20XX 後跟英數字字符',
				'he': 'פורמט: 20XX ואחריו תווים אלפانומריים',
				'tr': 'Format: 20XX ve ardından alfasayısal karakterler',
			},
			'event_id_required': {
				'en': 'Event ID is required',
				'es': 'El ID del evento es obligatorio',
				'pt': 'O ID do evento é obrigatório',
				'fr': 'L\'ID de l\'événement est obligatoire',
				'zh_tw': '事件 ID 為必填項',
				'he': 'ID אירוע נדרש',
				'tr': 'Etkinlik Kimliği Gerekli',
			},
			'event_id_invalid_format': {
				'en': 'Invalid format. Use: 20XX followed by letters/numbers/hyphens',
				'es': 'Formato inválido. Use: 20XX seguido de letras/números/guiones',
				'pt': 'Formato inválido. Use: 20XX seguido de letras/números/hífens',
				'fr': 'Format invalide. Utilisez: 20XX suivi de lettres/chiffres/tirets',
				'zh_tw': '格式無效。使用：20XX 後跟字母/數字/連字符',
				'he': 'פורמט לא חוקי. השתמש ב: 20XX ואחריו אותיות/ספרות/מקפים',
				'tr': 'Geçersiz format. Kullanın: 20XX ve ardından harfler/sayılar/tiretler',
			},
			'cancel': {
				'en': 'Cancel',
				'es': 'Cancelar',
				'pt': 'Cancelar',
				'fr': 'Annuler',
				'zh_tw': '取消',
				'he': 'ביטול',
				'tr': 'İptal',
			},
			'use_event': {
				'en': 'Use Event',
				'es': 'Usar evento',
				'pt': 'Usar evento',
				'fr': 'Utiliser l\'événement',
				'zh_tw': '使用事件',
				'he': 'השתמש באירוע',
				'tr': 'Etkinliği Kullan',
			},
			'add_event_manually': {
				'en': 'Add Event Manually',
				'es': 'Agregar evento manualmente',
				'pt': 'Adicionar evento manualmente',
				'fr': 'Ajouter un événement manuellement',
				'zh_tw': '手動添加事件',
				'he': 'הוסף אירוע ידנית',
				'tr': 'Etkinliği Manuel Olarak Ekle',
			},
			'no_server_connection': {
				'en': 'No Server Connection',
				'es': 'Sin conexión al servidor',
				'pt': 'Sem conexão com servidor',
				'fr': 'Pas de connexion au serveur',
				'zh_tw': '沒有伺服器連接',
				'he': 'אין חיבור שרת',
				'tr': 'Sunucu Bağlantısı Yok',
			},
			'unable_connect_server': {
				'en': 'Unable to connect to the server.\nYou can still enter an event ID manually.',
				'es': 'No se puede conectar al servidor.\nAún puedes ingresar una ID de evento manualmente.',
				'pt': 'Não é possível conectar ao servidor.\nVocê ainda pode inserir uma ID de evento manualmente.',
				'fr': 'Impossible de se connecter au serveur.\nVous pouvez toujours entrer un ID d\'événement manuellement.',
				'zh_tw': '無法連接到伺服器。\n您仍然可以手動輸入事件 ID。',
				'he': 'לא ניתן להתחבר לשרת.\nאתה עדיין יכול להזין ID אירוע ידנית.',
				'tr': 'Sunucuya bağlanamıyor.\nYine de etkinlik kimliğini manuel olarak girebilirsiniz.',
			},
			'change_server': {
				'en': 'Change Server',
				'es': 'Cambiar servidor',
				'pt': 'Alterar servidor',
				'fr': 'Changer de serveur',
				'zh_tw': '更改伺服器',
				'he': 'שנה שרת',
				'tr': 'Sunucuyu Değiştir',
			},
			'add_manually': {
				'en': 'Add Manually',
				'es': 'Agregar manualmente',
				'pt': 'Adicionar manualmente',
				'fr': 'Ajouter manuellement',
				'zh_tw': '手動添加',
				'he': 'הוסף ידנית',
				'tr': 'Manuel Olarak Ekle',
			},
		});
	}

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
				title: Text(_translate('enter_event_id')),
				content: Form(
					key: formKey,
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							TextFormField(
								controller: eventIdController,
								decoration: InputDecoration(
									labelText: _translate('event_id'),
									hintText: _translate('event_id_example'),
									helperText: _translate('event_id_format_help'),
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(8),
									),
								),
								validator: (value) {
									if (value == null || value.isEmpty) {
										return _translate('event_id_required');
									}

									// Validate format: /^20[0-9]{2}[a-zA-Z0-9\-]+$/
									final regex = RegExp(r'^20[0-9]{2}[a-zA-Z0-9\-]+$');
									if (!regex.hasMatch(value)) {
										return _translate('event_id_invalid_format');
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
						child: Text(_translate('cancel')),
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

									if (widget.onEventSelected != null) {
										widget.onEventSelected!(eventId);
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
						child: Text(_translate('use_event')),
					),
				],
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		// Watch locale to trigger rebuild when language changes
		ref.watch(selectedLocaleProvider);
		final events = ref.watch(eventListProvider);

		return Scaffold(
			appBar: AppBar(
				title: Text(_translate('select_event')),
				elevation: 0,
				automaticallyImplyLeading: false,
				actions: [
					ViperMenuButton(),
				],
			),
			body: ListView.builder(
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
								label: Text(_translate('add_event_manually')),
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
							if (widget.onEventSelected != null) {
								print('[EVENT_PICKER] Calling onEventSelected callback');
								widget.onEventSelected!(event.eventId);
							}
						},
					);
				},
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
