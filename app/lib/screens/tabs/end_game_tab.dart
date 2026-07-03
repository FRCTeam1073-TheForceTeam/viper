import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/app_providers.dart';
import '../../providers/scouting_data_provider.dart';
import '../../providers/pre_match_provider.dart';
import '../../providers/timeline_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/field_side_provider.dart';
import '../../providers/timeline_provider.dart';
import '../../services/localization.dart';
import '../../services/csv_builder.dart';
import '../../widgets/checkbox_button.dart';
import '../../widgets/checkbox_button_group.dart';
import '../../widgets/descriptor_checkbox_group.dart';
import '../../widgets/position_selector_area.dart';
import '../../widgets/radio_button_group.dart';
import '../../widgets/descriptor_text_field.dart';
import '../../widgets/descriptor_text_area.dart';
import '../../constants/colors.dart';
import '../../models/match_model.dart';
import '../../models/field_descriptor.dart';

class EndGameTab extends ConsumerStatefulWidget {
	final String eventId;
	final String? matchNumber;
	final String? teamNumber;
	final VoidCallback? onNextMatch;

	const EndGameTab({
		Key? key,
		required this.eventId,
		required this.matchNumber,
		required this.teamNumber,
		this.onNextMatch,
	}) : super(key: key);

	@override
	ConsumerState<EndGameTab> createState() => _EndGameTabState();
}

class _EndGameTabState extends ConsumerState<EndGameTab> {
	String? _lastScoutAction;

	String _translate(String key, {Map<String, String>? variables}) {
		final locale = ref.read(selectedLocaleProvider);
		return AppLocalizations.translate(key, locale: locale, variables: variables);
	}

