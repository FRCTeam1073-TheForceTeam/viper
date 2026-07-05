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

	static String translate(String key, {Locale? locale, Map<String, String>? variables}) {
		final resolvedLocale = locale ?? _currentLocale;
		final languageCode = resolvedLocale?.languageCode ?? 'en';
		final countryCode = resolvedLocale?.countryCode;

		// Try exact match first (e.g., zh_tw)
		String translation;
		if (countryCode != null) {
			final variantKey = '${languageCode}_${countryCode.toLowerCase()}';
			if (_translations[key]?.containsKey(variantKey) ?? false) {
				translation = _translations[key]![variantKey]!;
			} else if (_translations[key]?.containsKey(languageCode) ?? false) {
				translation = _translations[key]![languageCode]!;
			} else if (_translations[key]?.containsKey('en') ?? false) {
				translation = _translations[key]!['en']!;
			} else {
				translation = key;
			}
		} else {
			// Try language code only (e.g., 'es', 'fr', 'en')
			if (_translations[key]?.containsKey(languageCode) ?? false) {
				translation = _translations[key]![languageCode]!;
			} else if (_translations[key]?.containsKey('en') ?? false) {
				translation = _translations[key]!['en']!;
			} else {
				translation = key;
			}
		}

		// Apply variable substitutions if provided
		if (variables != null) {
			variables.forEach((varName, value) {
				translation = translation.replaceAll('_${varName}_', value);
			});
		}

		return translation;
	}

	/// Get all available translations for debugging
	static Map<String, Map<String, String>> getAllTranslations() => _translations;

	/// Debug: Print all registered translation keys
	static void debugPrintKeys() {
		for (var key in _translations.keys) {
		}
	}
}

extension LocalizationExtension on BuildContext {
	String t(String key) {
		return AppLocalizations.translate(key, locale: Localizations.localeOf(this));
	}
}
