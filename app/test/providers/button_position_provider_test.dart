import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viper_scout/providers/button_position_provider.dart';

void main() {
	group('ButtonPositionNotifier', () {
		test('initializes with empty positions', () {
			final notifier = ButtonPositionNotifier();

			expect(notifier.state.isEmpty, true);
		});

		test('setButtonPosition stores single position', () async {
			final notifier = ButtonPositionNotifier();
			final pos = Offset(100, 150);

			notifier.setButtonPosition('button1', pos);
			await Future.delayed(Duration(milliseconds: 10));

			expect(notifier.state['button1'], pos);
		});

		test('setButtonPositions stores multiple positions', () async {
			final notifier = ButtonPositionNotifier();
			final positions = {
				'button1': Offset(100, 150),
				'button2': Offset(200, 250),
				'button3': Offset(300, 350),
			};

			notifier.setButtonPositions(positions);
			await Future.delayed(Duration(milliseconds: 10));

			expect(notifier.state.length, 3);
			expect(notifier.state['button1'], Offset(100, 150));
			expect(notifier.state['button2'], Offset(200, 250));
			expect(notifier.state['button3'], Offset(300, 350));
		});

		test('getButtonPosition returns stored position', () async {
			final notifier = ButtonPositionNotifier();
			final pos = Offset(100, 150);

			notifier.setButtonPosition('button1', pos);
			await Future.delayed(Duration(milliseconds: 10));

			final retrieved = notifier.getButtonPosition('button1');

			expect(retrieved, pos);
		});

		test('getButtonPosition returns null for missing button', () {
			final notifier = ButtonPositionNotifier();

			final pos = notifier.getButtonPosition('missing');

			expect(pos, isNull);
		});

		test('setButtonPositions merges with existing positions', () async {
			final notifier = ButtonPositionNotifier();

			notifier.setButtonPosition('button1', Offset(100, 150));
			await Future.delayed(Duration(milliseconds: 10));

			notifier.setButtonPositions({
				'button2': Offset(200, 250),
				'button3': Offset(300, 350),
			});
			await Future.delayed(Duration(milliseconds: 10));

			expect(notifier.state.length, 3);
			expect(notifier.state.containsKey('button1'), true);
			expect(notifier.state.containsKey('button2'), true);
			expect(notifier.state.containsKey('button3'), true);
		});

		test('setButtonPositions overwrites existing position', () async {
			final notifier = ButtonPositionNotifier();

			notifier.setButtonPosition('button1', Offset(100, 150));
			await Future.delayed(Duration(milliseconds: 10));

			notifier.setButtonPosition('button1', Offset(200, 250));
			await Future.delayed(Duration(milliseconds: 10));

			expect(notifier.state['button1'], Offset(200, 250));
		});

		test('clear removes all positions', () async {
			final notifier = ButtonPositionNotifier();

			notifier.setButtonPositions({
				'button1': Offset(100, 150),
				'button2': Offset(200, 250),
			});
			await Future.delayed(Duration(milliseconds: 10));

			notifier.clear();

			expect(notifier.state.isEmpty, true);
		});
	});

	group('buttonPositionProvider', () {
		test('provides ButtonPositionNotifier with empty initial state', () {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			final positions = container.read(buttonPositionProvider);

			expect(positions.isEmpty, true);
		});

		test('allows setting positions via notifier', () async {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			container.read(buttonPositionProvider.notifier)
				.setButtonPosition('button1', Offset(100, 150));
			await Future.delayed(Duration(milliseconds: 10));

			final positions = container.read(buttonPositionProvider);

			expect(positions['button1'], Offset(100, 150));
		});

		test('allows getting position via notifier', () async {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			container.read(buttonPositionProvider.notifier)
				.setButtonPosition('button1', Offset(100, 150));
			await Future.delayed(Duration(milliseconds: 10));

			final pos = container.read(buttonPositionProvider.notifier)
				.getButtonPosition('button1');

			expect(pos, Offset(100, 150));
		});

		test('allows clearing all positions', () async {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			container.read(buttonPositionProvider.notifier)
				.setButtonPositions({
					'b1': Offset(1, 2),
					'b2': Offset(3, 4),
				});
			await Future.delayed(Duration(milliseconds: 10));

			container.read(buttonPositionProvider.notifier).clear();

			final positions = container.read(buttonPositionProvider);

			expect(positions.isEmpty, true);
		});
	});
}
