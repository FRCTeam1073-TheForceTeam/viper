import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:viper_scout/data/api/viper_api_client.dart';
import 'package:viper_scout/services/logger_service.dart';

class MockDio extends Mock implements Dio {}

void main() {
	late MockDio mockDio;

	setUpAll(() {
		setTestMode(true); // Silence all logging for this test suite
	});

	setUp(() {
		mockDio = MockDio();
		registerFallbackValue(Options());
	});

	group('EventModel.seasonFromEventId', () {
		test('extracts 4-digit year from eventId', () {
			expect(EventModel.seasonFromEventId('2026casf'), '2026');
			expect(EventModel.seasonFromEventId('2025week2'), '2025');
		});

		test('extracts 4-digit dash 2-digit season format', () {
			expect(EventModel.seasonFromEventId('2025-26test'), '2025-26');
			expect(EventModel.seasonFromEventId('2024-25week1'), '2024-25');
		});

		test('returns default 2026 for unrecognized format', () {
			expect(EventModel.seasonFromEventId('invalid'), '2026');
			expect(EventModel.seasonFromEventId(''), '2026');
		});

		test('handles numeric-only eventIds', () {
			expect(EventModel.seasonFromEventId('20261234'), '2026');
		});
	});

	group('EventModel.isFromSeason', () {
		test('returns true for matching season', () {
			final event = EventModel(
				eventId: '2026casf',
				name: 'Central Arizona',
			);

			expect(event.isFromSeason('2026'), true);
		});

		test('returns false for non-matching season', () {
			final event = EventModel(
				eventId: '2026casf',
				name: 'Central Arizona',
			);

			expect(event.isFromSeason('2025'), false);
		});

		test('works with 4-digit dash 2-digit format', () {
			final event = EventModel(
				eventId: '2025-26test',
				name: 'Test Event',
			);

			expect(event.isFromSeason('2025-26'), true);
			expect(event.isFromSeason('2026'), false);
		});
	});

	group('EventModel.season getter', () {
		test('returns extracted season from eventId', () {
			final event = EventModel(
				eventId: '2026casf',
				name: 'Central Arizona',
			);

			expect(event.season, '2026');
		});
	});

	group('ViperApiClient.fetchEventListCsv', () {
		test('returns CSV string on 200 response', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			const csvString = 'event,name,location\n2026casf,Central Arizona,Phoenix';

			when(() => mockDio.get('/event-list.cgi'))
				.thenAnswer((_) async => Response(
					data: csvString,
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await client.fetchEventListCsv();

			expect(result, csvString);
		});

		test('returns null on non-200 response', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			when(() => mockDio.get('/event-list.cgi'))
				.thenAnswer((_) async => Response(
					data: 'not found',
					statusCode: 404,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await client.fetchEventListCsv();

			expect(result, isNull);
		});

		test('returns null on exception', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			when(() => mockDio.get('/event-list.cgi'))
				.thenThrow(Exception('Network error'));

			final result = await client.fetchEventListCsv();

			expect(result, isNull);
		});
	});

	group('ViperApiClient.parseEventCsv', () {
		test('parses simple event CSV', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			const csv = 'event,name,location\n2026casf,Central Arizona,Phoenix';

			final events = client.parseEventCsv(csv);

			expect(events.length, 1);
			expect(events[0].eventId, '2026casf');
			expect(events[0].name, 'Central Arizona');
			expect(events[0].location, 'Phoenix');
		});

		test('parses multiple events', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			const csv = '''event,name,location
2026casf,Central Arizona,Phoenix
2026azsh,Arizona Santan Hills,Santan Hills''';

			final events = client.parseEventCsv(csv);

			expect(events.length, 2);
			expect(events[0].eventId, '2026casf');
			expect(events[1].eventId, '2026azsh');
		});

		test('parses events with dates', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			const csv = 'event,name,start,end\n2026casf,Event 1,2026-01-15,2026-01-17';

			final events = client.parseEventCsv(csv);

			expect(events.length, 1);
			expect(events[0].startDate, DateTime(2026, 1, 15));
			expect(events[0].endDate, DateTime(2026, 1, 17));
		});

		test('skips rows with missing eventId or name', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			const csv = '''event,name,location
2026casf,Event 1,Phoenix
,Missing Event ID,Location
2026event2,,Missing Name
2026event3,Good Event,Location''';

			final events = client.parseEventCsv(csv);

			// Should only have 2 valid events (rows 1 and 4)
			expect(events.length, 2);
			expect(events[0].eventId, '2026casf');
			expect(events[1].eventId, '2026event3');
		});

		test('handles malformed dates gracefully', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			const csv = 'event,name,start\n2026casf,Event 1,not-a-date';

			final events = client.parseEventCsv(csv);

			expect(events.length, 1);
			expect(events[0].startDate, isNull);
		});

		test('handles empty CSV', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			final events = client.parseEventCsv('');

			expect(events.isEmpty, true);
		});
	});

	group('ViperApiClient.fetchEventList', () {
		test('returns parsed events on successful fetch', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			when(() => mockDio.get('/event-list.cgi'))
				.thenAnswer((_) async => Response(
					data: 'event,name\n2026casf,Central Arizona',
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			final events = await client.fetchEventList();

			expect(events.length, 1);
			expect(events[0].eventId, '2026casf');
		});

		test('returns empty list on fetch failure', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			when(() => mockDio.get('/event-list.cgi'))
				.thenThrow(Exception('Network error'));

			final events = await client.fetchEventList();

			expect(events.isEmpty, true);
		});
	});

	group('ViperApiClient.testConnection', () {
		test('returns true on 200 response', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			when(() => mockDio.get('/event-list.cgi'))
				.thenAnswer((_) async => Response(
					data: 'ok',
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await client.testConnection();

			expect(result, true);
		});

		test('returns false on non-200 response', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			when(() => mockDio.get('/event-list.cgi'))
				.thenAnswer((_) async => Response(
					data: 'error',
					statusCode: 500,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await client.testConnection();

			expect(result, false);
		});

		test('returns false on exception', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			when(() => mockDio.get('/event-list.cgi'))
				.thenThrow(Exception('Network error'));

			final result = await client.testConnection();

			expect(result, false);
		});
	});

	group('ViperApiClient.fetchRaw', () {
		test('returns raw text from endpoint', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			when(() => mockDio.get('/test/data.txt'))
				.thenAnswer((_) async => Response(
					data: 'raw content',
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await client.fetchRaw('/test/data.txt');

			expect(result, 'raw content');
		});

		test('throws on non-200 response', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			when(() => mockDio.get('/test/data.txt'))
				.thenAnswer((_) async => Response(
					data: 'not found',
					statusCode: 404,
					requestOptions: RequestOptions(path: ''),
				));

			expect(
				() => client.fetchRaw('/test/data.txt'),
				throwsException,
			);
		});
	});

	group('ViperApiClient.fetchMatchScheduleCsv', () {
		test('fetches schedule CSV for event', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			const csv = 'match_number,red_1,blue_1\nqm1,3476,2064';

			when(() => mockDio.get('/data/2026casf.schedule.csv'))
				.thenAnswer((_) async => Response(
					data: csv,
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await client.fetchMatchScheduleCsv('2026casf');

			expect(result, csv);
		});

		test('returns null on failure', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			when(() => mockDio.get('/data/2026casf.schedule.csv'))
				.thenAnswer((_) async => Response(
					data: 'not found',
					statusCode: 404,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await client.fetchMatchScheduleCsv('2026casf');

			expect(result, isNull);
		});
	});

	group('ViperApiClient.fetchScoutingCsv', () {
		test('fetches scouting CSV for event', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			const csv = 'team,match,score\n3476,qm1,42';

			when(() => mockDio.get('/data/2026casf.scouting.csv'))
				.thenAnswer((_) async => Response(
					data: csv,
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await client.fetchScoutingCsv('2026casf');

			expect(result, csv);
		});

		test('returns null on failure', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			when(() => mockDio.get('/data/2026casf.scouting.csv'))
				.thenThrow(Exception('Network error'));

			final result = await client.fetchScoutingCsv('2026casf');

			expect(result, isNull);
		});
	});

	group('ViperApiClient.getRobotPhotoUrl', () {
		test('builds correct URL from eventId and team', () {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			final url = client.getRobotPhotoUrl('2026casf', '3476');

			expect(url, 'http://localhost/data/2026/3476.jpg');
		});

		test('extracts year from different event format', () {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			final url = client.getRobotPhotoUrl('2025-26test', '2064');

			expect(url, 'http://localhost/data/2025-26/2064.jpg');
		});
	});

	group('ViperApiClient.uploadScoutData', () {
		test('uploads CSV and returns success response', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			const csv = 'team,match\n3476,qm1';

			when(() => mockDio.post(
				'/scout/upload.cgi',
				data: any(named: 'data'),
				options: any(named: 'options'),
			)).thenAnswer((_) async => Response(
				data: {'status': 'ok'},
				statusCode: 200,
				requestOptions: RequestOptions(path: ''),
			));

			final result = await client.uploadScoutData(csv);

			expect(result['success'], true);
		});

		test('throws on non-2xx response', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			const csv = 'team,match\n3476,qm1';

			when(() => mockDio.post(
				'/scout/upload.cgi',
				data: any(named: 'data'),
				options: any(named: 'options'),
			)).thenAnswer((_) async => Response(
				data: 'error',
				statusCode: 500,
				requestOptions: RequestOptions(path: ''),
			));

			expect(
				() => client.uploadScoutData(csv),
				throwsException,
			);
		});
	});

	group('ViperApiClient.fetchPitScoutingData', () {
		test('parses pit scouting CSV', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			const csv = 'team,fuel_capacity\n3476,50\n2064,48';

			when(() => mockDio.get('/data/2026casf.pit.csv'))
				.thenAnswer((_) async => Response(
					data: csv,
					statusCode: 200,
					requestOptions: RequestOptions(path: ''),
				));

			final result = await client.fetchPitScoutingData('2026casf');

			expect(result.containsKey('3476'), true);
			expect(result.containsKey('2064'), true);
		});

		test('returns empty map on failure', () async {
			final client = ViperApiClient(baseUrl: 'http://localhost', dio: mockDio);

			when(() => mockDio.get('/data/2026casf.pit.csv'))
				.thenThrow(Exception('Network error'));

			final result = await client.fetchPitScoutingData('2026casf');

			expect(result.isEmpty, true);
		});
	});
}
