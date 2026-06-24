import 'package:dio/dio.dart';
import 'package:csv/csv.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'dart:convert';

/// Event model
class EventModel {
  final String eventId;
  final String name;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;

  EventModel({
    required this.eventId,
    required this.name,
    this.location,
    this.startDate,
    this.endDate,
  });

  /// Extract season year from eventId (e.g., "2024flbr" -> 2024)
  int get season => int.parse(eventId.substring(0, 4));

  /// Check if this event is from a specific season
  bool isFromSeason(int year) => season == year;
}

class ViperApiClient {
  final String baseUrl;
  final String? username;
  final String? password;
  late final Dio _dio;
  final Logger _logger = Logger();

  ViperApiClient({
    required this.baseUrl,
    this.username,
    this.password,
  }) {
    final dioOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) => status != null && status < 500,
    );

    _dio = Dio(dioOptions);

    // Add basic auth if credentials provided
    if (username != null && username!.isNotEmpty) {
      _addBasicAuth();
    }

    // Configure HTTP client to handle SSL/TLS certificates
    // This allows both valid certificates and self-signed certificates
    _configureHttpClient();
  }

  /// Add basic authentication header
  void _addBasicAuth() {
    if (username == null || username!.isEmpty) return;

    final credentials = '$username:${password ?? ''}';
    final encoded = Uri.encodeComponent(credentials);
    // For basic auth, we need to use base64 encoding
    final bytes = utf8.encode(credentials);
    final base64Str = base64Encode(bytes);

    _dio.options.headers['Authorization'] = 'Basic $base64Str';
    _logger.i('Basic auth configured for user: $username');
  }

  /// Configure HTTP client with custom SSL settings
  void _configureHttpClient() {
    try {
      // Get the underlying HttpClient from Dio's adapter
      final httpClient = HttpClient();

      // Allow connections to servers with certificate issues
      // This is useful for development and servers with self-signed certs
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        _logger.w(
          'Certificate validation issue for $host:$port. '
          'Accepting for development/testing.',
        );
        return true;
      };

      // Note: Setting a custom HttpClient on Dio is platform-dependent
      // The badCertificateCallback will only work on native platforms (iOS, Android, desktop)
      // On web, certificate validation is handled by the browser
    } catch (e) {
      _logger.w('Could not configure custom HTTP client: $e');
    }
  }

  /// Fetch event list from /event-list.cgi
  /// Returns list of events parsed from CSV response
  Future<List<EventModel>> fetchEventList() async {
    try {
      final fullUrl = '$baseUrl/event-list.cgi';
      _logger.i('📡 Fetching event list from: $fullUrl');

      final response = await _dio.get('/event-list.cgi');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch events: HTTP ${response.statusCode}',
        );
      }

      // Parse CSV response
      final csvString = response.data as String;
      _logger.d('Raw CSV response length: ${csvString.length} characters');
      _logger.d('First 200 chars: ${csvString.substring(0, csvString.length > 200 ? 200 : csvString.length)}');

      // Debug: check for line endings
      final hasCarriageReturn = csvString.contains('\r');
      final hasNewline = csvString.contains('\n');
      _logger.d('Line endings - CR: $hasCarriageReturn, LF: $hasNewline');

      // Split by newlines manually to see raw lines
      final rawLines = csvString.split(RegExp(r'\r?\n'));
      _logger.d('Raw line count: ${rawLines.length}');
      _logger.d('Lines by CsvToListConverter:');

      final csvList = const CsvToListConverter().convert(csvString);
      _logger.d('Parsed CSV rows: ${csvList.length}');

      if (csvList.length == 1) {
        _logger.e('ERROR: CSV parser only found 1 row! Trying alternative parsing...');
        // Try manual parsing
        final manualLines = csvString.split(RegExp(r'\r?\n'))
            .where((line) => line.trim().isNotEmpty)
            .toList();
        _logger.d('Manual line parsing found ${manualLines.length} non-empty lines');
        for (var i = 0; i < manualLines.take(5).length; i++) {
          _logger.d('  Line $i: ${manualLines[i].substring(0, manualLines[i].length > 100 ? 100 : manualLines[i].length)}');
        }
      }

      final events = <EventModel>[];

      // Skip header row if present
      final startIndex = _isHeaderRow(csvList.first) ? 1 : 0;
      _logger.d('Header detected at index 0: ${startIndex == 1}');

      if (csvList.length == 1) {
        _logger.e('ERROR: CSV parser only found 1 row! Using manual line parsing...');
        // CsvToListConverter failed - manually parse lines
        final manualLines = csvString.split(RegExp(r'\r?\n'))
            .where((line) => line.trim().isNotEmpty)
            .toList();

        _logger.d('Manual parsing found ${manualLines.length} non-empty lines');

        for (int i = 1; i < manualLines.length; i++) {
          try {
            final line = manualLines[i];
            // Simple CSV parsing - split by comma
            final fields = line.split(',');

            if (fields.length < 2) {
              _logger.w('Skipping line $i: insufficient fields (${fields.length})');
              continue;
            }

            final eventId = fields[0].trim();
            final name = fields[1].trim();
            final location = fields.length > 2 ? fields[2].trim() : '';
            final endDate = _parseDate(fields.length > 4 ? fields[4].trim() : null);
            final startDate = _parseDate(fields.length > 7 ? fields[7].trim() : null);

            if (eventId.isNotEmpty && name.isNotEmpty) {
              events.add(EventModel(
                eventId: eventId,
                name: name,
                location: location.isEmpty ? null : location,
                startDate: startDate,
                endDate: endDate,
              ));
              _logger.d('Manually added: $eventId - $name');
            }
          } catch (e) {
            _logger.w('Error parsing line $i: $e');
          }
        }
      } else {
        // Use CSV list normally
        for (int i = startIndex; i < csvList.length; i++) {
          final row = csvList[i];
          if (row.length < 3) {
            _logger.w('Skipping row $i: insufficient columns (${row.length} < 3)');
            continue;
          }

          try {
            final eventId = row[0]?.toString() ?? '';
            final name = row[1]?.toString() ?? '';
            final location = row[2]?.toString();
            // CSV columns: event, name, location, blue_alliance_id, end, first_inspires_id, orange_alliance_id, start
            final endDate = _parseDate(row.length > 4 ? row[4] : null);
            final startDate = _parseDate(row.length > 7 ? row[7] : null);

            if (eventId.isNotEmpty && name.isNotEmpty) {
              events.add(EventModel(
                eventId: eventId,
                name: name,
                location: location,
                startDate: startDate,
                endDate: endDate,
              ));
              _logger.d('Added event: $eventId - $name (start: ${startDate?.toString() ?? "null"})');
            } else {
              _logger.w('Skipping row $i: eventId or name is empty (eventId="$eventId", name="$name")');
            }
          } catch (e) {
            _logger.e('Error parsing row $i: $e');
            continue;
          }
        }
      }

      _logger.i('✅ Successfully fetched ${events.length} events from $fullUrl');
      if (events.isNotEmpty) {
        _logger.d('First event: ${events.first.eventId} - ${events.first.name}');
      }
      return events;
    } catch (e) {
      _logger.e('Error fetching event list: $e');
      rethrow;
    }
  }

  /// Upload scout data as CSV to /scout/upload.cgi
  /// [csvContent] is the full CSV string (headers + data rows)
  Future<Map<String, dynamic>> uploadScoutData(String csvContent) async {
    try {
      _logger.i('Uploading scout data');

      final response = await _dio.post(
        'scout/upload.cgi',
        data: {'csv': csvContent},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Upload failed: HTTP ${response.statusCode}',
        );
      }

      _logger.i('Scout data uploaded successfully');

      // Parse response (expecting JSON or plain text confirmation)
      return {'success': true, 'response': response.data};
    } catch (e) {
      _logger.e('Error uploading scout data: $e');
      rethrow;
    }
  }

  /// Test connection to backend
  Future<bool> testConnection() async {
    try {
      final fullUrl = '$baseUrl/event-list.cgi';
      _logger.i('🔗 Testing connection to: $fullUrl');

      final response = await _dio.get('/event-list.cgi');
      final isOk = response.statusCode == 200;

      if (isOk) {
        _logger.i('✅ Connection successful! (HTTP ${response.statusCode}) - $fullUrl');
      } else {
        _logger.w('❌ Connection failed (HTTP ${response.statusCode}) - $fullUrl');
      }

      return isOk;
    } catch (e) {
      final fullUrl = '$baseUrl/event-list.cgi';
      _logger.e('❌ Connection test error: $e\n   URL: $fullUrl');
      return false;
    }
  }

  // =========================================================================
  // PRIVATE HELPERS
  // =========================================================================

  /// Check if row is a CSV header row
  bool _isHeaderRow(List<dynamic> row) {
    if (row.isEmpty) return false;
    final first = row.first.toString().toLowerCase();
    return first.contains('event') || first.contains('id');
  }

  /// Parse date string (YYYY-MM-DD format)
  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }
}