	@override
	void initState() {
		super.initState();
		// Load last scout action from SharedPreferences
		_loadLastScoutAction();

		// Register translations on demand when this tab is first loaded
		AppLocalizations.addI18n({
			'end_game_gameplay_header': {
				'en': 'Game play',
				'es': 'Juego',
				'pt': 'Jogo',
				'fr': 'Jeu',
				'zh_tw': '遊戲',
				'he': 'משחק',
				'tr': 'Oyun oynama',
			},
			'auto_climb_legend': {
				'en': 'Where did team _TEAMNUM_ climb during autonomous?',
				'es': '¿Dónde trepó el equipo _TEAMNUM_ durante autónomo?',
				'pt': 'Onde a equipe _TEAMNUM_ escalou durante autônoma?',
				'fr': 'Où l\'équipe _TEAMNUM_ a-t-elle grimpé lors de l\'autonome?',
				'zh_tw': '隊伍_TEAMNUM_在自主期間爬到了哪裡?',
				'he': 'לאיזה גובה טיפס צוות _TEAMNUM_ במהלך אוטונומי?',
				'tr': 'Takım _TEAMNUM_ otonom sırasında nereye tırmandı?',
			},
			'tele_climb_legend': {
				'en': 'Where did team _TEAMNUM_ climb during teleop?',
				'es': '¿Dónde trepó el equipo _TEAMNUM_ durante teleop?',
				'pt': 'Onde a equipe _TEAMNUM_ escalou durante o teleop?',
				'fr': 'Où l\'équipe _TEAMNUM_ a-t-elle grimpé lors du téléopération?',
				'zh_tw': '隊伍_TEAMNUM_在遠程操作期間爬到了哪裡?',
				'he': 'לאיזה גובה טיפס צוות _TEAMNUM_ במהלך teleop?',
				'tr': 'Takım _TEAMNUM_ teleop sırasında nereye tırmandı?',
			},
			'climb_method_legend': {
				'en': 'How did team _TEAMNUM_ climb past level one?',
				'es': '¿Cómo trepó el equipo _TEAMNUM_ pasando el nivel uno?',
				'pt': 'Como a equipe _TEAMNUM_ escalou além do nível um?',
				'fr': 'Comment l\'équipe _TEAMNUM_ a-t-elle grimpé au-delà du niveau un?',
				'zh_tw': '隊伍_TEAMNUM_如何攀爬過第一級?',
				'he': 'כיצד טיפס צוות _TEAMNUM_ מעבר לרמה אחת?',
				'tr': 'Takım _TEAMNUM_ birinci seviyeyi geçerek nasıl tırmandı?',
			},
			'climb_method_rungs': {
				'en': 'Rungs',
				'es': 'Peldaños',
				'pt': 'Degraus',
				'fr': 'Barreaux',
				'zh_tw': '橫檔',
				'he': 'שלבים',
				'tr': 'Basamaklar',
			},
			'climb_method_rungs_desc': {
				'en': 'Climbed the rungs.',
				'es': 'Trepó los peldaños.',
				'pt': 'Escalou os degraus.',
				'fr': 'Grimpé les barreaux.',
				'zh_tw': '攀爬了橫檔。',
				'he': 'טיפס על השלבים.',
				'tr': 'Basamakları tırmanmıştır.',
			},
			'climb_method_uprights': {
				'en': 'Uprights',
				'es': 'Postes verticales',
				'pt': 'Colunas',
				'fr': 'Montants',
				'zh_tw': '豎柱',
				'he': 'עמודים',
				'tr': 'Dikey Taşıyıcılar',
			},
			'climb_method_uprights_desc': {
				'en': 'Climbed the uprights.',
				'es': 'Trepó los postes verticales.',
				'pt': 'Escalou as colunas.',
				'fr': 'Grimpé les montants.',
				'zh_tw': '攀爬了豎柱。',
				'he': 'טיפס על העמודים.',
				'tr': 'Dikey taşıyıcıları tırmandı.',
			},
			'climb_method_flip': {
				'en': 'Flip',
				'es': 'Voltear',
				'pt': 'Virar',
				'fr': 'Basculer',
				'zh_tw': '翻轉',
				'he': 'תפיסה והיפוך',
				'tr': 'Çevir',
			},
			'climb_method_flip_desc': {
				'en': 'Grabbed on and flipped upside down.',
				'es': 'Se agarró y dio la vuelta boca abajo.',
				'pt': 'Agarrou-se e virou de cabeça para baixo.',
				'fr': 'S\'est accroché et a basculé à l\'envers.',
				'zh_tw': '抓住並翻轉倒立。',
				'he': 'תפס והיפך לאחור.',
				'tr': 'Tutundu ve ters çevrildi.',
			},
			'demonstrated_capabilities': {
				'en': 'Team _TEAMNUM_ Demonstrated Capabilities',
				'es': 'Capacidades Demostradas del Equipo _TEAMNUM_',
				'pt': 'Capacidades Demonstradas da Equipe _TEAMNUM_',
				'fr': 'Capacités démontrées de l\'équipe _TEAMNUM_',
				'zh_tw': '隊伍_TEAMNUM_展示的能力',
				'he': 'יכולות שהוכחו בצוות _TEAMNUM_',
				'tr': 'Takım _TEAMNUM_ Gösterilen Yetenekler',
			},
			'shoot_move_desc': {
				'en': 'Shoot on the move',
				'es': 'Dispara en movimiento',
				'pt': 'Atirar em movimento',
				'fr': 'Tirer en mouvement',
				'zh_tw': '邊移動邊射擊',
				'he': 'ירוק תוך כדי תנועה',
				'tr': 'Hareket halinde ateş et',
			},
			'shoot_collecting_desc': {
				'en': 'Shoot while collecting',
				'es': 'Dispara mientras recoge',
				'pt': 'Atirar enquanto coleta',
				'fr': 'Tirer tout en collectant',
				'zh_tw': '邊收集邊射擊',
				'he': 'ירוק בזמן אוסף',
				'tr': 'Toplama sırasında ateş et',
			},
			'shoot_turret_desc': {
				'en': 'Change shooting direction while moving straight',
				'es': 'Cambia la dirección de tiro mientras te mueves hacia adelante',
				'pt': 'Mudar direção de tiro enquanto se move reto',
				'fr': 'Changer la direction de tir en se déplaçant droit',
				'zh_tw': '直線移動時改變射擊方向',
				'he': 'שנה כיוון יריה בעת תנועה ישר',
				'tr': 'Düz hareket ederken atış yönünü değiştir',
			},
			'shoot_climbing_desc': {
				'en': 'Shoot while climbing',
				'es': 'Dispara mientras escala',
				'pt': 'Atirar enquanto escala',
				'fr': 'Tirer tout en grimpant',
				'zh_tw': '攀爬時射擊',
				'he': 'ירוק בעת טיפוס',
				'tr': 'Tırmanış sırasında ateş et',
			},
			'fuel_strategy_legend': {
				'en': 'What was the main strategy team _TEAMNUM_ used to get fuel into the alliance zone?',
				'es': '¿Cuál fue la estrategia principal que el equipo _TEAMNUM_ usó para meter combustible en la zona de alianza?',
				'pt': 'Qual foi a estratégia principal que a equipe _TEAMNUM_ usou para colocar combustível na zona de aliança?',
				'fr': 'Quelle était la stratégie principale utilisée par l\'équipe _TEAMNUM_ pour obtenir du carburant dans la zone d\'alliance?',
				'zh_tw': '隊伍_TEAMNUM_將燃料送入聯盟區的主要策略是什麼?',
				'he': 'מה הייתה האסטרטגיה הראשית של צוות _TEAMNUM_ כדי להכניס דלק לאזור הברית?',
				'tr': 'Takım _TEAMNUM_\'un yakıtı ittifak bölgesine sokmak için kullandığı ana strateji nedir?',
			},
			'fuel_carried_label': {
				'en': 'Carried',
				'es': 'Llevada',
				'pt': 'Transportada',
				'fr': 'Portée',
				'zh_tw': '攜帶',
				'he': 'נשא',
				'tr': 'Taşıdı',
			},
			'fuel_carried_desc': {
				'en': 'Stored fuel in the robot and carried it.',
				'es': 'Almacenó combustible en el robot y lo transportó.',
				'pt': 'Armazenou combustível no robô e o transportou.',
				'fr': 'Carburant stocké dans le robot et transporté.',
				'zh_tw': '將燃料儲存在機器人中並運輸。',
				'he': 'אחסן דלק בו וביצע קריאות.',
				'tr': 'Yakıtı robotta depoladı ve taşıdı.',
			},
			'fuel_pushed_label': {
				'en': 'Pushed',
				'es': 'Empujada',
				'pt': 'Empurrada',
				'fr': 'Poussée',
				'zh_tw': '推送',
				'he': 'דחף',
				'tr': 'İtildi',
			},
			'fuel_pushed_desc': {
				'en': 'Pushed fuel over the bump or under the trench.',
				'es': 'Empujó combustible sobre el bache o bajo la trinchera.',
				'pt': 'Empurrou o combustível sobre a saliência ou sob a trincheira.',
				'fr': 'Carburant poussé par-dessus la bosse ou sous le fossé.',
				'zh_tw': '將燃料推過凸起或溝渠下方。',
				'he': 'דחף דלק מעל הבליטה או מתחת לתעלה.',
				'tr': 'Yakıtı tampon üzerinden veya hendek altından itti.',
			},
			'fuel_passed_label': {
				'en': 'Passed',
				'es': 'Pasada',
				'pt': 'Passou',
				'fr': 'Passé',
				'zh_tw': '通過',
				'he': 'עבר',
				'tr': 'Geçti',
			},
			'fuel_passed_desc': {
				'en': 'Shot fuel towards the alliance zone.',
				'es': 'Disparó combustible hacia la zona de alianza.',
				'pt': 'Disparou combustível em direção à zona de aliança.',
				'fr': 'Carburant tiré vers la zone d\'alliance.',
				'zh_tw': '向聯盟區射擊燃料。',
				'he': 'ירה בדלק לכיוון אזור הברית.',
				'tr': 'Yakıtı ittifak bölgesine doğru ateş etti.',
			},
			'fuel_received_label': {
				'en': 'Received',
				'es': 'Recibida',
				'pt': 'Recebida',
				'fr': 'Reçu',
				'zh_tw': '收到',
				'he': 'קיבל',
				'tr': 'Alındı',
			},
			'fuel_received_desc': {
				'en': 'Stayed in the alliance zone and received fuel from other bots.',
				'es': 'Se quedó en la zona de alianza y recibió combustible de otros bots.',
				'pt': 'Permaneceu na zona de aliança e recebeu combustível de outros bots.',
				'fr': 'Est resté dans la zone d\'alliance et a reçu du carburant d\'autres bots.',
				'zh_tw': '留在聯盟區並從其他機器人接收燃料。',
				'he': 'נשאר באזור הברית וקיבל דלק מרובוטים אחרים.',
				'tr': 'İttifak bölgesinde kaldı ve diğer botlardan yakıt aldı.',
			},
			'shooting_locations_legend': {
				'en': 'Were there a limited set of locations from which team _TEAMNUM_ could score fuel that could be defended? If so, mark them.',
				'es': '¿Había un conjunto limitado de ubicaciones desde donde el equipo _TEAMNUM_ podría anotar combustible que pudiera ser defendido? Si es así, márquelos.',
				'pt': 'Havia um conjunto limitado de locais de onde a equipe _TEAMNUM_ poderia marcar combustível que pudesse ser defendido? Se sim, marque-os.',
				'fr': 'Y avait-il un ensemble limité d\'emplacements à partir desquels l\'équipe _TEAMNUM_ pouvait marquer du carburant qui pouvait être défendu? Si oui, marquez-les.',
				'zh_tw': '隊伍_TEAMNUM_是否有一組有限的位置可以得分燃料可以防守?如果是，請標記它們。',
				'he': 'האם היו סט מוגבל של מיקומים מהם צוות _TEAMNUM_ יכול היה לצבור דלק שניתן להגן עליו? אם כן, סמן אותם.',
				'tr': 'Takım _TEAMNUM_ savunulabilecek yakıt puanı alabileceği sınırlı bir konum seti var mıydı? Varsa, işaretleyin.',
			},
			'undo_button': {
				'en': 'Undo',
				'es': 'Deshacer',
				'pt': 'Desfazer',
				'fr': 'Annuler',
				'zh_tw': '撤銷',
				'he': 'בטל',
				'tr': 'Geri Al',
			},
			'bricked_legend': {
				'en': 'Was team _TEAMNUM_ bricked?',
				'es': '¿Fue el equipo _TEAMNUM_ deshabilitado?',
				'pt': 'A equipe _TEAMNUM_ foi desabilitada?',
				'fr': 'L\'équipe _TEAMNUM_ a-t-elle été paralysée?',
				'zh_tw': '隊伍_TEAMNUM_被禁用了嗎?',
				'he': 'האם צוות _TEAMNUM_ היה מושבת?',
				'tr': 'Takım _TEAMNUM_ tuğla kullanmış mı?',
			},
			'bricked_no': {
				'en': 'No',
				'es': 'No',
				'pt': 'Não',
				'fr': 'Non',
				'zh_tw': '否',
				'he': 'לא',
				'tr': 'Hayır',
			},
			'bricked_no_desc': {
				'en': 'Didn\'t get disabled.',
				'es': 'No fue deshabilitado.',
				'pt': 'Não foi desabilitada.',
				'fr': 'N\'a pas été désactivée.',
				'zh_tw': '未被禁用。',
				'he': 'לא הושבת.',
				'tr': 'Devre dışı bırakılmadı.',
			},
			'bricked_some': {
				'en': 'Some',
				'es': 'Algunos',
				'pt': 'Alguns',
				'fr': 'Un peu',
				'zh_tw': '某些',
				'he': 'חלק',
				'tr': 'Bazı',
			},
			'bricked_some_desc': {
				'en': 'Disabled for a short time.',
				'es': 'Deshabilitado por un corto tiempo.',
				'pt': 'Desabilitada por um curto período.',
				'fr': 'Désactivée pour une courte durée.',
				'zh_tw': '被禁用很短的時間。',
				'he': 'הושבת לזמן קצר.',
				'tr': 'Kısa bir süre devre dışı bırakıldı.',
			},
			'bricked_half': {
				'en': 'Half',
				'es': 'Mitad',
				'pt': 'Metade',
				'fr': 'Moitié',
				'zh_tw': '半',
				'he': 'חצי',
				'tr': 'Yarısı',
			},
			'bricked_half_desc': {
				'en': 'Disabled for about half the match.',
				'es': 'Deshabilitado durante aproximadamente la mitad del partido.',
				'pt': 'Desabilitada por aproximadamente metade da partida.',
				'fr': 'Désactivée pendant environ la moitié du match.',
				'zh_tw': '在比賽的大約一半時間內被禁用。',
				'he': 'הושבת למשך כחצי המשחק.',
				'tr': 'Maçın yaklaşık yarısı boyunca devre dışı bırakıldı.',
			},
			'bricked_most': {
				'en': 'Most',
				'es': 'La mayoría',
				'pt': 'A maioria',
				'fr': 'Plupart',
				'zh_tw': '大部分',
				'he': 'רוב',
				'tr': 'Çoğu',
			},
			'bricked_most_desc': {
				'en': 'Disabled for most of the match.',
				'es': 'Deshabilitado durante la mayor parte del partido.',
				'pt': 'Desabilitada durante a maior parte da partida.',
				'fr': 'Désactivée pendant la majeure partie du match.',
				'zh_tw': '在大部分比賽時間內被禁用。',
				'he': 'הושבת למרבית המשחק.',
				'tr': 'Maçın çoğu süresince devre dışı bırakıldı.',
			},
			'bricked_all': {
				'en': 'All',
				'es': 'Todo',
				'pt': 'Tudo',
				'fr': 'Tous',
				'zh_tw': '全部',
				'he': 'הכל',
				'tr': 'Tümü',
			},
			'bricked_all_desc': {
				'en': 'Disabled for the entire match.',
				'es': 'Deshabilitado durante todo el partido.',
				'pt': 'Desabilitada durante toda a partida.',
				'fr': 'Désactivée pendant tout le match.',
				'zh_tw': '在整場比賽中被禁用。',
				'he': 'הושבת למשך כל המשחק.',
				'tr': 'Tüm maç boyunca devre dışı bırakıldı.',
			},
			'defense_legend': {
				'en': 'Team _TEAMNUM_ Defense Rating',
				'es': 'Clasificación de Defensa del Equipo _TEAMNUM_',
				'pt': 'Classificação de Defesa da Equipe _TEAMNUM_',
				'fr': 'Cote de défense de l\'équipe _TEAMNUM_',
				'zh_tw': '隊伍_TEAMNUM_防守評級',
				'he': 'דירוג הגנה של צוות _TEAMNUM_',
				'tr': 'Takım _TEAMNUM_ Savunma Derecesi',
			},
			'defense_none': {
				'en': 'None',
				'es': 'Ninguno',
				'pt': 'Nenhum',
				'fr': 'Aucun',
				'zh_tw': '無',
				'he': 'אין',
				'tr': 'Yok',
			},
			'defense_none_desc': {
				'en': 'Didn\'t play defense.',
				'es': 'No jugó defensa.',
				'pt': 'Não jogou defesa.',
				'fr': 'N\'a pas joué la défense.',
				'zh_tw': '未進行防守。',
				'he': 'לא שיחק הגנה.',
				'tr': 'Savunma oynamadı.',
			},
			'defense_bad': {
				'en': 'Bad',
				'es': 'Malo',
				'pt': 'Ruim',
				'fr': 'Mauvais',
				'zh_tw': '壞',
				'he': 'רע',
				'tr': 'Kötü',
			},
			'defense_bad_desc': {
				'en': 'More penalties playing defense than opponent points prevented.',
				'es': 'Más penalizaciones jugando defensa que puntos del oponente prevenidos.',
				'pt': 'Mais penalidades jogando defesa do que pontos adversários impedidos.',
				'fr': 'Plus de pénalités jouant la défense que les points adverses empêchés.',
				'zh_tw': '防守時的罰球多於阻止對手得分。',
				'he': 'יותר עונשים משחקי הגנה מנקודות אופוננט שמונעות.',
				'tr': 'Savunma oynananından daha fazla ceza, muhalif puanlarını engelledi.',
			},
			'defense_ineffective': {
				'en': 'Ineffective',
				'es': 'Ineficaz',
				'pt': 'Ineficaz',
				'fr': 'Inefficace',
				'zh_tw': '無效',
				'he': 'לא יעיל',
				'tr': 'Etkisiz',
			},
			'defense_ineffective_desc': {
				'en': 'Didn\'t significantly impact the game.',
				'es': 'No tuvo un impacto significativo en el juego.',
				'pt': 'Não teve impacto significativo no jogo.',
				'fr': 'N\'a pas eu d\'impact significatif sur le jeu.',
				'zh_tw': '對比賽沒有產生重大影響。',
				'he': 'לא השפיע באופן משמעותי על המשחק.',
				'tr': 'Oyunu önemli ölçüde etkilemedi.',
			},
			'defense_good': {
				'en': 'Good',
				'es': 'Bueno',
				'pt': 'Bom',
				'fr': 'Bon',
				'zh_tw': '好',
				'he': 'טוב',
				'tr': 'İyi',
			},
			'defense_good_desc': {
				'en': 'Prevented an opponent from scoring some points.',
				'es': 'Evitó que un oponente anotara algunos puntos.',
				'pt': 'Impediu um adversário de marcar alguns pontos.',
				'fr': 'A empêché un adversaire de marquer des points.',
				'zh_tw': '阻止對手得到一些分數。',
				'he': 'מנע מיריב לנקוד כמה נקודות.',
				'tr': 'Bir muhalifi bazı puanlar kazanmaktan engelledi.',
			},
			'defense_great': {
				'en': 'Great',
				'es': 'Excelente',
				'pt': 'Ótimo',
				'fr': 'Excellent',
				'zh_tw': '太棒了',
				'he': 'מעולה',
				'tr': 'Harika',
			},
			'defense_great_desc': {
				'en': 'Mostly shut down an opponent.',
				'es': 'Principalmente neutralizó a un oponente.',
				'pt': 'Principalmente desligou um adversário.',
				'fr': 'Surtout arrêté un adversaire.',
				'zh_tw': '主要關閉對手。',
				'he': 'בעיקר כיבה יריב.',
				'tr': 'Çoğunlukla bir muhalifi kapatmıştır.',
			},
			'defense_methods_legend': {
				'en': 'What methods did team _TEAMNUM_ use when defending?',
				'es': '¿Qué métodos usó el equipo _TEAMNUM_ al defender?',
				'pt': 'Quais métodos a equipe _TEAMNUM_ usou ao defender?',
				'fr': 'Quelles méthodes l\'équipe _TEAMNUM_ a-t-elle utilisées pour défendre?',
				'zh_tw': '隊伍_TEAMNUM_防守時使用了哪些方法?',
				'he': 'אילו שיטות השתמש צוות _TEAMNUM_ בהגנה?',
				'tr': 'Takım _TEAMNUM_ savunma yaparken hangi yöntemleri kullanmıştır?',
			},
			'defense_collected': {
				'en': 'Collected',
				'es': 'Recolectado',
				'pt': 'Coletou',
				'fr': 'Collecté',
				'zh_tw': '收集',
				'he': 'אסף',
				'tr': 'Topladı',
			},
			'defense_collected_desc': {
				'en': 'Collected fuel from opponents\' alliance zone.',
				'es': 'Recolectó combustible de la zona de alianza del oponente.',
				'pt': 'Coletou combustível da zona de aliança dos oponentes.',
				'fr': 'Carburant collecté à partir de la zone d\'alliance des adversaires.',
				'zh_tw': '從對手的聯盟區收集燃料。',
				'he': 'אסף דלק מאזור הברית של היריבים.',
				'tr': 'Rakiplerin ittifak bölgesinden yakıt topladı.',
			},
			'defense_hit': {
				'en': 'Hit',
				'es': 'Golpeado',
				'pt': 'Bateu',
				'fr': 'Frappé',
				'zh_tw': '碰撞',
				'he': 'פגע',
				'tr': 'Vurdu',
			},
			'defense_hit_desc': {
				'en': 'Hit or pushed the opponent to reduce their shooting accuracy.',
				'es': 'Golpeó o empujó al oponente para reducir su precisión de disparo.',
				'pt': 'Bateu ou empurrou o adversário para reduzir sua precisão de tiro.',
				'fr': 'Frappé ou poussé l\'adversaire pour réduire la précision de tir.',
				'zh_tw': '碰撞或推動對手以降低其射擊準確度。',
				'he': 'פגע או דחף את היריב כדי להפחית את דיוק הירי שלהם.',
				'tr': 'Muhalifi vurdu veya itti ve atış doğruluğunu azalttı.',
			},
			'defense_blocked': {
				'en': 'Blocked',
				'es': 'Bloqueado',
				'pt': 'Bloqueou',
				'fr': 'Bloqué',
				'zh_tw': '阻擋',
				'he': 'חסם',
				'tr': 'Engelledi',
			},
			'defense_blocked_desc': {
				'en': 'Blocked an opponent from entering or leaving the alliance zone.',
				'es': 'Bloqueó a un oponente para que no entrara o saliera de la zona de alianza.',
				'pt': 'Bloqueou um oponente de entrar ou sair da zona de aliança.',
				'fr': 'Bloqué un adversaire pour entrer ou quitter la zone d\'alliance.',
				'zh_tw': '阻止對手進入或離開聯盟區。',
				'he': 'חסם יריב מלהיכנס או לעזוב את אזור הברית.',
				'tr': 'Rakibin ittifak bölgesine girmesini veya ayrılmasını engelledi.',
			},
			'defense_pinned': {
				'en': 'Pinned',
				'es': 'Atrapado',
				'pt': 'Prendeu',
				'fr': 'Épinglé',
				'zh_tw': '牢固',
				'he': 'תקע',
				'tr': 'Sabitlendi',
			},
			'defense_pinned_desc': {
				'en': 'Pinned an opponent to prevent them from shooting or collecting.',
				'es': 'Atrapó a un oponente para evitar que disparara o recolectara.',
				'pt': 'Prendeu um oponente para impedir que disparasse ou coletasse.',
				'fr': 'Épinglé un adversaire pour les empêcher de tirer ou de collecter.',
				'zh_tw': '牢固對手以防止他們射擊或收集。',
				'he': 'תקע יריב כדי למנוע מהם להיות בגודל או אוספים.',
				'tr': 'Rakibi sabitleyerek atış veya toplama yapmasını engelledi.',
			},
			'defended_legend': {
				'en': 'Was team _TEAMNUM_ affected by defense?',
				'es': '¿Fue el equipo _TEAMNUM_ afectado por la defensa?',
				'pt': 'A equipe _TEAMNUM_ foi afetada pela defesa?',
				'fr': 'L\'équipe _TEAMNUM_ a-t-elle été affectée par la défense?',
				'zh_tw': '隊伍_TEAMNUM_是否受到防守影響?',
				'he': 'האם צוות _TEAMNUM_ הושפע על ידי הגנה?',
				'tr': 'Takım _TEAMNUM_ savunmadan etkilendi mi?',
			},
			'defended_undefended': {
				'en': 'Undefended',
				'es': 'Sin defensa',
				'pt': 'Indefeso',
				'fr': 'Non défendu',
				'zh_tw': '未防守',
				'he': 'לא מגונה',
				'tr': 'Korumasız',
			},
			'defended_undefended_desc': {
				'en': 'Didn\'t get defended.',
				'es': 'No fue defendido.',
				'pt': 'Não foi defendido.',
				'fr': 'N\'a pas été défendu.',
				'zh_tw': '沒有獲得防守。',
				'he': 'לא קיבל הגנה.',
				'tr': 'Savunma alamadı.',
			},
			'defended_turned_tables': {
				'en': 'Turned tables',
				'es': 'Giró las tornas',
				'pt': 'Reverteu a situação',
				'fr': 'Renversé la situation',
				'zh_tw': '扭轉局面',
				'he': 'הפך שולחנות',
				'tr': 'Masaları çevirdi',
			},
			'defended_turned_tables_desc': {
				'en': 'Unaffected and the defender got penalties.',
				'es': 'No fue afectado y el defensor recibió penalizaciones.',
				'pt': 'Não afetado e o defensor recebeu penalidades.',
				'fr': 'Inaffecté et le défenseur a reçu des pénalités.',
				'zh_tw': '不受影響，防守者受罰。',
				'he': 'לא הושפע והמגן קיבל עונשים.',
				'tr': 'Etkilenmedi ve savunmacı ceza aldı.',
			},
			'defended_unaffected': {
				'en': 'Unaffected',
				'es': 'No afectado',
				'pt': 'Não afetado',
				'fr': 'Non affecté',
				'zh_tw': '未受影響',
				'he': 'לא הושפע',
				'tr': 'Etkilenmedi',
			},
			'defended_unaffected_desc': {
				'en': 'Not slowed down by defense.',
				'es': 'No fue ralentizado por la defensa.',
				'pt': 'Não foi desacelerado pela defesa.',
				'fr': 'Pas ralenti par la défense.',
				'zh_tw': '防守未減速。',
				'he': 'לא הואט על ידי הגנה.',
				'tr': 'Savunma tarafından yavaşlatılmadı.',
			},
			'defended_slowed': {
				'en': 'Slowed',
				'es': 'Ralentizado',
				'pt': 'Desacelerado',
				'fr': 'Ralenti',
				'zh_tw': '放緩',
				'he': 'האט',
				'tr': 'Yavaşladı',
			},
			'defended_slowed_desc': {
				'en': 'Scored less than they would have.',
				'es': 'Anotó menos de lo que hubiera anotado.',
				'pt': 'Pontuou menos do que teria feito.',
				'fr': 'Marqué moins qu\'ils ne l\'auraient fait.',
				'zh_tw': '得分少於他們本來會得到的分數。',
				'he': 'נקוד פחות ממה שהיו קוטעים.',
				'tr': 'Aksi takdirde yapacakları kadar olmadı.',
			},
			'defended_slowed_greatly': {
				'en': 'Slowed greatly',
				'es': 'Ralentizado mucho',
				'pt': 'Desacelerado muito',
				'fr': 'Considérablement ralenti',
				'zh_tw': '大幅減速',
				'he': 'האט מאוד',
				'tr': 'Büyük ölçüde yavaşladı',
			},
			'defended_slowed_greatly_desc': {
				'en': 'Scored very little.',
				'es': 'Anotó muy poco.',
				'pt': 'Pontuou muito pouco.',
				'fr': 'Marqué très peu.',
				'zh_tw': '得分非常少。',
				'he': 'נקוד מעט מאוד.',
				'tr': 'Çok az puan attı.',
			},
			'misses_legend': {
				'en': 'How often did team _TEAMNUM_ miss their shots?',
				'es': '¿Con qué frecuencia el equipo _TEAMNUM_ falla sus disparos?',
				'pt': 'Com que frequência a equipe _TEAMNUM_ errou seus tiros?',
				'fr': 'Combien de fois l\'équipe _TEAMNUM_ a-t-elle raté ses tirs?',
				'zh_tw': '隊伍_TEAMNUM_多久會漏接他們的射擊?',
				'he': 'כמה פעמים צוות _TEAMNUM_ פספסו את הזריקות שלהם?',
				'tr': 'Takım _TEAMNUM_ kaç kez atışlarını ıskala attı?',
			},
			'misses_0_1': {
				'en': '0-1%',
				'es': '0-1%',
				'pt': '0-1%',
				'fr': '0-1%',
				'zh_tw': '0-1%',
				'he': '0-1%',
				'tr': '0-1%',
			},
			'misses_1_10': {
				'en': '1-10%',
				'es': '1-10%',
				'pt': '1-10%',
				'fr': '1-10%',
				'zh_tw': '1-10%',
				'he': '1-10%',
				'tr': '1-10%',
			},
			'misses_10_30': {
				'en': '10-30%',
				'es': '10-30%',
				'pt': '10-30%',
				'fr': '10-30%',
				'zh_tw': '10-30%',
				'he': '10-30%',
				'tr': '10-30%',
			},
			'misses_30_60': {
				'en': '30-60%',
				'es': '30-60%',
				'pt': '30-60%',
				'fr': '30-60%',
				'zh_tw': '30-60%',
				'he': '30-60%',
				'tr': '30-60%',
			},
			'misses_60_100': {
				'en': '60-100%',
				'es': '60-100%',
				'pt': '60-100%',
				'fr': '60-100%',
				'zh_tw': '60-100%',
				'he': '60-100%',
				'tr': '60-100%',
			},
			'scouter_header': {
				'en': 'Scouter',
				'es': 'Explorador',
				'pt': 'Explorador',
				'fr': 'Éclaireur',
				'zh_tw': '偵查員',
				'he': 'סוקר',
				'tr': 'İzcisi',
			},
			'review_requested_legend': {
				'en': 'Fall asleep? Watch the wrong robot? Press the wrong button?',
				'pt': 'Adormeceu? Assistiu ao robô errado? Pressionou o botão errado?',
				'fr': 'Vous vous êtes endormi ? Vous avez regardé le mauvais robot ? Vous avez appuyé sur le mauvais bouton ?',
				'zh_tw': '睡著了？看錯機器人？按錯按鈕了？',
				'he': 'נרדמת? צפה ברובוט הלא נכון? לחץ על הכפתור הלא נכון?',
				'tr': 'Uyudun mu? Yanlış robotu mu izliyorsun? Yanlış düğmeye mi bastınız?',
				'es': 'Este equipo solicitó revisión',
			},
			'review_requested_button': {
				'en': 'Request Review',
				'es': 'Solicitar Revisión',
				'pt': 'Solicitar Revisão',
				'fr': 'Demander Examen',
				'zh_tw': '要求審查',
				'he': 'בקש סקירה',
				'tr': 'İnceleme İste',
			},
			'scouter_name_question': {
				'en': 'Scouter Name',
				'es': 'Nombre del explorador',
				'pt': 'Nome do Explorador',
				'fr': 'Nom de l\'éclaireur',
				'zh_tw': '偵查員名稱',
				'he': 'שם הסוקר',
				'tr': 'İzcinin Adı',
			},
			'scouter_name_placeholder': {
				'en': 'Scouter name',
				'es': 'Nombre del explorador',
				'pt': 'Nome do explorador',
				'fr': 'Nom de l\'éclaireur',
				'zh_tw': '偵查員名稱',
				'he': 'שם הסוקר',
				'tr': 'İzcinin adı',
			},
			'comments_question': {
				'en': 'Comments',
				'es': 'Comentarios',
				'pt': 'Comentários',
				'fr': 'Commentaires',
				'zh_tw': '評論',
				'he': 'הערות',
				'tr': 'Yorumlar',
			},
			'comments_placeholder': {
				'en': 'Comments',
				'es': 'Comentarios...',
				'pt': 'Comentários',
				'fr': 'Commentaires',
				'zh_tw': '評論',
				'he': 'הערות',
				'tr': 'Yorumlar',
			},
			'save_data_question': {
				'en': 'Save data:',
				'es': '¿Guardar',
				'pt': 'Salvar dados:',
				'fr': 'Sauvegarder les données :',
				'zh_tw': '儲存資料：',
				'he': 'שמור נתונים:',
				'tr': 'Verileri kaydet:',
			},
			'next_match_button': {
				'en': 'Next Match',
				'es': 'Siguiente partida',
				'pt': 'Próxima partida',
				'fr': 'Prochain match',
				'zh_tw': '下一場比賽',
				'he': 'המשחק הבא',
				'tr': 'Sonraki Maç',
			},
			'upload_data_button': {
				'en': 'Upload Data',
				'es': 'Cargar datos',
				'pt': 'Carregar dados',
				'fr': 'Télécharger les données',
				'zh_tw': '上傳數據',
				'he': 'העלה נתונים',
				'tr': 'Verileri Yükle',
			},
			'qr_code_button': {
				'en': 'QR Code',
				'es': 'Código QR',
				'pt': 'Código QR',
				'fr': 'Code QR',
				'zh_tw': 'QR 圖碼',
				'he': 'קוד QR',
				'tr': 'QR Kodu',
			},
		});
	}

