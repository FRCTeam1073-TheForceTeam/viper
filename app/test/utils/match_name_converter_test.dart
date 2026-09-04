import 'package:flutter_test/flutter_test.dart';
import 'package:viper_scout/utils/match_name_converter.dart';

void main() {
	group('getMatchNumber', () {
		test('extracts number from qm', () {
			expect(getMatchNumber('qm5'), '5');
		});

		test('extracts number from sf', () {
			expect(getMatchNumber('sf2'), '2');
		});

		test('extracts multi-digit number', () {
			expect(getMatchNumber('qm123'), '123');
		});

		test('returns empty string for no number', () {
			expect(getMatchNumber(''), '');
		});

		test('returns empty string for text-only input', () {
			expect(getMatchNumber('abc'), '');
		});
	});

	group('getMatchTypeKey', () {
		test('extracts pm', () {
			expect(getMatchTypeKey('pm1'), 'pm');
		});

		test('extracts qm', () {
			expect(getMatchTypeKey('qm5'), 'qm');
		});

		test('extracts qf', () {
			expect(getMatchTypeKey('qf2'), 'qf');
		});

		test('extracts sf', () {
			expect(getMatchTypeKey('sf1'), 'sf');
		});

		test('extracts playoff rounds 1-5p', () {
			expect(getMatchTypeKey('1p5'), '1p');
			expect(getMatchTypeKey('2p3'), '2p');
			expect(getMatchTypeKey('3p1'), '3p');
			expect(getMatchTypeKey('4p2'), '4p');
			expect(getMatchTypeKey('5p4'), '5p');
		});

		test('extracts f for finals', () {
			expect(getMatchTypeKey('f1'), 'f');
		});

		test('returns empty string for unknown type', () {
			expect(getMatchTypeKey('xx1'), '');
		});

		test('returns empty string for empty input', () {
			expect(getMatchTypeKey(''), '');
		});
	});

	group('getMatchTypeName', () {
		test('maps pm to Practice', () {
			expect(getMatchTypeName('pm'), 'Practice ');
		});

		test('maps qm to Qualification', () {
			expect(getMatchTypeName('qm'), 'Qualification ');
		});

		test('maps qf to Quarter-final', () {
			expect(getMatchTypeName('qf'), 'Quarter-final ');
		});

		test('maps sf to Semi-final', () {
			expect(getMatchTypeName('sf'), 'Semi-final ');
		});

		test('maps playoff rounds', () {
			expect(getMatchTypeName('1p'), 'Playoffs first round ');
			expect(getMatchTypeName('2p'), 'Playoffs second round ');
			expect(getMatchTypeName('3p'), 'Playoffs third round ');
			expect(getMatchTypeName('4p'), 'Playoffs fourth round ');
			expect(getMatchTypeName('5p'), 'Playoffs fifth round ');
		});

		test('maps f to Final', () {
			expect(getMatchTypeName('f'), 'Final ');
		});

		test('returns empty string for unknown type', () {
			expect(getMatchTypeName('xx'), '');
		});
	});

	group('getShortMatchTypeName', () {
		test('maps pm to Prac', () {
			expect(getShortMatchTypeName('pm'), 'Prac ');
		});

		test('maps qm to Qual', () {
			expect(getShortMatchTypeName('qm'), 'Qual ');
		});

		test('maps qf to QF', () {
			expect(getShortMatchTypeName('qf'), 'QF ');
		});

		test('maps sf to SF', () {
			expect(getShortMatchTypeName('sf'), 'SF ');
		});

		test('maps playoff rounds', () {
			expect(getShortMatchTypeName('1p'), 'Playoff R1 M');
			expect(getShortMatchTypeName('2p'), 'Playoff R2 M');
			expect(getShortMatchTypeName('5p'), 'Playoff R5 M');
		});

		test('maps f to Final', () {
			expect(getShortMatchTypeName('f'), 'Final ');
		});

		test('returns empty string for unknown type', () {
			expect(getShortMatchTypeName('xx'), '');
		});
	});

	group('getMatchName', () {
		test('formats qm5 as Qualification 5', () {
			expect(getMatchName('qm5'), 'Qualification 5');
		});

		test('formats sf2 as Semi-final 2', () {
			expect(getMatchName('sf2'), 'Semi-final 2');
		});

		test('formats 1p3 as Playoffs first round 3', () {
			expect(getMatchName('1p3'), 'Playoffs first round 3');
		});

		test('returns empty string for empty input', () {
			expect(getMatchName(''), '');
		});

		test('returns empty string for unknown type', () {
			expect(getMatchName('xx5'), '5');
		});
	});

	group('getShortMatchName', () {
		test('formats qm5 as Qual 5', () {
			expect(getShortMatchName('qm5'), 'Qual 5');
		});

		test('formats sf2 as SF 2', () {
			expect(getShortMatchName('sf2'), 'SF 2');
		});

		test('formats 1p3 as Playoff R1 M3', () {
			expect(getShortMatchName('1p3'), 'Playoff R1 M3');
		});

		test('returns empty string for empty input', () {
			expect(getShortMatchName(''), '');
		});

		test('returns empty string for unknown type', () {
			expect(getShortMatchName('xx5'), '5');
		});
	});
}
