import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../providers/app_providers.dart';
import '../providers/locale_provider.dart';
import '../services/localization.dart';
import '../widgets/viper_menu_button.dart';
import '../utils/match_name_converter.dart';

class MatchSelectionScreen extends ConsumerStatefulWidget {
	final Function(String matchNumber, String teamNumber) onMatchSelected;
	final String? botPosition;

	const MatchSelectionScreen({
		Key? key,
		required this.onMatchSelected,
		this.botPosition,
	}) : super(key: key);

	@override
	ConsumerState<MatchSelectionScreen> createState() => _MatchSelectionScreenState();
}

class _MatchSelectionScreenState extends ConsumerState<MatchSelectionScreen> {
	late ScrollController _scrollController;
	late GlobalKey _scrollTargetKey;
	bool _hasScrolled = false;
	int _lastFirstUnscoutedIndex = -1;
	int _scrollRetries = 0;
	static const _maxScrollRetries = 15;

	// Photo preloading state
	bool _isPreloadingPhotos = false;
	int _preloadedCount = 0;

	/// Helper to get translated text with current provider locale
	String _translate(String key) {
		final locale = ref.read(selectedLocaleProvider);
		return AppLocalizations.translate(key, locale: locale);
	}

	@override
	void initState() {
		super.initState();

		// Register translations
		AppLocalizations.addI18n({
			'select_match': {
				'en': 'Select Match',
				'es': 'Seleccionar partido',
				'pt': 'Selecionar correspondência',
				'fr': 'Sélectionner un match',
				'zh_tw': '選擇比賽',
				'he': 'בחר משחק',
				'tr': 'Maçı Seçin',
			},
			'enter_match': {
				'en': 'Enter Match',
				'es': 'Ingrese partido',
				'pt': 'Insira correspondência',
				'fr': 'Entrez le match',
				'zh_tw': '輸入比賽',
				'he': 'הזן משחק',
				'tr': 'Maçı Girin',
			},
			'match_type': {
				'en': 'Match Type',
				'es': 'Tipo de partido',
				'pt': 'Tipo de correspondência',
				'fr': 'Type de match',
				'zh_tw': '比賽類型',
				'he': 'סוג משחק',
				'tr': 'Maç Türü',
			},
			'match_type_practice': {
				'en': 'Practice',
				'es': 'Práctica',
				'pt': 'Prática',
				'fr': 'Pratique',
				'zh_tw': '練習',
				'he': 'תרגול',
				'tr': 'Pratik',
			},
			'match_type_qualification': {
				'en': 'Qualification',
				'es': 'Calificación',
				'pt': 'Qualificação',
				'fr': 'Qualification',
				'zh_tw': '預賽',
				'he': 'הסמכה',
				'tr': 'Nitelik Açması',
			},
			'match_type_quarter_final': {
				'en': 'Quarter-final',
				'es': 'Cuartos de final',
				'pt': 'Quartas de final',
				'fr': 'Quart de finale',
				'zh_tw': '準決賽',
				'he': 'רבע גמר',
				'tr': 'Çeyrek Final',
			},
			'match_type_semi_final': {
				'en': 'Semi-final',
				'es': 'Semifinal',
				'pt': 'Semifinal',
				'fr': 'Demi-finale',
				'zh_tw': '半決賽',
				'he': 'חצי גמר',
				'tr': 'Yarı Final',
			},
			'match_type_playoff_1': {
				'en': 'Playoff Round 1',
				'es': 'Ronda de desempate 1',
				'pt': 'Rodada de playoff 1',
				'fr': 'Ronde éliminatoire 1',
				'zh_tw': '季後賽第 1 輪',
				'he': 'סבב פלייאוף 1',
				'tr': 'Playoff Turu 1',
			},
			'match_type_playoff_2': {
				'en': 'Playoff Round 2',
				'es': 'Ronda de desempate 2',
				'pt': 'Rodada de playoff 2',
				'fr': 'Ronde éliminatoire 2',
				'zh_tw': '季後賽第 2 輪',
				'he': 'סבב פלייאוף 2',
				'tr': 'Playoff Turu 2',
			},
			'match_type_playoff_3': {
				'en': 'Playoff Round 3',
				'es': 'Ronda de desempate 3',
				'pt': 'Rodada de playoff 3',
				'fr': 'Ronde éliminatoire 3',
				'zh_tw': '季後賽第 3 輪',
				'he': 'סבב פלייאוף 3',
				'tr': 'Playoff Turu 3',
			},
			'match_type_playoff_4': {
				'en': 'Playoff Round 4',
				'es': 'Ronda de desempate 4',
				'pt': 'Rodada de playoff 4',
				'fr': 'Ronde éliminatoire 4',
				'zh_tw': '季後賽第 4 輪',
				'he': 'סבב פלייאוף 4',
				'tr': 'Playoff Turu 4',
			},
			'match_type_playoff_5': {
				'en': 'Playoff Round 5',
				'es': 'Ronda de desempate 5',
				'pt': 'Rodada de playoff 5',
				'fr': 'Ronde éliminatoire 5',
				'zh_tw': '季後賽第 5 輪',
				'he': 'סבב פלייאוף 5',
				'tr': 'Playoff Turu 5',
			},
			'match_type_final': {
				'en': 'Final',
				'es': 'Final',
				'pt': 'Final',
				'fr': 'Finale',
				'zh_tw': '決賽',
				'he': 'גמר',
				'tr': 'Final',
			},
			'match_number': {
				'en': 'Match Number',
				'es': 'Número de partido',
				'pt': 'Número de correspondência',
				'fr': 'Numéro de match',
				'zh_tw': '比賽號碼',
				'he': 'מספר משחק',
				'tr': 'Maç Numarası',
			},
			'match_number_example': {
				'en': 'e.g., 5',
				'es': 'p. ej., 5',
				'pt': 'p. ex., 5',
				'fr': 'p. ex., 5',
				'zh_tw': '例如 5',
				'he': 'למשל, 5',
				'tr': 'örn. 5',
			},
			'match_number_required': {
				'en': 'Match number is required',
				'es': 'El número de partido es obligatorio',
				'pt': 'O número da correspondência é obrigatório',
				'fr': 'Le numéro de match est obligatoire',
				'zh_tw': '比賽號碼為必填項',
				'he': 'מספר משחק נדרש',
				'tr': 'Maç Numarası Gerekli',
			},
			'must_be_valid_number': {
				'en': 'Must be a valid number',
				'es': 'Debe ser un número válido',
				'pt': 'Deve ser um número válido',
				'fr': 'Doit être un nombre valide',
				'zh_tw': '必須是有效的數字',
				'he': 'חייב להיות מספר תקף',
				'tr': 'Geçerli bir numara olmalıdır',
			},
			'team_number': {
				'en': 'Team Number',
				'es': 'Número de equipo',
				'pt': 'Número do time',
				'fr': 'Numéro d\'équipe',
				'zh_tw': '隊伍號碼',
				'he': 'מספר קבוצה',
				'tr': 'Takım Numarası',
			},
			'team_number_example': {
				'en': 'e.g., 2058',
				'es': 'p. ej., 2058',
				'pt': 'p. ex., 2058',
				'fr': 'p. ex., 2058',
				'zh_tw': '例如 2058',
				'he': 'למשל, 2058',
				'tr': 'örn. 2058',
			},
			'team_number_required': {
				'en': 'Team number is required',
				'es': 'El número de equipo es obligatorio',
				'pt': 'O número do time é obrigatório',
				'fr': 'Le numéro d\'équipe est obligatoire',
				'zh_tw': '隊伍號碼為必填項',
				'he': 'מספר קבוצה נדרש',
				'tr': 'Takım Numarası Gerekli',
			},
			'cancel': {
				'en': 'Cancel',
				'es': 'Cancelar',
				'pt': 'Cancelar',
				'fr': 'Annuler',
				'zh_tw': '取消',
				'he': 'ביטול',
				'tr': 'İptal',
			},
			'use_match': {
				'en': 'Use Match',
				'es': 'Usar partido',
				'pt': 'Usar correspondência',
				'fr': 'Utiliser le match',
				'zh_tw': '使用比賽',
				'he': 'השתמש במשחק',
				'tr': 'Maçı Kullan',
			},
			'add_match_manually': {
				'en': 'Add Match Manually',
				'es': 'Agregar partido manualmente',
				'pt': 'Adicionar correspondência manualmente',
				'fr': 'Ajouter un match manuellement',
				'zh_tw': '手動添加比賽',
				'he': 'הוסף משחק ידנית',
				'tr': 'Maçı Manuel Olarak Ekle',
			},
			'error_loading_scouted_matches': {
				'en': 'Error loading scouted matches',
				'es': 'Error al cargar partidos explorados',
				'pt': 'Erro ao carregar correspondências escotadas',
				'fr': 'Erreur lors du chargement des matchs observés',
				'zh_tw': '加載已觀察比賽時出錯',
				'he': 'שגיאה בטעינת משחקים שנחקרו',
				'tr': 'Scout Edilen Maçlar Yüklenirken Hata',
			},
			'error_loading_matches': {
				'en': 'Error loading matches',
				'es': 'Error al cargar partidos',
				'pt': 'Erro ao carregar correspondências',
				'fr': 'Erreur lors du chargement des matchs',
				'zh_tw': '加載比賽時出錯',
				'he': 'שגיאה בטעינת משחקים',
				'tr': 'Maçlar Yüklenirken Hata',
			},
		});

		_scrollController = ScrollController();
		_scrollTargetKey = GlobalKey();
	}

