import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';

class ViperMenuButton extends StatelessWidget {
	final VoidCallback? onChangeEvent;
	final VoidCallback? onChangeBotPosition;
	final VoidCallback? onChangeMatch;
	final VoidCallback? onChangeServer;
	final VoidCallback? onSync;
	final bool isSyncing;
	final int pendingCount;

	const ViperMenuButton({
		Key? key,
		this.onChangeEvent,
		this.onChangeBotPosition,
		this.onChangeMatch,
		this.onChangeServer,
		this.onSync,
		this.isSyncing = false,
		this.pendingCount = 0,
	}) : super(key: key);

	void _showMenu(BuildContext context) {
		showModalBottomSheet(
			context: context,
			builder: (context) => Padding(
				padding: const EdgeInsets.all(16),
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						if (onChangeMatch != null)
							ElevatedButton.icon(
								icon: const Icon(Icons.sports),
								label: const Text('Change Match'),
								onPressed: () {
									Navigator.pop(context);
									onChangeMatch?.call();
								},
							)
						else
							SizedBox.shrink(),
						if (onChangeBotPosition != null)
							Padding(
								padding: const EdgeInsets.only(top: 8),
								child: ElevatedButton.icon(
									icon: const Icon(Icons.sports_esports),
									label: const Text('Change Robot Position'),
									onPressed: () {
										Navigator.pop(context);
										onChangeBotPosition?.call();
									},
								),
							)
						else
							SizedBox.shrink(),
						if (onChangeEvent != null)
							Padding(
								padding: const EdgeInsets.only(top: 8),
								child: ElevatedButton.icon(
									icon: const Icon(Icons.event),
									label: const Text('Change Event'),
									onPressed: () {
										Navigator.pop(context);
										onChangeEvent?.call();
									},
								),
							)
						else
							SizedBox.shrink(),
						if (onChangeServer != null)
							Padding(
								padding: const EdgeInsets.only(top: 8),
								child: ElevatedButton.icon(
									icon: const Icon(Icons.storage),
									label: const Text('Change Server'),
									onPressed: () {
										Navigator.pop(context);
										onChangeServer?.call();
									},
								),
							)
						else
							SizedBox.shrink(),
						if (onSync != null)
							Padding(
								padding: const EdgeInsets.only(top: 8),
								child: ElevatedButton.icon(
									icon: const Icon(Icons.sync),
									label: const Text('Manual Sync'),
									onPressed: () {
										Navigator.pop(context);
										onSync?.call();
									},
								),
							)
						else
							SizedBox.shrink(),
						Padding(
							padding: const EdgeInsets.only(top: 16),
							child: _LanguageSelector(onLanguageChanged: () {
								Navigator.pop(context);
							}),
						),
					],
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		if (onChangeEvent == null &&
			onChangeBotPosition == null &&
			onChangeMatch == null &&
			onChangeServer == null &&
			onSync == null) {
			return SizedBox.shrink();
		}

		return IconButton(
			icon: const Icon(Icons.more_vert),
			onPressed: () => _showMenu(context),
		);
	}
}

class _LanguageSelector extends StatefulWidget {
	final VoidCallback onLanguageChanged;

	const _LanguageSelector({Key? key, required this.onLanguageChanged})
		: super(key: key);

	@override
	State<_LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<_LanguageSelector> {
	bool _expanded = false;

	@override
	Widget build(BuildContext context) {
		return Column(
			mainAxisSize: MainAxisSize.min,
			crossAxisAlignment: CrossAxisAlignment.stretch,
			children: [
				ElevatedButton.icon(
					icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
					label: const Text('Language'),
					onPressed: () {
						setState(() => _expanded = !_expanded);
					},
				),
				if (_expanded)
					Padding(
						padding: const EdgeInsets.only(top: 8),
						child: Wrap(
							spacing: 4,
							runSpacing: 4,
							children: supportedLanguages.entries.map((entry) {
								return Consumer(builder: (context, ref, child) {
									return FilterChip(
										label: Text(entry.value),
										onSelected: (_) {
											ref
												.read(selectedLocaleProvider.notifier)
												.setLanguage(entry.key);
											widget.onLanguageChanged();
										},
									);
								});
							}).toList(),
						),
					),
			],
		);
	}
}
