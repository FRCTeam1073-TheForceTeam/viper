import 'package:flutter/material.dart';

class AppLocalizations {
	static final Map<String, Map<String, String>> _translations = {};

	// Store the current locale statically (will be updated by provider)
	static Locale? _currentLocale;

	/// Register translations (call from each screen/service that needs i18n)
	static void addI18n(Map<String, Map<String, String>> translations) {
		_translations.addAll(translations);
	}

	/// Set the current locale (called by Riverpod provider)
	static void setLocale(Locale locale) {
		_currentLocale = locale;
	}

	/// Get the current locale
	static Locale? getLocale() => _currentLocale;

	static String translate(String key, {Locale? locale}) {
		final languageCode = (locale ?? _currentLocale)?.languageCode ?? 'en';
		final countryCode = (locale ?? _currentLocale)?.countryCode;

		// Try exact match first (e.g., zh_TW)
		if (countryCode != null) {
			final variantKey = '${languageCode}_${countryCode.toLowerCase()}';
			if (_translations[key]?.containsKey(variantKey) ?? false) {
				return _translations[key]![variantKey]!;
			}
		}

		// Fall back to language code only
		return _translations[key]?[languageCode] ?? _translations[key]?['en'] ?? key;
	}

	static String get(String key, {Locale? locale}) {
		return translate(key, locale: locale);
	}
}

extension LocalizationExtension on BuildContext {
	String t(String key) {
		return AppLocalizations.translate(key, locale: Localizations.localeOf(this));
	}
}