	@override
	void dispose() {
		_scrollController.dispose();
		super.dispose();
	}

	@override
	void didUpdateWidget(covariant MatchSelectionScreen oldWidget) {
		super.didUpdateWidget(oldWidget);
		// Reset scroll when widget updates (e.g., bot position changes)
		_hasScrolled = false;
		_scrollRetries = 0;
	}

	/// Preload robot photos for all visible matches
	/// Starts from nextMatchIndex, goes to end, then loops back to beginning
	void _preloadRobotPhotos(
		List<dynamic> visibleMatches,
		int startIndex,
		String? eventId,
	) {
		if (!mounted || visibleMatches.isEmpty || eventId == null) return;
		if (_isPreloadingPhotos) return; // Already preloading

		_isPreloadingPhotos = true;
		_preloadedCount = 0;

		// Try to get API client from ref (may still be loading)
		final apiClientAsync = ref.read(apiClientProvider);
		apiClientAsync.whenData((apiClient) {
			if (!mounted) return; // Widget disposed

			// Create list of indices in circular order starting from startIndex
			final indices = <int>[];
			for (int i = 0; i < visibleMatches.length; i++) {
				indices.add((startIndex + i) % visibleMatches.length);
			}

			// Preload photos sequentially
			_preloadPhotosSequentially(apiClient, visibleMatches, indices, 0);
		});
	}

