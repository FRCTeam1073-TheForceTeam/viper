import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
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
		// For basic auth, we need to use base64 encoding
		final bytes = utf8.encode(credentials);
		final base64Str = base64Encode(bytes);

		_dio.options.headers['Authorization'] = 'Basic $base64Str';
		print('Basic auth configured for user: $username');
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
			print('📡 Fetching event list CSV from: $fullUrl');

			final response = await _dio.get('/event-list.cgi');

			if (response.statusCode != 200) {
				throw Exception(
					'Failed to fetch events: HTTP ${response.statusCode}',
				);
			}

			final csvString = response.data as String;
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

			print('✅ Successfully parsed ${events.length} events from CSV');
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
			print('📡 Fetching event list from: $fullUrl');

			final csvString = await fetchEventListCsv();
			if (csvString == null) {
				print('Returning empty event list - manual event entry will be available');
				return [];
			}

			return parseEventCsv(csvString);
		} catch (e) {
			_logger.e('Error fetching event list: $e');
			// Return empty list instead of throwing - allows offline/no-server operation
			print('Returning empty event list - manual event entry will be available');
			return [];
		}
	}

	/// Upload scout data as CSV to /scout/upload.cgi
	/// [csvContent] is the full CSV string (headers + data rows)
	Future<Map<String, dynamic>> uploadScoutData(String csvContent) async {
		try {
			print('Uploading scout data');

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

			print('Scout data uploaded successfully');

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
			print('🔗 Testing connection to: $fullUrl');

			final response = await _dio.get('/event-list.cgi');
			final isOk = response.statusCode == 200;

			if (isOk) {
				print('✅ Connection successful! (HTTP ${response.statusCode}) - $fullUrl');
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
			print('📡 Fetching raw from: $fullUrl');

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
			print('📡 Fetching match schedule CSV from: $fullUrl');

			final response = await _dio.get(path);

			if (response.statusCode != 200) {
				throw Exception(
					'Failed to fetch schedule: HTTP ${response.statusCode}',
				);
			}

			final csvString = response.data as String;
			return csvString;
		} catch (e) {
			_logger.e('Error fetching match schedule CSV for $eventId: $e');
			return null;
		}
	}

	/// Fetch scouting CSV for a specific event
	Future<String?> fetchScoutingCsv(String eventId) async {
		try {
			final path = '/data/$eventId.scouting.csv';
			final fullUrl = '$baseUrl$path';
			print('📡 Fetching scouting CSV from: $fullUrl');

			final response = await _dio.get(path);

			if (response.statusCode != 200) {
				throw Exception(
					'Failed to fetch scouting data: HTTP ${response.statusCode}',
				);
			}

			final csvString = response.data as String;
			return csvString;
		} catch (e) {
			_logger.e('Error fetching scouting CSV for $eventId: $e');
			return null;
		}
	}

	// =========================================================================
	// ROBOT PHOTOS
	// =========================================================================

	static const int _maxCachedImages = 500;
	static const int _staleCacheDays = 7; // Refresh cache if older than this

	/// Build the full URL for a robot photo
	/// Returns URL like: http://localhost:8080/data/2026/1234.jpg
	String getRobotPhotoUrl(String eventId, String teamNumber) {
		final year = _extractYearFromEventId(eventId);
		final url = '$baseUrl/data/$year/$teamNumber.jpg';
		print('🖼️ Robot photo URL: $url (eventId: $eventId, team: $teamNumber)');
		return url;
	}

	/// Get the cache directory for robot photos
	Future<Directory> _getCacheDirectory() async {
		final cacheDir = await getApplicationCacheDirectory();
		final photoCacheDir = Directory('${cacheDir.path}/robot_photos');
		if (!await photoCacheDir.exists()) {
			await photoCacheDir.create(recursive: true);
		}
		return photoCacheDir;
	}

	/// Generate a cache file path from year and team number
	/// Returns a file in the cache directory named as year-teamNumber.jpg
	Future<File> _getCacheFile(String year, String teamNumber) async {
		final cacheDir = await _getCacheDirectory();
		final fileName = '$year-$teamNumber.jpg';
		return File('${cacheDir.path}/$fileName');
	}

	/// Clean up cache if it exceeds maximum size
	/// Removes oldest files first
	Future<void> _cleanupCacheIfNeeded() async {
		try {
			final cacheDir = await _getCacheDirectory();
			final files = cacheDir.listSync();

			if (files.length <= _maxCachedImages) {
				return;
			}

			// Sort by modification time (oldest first)
			final fileList = files.where((f) => f is File).cast<File>().toList();
			fileList.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));

			// Delete oldest files until we're under the limit
			final filesToDelete = fileList.length - _maxCachedImages;
			for (int i = 0; i < filesToDelete; i++) {
				await fileList[i].delete();
				print('🗑️ Deleted cached robot photo: ${fileList[i].path}');
			}
		} catch (e) {
			_logger.w('Error cleaning up robot photo cache: $e');
		}
	}

	/// Fetch robot photo as bytes
	/// Uses authenticated Dio client to respect credentials
	/// Caches images to persistent storage (max 500 images)
	/// If cache is stale (>7 days old), returns cached version but refreshes in background
	Future<Uint8List?> fetchRobotPhotoBytes(String eventId, String teamNumber) async {
		try {
			final year = _extractYearFromEventId(eventId);
			final path = '/data/$year/$teamNumber.jpg';
			final fullUrl = '$baseUrl$path';

			// Check cache first
			final cacheFile = await _getCacheFile(year, teamNumber);
			if (await cacheFile.exists()) {
				print('📦 Loading robot photo from cache: $fullUrl');
				final cachedBytes = await cacheFile.readAsBytes();

				// Check if cache is stale (more than _staleCacheDays old)
				try {
					final fileStat = cacheFile.statSync();
					final age = DateTime.now().difference(fileStat.modified);
					if (age.inDays > _staleCacheDays) {
						print('🔄 Cache is stale (${age.inDays} days old), refreshing in background...');
						// Refresh cache in background without awaiting
						_refreshRobotPhotoCache(eventId, teamNumber);
					}
				} catch (e) {
					_logger.w('Error checking cache age: $e');
				}

				return cachedBytes;
			}

			// Not in cache, download it
			print('📥 Downloading robot photo from: $fullUrl');

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

			// Save to cache
			final imageBytes = Uint8List.fromList(response.data!);
			try {
				await cacheFile.writeAsBytes(imageBytes);
				print('💾 Cached robot photo: ${imageBytes.length} bytes');

				// Cleanup cache if needed
				await _cleanupCacheIfNeeded();
			} catch (e) {
				_logger.w('Could not cache robot photo: $e');
				// Still return the image even if caching fails
			}

			print('✅ Robot photo downloaded: ${imageBytes.length} bytes');
			return imageBytes;
		} catch (e) {
			_logger.e('Error downloading robot photo for $eventId/$teamNumber: $e');
			return null;
		}
	}

	/// Preload a robot photo into cache without returning the image data
	/// Ensures the photo is downloaded and cached for later use
	/// Waits for stale cache to be refreshed before returning
	Future<void> preloadRobotPhoto(String eventId, String teamNumber) async {
		try {
			final year = _extractYearFromEventId(eventId);

			// Check cache first
			final cacheFile = await _getCacheFile(year, teamNumber);
			if (await cacheFile.exists()) {
				// Cache exists, check if it's stale
				try {
					final fileStat = cacheFile.statSync();
					final age = DateTime.now().difference(fileStat.modified);
					if (age.inDays > _staleCacheDays) {
						// Cache is stale, refresh it and wait for completion
						print('🔄 Stale cache detected (${age.inDays} days old), refreshing for preload...');
						await _refreshRobotPhotoCache(eventId, teamNumber);
					} else {
						// Cache is fresh, no need to download
						print('📦 Cache is fresh (${age.inDays} days old), no refresh needed');
					}
				} catch (e) {
					_logger.w('Error checking cache age during preload: $e');
				}
			} else {
				// Cache doesn't exist, download it
				print('📥 No cache found, downloading for preload...');
				await fetchRobotPhotoBytes(eventId, teamNumber);
			}
		} catch (e) {
			_logger.e('Error preloading robot photo for $eventId/$teamNumber: $e');
		}
	}

	/// Refresh a cached robot photo in the background without blocking
	/// Called when a cached image is stale (older than _staleCacheDays)
	/// Returns immediately without awaiting
	Future<void> _refreshRobotPhotoCache(String eventId, String teamNumber) async {
		try {
			final year = _extractYearFromEventId(eventId);
			final path = '/data/$year/$teamNumber.jpg';
			final fullUrl = '$baseUrl$path';

			print('🔄 Background refresh started for: $fullUrl');

			final response = await _dio.get<List<int>>(
				path,
				options: Options(responseType: ResponseType.bytes),
			);

			if (response.statusCode != 200) {
				_logger.w('Background refresh failed: HTTP ${response.statusCode} for $fullUrl');
				return;
			}

			if (response.data == null || response.data!.isEmpty) {
				_logger.w('Background refresh returned empty data for $fullUrl');
				return;
			}

			// Update cache
			final cacheFile = await _getCacheFile(year, teamNumber);
			final imageBytes = Uint8List.fromList(response.data!);

			try {
				await cacheFile.writeAsBytes(imageBytes);
				print('✅ Background refresh complete: updated ${imageBytes.length} bytes for $fullUrl');
			} catch (e) {
				_logger.w('Could not update cached robot photo during refresh: $e');
			}
		} catch (e) {
			_logger.w('Background refresh error for $eventId/$teamNumber: $e');
		}
	}

	/// Fetch pit scouting data CSV for a specific event
	/// Returns map of team data with fuel_capacity and other pit scout info
	Future<Map<String, dynamic>> fetchPitScoutingData(String eventId) async {
		try {
			final path = '/data/$eventId.pit.csv';
			final fullUrl = '$baseUrl$path';
			print('📡 Fetching pit scouting data from: $fullUrl');

			final response = await _dio.get(path);

			if (response.statusCode != 200) {
				throw Exception(
					'Failed to fetch pit scouting data: HTTP ${response.statusCode}',
				);
			}

			final csvString = response.data as String;
			final csvData = csvToArrayOfMaps(csvString);
			final data = <String, dynamic>{};

			for (final teamData in csvData) {
				final team = (teamData['team'] ?? '').toString().trim();
				if (team.isNotEmpty) {
					data[team] = teamData;
				}
			}

			print('✅ Parsed pit scouting data for ${data.length} teams');
			return data;
		} catch (e) {
			_logger.e('Error fetching pit scouting data for $eventId: $e');
			return {};
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
