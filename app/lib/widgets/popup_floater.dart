import 'package:flutter/material.dart';

/// A floating animation widget that displays a numeric value
/// Used to show feedback (+1, +5, +10, -1) when fuel is added
/// Animates with a fade-out and upward movement over 5 seconds
class PopupFloater extends StatefulWidget {
	/// Text to display (e.g., "+1", "+5", "+10", "-1")
	final String text;

	/// X position (screen-relative)
	final double initialX;

	/// Y position (screen-relative)
	final double initialY;

	/// Duration for fade-out animation
	final Duration animationDuration;

	/// Called when animation completes
	final VoidCallback? onAnimationComplete;

	const PopupFloater({
		Key? key,
		required this.text,
		required this.initialX,
		required this.initialY,
		this.animationDuration = const Duration(seconds: 5),
		this.onAnimationComplete,
	}) : super(key: key);

	@override
	State<PopupFloater> createState() => _PopupFloaterState();
}

class _PopupFloaterState extends State<PopupFloater>
	with SingleTickerProviderStateMixin {
	late AnimationController _controller;
	late Animation<double> _opacityAnimation;
	late Animation<Offset> _offsetAnimation;

	@override
	void initState() {
		super.initState();

		// Create animation controller
		_controller = AnimationController(
			duration: widget.animationDuration,
			vsync: this,
		);

		// Opacity animation: 1.0 → 0.0
		_opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
			CurvedAnimation(parent: _controller, curve: Curves.easeOut),
		);

		// Offset animation: move up by ~60 pixels
		_offsetAnimation = Tween<Offset>(
			begin: const Offset(0, 0),
			end: const Offset(0, -60),
		).animate(
			CurvedAnimation(parent: _controller, curve: Curves.easeOut),
		);

		// Start animation
		_controller.forward().then((_) {
			widget.onAnimationComplete?.call();
		});
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		// Determine if this is a negative value (red) or positive (green/yellow)
		final isNegative = widget.text.startsWith('-');
		final textColor = isNegative ? Colors.red.shade500 : Colors.lime.shade400;

		return Positioned(
			left: widget.initialX,
			top: widget.initialY,
			child: AnimatedBuilder(
				animation: _controller,
				builder: (context, child) {
					return Transform.translate(
						offset: _offsetAnimation.value,
						child: Opacity(
							opacity: _opacityAnimation.value,
							child: Text(
								widget.text,
								style: TextStyle(
									fontSize: 28,
									fontWeight: FontWeight.bold,
									color: textColor,
									shadows: [
										Shadow(
											color: Colors.black.withValues(alpha: 0.5),
											blurRadius: 4,
											offset: const Offset(0, 2),
										),
									],
								),
							),
						),
					);
				},
			),
		);
	}
}