	/// Helper to preload photos one at a time
	void _preloadPhotosSequentially(
		dynamic apiClient,
		List<dynamic> visibleMatches,
		List<int> indices,
		int currentIndex,
	) {
		if (!mounted || currentIndex >= indices.length) {
			_isPreloadingPhotos = false;
			return;
		}

		final matchIndex = indices[currentIndex];
		final match = visibleMatches[matchIndex];
		final team = widget.botPosition != null
				? match.getTeamForPosition(widget.botPosition!)
				: null;

		if (team != null && team.isNotEmpty) {
			// Preload the photo (will cache it)
			apiClient.preloadRobotPhoto(match.matchNumber, team).then((_) {
				if (mounted) {
					_preloadedCount++;
					// Continue with next photo after a small delay to avoid overwhelming the system
					Future.delayed(const Duration(milliseconds: 100), () {
						if (mounted) {
							_preloadPhotosSequentially(apiClient, visibleMatches, indices, currentIndex + 1);
						}
					});
				}
			}).catchError((e) {
				// Error preloading, continue anyway
				if (mounted) {
					Future.delayed(const Duration(milliseconds: 100), () {
						if (mounted) {
							_preloadPhotosSequentially(apiClient, visibleMatches, indices, currentIndex + 1);
						}
					});
				}
			});
		} else {
			// No team for this match, skip and continue
			_preloadPhotosSequentially(apiClient, visibleMatches, indices, currentIndex + 1);
		}
	}

