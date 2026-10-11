import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:viper_scout/services/local_js_service.dart';
import 'package:viper_scout/services/logger_service.dart';

class MockDio extends Mock implements Dio {}

void main() {
	late MockDio mockDio;
	late LocalJsService service;

	setUpAll(() {
		setTestMode(true); // Silence all logging for this test suite
	});

	setUp(() {
		SharedPreferences.setMockInitialValues({});
		mockDio = MockDio();
	});

	group('LocalJsService._parseJsVariables', () {
		test('indirectly tested via fetchLocalJs', () {
			// _parseJsVariables is tested indirectly through fetchLocalJs
			// See LocalJsService.fetchLocalJs tests below
			expect(true, true);
		});
	});

	group('LocalJsService._parseJsValue', () {
		test('parses boolean true', () async {
			final prefs = await SharedPreferences.getInstance();
			service = LocalJsService(prefs: prefs, dio: mockDio);

			// Setup mock response
			when(() => mockDio.get('${'http://localhost'}/local.js'))
				.thenAnswer((_) async => Response(
					data: 'var enabled = true;',
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await service.fetchLocalJs('http://localhost');

			expect(result['enabled'], true);
		});

		test('parses boolean false', () async {
			final prefs = await SharedPreferences.getInstance();
			service = LocalJsService(prefs: prefs, dio: mockDio);

			when(() => mockDio.get('${'http://localhost'}/local.js'))
				.thenAnswer((_) async => Response(
					data: 'var disabled = false;',
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await service.fetchLocalJs('http://localhost');

			expect(result['disabled'], false);
		});

		test('parses null', () async {
			final prefs = await SharedPreferences.getInstance();
			service = LocalJsService(prefs: prefs, dio: mockDio);

			when(() => mockDio.get('${'http://localhost'}/local.js'))
				.thenAnswer((_) async => Response(
					data: 'var empty = null;',
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await service.fetchLocalJs('http://localhost');

			expect(result['empty'], isNull);
		});

		test('parses string with double quotes', () async {
			final prefs = await SharedPreferences.getInstance();
			service = LocalJsService(prefs: prefs, dio: mockDio);

			when(() => mockDio.get('${'http://localhost'}/local.js'))
				.thenAnswer((_) async => Response(
					data: 'var msg = "hello world";',
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await service.fetchLocalJs('http://localhost');

			expect(result['msg'], 'hello world');
		});

		test('parses string with single quotes', () async {
			final prefs = await SharedPreferences.getInstance();
			service = LocalJsService(prefs: prefs, dio: mockDio);

			when(() => mockDio.get('${'http://localhost'}/local.js'))
				.thenAnswer((_) async => Response(
					data: "var msg = 'hello world';",
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await service.fetchLocalJs('http://localhost');

			expect(result['msg'], 'hello world');
		});

		test('parses integer', () async {
			final prefs = await SharedPreferences.getInstance();
			service = LocalJsService(prefs: prefs, dio: mockDio);

			when(() => mockDio.get('${'http://localhost'}/local.js'))
				.thenAnswer((_) async => Response(
					data: 'var count = 42;',
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await service.fetchLocalJs('http://localhost');

			expect(result['count'], 42);
		});

		test('parses floating point number', () async {
			final prefs = await SharedPreferences.getInstance();
			service = LocalJsService(prefs: prefs, dio: mockDio);

			when(() => mockDio.get('${'http://localhost'}/local.js'))
				.thenAnswer((_) async => Response(
					data: 'var pi = 3.14;',
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await service.fetchLocalJs('http://localhost');

			expect(result['pi'], 3.14);
		});

		test('parses array', () async {
			final prefs = await SharedPreferences.getInstance();
			service = LocalJsService(prefs: prefs, dio: mockDio);

			when(() => mockDio.get('${'http://localhost'}/local.js'))
				.thenAnswer((_) async => Response(
					data: 'var items = [1, 2, 3];',
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await service.fetchLocalJs('http://localhost');

			expect(result['items'], [1, 2, 3]);
		});

		test('parses object', () async {
			final prefs = await SharedPreferences.getInstance();
			service = LocalJsService(prefs: prefs, dio: mockDio);

			when(() => mockDio.get('${'http://localhost'}/local.js'))
				.thenAnswer((_) async => Response(
					data: 'var config = {"key": "value"};',
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await service.fetchLocalJs('http://localhost');

			expect(result['config'], isMap);
			expect(result['config']['key'], 'value');
		});
	});

	group('LocalJsService.fetchLocalJs', () {
		test('returns parsed variables on 200 response', () async {
			final prefs = await SharedPreferences.getInstance();
			service = LocalJsService(prefs: prefs, dio: mockDio);

			when(() => mockDio.get('${'http://localhost'}/local.js'))
				.thenAnswer((_) async => Response(
					data: 'var enabled = true;\nvar count = 5;',
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await service.fetchLocalJs('http://localhost');

			expect(result['enabled'], true);
			expect(result['count'], 5);
		});

		test('normalizes baseUrl by removing trailing slash', () async {
			final prefs = await SharedPreferences.getInstance();
			service = LocalJsService(prefs: prefs, dio: mockDio);

			when(() => mockDio.get('http://localhost/local.js'))
				.thenAnswer((_) async => Response(
					data: 'var test = 1;',
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await service.fetchLocalJs('http://localhost/');

			expect(result, isNotEmpty);
		});

		test('returns empty map on non-200 response', () async {
			final prefs = await SharedPreferences.getInstance();
			service = LocalJsService(prefs: prefs, dio: mockDio);

			when(() => mockDio.get('${'http://localhost'}/local.js'))
				.thenAnswer((_) async => Response(
					data: 'not found',
					statusCode: 404,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await service.fetchLocalJs('http://localhost');

			expect(result, isEmpty);
		});

		test('returns empty map on exception', () async {
			final prefs = await SharedPreferences.getInstance();
			service = LocalJsService(prefs: prefs, dio: mockDio);

			when(() => mockDio.get('${'http://localhost'}/local.js'))
				.thenThrow(Exception('Network error'));

			final result = await service.fetchLocalJs('http://localhost');

			expect(result, isEmpty);
		});

		test('caches variables with timestamp', () async {
			final prefs = await SharedPreferences.getInstance();
			service = LocalJsService(prefs: prefs, dio: mockDio);

			when(() => mockDio.get('${'http://localhost'}/local.js'))
				.thenAnswer((_) async => Response(
					data: 'var count = 42;',
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			await service.fetchLocalJs('http://localhost');

			final keys = prefs.getKeys();
			final hasCacheEntry = keys.any((k) => k.startsWith('local_js_'));
			final hasTimestamp = keys.any((k) => k.startsWith('local_js_timestamp_'));

			expect(hasCacheEntry, true);
			expect(hasTimestamp, true);
		});
	});

	group('LocalJsService.getVariables', () {
		test('returns cached variables immediately when available', () async {
			final prefs = await SharedPreferences.getInstance();
			service = LocalJsService(prefs: prefs, dio: mockDio);

			when(() => mockDio.get('${'http://localhost'}/local.js'))
				.thenAnswer((_) async => Response(
					data: 'var count = 42;',
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			// First call: fetches and caches
			await service.getVariables('http://localhost');

			// Reset mock to verify it doesn't get called again
			reset(mockDio);

			// Second call: should return cached value without calling Dio
			final result = await service.getVariables('http://localhost');

			expect(result['count'], 42);
			verifyNever(() => mockDio.get(any()));
		});

		test('fetches fresh data when cache is missing', () async {
			final prefs = await SharedPreferences.getInstance();
			service = LocalJsService(prefs: prefs, dio: mockDio);

			when(() => mockDio.get('${'http://localhost'}/local.js'))
				.thenAnswer((_) async => Response(
					data: 'var count = 42;',
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await service.getVariables('http://localhost');

			expect(result['count'], 42);
			verify(() => mockDio.get(any())).called(1);
		});
	});

	group('LocalJsService.clearCache', () {
		test('removes all cached variables', () async {
			final prefs = await SharedPreferences.getInstance();
			service = LocalJsService(prefs: prefs, dio: mockDio);

			when(() => mockDio.get('${'http://localhost'}/local.js'))
				.thenAnswer((_) async => Response(
					data: 'var count = 42;',
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			// Cache some data
			await service.fetchLocalJs('http://localhost');

			var keys = prefs.getKeys();
			expect(keys.any((k) => k.startsWith('local_js_')), true);

			// Clear cache
			await service.clearCache();

			keys = prefs.getKeys();
			expect(keys.any((k) => k.startsWith('local_js_')), false);
			expect(keys.any((k) => k.startsWith('local_js_timestamp_')), false);
		});
	});
}
