import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viper_scout/services/localization.dart';

void main() {
	setUp(() {
		// Reset all state before each test
		AppLocalizations.resetForTesting();
	});

	group('AppLocalizations.translate', () {
		test('returns key when no translations registered', () {
			expect(AppLocalizations.translate('missing_key'), 'missing_key');
		});

		test('returns exact locale match (variant)', () {
			AppLocalizations.addI18n({
				'greeting': {
					'zh_tw': 'Hello (Traditional Chinese)',
					'en': 'Hello (English)',
				}
			});

			final result = AppLocalizations.translate('greeting', locale: Locale('zh', 'TW'));
			expect(result, 'Hello (Traditional Chinese)');
		});

		test('falls back to language-only match when variant unavailable', () {
			AppLocalizations.addI18n({
				'greeting': {
					'zh': 'Hello (Chinese)',
					'en': 'Hello (English)',
				}
			});

			final result = AppLocalizations.translate('greeting', locale: Locale('zh', 'HK'));
			expect(result, 'Hello (Chinese)');
		});

		test('falls back to en when language not available', () {
			AppLocalizations.addI18n({
				'greeting': {
					'es': 'Hola',
					'en': 'Hello',
				}
			});

			final result = AppLocalizations.translate('greeting', locale: Locale('fr'));
			expect(result, 'Hello');
		});

		test('returns key when no en fallback available', () {
			AppLocalizations.addI18n({
				'greeting': {
					'es': 'Hola',
				}
			});

			final result = AppLocalizations.translate('greeting', locale: Locale('fr'));
			expect(result, 'greeting');
		});

		test('uses current locale when locale parameter not provided', () {
			AppLocalizations.addI18n({
				'greeting': {
					'en': 'Hello',
					'es': 'Hola',
				}
			});
			AppLocalizations.setLocale(Locale('es'));

			final result = AppLocalizations.translate('greeting');
			expect(result, 'Hola');
		});

		test('overrides current locale when locale parameter provided', () {
			AppLocalizations.addI18n({
				'greeting': {
					'en': 'Hello',
					'es': 'Hola',
				}
			});
			AppLocalizations.setLocale(Locale('es'));

			final result = AppLocalizations.translate('greeting', locale: Locale('en'));
			expect(result, 'Hello');
		});

		test('substitutes variables in translated string', () {
			AppLocalizations.addI18n({
				'welcome': {
					'en': 'Welcome, _name_!',
				}
			});

			final result = AppLocalizations.translate('welcome', variables: {'name': 'Alice'});
			expect(result, 'Welcome, Alice!');
		});

		test('substitutes multiple variables', () {
			AppLocalizations.addI18n({
				'match_info': {
					'en': 'Match _match_ - Team _team_',
				}
			});

			final result = AppLocalizations.translate('match_info', variables: {
				'match': 'qm5',
				'team': '3476',
			});
			expect(result, 'Match qm5 - Team 3476');
		});

		test('leaves unreplaced variables in string', () {
			AppLocalizations.addI18n({
				'message': {
					'en': 'Hello _name_ from _city_',
				}
			});

			final result = AppLocalizations.translate('message', variables: {'name': 'Alice'});
			expect(result, 'Hello Alice from _city_');
		});

		test('getLocale returns null when no locale is set', () {
			final locale = AppLocalizations.getLocale();
			expect(locale, isNull);
		});

		test('prefers variant over language-only in fallback chain', () {
			AppLocalizations.addI18n({
				'greeting': {
					'zh_tw': 'Traditional',
					'zh': 'Simplified',
					'en': 'English',
				}
			});

			final result = AppLocalizations.translate('greeting', locale: Locale('zh', 'TW'));
			expect(result, 'Traditional');
		});
	});

	group('AppLocalizations.setLocale and getLocale', () {
		test('setLocale stores locale', () {
			final locale = Locale('es', 'MX');
			AppLocalizations.setLocale(locale);

			expect(AppLocalizations.getLocale(), locale);
		});

		test('getLocale returns null when not set', () {
			expect(AppLocalizations.getLocale(), null);
		});

		test('can switch between locales', () {
			AppLocalizations.setLocale(Locale('en'));
			expect(AppLocalizations.getLocale()?.languageCode, 'en');

			AppLocalizations.setLocale(Locale('es'));
			expect(AppLocalizations.getLocale()?.languageCode, 'es');
		});
	});

	group('AppLocalizations.addI18n', () {
		test('adds translations to empty map', () {
			AppLocalizations.addI18n({
				'key1': {'en': 'value1'},
			});

			expect(AppLocalizations.translate('key1'), 'value1');
		});

		test('merges translations with existing ones', () {
			AppLocalizations.addI18n({
				'key1': {'en': 'value1'},
			});
			AppLocalizations.addI18n({
				'key2': {'en': 'value2'},
			});

			expect(AppLocalizations.translate('key1'), 'value1');
			expect(AppLocalizations.translate('key2'), 'value2');
		});

		test('overrides existing keys when adding', () {
			AppLocalizations.addI18n({
				'key': {'en': 'old value'},
			});
			AppLocalizations.addI18n({
				'key': {'en': 'new value'},
			});

			expect(AppLocalizations.translate('key'), 'new value');
		});
	});

	group('AppLocalizations.getAllTranslations', () {
		test('returns all registered translations', () {
			AppLocalizations.addI18n({
				'key1': {'en': 'value1'},
				'key2': {'es': 'valor2'},
			});

			final all = AppLocalizations.getAllTranslations();
			expect(all.containsKey('key1'), true);
			expect(all.containsKey('key2'), true);
		});
	});
}