	void _performScroll(int scrollTargetIndex, int firstUnscoutedIndex) {
		if (_hasScrolled || scrollTargetIndex < 0) return;

		if (_scrollTargetKey.currentContext != null) {
			final renderBox = _scrollTargetKey.currentContext!.findRenderObject() as RenderBox?;
			if (renderBox != null) {
				// Calculate exact scroll offset using measured item height
				final itemHeight = renderBox.size.height;
				final correctOffset = (scrollTargetIndex * itemHeight).toDouble();

				// Scroll to exact position using measured height
				_scrollController.animateTo(
					correctOffset,
					duration: const Duration(milliseconds: 300),
					curve: Curves.easeInOut,
				);
				_hasScrolled = true;
				_scrollRetries = 0;
			} else {
				// RenderBox not found, retry
				_scrollRetries++;
				SchedulerBinding.instance.scheduleFrameCallback((_) {
					_performScroll(scrollTargetIndex, firstUnscoutedIndex);
				});
			}
		} else if (_scrollRetries == 0) {
			// First retry: jump to approximate position to force item to render
			// Use 50px estimated height since we'll measure on next retry
			final approxItemHeight = 50.0;
			final approxOffset = (scrollTargetIndex * approxItemHeight).toDouble();
			_scrollController.jumpTo(approxOffset);
			_scrollRetries++;
			SchedulerBinding.instance.scheduleFrameCallback((_) {
				_performScroll(scrollTargetIndex, firstUnscoutedIndex);
			});
		} else if (_scrollRetries < _maxScrollRetries) {
			_scrollRetries++;
			SchedulerBinding.instance.scheduleFrameCallback((_) {
				_performScroll(scrollTargetIndex, firstUnscoutedIndex);
			});
		} else {
			_hasScrolled = true;
		}
	}

