import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared match timer start time - both auto and tele tabs reference this single timer
class MatchTimerNotifier extends StateNotifier<DateTime?> {
	MatchTimerNotifier() : super(null);

	/// Set the match timer start time (called when match timer starts)
	void setStartTime(DateTime startTime) {
		state = startTime;
	}

	/// Clear the timer (called when match ends or scout is reset)
	void clear() {
		state = null;
	}

	/// Get seconds elapsed since match timer started
	int getElapsedSeconds() {
		if (state == null) return 0;
		return DateTime.now().difference(state!).inSeconds;
	}
}

/// Provider for shared match timer start time
final matchTimerProvider = StateNotifierProvider<MatchTimerNotifier, DateTime?>((ref) {
	return MatchTimerNotifier();
});
