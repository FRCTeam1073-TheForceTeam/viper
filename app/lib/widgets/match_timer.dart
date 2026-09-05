import 'package:flutter/material.dart';
import 'dart:async';

/// Match timer widget that displays elapsed time in M:SS format
/// Matches web app timer implementation for auto/teleop phases
class MatchTimer extends StatefulWidget {
	/// Timestamp when the match started (0 if not started)
	final DateTime? startTime;

	/// Autonomous period length in milliseconds, before the gap to teleop
	final int autoPeriodMs;

	/// Gap between autonomous ending and teleop being controllable, in milliseconds
	final int autoGapMs;

	/// Callback when auto period ends and teleop should begin
	final VoidCallback? onAutoEnded;

	/// Custom text style (uses monospace font)
	final TextStyle? textStyle;

	const MatchTimer({
		super.key,
		this.startTime,
		required this.autoPeriodMs,
		required this.autoGapMs,
		this.onAutoEnded,
		this.textStyle,
	});

	@override
	State<MatchTimer> createState() => _MatchTimerState();
}

class _MatchTimerState extends State<MatchTimer> {
	Timer? _updateTimer;
	String _displayTime = '0:00';
	bool _autoEnded = false;

	late int _teleSwitchTimeMs;

	@override
	void initState() {
		super.initState();
		_teleSwitchTimeMs = widget.autoPeriodMs + widget.autoGapMs;
		if (widget.startTime != null) {
			_startTimer();
		}
	}

	@override
	void didUpdateWidget(MatchTimer oldWidget) {
		super.didUpdateWidget(oldWidget);
		if (widget.autoPeriodMs != oldWidget.autoPeriodMs || widget.autoGapMs != oldWidget.autoGapMs) {
			_teleSwitchTimeMs = widget.autoPeriodMs + widget.autoGapMs;
		}
		if (widget.startTime != oldWidget.startTime) {
			_updateTimer?.cancel();
			// Reset flag only if we have a new start time
			_autoEnded = false;
			if (widget.startTime != null) {
				_startTimer();
			} else {
				setState(() => _displayTime = '0:00');
			}
		}
	}

	void _startTimer() {
		// Check if we're already past the auto switch time
		if (widget.startTime != null) {
			final elapsedMs = DateTime.now().difference(widget.startTime!).inMilliseconds;
			if (elapsedMs >= _teleSwitchTimeMs) {
				_autoEnded = true;
				// Don't call the callback - we're already past auto end time
			}
		}

		// Trigger immediate update
		_updateDisplay();
		// Update every 100ms (matching web app)
		_updateTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
			_updateDisplay();
		});
	}

	void _updateDisplay() {
		if (widget.startTime == null) {
			setState(() => _displayTime = '0:00');
			return;
		}

		final elapsedMs = DateTime.now().difference(widget.startTime!).inMilliseconds;
		final gameTimeMs = elapsedMs.clamp(0, 999999);

		// Check if auto period has ended and trigger callback
		if (gameTimeMs >= _teleSwitchTimeMs && !_autoEnded) {
			_autoEnded = true;
			widget.onAutoEnded?.call();
		}

		setState(() => _displayTime = _formatGameTime(gameTimeMs));
	}

	/// Format elapsed time as M:SS (matching web app)
	String _formatGameTime(int ms) {
		final totalSeconds = ms ~/ 1000;
		final minutes = totalSeconds ~/ 60;
		final seconds = totalSeconds % 60;
		return '$minutes:${seconds.toString().padLeft(2, '0')}';
	}

	@override
	void dispose() {
		_updateTimer?.cancel();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Text(
			_displayTime,
			style: widget.textStyle ??
				const TextStyle(
					fontSize: 20,
					fontWeight: FontWeight.bold,
					fontFamily: 'monospace',
					color: Colors.white,
				),
		);
	}
}