	void _showManualMatchEntryDialog(BuildContext context, WidgetRef ref) {
		final TextEditingController matchNumberController = TextEditingController();
		final TextEditingController teamNumberController = TextEditingController();
		final GlobalKey<FormState> formKey = GlobalKey<FormState>();
		String selectedMatchType = 'qm'; // Default to qualification

		final matchTypes = {
			'pm': _translate('match_type_practice'),
			'qm': _translate('match_type_qualification'),
			'qf': _translate('match_type_quarter_final'),
			'sf': _translate('match_type_semi_final'),
			'1p': _translate('match_type_playoff_1'),
			'2p': _translate('match_type_playoff_2'),
			'3p': _translate('match_type_playoff_3'),
			'4p': _translate('match_type_playoff_4'),
			'5p': _translate('match_type_playoff_5'),
			'f': _translate('match_type_final'),
		};

		showDialog(
			context: context,
			builder: (context) => StatefulBuilder(
				builder: (context, setState) => AlertDialog(
					title: Text(_translate('enter_match')),
					content: Form(
						key: formKey,
						child: Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								DropdownButtonFormField<String>(
									value: selectedMatchType,
									decoration: InputDecoration(
										labelText: _translate('match_type'),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(8),
										),
									),
									onChanged: (value) {
										if (value != null) {
											setState(() => selectedMatchType = value);
										}
									},
									items: matchTypes.entries
										.map((e) => DropdownMenuItem(
											value: e.key,
											child: Text(e.value),
										))
										.toList(),
								),
								const SizedBox(height: 12),
								TextFormField(
									controller: matchNumberController,
									decoration: InputDecoration(
										labelText: _translate('match_number'),
										hintText: _translate('match_number_example'),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(8),
										),
									),
									keyboardType: TextInputType.number,
									validator: (value) {
										if (value == null || value.isEmpty) {
											return _translate('match_number_required');
										}
										if (int.tryParse(value) == null) {
											return _translate('must_be_valid_number');
										}
										return null;
									},
								),
								const SizedBox(height: 12),
								TextFormField(
									controller: teamNumberController,
									decoration: InputDecoration(
										labelText: _translate('team_number'),
										hintText: _translate('team_number_example'),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(8),
										),
									),
									keyboardType: TextInputType.number,
									validator: (value) {
										if (value == null || value.isEmpty) {
											return _translate('team_number_required');
										}
										if (int.tryParse(value) == null) {
											return _translate('must_be_valid_number');
										}
										return null;
									},
								),
							],
						),
					),
					actions: [
						TextButton(
							onPressed: () {
								Navigator.pop(context);
							},
							child: Text(_translate('cancel')),
						),
						ElevatedButton(
							onPressed: () async {
								if (formKey.currentState!.validate()) {
									final matchNumber = matchNumberController.text.trim();
									final teamNumber = teamNumberController.text.trim();
									final matchId = '$selectedMatchType$matchNumber';
									Navigator.pop(context);

									try {
										widget.onMatchSelected(matchId, teamNumber);
									} catch (e) {
										if (context.mounted) {
											ScaffoldMessenger.of(context).showSnackBar(
												SnackBar(content: Text('Error: $e')),
											);
										}
									}
								}
							},
							child: Text(_translate('use_match')),
						),
					],
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		// Watch locale to trigger rebuild when language changes
		ref.watch(selectedLocaleProvider);
		final matchesAsync = ref.watch(matchListProvider);
		final selectedEventId = ref.watch(selectedEventProvider);
		final selectedBot = ref.watch(selectedBotPositionProvider);
		final events = ref.watch(eventListProvider);

		// Find the event name from the event list
		String? eventName;
		if (selectedEventId != null) {
			try {
				eventName = events.firstWhere((e) => e.eventId == selectedEventId).name;
			} catch (e) {
				eventName = null;
			}
		}

		return Scaffold(
			appBar: AppBar(
				title: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					mainAxisSize: MainAxisSize.min,
					children: [
						if (eventName != null)
							Text(
								'$eventName${selectedBot != null ? ' • Pos: $selectedBot' : ''}',
								style: Theme.of(context).textTheme.titleMedium?.copyWith(
									color: Colors.white,
								),
							),
						Text(
							_translate('select_match'),
							style: Theme.of(context).textTheme.labelLarge?.copyWith(
								color: Colors.white70,
							),
						),
					],
				),
				elevation: 0,
				automaticallyImplyLeading: false,
				actions: [
					ViperMenuButton(),
				],
			),
			body: matchesAsync.when(
				data: (matches) {
					return ref.watch(scoutedMatchesProvider).when(
						data: (scoutedMatchSet) {
							// Find the last (most recent) scouted match
							String? lastScoutedMatch;
							for (int i = matches.length - 1; i >= 0; i--) {
								if (scoutedMatchSet.contains(matches[i].matchNumber)) {
									lastScoutedMatch = matches[i].matchNumber;
									break;
								}
							}

							// Filter to only visible items (those with a team for this bot position)
							final visibleMatches = <(int arrayIndex, dynamic match)>[];
							for (int i = 0; i < matches.length; i++) {
								final match = matches[i];
								final team = widget.botPosition != null
										? match.getTeamForPosition(widget.botPosition!)
										: null;
								if (team != null && team.isNotEmpty) {
									visibleMatches.add((i, match));
								}
							}

							// Find first unscouted in visible list
							int firstUnscoutedIndex = -1;
							for (int i = 0; i < visibleMatches.length; i++) {
								final match = visibleMatches[i].$2;
								final isScouted = scoutedMatchSet.contains(match.matchNumber) ||
									(lastScoutedMatch != null &&
										matches.indexWhere((m) => m.matchNumber == match.matchNumber) <=
										matches.indexWhere((m) => m.matchNumber == lastScoutedMatch));
								if (!isScouted) {
									firstUnscoutedIndex = i;
									break;
								}
							}

							// Calculate scroll target (2 items before first unscouted)
							final scrollTargetIndex = firstUnscoutedIndex == -1
								? 0
								: (firstUnscoutedIndex - 2).clamp(0, visibleMatches.length - 1);

							// Reset scroll state if first unscouted changed
							if (firstUnscoutedIndex != _lastFirstUnscoutedIndex) {
								_hasScrolled = false;
								_scrollRetries = 0;
								_lastFirstUnscoutedIndex = firstUnscoutedIndex;
							}

							// Schedule scroll after frame is painted
							SchedulerBinding.instance.scheduleFrameCallback((_) {
								_performScroll(scrollTargetIndex, firstUnscoutedIndex);

							// Start preloading robot photos from the next match
							final nextMatchIndex = firstUnscoutedIndex > -1 ? firstUnscoutedIndex : 0;
							SchedulerBinding.instance.addPostFrameCallback((_) {
								_preloadRobotPhotos(
									visibleMatches.map((item) => item.$2).toList(),
									nextMatchIndex,
									ref.read(selectedEventProvider),
								);
							});
						});

						return ListView.builder(
							controller: _scrollController,
							itemCount: visibleMatches.length + 1,
							itemBuilder: (context, index) {
								// Manual entry button at the bottom
								if (index == visibleMatches.length) {
									return Padding(
										padding: const EdgeInsets.all(16.0),
										child: ElevatedButton.icon(
											onPressed: () => _showManualMatchEntryDialog(context, ref),
											icon: const Icon(Icons.add),
											label: Text(_translate('add_match_manually')),
										),
									);
								}
									final match = visibleMatches[index].$2;
									final team = widget.botPosition != null
											? match.getTeamForPosition(widget.botPosition!)
											: null;

									// Mark as scouted if:
									// 1. It's explicitly in scoutedMatches, OR
									// 2. It's before or equal to the last scouted match
									final isScouted = scoutedMatchSet.contains(match.matchNumber) ||
										(lastScoutedMatch != null &&
											matches.indexWhere((m) => m.matchNumber == match.matchNumber) <=
											matches.indexWhere((m) => m.matchNumber == lastScoutedMatch));

									// Determine team color (R1-R3 = red, B1-B3 = blue)
									final isRedTeam = widget.botPosition?.startsWith('R') ?? false;
									final teamBgColor = isRedTeam ? AppColors.redTeamColor : AppColors.blueTeamColor;

									// When scouted, show dark background with green text
									final tileColor = isScouted ? AppColors.lowlightBgColor : AppColors.mainBgColor;
									final textColor = isScouted ? AppColors.highlightFgColor : AppColors.mainFgColor;

									return ListTile(
										key: index == scrollTargetIndex ? _scrollTargetKey : null,
										onTap: () {
											widget.onMatchSelected(match.matchNumber, team!);
										},
										tileColor: tileColor,
										leading: Container(
											padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
											decoration: BoxDecoration(
												color: isScouted ? AppColors.lowlightBgColor : teamBgColor,
												borderRadius: BorderRadius.circular(4),
											),
											child: Text(
												team!,
												style: TextStyle(
													color: textColor,
													fontWeight: FontWeight.bold,
												),
											),
										),
										title: Text(
											getShortMatchName(match.matchNumber),
											style: TextStyle(color: textColor),
										),
									);
								},
							);
						},
						loading: () => const Center(
							child: CircularProgressIndicator(),
						),
						error: (error, stack) => Center(
							child: Text(_translate('error_loading_scouted_matches')),
						),
					);
				},
				loading: () => const Center(
					child: CircularProgressIndicator(),
				),
				error: (error, stack) => Center(
					child: Text(_translate('error_loading_matches')),
				),
			),
		);
	}
}
