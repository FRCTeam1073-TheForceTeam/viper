import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viper_scout/providers/floating_popup_provider.dart';

void main() {
	group('FloatingPopup', () {
		test('creates popup with all fields', () {
			final popup = FloatingPopup(
				id: 'popup1',
				text: '+5',
				initialX: 100,
				initialY: 200,
			);

			expect(popup.id, 'popup1');
			expect(popup.text, '+5');
			expect(popup.initialX, 100);
			expect(popup.initialY, 200);
		});

		test('stores different text values', () {
			final popup1 = FloatingPopup(id: 'p1', text: '+1', initialX: 0, initialY: 0);
			final popup2 = FloatingPopup(id: 'p2', text: '+10', initialX: 0, initialY: 0);
			final popup3 = FloatingPopup(id: 'p3', text: '-1', initialX: 0, initialY: 0);

			expect(popup1.text, '+1');
			expect(popup2.text, '+10');
			expect(popup3.text, '-1');
		});
	});

	group('FloatingPopupNotifier', () {
		test('initializes with empty popup list', () {
			final notifier = FloatingPopupNotifier();

			expect(notifier.state.isEmpty, true);
		});

		test('addPopup adds popup to list', () {
			final notifier = FloatingPopupNotifier();

			notifier.addPopup('+5', 100, 150);

			expect(notifier.state.length, 1);
			expect(notifier.state[0].text, '+5');
			expect(notifier.state[0].initialX, 100);
			expect(notifier.state[0].initialY, 150);
		});

		test('addPopup generates unique IDs', () {
			final notifier = FloatingPopupNotifier();

			notifier.addPopup('+1', 10, 20);
			notifier.addPopup('+2', 30, 40);

			expect(notifier.state[0].id, isNotEmpty);
			expect(notifier.state[1].id, isNotEmpty);
			expect(notifier.state[0].id, isNot(notifier.state[1].id));
		});

		test('removePopup removes popup by ID', () {
			final notifier = FloatingPopupNotifier();

			notifier.addPopup('+1', 10, 20);
			notifier.addPopup('+2', 30, 40);

			final idToRemove = notifier.state[0].id;
			notifier.removePopup(idToRemove);

			expect(notifier.state.length, 1);
			expect(notifier.state[0].text, '+2');
		});

		test('removePopup does nothing for non-existent ID', () {
			final notifier = FloatingPopupNotifier();

			notifier.addPopup('+1', 10, 20);
			notifier.removePopup('nonexistent');

			expect(notifier.state.length, 1);
		});

		test('clear removes all popups', () {
			final notifier = FloatingPopupNotifier();

			notifier.addPopup('+1', 10, 20);
			notifier.addPopup('+2', 30, 40);
			notifier.addPopup('+3', 50, 60);

			notifier.clear();

			expect(notifier.state.isEmpty, true);
		});

		test('multiple adds followed by selective removes', () {
			final notifier = FloatingPopupNotifier();

			notifier.addPopup('+1', 10, 20);
			notifier.addPopup('+2', 30, 40);
			notifier.addPopup('+3', 50, 60);

			final secondId = notifier.state[1].id;
			notifier.removePopup(secondId);

			expect(notifier.state.length, 2);
			expect(notifier.state[0].text, '+1');
			expect(notifier.state[1].text, '+3');
		});
	});

	group('floatingPopupProvider', () {
		test('provides FloatingPopupNotifier with empty initial state', () {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			final popups = container.read(floatingPopupProvider);

			expect(popups.isEmpty, true);
		});

		test('allows adding popups via notifier', () {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			container.read(floatingPopupProvider.notifier).addPopup('+5', 100, 150);

			final popups = container.read(floatingPopupProvider);

			expect(popups.length, 1);
			expect(popups[0].text, '+5');
		});

		test('allows removing popups via notifier', () {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			container.read(floatingPopupProvider.notifier).addPopup('+1', 10, 20);
			container.read(floatingPopupProvider.notifier).addPopup('+2', 30, 40);

			final popups = container.read(floatingPopupProvider);
			final idToRemove = popups[0].id;

			container.read(floatingPopupProvider.notifier).removePopup(idToRemove);

			final updated = container.read(floatingPopupProvider);

			expect(updated.length, 1);
			expect(updated[0].text, '+2');
		});

		test('allows clearing all popups via notifier', () {
			final container = ProviderContainer();
			addTearDown(container.dispose);

			container.read(floatingPopupProvider.notifier).addPopup('+1', 10, 20);
			container.read(floatingPopupProvider.notifier).addPopup('+2', 30, 40);

			container.read(floatingPopupProvider.notifier).clear();

			final popups = container.read(floatingPopupProvider);

			expect(popups.isEmpty, true);
		});
	});
}
