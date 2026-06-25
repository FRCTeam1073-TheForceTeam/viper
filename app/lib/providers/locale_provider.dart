import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/localization.dart';

// Supported languages
const supportedLanguages = {
	'en': 'English',
	'es': 'Español',
	'fr': 'Français',
	'pt': 'Português',
	'zh_tw': '繁體中文',
	'tr': 'Türkçe',
	'he': 'עברית',
};

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
	return SharedPreferences.getInstance();
});

final selectedLocaleProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
	final prefs = ref.watch(sharedPreferencesProvider);
	return prefs.when(
		data: (prefs) => LocaleNotifier(prefs),
		loading: () => LocaleNotifier.empty(),
		error: (err, stack) => LocaleNotifier.empty(),
	);
});

class LocaleNotifier extends StateNotifier<Locale> {
	final SharedPreferences? prefs;

	LocaleNotifier(this.prefs) : super(_loadLocale(prefs)) {
		AppLocalizations.setLocale(state);
	}

	LocaleNotifier.empty() : prefs = null, super(const Locale('en')) {
		AppLocalizations.setLocale(state);
	}

	static Locale _loadLocale(SharedPreferences? prefs) {
		final savedLocale = prefs?.getString('locale');
		if (savedLocale != null) {
			if (savedLocale.contains('_')) {
				final parts = savedLocale.split('_');
				return Locale(parts[0], parts[1]);
			}
			return Locale(savedLocale);
		}
		return const Locale('en');
	}

	void setLocale(Locale locale) {
		state = locale;
		AppLocalizations.setLocale(locale);
		final localeString = locale.countryCode != null
			? '${locale.languageCode}_${locale.countryCode}'
			: locale.languageCode;
		prefs?.setString('locale', localeString);
	}

	void setLanguage(String languageCode) {
		final locale = Locale(languageCode);
		setLocale(locale);
	}
}
