import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../data/database/scout_database.dart';
import '../providers/app_providers.dart';
import '../providers/locale_provider.dart';
import '../services/form_validation.dart';
import '../services/localization.dart';
import '../widgets/viper_menu_button.dart';

class ServerConfigScreen extends ConsumerStatefulWidget {
	final Function(String) onServerConfigured;

	const ServerConfigScreen({
		super.key,
		required this.onServerConfigured,
	});

	@override
	ConsumerState<ServerConfigScreen> createState() =>
			_ServerConfigScreenState();
}

class _ServerConfigScreenState extends ConsumerState<ServerConfigScreen> {
	late TextEditingController _backendUrlController;
	late TextEditingController _usernameController;
	late TextEditingController _passwordController;
	final _formKey = GlobalKey<FormState>();
	bool _isLoading = false;

	/// Helper to get translated text with current provider locale
	String _translate(String key) {
		final locale = ref.read(selectedLocaleProvider);
		return AppLocalizations.translate(key, locale: locale);
	}

	@override
	void initState() {
		super.initState();
		_backendUrlController = TextEditingController();
		_usernameController = TextEditingController();
		_passwordController = TextEditingController();

		// Register translations
		AppLocalizations.addI18n({
			'configure_backend_server': {
				'en': 'Configure Backend Server',
				'es': 'Configurar servidor backend',
				'pt': 'Configurar servidor backend',
				'fr': 'Configurer le serveur backend',
				'zh_tw': '配置後端伺服器',
				'he': 'הגדר שרת אחורי',
				'tr': 'Arka Uç Sunucusunu Yapılandır',
			},
			'backend_server_url': {
				'en': 'Backend Server URL',
				'es': 'URL del servidor backend',
				'pt': 'URL do servidor backend',
				'fr': 'URL du serveur backend',
				'zh_tw': '後端伺服器 URL',
				'he': 'כתובת URL של שרת אחורי',
				'tr': 'Arka Uç Sunucusu URL\'si',
			},
			'backend_url_hint': {
				'en': 'demo.viperscout.com',
				'es': 'demo.viperscout.com',
				'pt': 'demo.viperscout.com',
				'fr': 'demo.viperscout.com',
				'zh_tw': 'demo.viperscout.com',
				'he': 'demo.viperscout.com',
				'tr': 'demo.viperscout.com',
			},
			'backend_url_examples': {
				'en': 'Examples: 192.168.1.100, demo.viperscout.com, http://localhost:8080',
				'es': 'Ejemplos: 192.168.1.100, demo.viperscout.com, http://localhost:8080',
				'pt': 'Exemplos: 192.168.1.100, demo.viperscout.com, http://localhost:8080',
				'fr': 'Exemples: 192.168.1.100, demo.viperscout.com, http://localhost:8080',
				'zh_tw': '範例: 192.168.1.100, demo.viperscout.com, http://localhost:8080',
				'he': 'דוגמאות: 192.168.1.100, demo.viperscout.com, http://localhost:8080',
				'tr': 'Örnekler: 192.168.1.100, demo.viperscout.com, http://localhost:8080',
			},
			'backend_url_invalid': {
				'en': 'Please enter a valid server address (e.g., demo.viperscout.com or 192.168.1.100)',
				'es': 'Por favor ingresa una dirección de servidor válida (p. ej., demo.viperscout.com o 192.168.1.100)',
				'pt': 'Por favor, digite um endereço de servidor válido (por exemplo, demo.viperscout.com ou 192.168.1.100)',
				'fr': 'Veuillez entrer une adresse de serveur valide (par exemple, demo.viperscout.com ou 192.168.1.100)',
				'zh_tw': '請輸入有效的伺服器地址（例如 demo.viperscout.com 或 192.168.1.100）',
				'he': 'אנא הזן כתובת שרת תקפה (למשל demo.viperscout.com או 192.168.1.100)',
				'tr': 'Lütfen geçerli bir sunucu adresi girin (örn. demo.viperscout.com veya 192.168.1.100)',
			},
			'username_optional': {
				'en': 'Username (optional)',
				'es': 'Usuario (opcional)',
				'pt': 'Usuário (opcional)',
				'fr': 'Nom d\'utilisateur (optionnel)',
				'zh_tw': '使用者名稱（可選）',
				'he': 'שם משתמש (אופציונלי)',
				'tr': 'Kullanıcı Adı (İsteğe Bağlı)',
			},
			'username_hint': {
				'en': 'username',
				'es': 'usuario',
				'pt': 'usuário',
				'fr': 'nom d\'utilisateur',
				'zh_tw': '使用者名稱',
				'he': 'שם משתמש',
				'tr': 'kullanıcı adı',
			},
			'password_optional': {
				'en': 'Password (optional)',
				'es': 'Contraseña (opcional)',
				'pt': 'Senha (opcional)',
				'fr': 'Mot de passe (optionnel)',
				'zh_tw': '密碼（可選）',
				'he': 'סיסמה (אופציונלי)',
				'tr': 'Şifre (İsteğe Bağlı)',
			},
			'password_hint': {
				'en': 'password',
				'es': 'contraseña',
				'pt': 'senha',
				'fr': 'mot de passe',
				'zh_tw': '密碼',
				'he': 'סיסמה',
				'tr': 'şifre',
			},
			'test_and_save': {
				'en': 'Test & Save',
				'es': 'Probar y guardar',
				'pt': 'Testar e salvar',
				'fr': 'Tester et enregistrer',
				'zh_tw': '測試並保存',
				'he': 'בדוק והשמור',
				'tr': 'Test Et Kaydet',
			},
			'testing_connection': {
				'en': 'Testing connection...',
				'es': 'Probando conexión...',
				'pt': 'Testando conexão...',
				'fr': 'Test de connexion...',
				'zh_tw': '測試連接中...',
				'he': 'בדיקת חיבור...',
				'tr': 'Bağlantı Test Ediliyor...',
			},
			'server_connected_successfully': {
				'en': '✓ Server connected successfully!',
				'es': '✓ ¡Servidor conectado exitosamente!',
				'pt': '✓ Servidor conectado com sucesso!',
				'fr': '✓ Serveur connecté avec succès!',
				'zh_tw': '✓ 伺服器已成功連接！',
				'he': '✓ השרת התחבר בהצלחה!',
				'tr': '✓ Sunucu başarıyla bağlandı!',
			},
			'server_connection_failed': {
				'en': '✗ Server did not respond or returned an error.\n\nMake sure the URL is correct and the server is running.\nTrying http:// instead of https:// may help.',
				'es': '✗ El servidor no respondió o devolvió un error.\n\nAsegúrate de que la URL sea correcta y que el servidor esté en ejecución.\nIntenta usar http:// en lugar de https://',
				'pt': '✗ O servidor não respondeu ou retornou um erro.\n\nCertifique-se de que a URL está correta e que o servidor está em execução.\nTentativa com http:// em vez de https:// pode ajudar.',
				'fr': '✗ Le serveur n\'a pas répondu ou a renvoyé une erreur.\n\nAssurez-vous que l\'URL est correcte et que le serveur fonctionne.\nEssayer http:// au lieu de https:// peut aider.',
				'zh_tw': '✗ 伺服器沒有回應或返回錯誤。\n\n確保 URL 正確且伺服器正在運行。\n嘗試使用 http:// 而不是 https:// 可能會有幫助。',
				'he': '✗ השרת לא הגיב או החזיר שגיאה.\n\nוודא שה-URL נכון ושהשרת פועל.\nניסיון להשתמש ב-http:// במקום https:// עשוי לעזור.',
				'tr': '✗ Sunucu yanıt vermedi veya bir hata döndürdü.\n\nURL\'in doğru olduğundan ve sunucunun çalıştığından emin olun.\nhttp:// yerine https:// kullanmayı deneyin.',
			},
			'ssl_certificate_error': {
				'en': 'SSL Certificate error. Try using http:// instead of https://, or ensure the server certificate is valid.',
				'es': 'Error de certificado SSL. Intenta usar http:// en lugar de https://, o asegúrate de que el certificado del servidor sea válido.',
				'pt': 'Erro de certificado SSL. Tente usar http:// em vez de https://, ou certifique-se de que o certificado do servidor seja válido.',
				'fr': 'Erreur de certificat SSL. Essayez d\'utiliser http:// au lieu de https://, ou assurez-vous que le certificat du serveur est valide.',
				'zh_tw': 'SSL 證書錯誤。嘗試使用 http:// 而不是 https://，或確保伺服器憑證有效。',
				'he': 'שגיאת תעודת SSL. נסה להשתמש ב-http:// במקום https://، או וודא שתעודת השרת תקפה.',
				'tr': 'SSL Sertifikası hatası. http:// yerine https:// kullanmayı deneyin veya sunucu sertifikasının geçerli olduğundan emin olun.',
			},
			'connection_refused': {
				'en': 'Connection refused. Make sure the server is running and the URL is correct.',
				'es': 'Conexión rechazada. Asegúrate de que el servidor esté en ejecución y la URL sea correcta.',
				'pt': 'Conexão recusada. Certifique-se de que o servidor está em execução e a URL está correta.',
				'fr': 'Connexion refusée. Assurez-vous que le serveur fonctionne et que l\'URL est correcte.',
				'zh_tw': '連接被拒絕。確保伺服器正在運行且 URL 正確。',
				'he': 'החיבור נדחה. וודא שהשרת פועל ו-URL נכון.',
				'tr': 'Bağlantı reddedildi. Sunucunun çalıştığından ve URL\'in doğru olduğundan emin olun.',
			},
			'unable_resolve_address': {
				'en': 'Unable to resolve server address. Check the URL and your internet connection.',
				'es': 'No se puede resolver la dirección del servidor. Verifica la URL y tu conexión a Internet.',
				'pt': 'Não é possível resolver o endereço do servidor. Verifique a URL e sua conexão com a Internet.',
				'fr': 'Impossible de résoudre l\'adresse du serveur. Vérifiez l\'URL et votre connexion Internet.',
				'zh_tw': '無法解析伺服器地址。檢查 URL 和您的網際網路連接。',
				'he': 'לא ניתן להحיל את כתובת השרת. בדוק את ה-URL ואת חיבור האינטרנט שלך.',
				'tr': 'Sunucu adresi çözülemiyor. URL\'i ve internet bağlantınızı kontrol edin.',
			},
			'connection_timeout': {
				'en': 'Connection timeout. The server took too long to respond.',
				'es': 'Tiempo de conexión agotado. El servidor tardó demasiado en responder.',
				'pt': 'Tempo limite de conexão. O servidor demorou muito para responder.',
				'fr': 'Délai d\'attente de connexion. Le serveur a mis trop de temps pour répondre.',
				'zh_tw': '連接逾時。伺服器回應時間過長。',
				'he': 'תם הזמן לחיבור. השרת לקח יותר מדי זמן לתגובה.',
				'tr': 'Bağlantı zaman aşımı. Sunucu çok uzun süre yanıt vermedi.',
			},
			'error_prefix': {
				'en': 'Error',
				'es': 'Error',
				'pt': 'Erro',
				'fr': 'Erreur',
				'zh_tw': '錯誤',
				'he': 'שגיאה',
				'tr': 'Hata',
			},
			'skip_for_now': {
				'en': 'Skip for now',
				'es': 'Omitir por ahora',
				'pt': 'Pular por enquanto',
				'fr': 'Ignorer pour l\'instant',
				'zh_tw': '暫時跳過',
				'he': 'דלג לעכשיו',
				'tr': 'Şimdilik Atla',
			},
		});

		_loadExistingConfig();
	}

