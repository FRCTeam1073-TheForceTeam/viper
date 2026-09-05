import 'package:flutter/material.dart';
import '../../../../services/localization.dart';

/// Widget that displays 3 quick-add buttons for fuel scoring
/// Uses large, accessible circular buttons for quick tapping during match
class FuelQuickAddButtons extends StatefulWidget {
	/// Called when fuel is added: (field, amount, label)
	final Function(String field, int amount, String label) onFuelAdded;

	/// Current counter values for display
	final int fuelHubScore;
	final int fuelNeutralPass;

	/// Locale for translations
	final String locale;

	const FuelQuickAddButtons({
		super.key,
		required this.onFuelAdded,
		this.fuelHubScore = 0,
		this.fuelNeutralPass = 0,
		this.locale = 'en',
	});

	@override
	State<FuelQuickAddButtons> createState() => _FuelQuickAddButtonsState();
}

class _FuelQuickAddButtonsState extends State<FuelQuickAddButtons> {
	String _translate(String key) {
		return AppLocalizations.translate(key, variables: {});
	}

	@override
	Widget build(BuildContext context) {
		return Container(
			margin: const EdgeInsets.all(8),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					// Header
					Padding(
						padding: const EdgeInsets.all(8),
						child: Text(
							_translate('fuel_scoring'),
							style: const TextStyle(
								fontSize: 14,
								fontWeight: FontWeight.bold,
							),
						),
					),

					// Fuel buttons in a row
					Container(
						padding: const EdgeInsets.symmetric(horizontal: 8),
						child: Row(
							mainAxisAlignment: MainAxisAlignment.spaceEvenly,
							children: [
								// Fuel Hub Score button
								_buildFuelButton(
									label: 'Hub\nScore',
									count: widget.fuelHubScore,
									field: 'auto_fuel_score',
									amount: 1,
									color: Colors.amber.shade700,
									icon: Icons.flag_circle,
								),

								// Neutral Pass button
								_buildFuelButton(
									label: 'Neutral\nPass',
									count: widget.fuelNeutralPass,
									field: 'auto_fuel_neutral_alliance_pass',
									amount: 1,
									color: Colors.orange.shade700,
									icon: Icons.arrow_forward_ios,
								),

								// Collect Depot button (checkbox style)
								GestureDetector(
									onTap: () {
										widget.onFuelAdded(
											'auto_collect_depot',
											1,
											_translate('collect_from_depot'),
										);
									},
									child: Container(
										width: 60,
										height: 70,
										decoration: BoxDecoration(
											color: Colors.green.shade700,
											borderRadius: BorderRadius.circular(8),
											boxShadow: [
												BoxShadow(
													color: Colors.black.withValues(alpha: 0.3),
													blurRadius: 4,
													offset: const Offset(0, 2),
												),
											],
										),
										child: Column(
											mainAxisAlignment: MainAxisAlignment.center,
											children: [
												Icon(
													Icons.check_box_outline_blank,
													color: Colors.white,
													size: 28,
												),
												const SizedBox(height: 4),
												Text(
													'Collect\nDepot',
													textAlign: TextAlign.center,
													style: const TextStyle(
														color: Colors.white,
														fontSize: 9,
														fontWeight: FontWeight.bold,
													),
												),
											],
										),
									),
								),
							],
						),
					),

					// Collect options row
					Container(
						padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
						child: Row(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								GestureDetector(
									onTap: () {
										widget.onFuelAdded(
											'auto_collect_outpost',
											1,
											_translate('collect_from_outpost'),
										);
									},
									child: Container(
										width: 100,
										height: 50,
										decoration: BoxDecoration(
											color: Colors.teal.shade600,
											borderRadius: BorderRadius.circular(4),
											border: Border.all(
												color: Colors.white,
												width: 1,
											),
										),
										child: Column(
											mainAxisAlignment: MainAxisAlignment.center,
											children: [
												Icon(
													Icons.shopping_basket,
													color: Colors.white,
													size: 20,
												),
												const SizedBox(height: 2),
												Text(
													'Collect\nOutpost',
													textAlign: TextAlign.center,
													style: const TextStyle(
														color: Colors.white,
														fontSize: 10,
														fontWeight: FontWeight.bold,
													),
												),
											],
										),
									),
								),
							],
						),
					),
				],
			),
		);
	}

	/// Build a single fuel counter button
	Widget _buildFuelButton({
		required String label,
		required int count,
		required String field,
		required int amount,
		required Color color,
		required IconData icon,
	}) {
		return GestureDetector(
			onTap: () {
				widget.onFuelAdded(field, amount, label);
			},
			child: Container(
				width: 65,
				height: 75,
				decoration: BoxDecoration(
					color: color,
					shape: BoxShape.circle,
					boxShadow: [
						BoxShadow(
							color: Colors.black.withValues(alpha: 0.4),
							blurRadius: 4,
							offset: const Offset(0, 2),
						),
					],
				),
				child: Stack(
					alignment: Alignment.center,
					children: [
						// Background circle for counter
						Container(
							width: 65,
							height: 65,
							decoration: BoxDecoration(
								shape: BoxShape.circle,
								color: Colors.white.withValues(alpha: 0.15),
							),
						),

						// Main content
						Column(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Icon(
									icon,
									color: Colors.white,
									size: 24,
								),
								const SizedBox(height: 2),
								Text(
									label,
									textAlign: TextAlign.center,
									style: const TextStyle(
										color: Colors.white,
										fontSize: 9,
										fontWeight: FontWeight.bold,
									),
								),
							],
						),

						// Counter badge (top right)
						if (count > 0)
							Positioned(
								top: 0,
								right: 0,
								child: Container(
									width: 28,
									height: 28,
									decoration: BoxDecoration(
										shape: BoxShape.circle,
										color: Colors.red.shade700,
										border: Border.all(color: Colors.white, width: 2),
									),
									child: Center(
										child: Text(
											count.toString(),
											style: const TextStyle(
												color: Colors.white,
												fontSize: 12,
												fontWeight: FontWeight.bold,
											),
										),
									),
								),
							),
					],
				),
			),
		);
	}
}
