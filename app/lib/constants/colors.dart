import 'package:flutter/material.dart';

/// Color constants that mirror the CSS variables from main.css
/// These maintain visual consistency between the web and Flutter versions
class AppColors {
	// Main colors
	static const Color mainBgColor = Color(0xFF000000);
	static const Color mainFgColor = Color(0xFFDDDDDD);
	static const Color mainBorderColor = Color(0xFF666666);

	// Section colors
	static const Color sectionBgColor = Color(0xFF555555);

	// Link colors
	static const Color linkColor = Color(0xFF99CCFF);
	static const Color linkVisitedColor = Color(0xFFCC99FF);

	// Team colors
	static const Color redTeamColor = Color(0xFFAA2211);
	static const Color blueTeamColor = Color(0xFF1133AA);

	// Status colors
	static const Color winnerColor = Color(0xFFEEEE66);
	static const Color alertFgColor = Color(0xFFFFFF00);

	// Button colors
	static const Color buttonBgColor = Color(0xFFBBBBBB);
	static const Color buttonFgColor = Color(0xFF333333);
	static const Color buttonSelectedBgColor = Color(0xFF77DD77);
	static const Color buttonDisabledDecorationColor = Color(0xFFCC6666);

	// Highlight/Lowlight colors
	static const Color highlightBgColor = Color(0xFF006600);
	static const Color highlightFgColor = Color(0xFF77DD77);
	static const Color highlight2FgColor = Color(0xFFFF9900);
	static const Color lowlightBgColor = Color(0xFF333333);

	// Focus color
	static const Color focusBgColor = Color(0xFF665500);

	// Diff colors
	static const Color diffAddBgColor = Color(0xFF114411);
	static const Color diffRemBgColor = Color(0xFF441111);

	// Translucent colors
	static const Color translucentHideColor = Color(0x333333DD);
}