	Future<void> _loadExistingConfig() async {
		try {
			final db = await ref.read(databaseProvider.future);
			final config = await db.getCurrentConfig();

			if (config != null) {
				_backendUrlController.text = config.backendUrl;
				if (config.username != null) {
					_usernameController.text = config.username!;
				}
				if (config.password != null) {
					_passwordController.text = config.password!;
				}
			}
		} catch (e) {
			// Ignore errors during load
		}
	}

	@override
	void dispose() {
		_backendUrlController.dispose();
		_usernameController.dispose();
		_passwordController.dispose();
		super.dispose();
	}

	/// Normalize server URL by prepending protocol if missing
	/// - IP addresses get http://
	/// - Hostnames get https://
	String _normalizeUrl(String url) {
		url = url.trim();

		// If already has protocol, return as-is
		if (url.startsWith('http://') || url.startsWith('https://')) {
			return url;
		}

		// Check if it's an IP address (including localhost and IPv6)
		final isIpAddress = _isIpAddress(url);

		return isIpAddress ? 'http://$url' : 'https://$url';
	}

	/// Check if a string is an IP address (IPv4, IPv6, localhost, or with port)
	bool _isIpAddress(String str) {
		// Remove port if present (e.g., "192.168.1.1:8080" or "[::1]:8080")
		String host = str;
		if (host.contains(':')) {
			// Handle IPv6 [::1]:8080 format
			if (host.startsWith('[')) {
				host = host.substring(1, host.lastIndexOf(']'));
			} else {
				// For IPv4 or hostname with port, take everything before first colon
				host = host.split(':').first;
			}
		}

		// Check for localhost
		if (host == 'localhost') return true;

		// IPv4 check: all parts are numbers 0-255
		final ipv4Pattern = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
		if (ipv4Pattern.hasMatch(host)) {
			final parts = host.split('.');
			return parts.every((part) {
				final num = int.tryParse(part);
				return num != null && num >= 0 && num <= 255;
			});
		}

		// IPv6 check: contains colons or is "::1"
		if (host.contains(':') || host == '::1') {
			return true;
		}

		return false;
	}

