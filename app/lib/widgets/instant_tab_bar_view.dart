import 'package:flutter/material.dart';

/// A TabBarView that jumps to pages instantly instead of animating
class InstantTabBarView extends StatefulWidget {
	final TabController controller;
	final List<Widget> children;
	final ScrollPhysics? physics;

	const InstantTabBarView({
		super.key,
		required this.controller,
		required this.children,
		this.physics,
	});

	@override
	State<InstantTabBarView> createState() => _InstantTabBarViewState();
}

class _InstantTabBarViewState extends State<InstantTabBarView> {
	late PageController _pageController;

	@override
	void initState() {
		super.initState();
		_pageController = PageController(initialPage: widget.controller.index);
		widget.controller.addListener(_onTabChanged);
	}

	@override
	void didUpdateWidget(InstantTabBarView oldWidget) {
		super.didUpdateWidget(oldWidget);
		if (oldWidget.controller != widget.controller) {
			oldWidget.controller.removeListener(_onTabChanged);
			widget.controller.addListener(_onTabChanged);
			_pageController.dispose();
			_pageController = PageController(initialPage: widget.controller.index);
		}
	}

	void _onTabChanged() {
		// Jump to page instantly without animation
		_pageController.jumpToPage(widget.controller.index);
	}

	@override
	void dispose() {
		widget.controller.removeListener(_onTabChanged);
		_pageController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return PageView(
			controller: _pageController,
			physics: widget.physics ?? const NeverScrollableScrollPhysics(),
			onPageChanged: (index) {
				widget.controller.index = index;
			},
			children: widget.children,
		);
	}
}