	Future<void> _loadLastScoutAction() async {
		final prefs = await SharedPreferences.getInstance();
		setState(() {
			_lastScoutAction = prefs.getString('lastScoutAction');
		});
	}

	Future<void> _saveLastScoutAction(String action) async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.setString('lastScoutAction', action);
	}


	@override
	void dispose() {
		super.dispose();
	}

	String _getFeaturedButton(List<MatchModel>? matches) {
		if (_lastScoutAction == 'qr') return 'qr';
		if (matches == null || matches.isEmpty) return 'upload';
		final currentMatch = widget.matchNumber;
		bool hasNextMatch = false;
		bool foundCurrent = false;
		for (var m in matches) {
			if (foundCurrent) {
				hasNextMatch = true;
				break;
			}
			if (m.matchNumber == currentMatch) {
				foundCurrent = true;
			}
		}
		return hasNextMatch ? 'next' : 'upload';
	}

	Future<void> _saveCurrentMatch() async {
		try {
			final selectedEvent = ref.read(selectedEventProvider);
			final selectedMatch = ref.read(selectedMatchProvider);
			final db = await ref.read(databaseProvider.future);

			if (selectedEvent == null || selectedMatch.match == null || selectedMatch.team == null) {
				return;
			}

			// Read all scouting data from providers
			final preMatch = ref.read(preMatchProvider);
			final scoutingData = ref.read(scoutingDataProvider);
			final timeline = ref.read(timelineProvider);

			// Build scout data map by merging all provider data
			final sessionStartTime = ref.read(scoutingSessionCreatedProvider)!;
			final originalCreatedTime = ref.read(originalCreatedProvider);
			final createdTime = originalCreatedTime ?? sessionStartTime;
			final scoutDataMap = <String, dynamic>{
				'event': selectedEvent,
				'match': selectedMatch.match,
				'team': selectedMatch.team,
				'created': createdTime,
				'modified': sessionStartTime,
			};

			// Add pre-match data
			scoutDataMap.addAll(preMatch.toMap());

			// Add unified scouting data (auto, tele, and end-game)
			scoutDataMap.addAll(scoutingData.toMap());

			// Add timeline once (shared between auto and tele)
			scoutDataMap['timeline'] = TimelineEvent.formatTimeline(timeline);

			// Debug: log what we're about to save
			print('[SAVE_DATA] auto_trench_depot_alliance_to_neutral=${scoutDataMap['auto_trench_depot_alliance_to_neutral']}');
			print('[SAVE_DATA] tele_trench_depot_alliance_to_neutral=${scoutDataMap['tele_trench_depot_alliance_to_neutral']}');
			print('[SAVE_DATA] timeline=${scoutDataMap['timeline']}');

			// Build CSV
			final csv = CsvBuilder.buildScoutCsv([scoutDataMap]);
			final lines = csv.split('\n');
			if (lines.length < 2) return;

			final headers = lines[0];
			final data = lines[1];

			// Save to upload queue
			await db.insertUploadHistory(
				event: selectedEvent,
				match: selectedMatch.match!,
				team: selectedMatch.team!,
				csvHeaders: headers,
				csvData: data,
				status: 'pending',
			);

			// Reset all scouting providers
			ref.read(preMatchProvider.notifier).reset();
			ref.read(scoutingDataProvider.notifier).reset();
			ref.read(originalCreatedProvider.notifier).clear();
			ref.read(scoutingSessionCreatedProvider.notifier).clear();
		} catch (e) {
			print('Error saving match: $e');
		}
	}

	Future<void> _goToNextMatch() async {
		await _saveCurrentMatch();
		await _saveLastScoutAction('next');

		// Find next match
		final matches = ref.read(matchListProvider);
		final selectedMatch = ref.read(selectedMatchProvider);
		final selectedBot = ref.read(selectedBotPositionProvider);

		await matches.when(
			data: (matchList) async {
				bool foundCurrent = false;
				for (var m in matchList) {
					if (foundCurrent) {
						// Found next match, get team for our position
						final teamNum = selectedBot != null ? m.teams[selectedBot] : null;
						if (teamNum != null) {
							ref.read(selectedMatchProvider.notifier).setMatch(m.matchNumber, teamNum);
							widget.onNextMatch?.call();
						}
						return;
					}
					if (m.matchNumber == selectedMatch.match) {
						foundCurrent = true;
					}
				}
			},
			loading: () {},
			error: (_, __) {},
		);
	}

	Future<void> _goToUpload() async {
		await _saveCurrentMatch();
		await _saveLastScoutAction('upload');
		if (mounted) {
			ref.read(navigationProvider.notifier).navigateTo(NavScreen.uploadData);
		}
	}

	Future<void> _goToQRCode() async {
		await _saveCurrentMatch();
		await _saveLastScoutAction('qr');
		// TODO: Show QR code dialog
		// For now, just show a snackbar
		if (mounted) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('QR Code feature coming soon')),
			);
		}
	}

	@override
	Widget build(BuildContext context) {
		ref.watch(selectedLocaleProvider);
		final scoutingData = ref.watch(scoutingDataProvider);
		final matches = ref.watch(matchListProvider);
		final fieldSide = ref.watch(selectedFieldSideProvider);

		// Read climb levels from scouting data
		final autoClimbLevel = scoutingData.getFieldValue('auto_climb_level').asInt();
		final teleClimbLevel = scoutingData.getFieldValue('tele_climb_level').asInt();

		// Determine team color from bot position (B1, B2, B3 = blue; R1, R2, R3 = red)
		final botPosition = ref.watch(selectedBotPositionProvider);
		final isBlueTeam = botPosition?.startsWith('B') ?? false;

		final featuredButton = matches.when(
			data: (m) => _getFeaturedButton(m),
			loading: () => 'next',
			error: (_, __) => 'next',
		);

		return SingleChildScrollView(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [
					// Header: Gameplay
					Padding(
						padding: const EdgeInsets.only(bottom: 16),
						child: Text(
							_translate('end_game_gameplay_header'),
							style: Theme.of(context).textTheme.headlineSmall,
						),
					),

					// Auto Climb Position (conditional: autoClimbLevel > 0)
					if (autoClimbLevel > 0) ...[
						Padding(
							padding: const EdgeInsets.only(bottom: 16),
							child: Text(
								_translate('auto_climb_legend', variables: {'TEAMNUM': widget.teamNumber ?? ''}),
								style: Theme.of(context).textTheme.titleMedium,
							),
						),
						Align(
							alignment: Alignment.centerLeft,
							child: PositionSelectorArea.forField(
								descriptor: FieldDescriptor(name: 'auto_climb_position'),
								model: scoutingData,
								provider: scoutingDataProvider,
								ref: ref,
								isBlueTeam: isBlueTeam,
								fieldSide: fieldSide,
								blueImagePath: 'assets/images/climb-area-blue.png',
								redImagePath: 'assets/images/climb-area-red.png',
								width: 209,
								height: 249,
								markerSize: 60,
							),
						),
						const SizedBox(height: 16),
					],

					// Tele Climb Position (conditional: teleClimbLevel > 0)
					if (teleClimbLevel > 0) ...[
						Padding(
							padding: const EdgeInsets.only(bottom: 16),
							child: Text(
								_translate('tele_climb_legend', variables: {'TEAMNUM': widget.teamNumber ?? ''}),
								style: Theme.of(context).textTheme.titleMedium,
							),
						),
						Align(
							alignment: Alignment.centerLeft,
							child: PositionSelectorArea.forField(
								descriptor: FieldDescriptor(name: 'tele_climb_position'),
								model: scoutingData,
								provider: scoutingDataProvider,
								ref: ref,
								isBlueTeam: isBlueTeam,
								fieldSide: fieldSide,
								blueImagePath: 'assets/images/climb-area-blue.png',
								redImagePath: 'assets/images/climb-area-red.png',
								width: 209,
								height: 249,
								markerSize: 60,
							),
						),
						const SizedBox(height: 16),
					],

					const SizedBox(height: 16),

					// Climb Method (conditional: teleClimbLevel > 1)
					if (teleClimbLevel > 1)
						Card(
							child: Padding(
								padding: const EdgeInsets.all(16),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											_translate('climb_method_legend', variables: {'TEAMNUM': widget.teamNumber ?? ''}),
											style: Theme.of(context).textTheme.titleMedium,
										),
										const SizedBox(height: 12),
										RadioButtonGroup.forField(
											descriptor: FieldDescriptor(name: 'climb_method'),
											model: scoutingData,
											ref: ref,
											provider: scoutingDataProvider,
											options: [
												RadioButtonOption(
													value: 'rungs',
													labelKey: 'climb_method_rungs',
													descKey: 'climb_method_rungs_desc',
												),
												RadioButtonOption(
													value: 'uprights',
													labelKey: 'climb_method_uprights',
													descKey: 'climb_method_uprights_desc',
												),
												RadioButtonOption(
													value: 'flip',
													labelKey: 'climb_method_flip',
													descKey: 'climb_method_flip_desc',
												),
											],
										),
									],
								),
							),
						),

					const SizedBox(height: 16),

					// Demonstrated Capabilities
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										_translate('demonstrated_capabilities', variables: {'TEAMNUM': widget.teamNumber ?? ''}),
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 12),
									DescriptorCheckboxGroup.forFields(
										object: scoutingData,
										descriptors: [
											FieldDescriptor(name: 'shoot_move', uiLabelKey: 'shoot_move_desc'),
											FieldDescriptor(name: 'shoot_collecting', uiLabelKey: 'shoot_collecting_desc'),
											FieldDescriptor(name: 'shoot_turret', uiLabelKey: 'shoot_turret_desc'),
											FieldDescriptor(name: 'shoot_climbing', uiLabelKey: 'shoot_climbing_desc'),
										],
										onChanged: (fieldName, newValue) {
											ref.read(scoutingDataProvider.notifier).update(
												scoutingData.updateField(fieldName, newValue),
											);
										},
									),
									const SizedBox(height: 16),
								],
							),
						),
					),

					const SizedBox(height: 16),

					// Fuel Strategy
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										_translate('fuel_strategy_legend', variables: {'TEAMNUM': widget.teamNumber ?? ''}),
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 12),
									RadioButtonGroup.forField(
										descriptor: FieldDescriptor(name: 'fuel_to_alliance'),
										model: scoutingData,
										ref: ref,
										provider: scoutingDataProvider,
										options: [
											RadioButtonOption(
												value: 'carried',
												labelKey: 'fuel_carried_label',
												descKey: 'fuel_carried_desc',
											),
											RadioButtonOption(
												value: 'pushed',
												labelKey: 'fuel_pushed_label',
												descKey: 'fuel_pushed_desc',
											),
											RadioButtonOption(
												value: 'passed',
												labelKey: 'fuel_passed_label',
												descKey: 'fuel_passed_desc',
											),
											RadioButtonOption(
												value: 'received',
												labelKey: 'fuel_received_label',
												descKey: 'fuel_received_desc',
											),
										],
									),
								],
							),
						),
					),

					const SizedBox(height: 16),

					// Shooting Locations
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										_translate('shooting_locations_legend', variables: {'TEAMNUM': widget.teamNumber ?? ''}),
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 12),
									Align(
										alignment: Alignment.centerLeft,
										child: PositionSelectorArea.forField(
											descriptor: FieldDescriptor(name: 'shooting_locations'),
											model: scoutingData,
											provider: scoutingDataProvider,
											ref: ref,
											isBlueTeam: isBlueTeam,
											fieldSide: fieldSide,
											blueImagePath: 'assets/images/shooting-locations-blue.png',
											redImagePath: 'assets/images/shooting-locations-red.png',
											width: 258,
											height: 400,
											markerSize: 40,
											multiSelect: true,
										),
									),
									const SizedBox(height: 12),
									Align(
										alignment: Alignment.centerLeft,
										child: FilledButton.icon(
											onPressed: () {
												// Call undo through the descriptor
												final descriptor = FieldDescriptor(name: 'shooting_locations');
												scoutingData.registerDescriptor(descriptor);
												final currentValue = scoutingData.getFieldValue(descriptor.name).asString();
												final positions = currentValue.split(' ').where((p) => p.isNotEmpty).toList();
												if (positions.isNotEmpty) {
													positions.removeLast();
													final newValue = positions.join(' ');
													print('💾 Undo: Saving shooting_locations: $newValue');
													final updated = scoutingData.updateField(descriptor.name, newValue);
													ref.read(scoutingDataProvider.notifier).update(updated);
												}
											},
											style: FilledButton.styleFrom(
												backgroundColor: AppColors.buttonBgColor,
												foregroundColor: AppColors.buttonFgColor,
											),
											icon: const Icon(Icons.undo),
											label: Text(_translate('undo_button')),
										),
									),
								],
							),
						),
					),

					const SizedBox(height: 16),

					// Bricked
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										_translate('bricked_legend', variables: {'TEAMNUM': widget.teamNumber ?? ''}),
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 12),
									RadioButtonGroup.forField(
										descriptor: FieldDescriptor(name: 'bricked'),
										model: scoutingData,
										ref: ref,
										provider: scoutingDataProvider,
										options: [
											RadioButtonOption(
												value: '',
												labelKey: 'bricked_no',
												descKey: 'bricked_no_desc',
											),
											RadioButtonOption(
												value: 'some',
												labelKey: 'bricked_some',
												descKey: 'bricked_some_desc',
											),
											RadioButtonOption(
												value: 'half',
												labelKey: 'bricked_half',
												descKey: 'bricked_half_desc',
											),
											RadioButtonOption(
												value: 'most',
												labelKey: 'bricked_most',
												descKey: 'bricked_most_desc',
											),
											RadioButtonOption(
												value: 'all',
												labelKey: 'bricked_all',
												descKey: 'bricked_all_desc',
											),
										],
									),
								],
							),
						),
					),

					const SizedBox(height: 16),

					// Defense Rating
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										_translate('defense_legend', variables: {'TEAMNUM': widget.teamNumber ?? ''}),
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 12),
									RadioButtonGroup.forField(
										descriptor: FieldDescriptor(name: 'defense'),
										model: scoutingData,
										ref: ref,
										provider: scoutingDataProvider,
										options: [
											RadioButtonOption(
												value: '',
												labelKey: 'defense_none',
												descKey: 'defense_none_desc',
											),
											RadioButtonOption(
												value: 'bad',
												labelKey: 'defense_bad',
												descKey: 'defense_bad_desc',
											),
											RadioButtonOption(
												value: 'ineffective',
												labelKey: 'defense_ineffective',
												descKey: 'defense_ineffective_desc',
											),
											RadioButtonOption(
												value: 'good',
												labelKey: 'defense_good',
												descKey: 'defense_good_desc',
											),
											RadioButtonOption(
												value: 'great',
												labelKey: 'defense_great',
												descKey: 'defense_great_desc',
											),
										],
									),
								],
							),
						),
					),

					const SizedBox(height: 16),

					// Defense Methods (conditional: defenseRating != '')
					if (scoutingData.getFieldValue('defense').asString().isNotEmpty)
						Card(
							child: Padding(
								padding: const EdgeInsets.all(16),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											_translate('defense_methods_legend', variables: {'TEAMNUM': widget.teamNumber ?? ''}),
											style: Theme.of(context).textTheme.titleMedium,
										),
										const SizedBox(height: 12),
										DescriptorCheckboxGroup.forFields(
											object: scoutingData,
											descriptors: [
												FieldDescriptor(
													name: 'defense_collected',
													uiLabelKey: 'defense_collected',
													descriptionLabelKey: 'defense_collected_desc',
												),
												FieldDescriptor(
													name: 'defense_hit',
													uiLabelKey: 'defense_hit',
													descriptionLabelKey: 'defense_hit_desc',
												),
												FieldDescriptor(
													name: 'defense_blocked',
													uiLabelKey: 'defense_blocked',
													descriptionLabelKey: 'defense_blocked_desc',
												),
												FieldDescriptor(
													name: 'defense_pinned',
													uiLabelKey: 'defense_pinned',
													descriptionLabelKey: 'defense_pinned_desc',
												),
											],
											onChanged: (fieldName, newValue) {
												ref.read(scoutingDataProvider.notifier).update(
													scoutingData.updateField(fieldName, newValue),
												);
											},
										),
									],
								),
							),
						),

					const SizedBox(height: 16),

					// Defended
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										_translate('defended_legend', variables: {'TEAMNUM': widget.teamNumber ?? ''}),
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 12),
									RadioButtonGroup.forField(
										descriptor: FieldDescriptor(name: 'defended'),
										model: scoutingData,
										ref: ref,
										provider: scoutingDataProvider,
										options: [
											RadioButtonOption(
												value: '',
												labelKey: 'defended_undefended',
												descKey: 'defended_undefended_desc',
											),
											RadioButtonOption(
												value: 'turned-tables',
												labelKey: 'defended_turned_tables',
												descKey: 'defended_turned_tables_desc',
											),
											RadioButtonOption(
												value: 'unaffected',
												labelKey: 'defended_unaffected',
												descKey: 'defended_unaffected_desc',
											),
											RadioButtonOption(
												value: 'slowed',
												labelKey: 'defended_slowed',
												descKey: 'defended_slowed_desc',
											),
											RadioButtonOption(
												value: 'slowed-greatly',
												labelKey: 'defended_slowed_greatly',
												descKey: 'defended_slowed_greatly_desc',
											),
										],
									),
								],
							),
						),
					),

					const SizedBox(height: 16),

					// Misses
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										_translate('misses_legend', variables: {'TEAMNUM': widget.teamNumber ?? ''}),
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 12),
									RadioButtonGroup.forField(
										descriptor: FieldDescriptor(name: 'misses'),
										model: scoutingData,
										ref: ref,
										provider: scoutingDataProvider,
										options: [
											RadioButtonOption(
												value: '0_1',
												labelKey: 'misses_0_1',
											),
											RadioButtonOption(
												value: '1_10',
												labelKey: 'misses_1_10',
											),
											RadioButtonOption(
												value: '10_30',
												labelKey: 'misses_10_30',
											),
											RadioButtonOption(
												value: '30_60',
												labelKey: 'misses_30_60',
											),
											RadioButtonOption(
												value: '60_100',
												labelKey: 'misses_60_100',
											),
										],
									),
								],
							),
						),
					),

					const SizedBox(height: 16),

					// Scouter Info Header
					Padding(
						padding: const EdgeInsets.only(bottom: 16),
						child: Text(
							_translate('scouter_header'),
							style: Theme.of(context).textTheme.headlineSmall,
						),
					),

					// Scouter Info Card
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										_translate('review_requested_legend'),
										style: const TextStyle(
											fontSize: 14,
											fontStyle: FontStyle.italic,
											color: Colors.grey,
										),
									),
									const SizedBox(height: 8),
									CheckboxButton.forField(
										descriptor: FieldDescriptor(
											name: 'review_requested',
											uiLabelKey: 'review_requested_button',
										),
										model: scoutingData,
										ref: ref,
										provider: scoutingDataProvider,
									),
									const SizedBox(height: 16),
									DescriptorTextField.forField(
										descriptor: FieldDescriptor(
											name: 'scouter',
											uiLabelKey: 'scouter_name_question',
										),
										model: scoutingData,
										ref: ref,
										provider: scoutingDataProvider,
										maxLength: 32,
									),
									const SizedBox(height: 16),
									DescriptorTextArea.forField(
										descriptor: FieldDescriptor(
											name: 'comments',
											uiLabelKey: 'comments_question',
										),
										model: scoutingData,
										ref: ref,
										provider: scoutingDataProvider,
										minLines: 3,
										maxLines: 5,
									),
								],
							),
						),
					),

					const SizedBox(height: 24),

					// Done Buttons
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.stretch,
								children: [
									Text(
										_translate('save_data_question'),
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 16),
									// Featured button
									if (featuredButton == 'next')
										FilledButton(
											onPressed: _goToNextMatch,
											child: Text(_translate('next_match_button')),
										)
									else if (featuredButton == 'upload')
										FilledButton(
											onPressed: _goToUpload,
											child: Text(_translate('upload_data_button')),
										)
									else if (featuredButton == 'qr')
										FilledButton(
											onPressed: _goToQRCode,
											child: Text(_translate('qr_code_button')),
										),
									const SizedBox(height: 12),
									// Other buttons (smaller)
									Row(
										children: [
											if (featuredButton != 'next')
												Expanded(
													child: OutlinedButton(
														onPressed: _goToNextMatch,
														child: Text(_translate('next_match_button')),
													),
												),
											if (featuredButton != 'next') const SizedBox(width: 8),
											if (featuredButton != 'upload')
												Expanded(
													child: OutlinedButton(
														onPressed: _goToUpload,
														child: Text(_translate('upload_data_button')),
													),
												),
											if (featuredButton != 'upload') const SizedBox(width: 8),
											if (featuredButton != 'qr')
												Expanded(
													child: OutlinedButton(
														onPressed: _goToQRCode,
														child: Text(_translate('qr_code_button')),
													),
												),
										],
									),
								],
							),
						),
					),
				],
			),
		);
	}
}