	/// Validate that the server URL is not empty or just a bare protocol
	bool _isValidServerUrl(String url) {
		if (url.isEmpty) return false;
		// Reject bare protocols or just slashes
		if (url == 'https://' || url == 'http://' || url == '/') return false;
		// URL should have something after the protocol or hostname
		final trimmed = url.trim();
		if (trimmed.isEmpty) return false;
		return true;
	}

	Future<void> _testAndSaveConnection() async {
		if (!_formKey.currentState!.validate()) {
			return;
		}

		setState(() => _isLoading = true);

		try {
			// Save configuration to database first
			final db = await ref.read(databaseProvider.future);
			final config = await db.getCurrentConfig();
			final backendUrl = _normalizeUrl(_backendUrlController.text);
			final username = _usernameController.text.trim();
			final password = _passwordController.text;

			// Validate the URL before saving
			if (!_isValidServerUrl(backendUrl)) {
				if (!mounted) return;
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text(_translate('backend_url_invalid')),
						backgroundColor: Colors.red,
						duration: const Duration(seconds: 3),
					),
				);
				setState(() => _isLoading = false);
				return;
			}

			if (config != null) {
				await db.upsertConfig(
					config.copyWith(
						backendUrl: backendUrl,
						username: Value(username.isNotEmpty ? username : null),
						password: Value(password.isNotEmpty ? password : null),
					),
				);
			} else {
				// Create new config with URL and credentials
				await db.upsertConfig(
					ServerConfigData(
						id: 1,
						backendUrl: backendUrl,
						username: username.isNotEmpty ? username : null,
						password: password.isNotEmpty ? password : null,
						selectedEventId: null,
						selectedTeam: null,
						scouterName: null,
						lastEventChangeDate: null,
					),
				);
			}

