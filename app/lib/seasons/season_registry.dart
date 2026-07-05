import 'season_module.dart';
import '2026/module.dart';

/// Registry of all implemented season modules, keyed by season string.
/// For FRC events, the key is a 4-digit year like '2026'.
/// For FTC events, the key is a two-year season like '2025-26'.
final Map<String, SeasonModule> seasonModules = {
	'2026': Season2026Module(),
};

/// Get the SeasonModule for a given season string, or null if not implemented.
SeasonModule? seasonModuleFor(String season) => seasonModules[season];

/// The most-recent (latest) supported season.
/// Used as a fallback default when season parsing fails.
/// String comparison works because all keys share the same 4-digit-year-prefix
/// convention ('2026', '2025-26', '2025', ...), so lexicographic order matches
/// chronological order.
String get defaultSeason => seasonModules.keys.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
