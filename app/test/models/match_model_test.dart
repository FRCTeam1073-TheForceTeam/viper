import 'package:flutter_test/flutter_test.dart';
import 'package:viper_scout/models/match_model.dart';

void main() {
	group('MatchModel construction', () {
		test('creates match with number and teams', () {
			final teams = {
				'R1': '3476',
				'R2': '2064',
				'R3': '6347',
				'B1': '1690',
				'B2': '5418',
				'B3': '7419',
			};
			final match = MatchModel(matchNumber: 'qm5', teams: teams);

			expect(match.matchNumber, 'qm5');
			expect(match.teams, teams);
		});

		test('stores different match number formats', () {
			final match1 = MatchModel(matchNumber: 'qm5', teams: {});
			final match2 = MatchModel(matchNumber: 'qf1m2', teams: {});
			final match3 = MatchModel(matchNumber: 'f2m1', teams: {});

			expect(match1.matchNumber, 'qm5');
			expect(match2.matchNumber, 'qf1m2');
			expect(match3.matchNumber, 'f2m1');
		});

		test('accepts empty teams map', () {
			final match = MatchModel(matchNumber: 'qm1', teams: {});

			expect(match.teams.isEmpty, true);
		});

		test('accepts partial teams map', () {
			final teams = {'R1': '3476', 'R2': '2064'};
			final match = MatchModel(matchNumber: 'qm1', teams: teams);

			expect(match.teams.length, 2);
			expect(match.teams['R1'], '3476');
			expect(match.teams['R2'], '2064');
		});
	});

	group('MatchModel.getTeamForPosition', () {
		test('returns team number for position', () {
			final teams = {'R1': '3476', 'B1': '1690'};
			final match = MatchModel(matchNumber: 'qm5', teams: teams);

			expect(match.getTeamForPosition('R1'), '3476');
			expect(match.getTeamForPosition('B1'), '1690');
		});

		test('returns null for missing position', () {
			final teams = {'R1': '3476'};
			final match = MatchModel(matchNumber: 'qm5', teams: teams);

			expect(match.getTeamForPosition('B2'), isNull);
		});

		test('returns null from empty teams map', () {
			final match = MatchModel(matchNumber: 'qm5', teams: {});

			expect(match.getTeamForPosition('R1'), isNull);
		});

		test('is case-sensitive for position key', () {
			final teams = {'R1': '3476'};
			final match = MatchModel(matchNumber: 'qm5', teams: teams);

			expect(match.getTeamForPosition('R1'), '3476');
			expect(match.getTeamForPosition('r1'), isNull); // lowercase not found
		});
	});

	group('MatchModel.toString', () {
		test('formats match number in toString', () {
			final match = MatchModel(matchNumber: 'qm5', teams: {});

			expect(match.toString(), 'Match qm5');
		});

		test('formats different match numbers', () {
			final match1 = MatchModel(matchNumber: 'qf1m2', teams: {});
			final match2 = MatchModel(matchNumber: 'f2m1', teams: {});

			expect(match1.toString(), 'Match qf1m2');
			expect(match2.toString(), 'Match f2m1');
		});
	});

	group('MatchModel round-trip', () {
		test('preserves all data through construction', () {
			final teams = {
				'R1': '3476',
				'R2': '2064',
				'R3': '6347',
				'B1': '1690',
				'B2': '5418',
				'B3': '7419',
			};
			final original = MatchModel(matchNumber: 'qm5', teams: teams);

			expect(original.matchNumber, 'qm5');
			expect(original.teams.length, 6);
			expect(original.getTeamForPosition('R1'), '3476');
			expect(original.getTeamForPosition('B3'), '7419');
		});
	});
}
