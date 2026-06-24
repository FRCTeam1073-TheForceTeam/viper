import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../data/database/scout_database.dart';
import '../providers/app_providers.dart';
import '../services/form_validation.dart';

class ServerConfigScreen extends ConsumerStatefulWidget {
  final Function(String) onServerConfigured;

  const ServerConfigScreen({
    required this.onServerConfigured,
    Key? key,
  }) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _backendUrlController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
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

  Future<void> _testAndSaveConnection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Save configuration to database first
      final db = await ref.read(databaseProvider.future);
      final config = await db.getCurrentConfig();
      final backendUrl = _backendUrlController.text.trim();
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

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
          const SnackBar(
            content: Text('Testing connection...'),
            duration: Duration(seconds: 1),
          ),
        );

        final testPassed = await apiClient.testConnection();

        if (!mounted) return;

        if (testPassed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Server connected successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Call the callback
          widget.onServerConfigured(backendUrl);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✗ Server did not respond or returned an error.\n\nMake sure the URL is correct and the server is running.\nTrying http:// instead of https:// may help.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      String errorMessage = e.toString();
      if (errorMessage.contains('CERTIFICATE')) {
        errorMessage = 'SSL Certificate error. Try using http:// instead of https://, or ensure the server certificate is valid.';
      } else if (errorMessage.contains('Connection refused')) {
        errorMessage = 'Connection refused. Make sure the server is running and the URL is correct.';
      } else if (errorMessage.contains('getaddrinfo')) {
        errorMessage = 'Unable to resolve server address. Check the URL and your internet connection.';
      } else if (errorMessage.contains('Timeout')) {
        errorMessage = 'Connection timeout. The server took too long to respond.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $errorMessage'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Backend Server'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              const Text(
                'Welcome to Viper Scout',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'First, let\'s connect to your backend server',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 40),

              // Backend URL input
              Text(
                'Backend Server URL',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _backendUrlController,
                decoration: InputDecoration(
                  hintText: 'http://192.168.1.100:8080',
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
                'Examples: http://192.168.1.100, http://viper.example.com, http://localhost:8080',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
              const SizedBox(height: 30),

              // Username input (optional)
              Text(
                'Username (optional)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'username',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Password input (optional)
              Text(
                'Password (optional)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'password',
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.check_circle),
                  label: Text(
                    _isLoading ? 'Testing connection...' : 'Test & Save',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ℹ Server Information',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.blue[900],
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your Viper server URL (e.g., https://1073.viperscout.com).\n\n'
                      'The app will test the connection by accessing /cgi/event-list.cgi.\n\n'
                      'If connection fails with HTTPS, try using http:// instead.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue[900],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