			// Invalidate and recreate API client with new base URL
			ref.invalidate(apiClientProvider);

			// Now test the connection with the configured backend
			final updatedConfig = await db.getCurrentConfig();
			if (updatedConfig != null) {
				final apiClient = await ref.read(apiClientProvider.future);

				if (!mounted) return;

				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
					content: Text(_translate('testing_connection')),
					duration: const Duration(seconds: 1),
				),
			);

			final testPassed = await apiClient.testConnection();

			if (!mounted) return;

			if (testPassed) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text(_translate('server_connected_successfully')),
					backgroundColor: Colors.green,
					duration: const Duration(seconds: 2),
				),
			);

			// Fetch local.js configuration in the background
			ref.invalidate(localJsVariablesProvider);

			// Call the callback
			widget.onServerConfigured(backendUrl);
				} else {
					ScaffoldMessenger.of(context).showSnackBar(
						SnackBar(
							content: Text(_translate('server_connection_failed')),
							backgroundColor: Colors.red,
							duration: const Duration(seconds: 4),
						),
					);
				}
			}
		} catch (e) {
			if (!mounted) return;

			String errorMessage = e.toString();
			if (errorMessage.contains('CERTIFICATE')) {
				errorMessage = _translate('ssl_certificate_error');
			} else if (errorMessage.contains('Connection refused')) {
				errorMessage = _translate('connection_refused');
			} else if (errorMessage.contains('getaddrinfo')) {
				errorMessage = _translate('unable_resolve_address');
			} else if (errorMessage.contains('Timeout')) {
				errorMessage = _translate('connection_timeout');
			}

			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text('${_translate('error_prefix')}: $errorMessage'),
					backgroundColor: Colors.red,
					duration: const Duration(seconds: 4),
				),
			);
		} finally {
			if (mounted) {
				setState(() => _isLoading = false);
			}
		}
	}

	@override
	Widget build(BuildContext context) {
		// Watch locale to rebuild when language changes
		final locale = ref.watch(selectedLocaleProvider);

		// Helper to get translated text with current locale
		String t(String key) => AppLocalizations.translate(key, locale: locale);

		return Scaffold(
			appBar: AppBar(
				title: Text(t('configure_backend_server')),
				centerTitle: true,
				elevation: 0,
				automaticallyImplyLeading: false,
				actions: [
					ViperMenuButton(),
				],
			),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(24),
				child: Form(
					key: _formKey,
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							// Backend URL input
							Text(
								t('backend_server_url'),
								style: Theme.of(context).textTheme.titleMedium,
							),
							const SizedBox(height: 12),
							TextFormField(
								controller: _backendUrlController,
								decoration: InputDecoration(
									hintText: t('backend_url_hint'),
									prefixIcon: const Icon(Icons.language),
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(8),
									),
								),
								validator: (value) =>
										FormValidation.validateHostname(value ?? ''),
							),
							const SizedBox(height: 12),
							Text(
								t('backend_url_examples'),
								style: Theme.of(context).textTheme.bodySmall?.copyWith(
									color: Colors.grey[500],
								),
							),
							const SizedBox(height: 30),

							// Username input (optional)
							Text(
								t('username_optional'),
								style: Theme.of(context).textTheme.titleMedium,
							),
							const SizedBox(height: 12),
							TextFormField(
								controller: _usernameController,
								decoration: InputDecoration(
									hintText: t('username_hint'),
									prefixIcon: const Icon(Icons.person),
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(8),
									),
								),
							),
							const SizedBox(height: 30),

							// Password input (optional)
							Text(
								t('password_optional'),
								style: Theme.of(context).textTheme.titleMedium,
							),
							const SizedBox(height: 12),
							TextFormField(
								controller: _passwordController,
								obscureText: true,
								decoration: InputDecoration(
									hintText: t('password_hint'),
									prefixIcon: const Icon(Icons.lock),
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(8),
									),
								),
							),
							const SizedBox(height: 40),

							// Test connection button
							SizedBox(
								width: double.infinity,
								child: FilledButton.icon(
									onPressed: _isLoading ? null : _testAndSaveConnection,
									icon: _isLoading
											? SizedBox(
													width: 20,
													height: 20,
													child: CircularProgressIndicator(
														strokeWidth: 2,
														valueColor: AlwaysStoppedAnimation<Color>(
															Theme.of(context).colorScheme.onPrimary,
														),
													),
												)
											: const Icon(Icons.check_circle),
									label: Text(
										_isLoading ? t('testing_connection') : t('test_and_save'),
										style: const TextStyle(
											fontSize: 16,
											fontWeight: FontWeight.w600,
										),
									),
								),
							),
							const SizedBox(height: 12),
							// Skip for now button
							SizedBox(
								width: double.infinity,
								child: TextButton(
									onPressed: () {
										ref.read(navigationCommandProvider.notifier).navigateTo(NavigationTarget.event);
									},
									child: Text(
										t('skip_for_now'),
										style: const TextStyle(
											fontSize: 16,
											fontWeight: FontWeight.w600,
										),
									),
								),
							),
						],
					),
				),
			),
		);
	}
}
