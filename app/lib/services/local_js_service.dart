import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'logger_service.dart';

class LocalJsService {
	final SharedPreferences _prefs;
	final Dio _dio;
	final Logger _logger = getLogger();

	static const String _cacheKeyPrefix = 'local_js_';
	static const String _timestampKeyPrefix = 'local_js_timestamp_';
	static const Duration _cacheExpiry = Duration(hours: 24);

	LocalJsService({
		required SharedPreferences prefs,
		required Dio dio,
	})	: _prefs = prefs,
		_dio = dio;

	/// Fetch and parse /local.js from the server
	/// Returns a map of variable names to their values
	Future<Map<String, dynamic>> fetchLocalJs(String baseUrl) async {
		try {
			final normalizedUrl = baseUrl.endsWith('/')
				? baseUrl.substring(0, baseUrl.length - 1)
				: baseUrl;

			final response = await _dio.get('$normalizedUrl/local.js');

			if (response.statusCode == 200 && response.data is String) {
				final parsed = _parseJsVariables(response.data as String);
				await _cacheVariables(normalizedUrl, parsed);
				return parsed;
			}

			_logger.w('Failed to fetch local.js: ${response.statusCode}');
			return {};
		} catch (e) {
			_logger.e('Error fetching local.js: $e');
			return {};
		}
	}

	/// Get cached variables or fetch fresh if cache is stale
	/// Returns cached values immediately and triggers background refresh if needed
	Future<Map<String, dynamic>> getVariables(String baseUrl) async {
		final cached = _getCachedVariables(baseUrl);

		if (cached != null) {
			final isCacheStale = _isCacheExpired(baseUrl);
			if (isCacheStale) {
				// Trigger background refresh without waiting
				fetchLocalJs(baseUrl).catchError((e) {
					_logger.e('Background refresh failed: $e');
					return <String, dynamic>{};
				});
			}
			return cached;
		}

		// No cache, fetch immediately
		return fetchLocalJs(baseUrl);
	}

	/// Parse JavaScript variable declarations from text
	/// Supports: var name = value;
	/// Values can be boolean, string, number, null, array, or object
	Map<String, dynamic> _parseJsVariables(String jsContent) {
		final result = <String, dynamic>{};

		// Match: var name = value;
		// Captures: name and value (including quotes)
		final regex = RegExp(
			r'var\s+(\w+)\s*=\s*(.+?);',
			multiLine: true,
		);

		for (final match in regex.allMatches(jsContent)) {
			final name = match.group(1);
			final rawValue = match.group(2);

			if (name != null && rawValue != null) {
				try {
					result[name] = _parseJsValue(rawValue.trim());
				} catch (e) {
					_logger.w('Failed to parse variable $name: $e');
				}
			}
		}

		return result;
	}

	/// Parse a single JavaScript value to a Dart value
	dynamic _parseJsValue(String value) {
		value = value.trim();

		// Boolean
		if (value == 'true') return true;
		if (value == 'false') return false;

		// Null
		if (value == 'null') return null;

		// String (single or double quoted)
		if ((value.startsWith('"') && value.endsWith('"')) ||
				(value.startsWith("'") && value.endsWith("'"))) {
			return value.substring(1, value.length - 1);
		}

		// Number
		if (int.tryParse(value) != null) {
			return int.parse(value);
		}
		if (double.tryParse(value) != null) {
			return double.parse(value);
		}

		// Array
		if (value.startsWith('[') && value.endsWith(']')) {
			return jsonDecode(value);
		}

		// Object
		if (value.startsWith('{') && value.endsWith('}')) {
			return jsonDecode(value);
		}

		// If we can't parse it, return the string as-is
		return value;
	}

	/// Cache variables with timestamp
	Future<void> _cacheVariables(String baseUrl, Map<String, dynamic> variables) async {
		final key = _getCacheKey(baseUrl);
		final timestampKey = _getTimestampKey(baseUrl);

		await Future.wait([
			_prefs.setString(key, jsonEncode(variables)),
			_prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch),
		]);
	}

	/// Get cached variables from storage
	Map<String, dynamic>? _getCachedVariables(String baseUrl) {
		final key = _getCacheKey(baseUrl);
		final cached = _prefs.getString(key);

		if (cached == null) return null;

		try {
			return Map<String, dynamic>.from(jsonDecode(cached) as Map);
		} catch (e) {
			_logger.e('Failed to decode cached variables: $e');
			return null;
		}
	}

	/// Check if cache has expired (> 24 hours old)
	bool _isCacheExpired(String baseUrl) {
		final timestampKey = _getTimestampKey(baseUrl);
		final timestamp = _prefs.getInt(timestampKey);

		if (timestamp == null) return true;

		final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
		return DateTime.now().difference(cacheTime) > _cacheExpiry;
	}

	String _getCacheKey(String baseUrl) => '$_cacheKeyPrefix${baseUrl.hashCode}';
	String _getTimestampKey(String baseUrl) => '$_timestampKeyPrefix${baseUrl.hashCode}';

	/// Clear all cached variables (useful for testing or reset)
	Future<void> clearCache() async {
		final allKeys = _prefs.getKeys();
		final keysToRemove = allKeys
			.where((key) => key.startsWith(_cacheKeyPrefix) || key.startsWith(_timestampKeyPrefix))
			.toList();

		await Future.wait(
			keysToRemove.map((key) => _prefs.remove(key)),
		);
	}
}
