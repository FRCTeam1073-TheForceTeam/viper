import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import '../../services/csv_parser.dart';

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
		required String baseUrl,
		this.username,
		this.password,
	}) : baseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl {
		final dioOptions = BaseOptions(
			baseUrl: this.baseUrl,
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

	/// Fetch raw CSV string from /event-list.cgi
	/// Returns the raw CSV string for caching purposes
	Future<String?> fetchEventListCsv() async {
		try {
			final fullUrl = '$baseUrl/event-list.cgi';
			_logger.i('📡 Fetching event list CSV from: $fullUrl');

			final response = await _dio.get('/event-list.cgi');

			if (response.statusCode != 200) {
				throw Exception(
					'Failed to fetch events: HTTP ${response.statusCode}',
				);
			}

			final csvString = response.data as String;
			_logger.d('Raw CSV response length: ${csvString.length} characters');
			return csvString;
		} catch (e) {
			_logger.e('Error fetching event list CSV: $e');
			return null;
		}
	}

	/// Parse event CSV string into EventModel list
	/// Used for both cached and fresh CSV data
	List<EventModel> parseEventCsv(String csvString) {
		try {
			final csvData = csvToArrayOfMaps(csvString);
			_logger.d('Parsed CSV rows: ${csvData.length}');

			final events = <EventModel>[];

			// Convert each CSV row to EventModel
			for (int i = 0; i < csvData.length; i++) {
				try {
					final row = csvData[i];
					final eventId = (row['event'] ?? '').toString().trim();
					final name = (row['name'] ?? '').toString().trim();
					final location = (row['location'] ?? '').toString().trim();
					final startDateStr = (row['start'] ?? '').toString().trim();
					final endDateStr = (row['end'] ?? '').toString().trim();

					if (eventId.isEmpty || name.isEmpty) {
						_logger.w('Skipping row $i: eventId or name is empty');
						continue;
					}

					final startDate = _parseDate(startDateStr.isNotEmpty ? startDateStr : null);
					final endDate = _parseDate(endDateStr.isNotEmpty ? endDateStr : null);

					events.add(EventModel(
						eventId: eventId,
						name: name,
						location: location.isNotEmpty ? location : null,
						startDate: startDate,
						endDate: endDate,
					));
				} catch (e) {
					_logger.e('Error parsing row $i: $e');
					continue;
				}
			}

			_logger.i('✅ Successfully parsed ${events.length} events from CSV');
			return events;
		} catch (e) {
			_logger.e('Error parsing event CSV: $e');
			return [];
		}
	}

	/// Fetch event list from /event-list.cgi
	/// Returns list of events parsed from CSV response
	Future<List<EventModel>> fetchEventList() async {
		try {
			final fullUrl = '$baseUrl/event-list.cgi';
			_logger.i('📡 Fetching event list from: $fullUrl');

			final csvString = await fetchEventListCsv();
			if (csvString == null) {
				_logger.i('Returning empty event list - manual event entry will be available');
				return [];
			}

			return parseEventCsv(csvString);
		} catch (e) {
			_logger.e('Error fetching event list: $e');
			// Return empty list instead of throwing - allows offline/no-server operation
			_logger.i('Returning empty event list - manual event entry will be available');
			return [];
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

	/// Fetch raw text from a server endpoint
	Future<String> fetchRaw(String path) async {
		try {
			final fullUrl = '$baseUrl$path';
			_logger.i('📡 Fetching raw from: $fullUrl');

			final response = await _dio.get(path);

			if (response.statusCode != 200) {
				throw Exception(
					'Failed to fetch: HTTP ${response.statusCode} from $fullUrl',
				);
			}

			return response.data as String;
		} catch (e) {
			final fullUrl = '$baseUrl$path';
			_logger.e('Error fetching raw data from $fullUrl: $e');
			rethrow;
		}
	}

	/// Fetch match schedule CSV for a specific event
	Future<String?> fetchMatchScheduleCsv(String eventId) async {
		try {
			final path = '/data/$eventId.schedule.csv';
			final fullUrl = '$baseUrl$path';
			_logger.i('📡 Fetching match schedule CSV from: $fullUrl');

			final response = await _dio.get(path);

			if (response.statusCode != 200) {
				throw Exception(
					'Failed to fetch schedule: HTTP ${response.statusCode}',
				);
			}

			final csvString = response.data as String;
			_logger.d('Raw schedule CSV response length: ${csvString.length} characters');
			return csvString;
		} catch (e) {
			_logger.e('Error fetching match schedule CSV for $eventId: $e');
			return null;
		}
	}

	// =========================================================================
	// ROBOT PHOTOS
	// =========================================================================

	/// Build the full URL for a robot photo
	/// Returns URL like: http://localhost:8080/data/2026/1234.jpg
	String getRobotPhotoUrl(String eventId, String teamNumber) {
		final year = _extractYearFromEventId(eventId);
		final url = '$baseUrl/data/$year/$teamNumber.jpg';
		_logger.d('🖼️ Robot photo URL: $url (eventId: $eventId, team: $teamNumber)');
		return url;
	}

	/// Fetch robot photo as bytes
	/// Uses authenticated Dio client to respect credentials
	Future<Uint8List?> fetchRobotPhotoBytes(String eventId, String teamNumber) async {
		try {
			final year = _extractYearFromEventId(eventId);
			final path = '/data/$year/$teamNumber.jpg';
			final fullUrl = '$baseUrl$path';

			_logger.i('📥 Downloading robot photo from: $fullUrl');

			final response = await _dio.get<List<int>>(
				path,
				options: Options(responseType: ResponseType.bytes),
			);

			if (response.statusCode != 200) {
				_logger.e('Failed to fetch robot photo: HTTP ${response.statusCode}');
				return null;
			}

			if (response.data == null || response.data!.isEmpty) {
				_logger.w('Robot photo returned empty data');
				return null;
			}

			_logger.i('✅ Robot photo downloaded: ${response.data!.length} bytes');
			return Uint8List.fromList(response.data!);
		} catch (e) {
			_logger.e('Error downloading robot photo for $eventId/$teamNumber: $e');
			return null;
		}
	}

	/// Extract year from eventId
	/// Examples: "2026demo" -> "2026", "2025falb" -> "2025"
	String _extractYearFromEventId(String eventId) {
		final yearMatch = RegExp(r'(\d{4})').firstMatch(eventId);
		if (yearMatch != null) {
			return yearMatch.group(1) ?? '2026';
		}
		return '2026'; // Default year
	}

	// =========================================================================
	// PRIVATE HELPERS
	// =========================================================================

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
