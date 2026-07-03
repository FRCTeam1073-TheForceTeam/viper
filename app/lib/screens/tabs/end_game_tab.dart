import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/app_providers.dart';
import '../../providers/end_game_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auto_tab_controller.dart';
import '../../providers/tele_tab_controller.dart';
import '../../providers/timeline_provider.dart';
import '../../services/localization.dart';
import '../../services/csv_builder.dart';
import '../../widgets/checkbox_button.dart';
import '../../widgets/checkbox_button_group.dart';
import '../../widgets/radio_button_group.dart';
import '../../constants/colors.dart';
import '../../models/match_model.dart';

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
	late TextEditingController _scouterNameController;
	late TextEditingController _commentsController;
	String? _lastScoutAction;

	String _translate(String key, {Map<String, String>? variables}) {
		final locale = ref.read(selectedLocaleProvider);
		return AppLocalizations.translate(key, locale: locale, variables: variables);
	}

	@override
	void initState() {
		super.initState();
		_scouterNameController = TextEditingController();
		_commentsController = TextEditingController();

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
				'en': 'Request Review',
				'es': 'Solicitar Revisión',
				'pt': 'Solicitar Revisão',
				'fr': 'Demander Examen',
				'zh_tw': '要求審查',
				'he': 'בקש סקירה',
				'tr': 'İnceleme İste',
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

	void _handleClimbPositionTap(TapDownDetails details, String climbType, BuildContext context, GlobalKey mapKey) {
		if (mapKey.currentContext == null) {
			print('❌ Climb position tap: mapKey.currentContext is null');
			return;
		}

		try {
			final RenderBox renderBox = mapKey.currentContext!.findRenderObject() as RenderBox;
			final size = renderBox.size;
			final localPosition = renderBox.globalToLocal(details.globalPosition);

			// Convert tap position to percent coordinates (1-99, to avoid edges)
			final px = ((localPosition.dx / size.width) * 100).clamp(1.0, 99.0).toInt();
			final py = ((localPosition.dy / size.height) * 100).clamp(1.0, 99.0).toInt();
			final positionStr = '${px}x$py';

			print('✅ Climb position tap: $climbType = $positionStr (global: ${details.globalPosition}, local: ${localPosition})');

			// Update endGameProvider with the position
			final endGame = ref.read(endGameProvider);
			if (climbType == 'auto') {
				ref.read(endGameProvider.notifier).update(
					endGame.copyWith(autoClimbPosition: positionStr),
				);
				print('   Updated autoClimbPosition to: $positionStr');
			} else if (climbType == 'tele') {
				ref.read(endGameProvider.notifier).update(
					endGame.copyWith(teleClimbPosition: positionStr),
				);
				print('   Updated teleClimbPosition to: $positionStr');
			}
		} catch (e, stackTrace) {
			print('❌ Error in climb position tap: $e');
			print(stackTrace);
		}
	}

	Widget _buildClimbPositionMap({
		required String title,
		required String climbType,
		required String position,
		required String imagePath,
		required BuildContext context,
	}) {
		final mapKey = GlobalKey();
		final isBlueTeam = widget.teamNumber?.startsWith('B') ?? false;

		return Card(
			child: Padding(
				padding: const EdgeInsets.all(16),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Text(
							_translate(title, variables: {'TEAMNUM': widget.teamNumber ?? ''}),
							style: Theme.of(context).textTheme.titleMedium,
						),
						const SizedBox(height: 12),
						GestureDetector(
							onTapDown: (details) => _handleClimbPositionTap(details, climbType, context, mapKey),
							child: LayoutBuilder(
								builder: (context, constraints) {
									return Container(
										key: mapKey,
										height: 250,
										width: constraints.maxWidth,
										decoration: BoxDecoration(
											border: Border.all(color: AppColors.mainBorderColor),
											borderRadius: BorderRadius.circular(8),
										),
										child: Stack(
											children: [
												Image.asset(
													imagePath,
													fit: BoxFit.contain,
													width: double.infinity,
													height: double.infinity,
												),
												if (position.isNotEmpty)
													_buildPositionMarker(position, isBlueTeam, constraints.maxWidth),
											],
										),
									);
								},
							),
						),
						if (position.isNotEmpty)
							Padding(
								padding: const EdgeInsets.only(top: 8),
								child: Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										Text('Position: $position', style: const TextStyle(fontWeight: FontWeight.bold)),
										OutlinedButton(
											onPressed: () {
												final endGame = ref.read(endGameProvider);
												if (climbType == 'auto') {
													ref.read(endGameProvider.notifier).update(
														endGame.copyWith(autoClimbPosition: null),
													);
												} else if (climbType == 'tele') {
													ref.read(endGameProvider.notifier).update(
														endGame.copyWith(teleClimbPosition: null),
													);
												}
											},
											child: const Text('Clear'),
										),
									],
								),
							),
					],
				),
			),
		);
	}

	Widget _buildPositionMarker(String? position, bool isBlueTeam, double containerWidth) {
		if (position == null || position.isEmpty) return const SizedBox.shrink();
		// Parse position string "XxY" to get percent coordinates
		final parts = position.toLowerCase().split('x');
		if (parts.length != 2) return const SizedBox.shrink();

		final px = double.tryParse(parts[0]) ?? 50;
		final py = double.tryParse(parts[1]) ?? 50;

		return Positioned(
			left: (px / 100) * containerWidth - 30,  // Center the marker (60px wide)
			top: (py / 100) * 250 - 30,   // Center the marker (60px tall)
			child: Container(
				width: 60,
				height: 60,
				decoration: BoxDecoration(
					border: Border.all(
						color: isBlueTeam ? AppColors.blueTeamColor : AppColors.redTeamColor,
						width: 3,
					),
					color: Colors.grey[600],
					borderRadius: BorderRadius.circular(3),
				),
			),
		);
	}

	@override
	void dispose() {
		_scouterNameController.dispose();
		_commentsController.dispose();
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
			final endGame = ref.read(endGameProvider);
			final autoState = ref.read(autoTabControllerProvider);
			final teleState = ref.read(teleTabControllerProvider);
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

			// Add auto and tele tab data
			scoutDataMap.addAll(autoState.toMap());
			scoutDataMap.addAll(teleState.toMap());

			// Add timeline once (shared between auto and tele)
			scoutDataMap['timeline'] = TimelineEvent.formatTimeline(timeline);

			// Add end game fields (matching 2026 web app schema)
			scoutDataMap.addAll(endGame.toMap());

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
			ref.read(autoTabControllerProvider.notifier).reset();
			ref.read(teleTabControllerProvider.notifier).reset();
			ref.read(endGameProvider.notifier).reset();
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
		final endGame = ref.watch(endGameProvider);
		final matches = ref.watch(matchListProvider);
		final autoState = ref.watch(autoTabControllerProvider);
		final teleState = ref.watch(teleTabControllerProvider);

		// Sync text controllers with endGame values
		_scouterNameController.text = endGame.scouterName ?? '';
		_commentsController.text = endGame.comments ?? '';

		// Read climb levels from auto and tele tab state
		final autoClimbLevel = autoState.climbLevel;
		final teleClimbLevel = teleState.climbLevel;

		final isBlueTeam = widget.teamNumber?.startsWith('B') ?? false;
		final climbAreaImage = isBlueTeam
			? 'assets/images/climb-area-blue.png'
			: 'assets/images/climb-area-red.png';

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
					if (autoClimbLevel > 0)
						_buildClimbPositionMap(
							title: 'auto_climb_legend',
							climbType: 'auto',
							position: endGame.autoClimbPosition ?? '',
							imagePath: climbAreaImage,
							context: context,
						),

					const SizedBox(height: 16),

					// Tele Climb Position (conditional: teleClimbLevel > 0)
					if (teleClimbLevel > 0)
						_buildClimbPositionMap(
							title: 'tele_climb_legend',
							climbType: 'tele',
							position: endGame.teleClimbPosition ?? '',
							imagePath: climbAreaImage,
							context: context,
						),

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
										RadioButtonGroup(
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
											selectedValue: endGame.climbMethod,
											onChanged: (value) {
												ref.read(endGameProvider.notifier).update(
													endGame.copyWith(climbMethod: value),
												);
											},
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
									CheckboxButtonGroup(
										options: const [
											CheckboxButtonOption(translationKey: 'shoot_move_desc'),
											CheckboxButtonOption(translationKey: 'shoot_collecting_desc'),
											CheckboxButtonOption(translationKey: 'shoot_turret_desc'),
											CheckboxButtonOption(translationKey: 'shoot_climbing_desc'),
										],
										selectedValues: [
											endGame.shootOnMove,
											endGame.shootWhileCollecting,
											endGame.shootTurret,
											endGame.shootClimbing,
										],
										onChanged: (index) {
											switch (index) {
												case 0:
													ref.read(endGameProvider.notifier).update(
														endGame.copyWith(shootOnMove: !endGame.shootOnMove),
													);
													break;
												case 1:
													ref.read(endGameProvider.notifier).update(
														endGame.copyWith(shootWhileCollecting: !endGame.shootWhileCollecting),
													);
													break;
												case 2:
													ref.read(endGameProvider.notifier).update(
														endGame.copyWith(shootTurret: !endGame.shootTurret),
													);
													break;
												case 3:
													ref.read(endGameProvider.notifier).update(
														endGame.copyWith(shootClimbing: !endGame.shootClimbing),
													);
													break;
											}
										},
									),
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
									RadioButtonGroup(
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
										selectedValue: endGame.fuelStrategy,
										onChanged: (value) {
											ref.read(endGameProvider.notifier).update(
												endGame.copyWith(fuelStrategy: value),
											);
										},
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
									RadioButtonGroup(
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
										selectedValue: endGame.bricked,
										onChanged: (value) {
											ref.read(endGameProvider.notifier).update(
												endGame.copyWith(bricked: value),
											);
										},
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
									RadioButtonGroup(
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
										selectedValue: endGame.defenseRating,
										onChanged: (value) {
											ref.read(endGameProvider.notifier).update(
												endGame.copyWith(defenseRating: value),
											);
										},
									),
								],
							),
						),
					),

					const SizedBox(height: 16),

					// Defense Methods (conditional: defenseRating != '')
					if (endGame.defenseRating != null && endGame.defenseRating != '')
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
										CheckboxButtonGroup(
											options: const [
												CheckboxButtonOption(translationKey: 'defense_collected_desc'),
												CheckboxButtonOption(translationKey: 'defense_hit_desc'),
												CheckboxButtonOption(translationKey: 'defense_blocked_desc'),
												CheckboxButtonOption(translationKey: 'defense_pinned_desc'),
											],
											selectedValues: [
												endGame.defenseCollected,
												endGame.defenseHit,
												endGame.defenseBlocked,
												endGame.defensePinned,
											],
											onChanged: (index) {
												switch (index) {
													case 0:
														ref.read(endGameProvider.notifier).update(
															endGame.copyWith(defenseCollected: !endGame.defenseCollected),
														);
														break;
													case 1:
														ref.read(endGameProvider.notifier).update(
															endGame.copyWith(defenseHit: !endGame.defenseHit),
														);
														break;
													case 2:
														ref.read(endGameProvider.notifier).update(
															endGame.copyWith(defenseBlocked: !endGame.defenseBlocked),
														);
														break;
													case 3:
														ref.read(endGameProvider.notifier).update(
															endGame.copyWith(defensePinned: !endGame.defensePinned),
														);
														break;
												}
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
									RadioButtonGroup(
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
										selectedValue: endGame.defended,
										onChanged: (value) {
											ref.read(endGameProvider.notifier).update(
												endGame.copyWith(defended: value),
											);
										},
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
									RadioButtonGroup(
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
										selectedValue: endGame.misses,
										onChanged: (value) {
											ref.read(endGameProvider.notifier).update(
												endGame.copyWith(misses: value),
											);
										},
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
									CheckboxButton(
										isChecked: endGame.reviewRequest,
										translationKey: 'review_requested_button',
										onChanged: (value) {
											ref.read(endGameProvider.notifier).update(
												endGame.copyWith(reviewRequest: value == 1),
											);
										},
									),
									const SizedBox(height: 16),
									TextField(
										controller: _scouterNameController,
										decoration: InputDecoration(
											labelText: _translate('scouter_name_question'),
											border: const OutlineInputBorder(),
										),
										maxLength: 32,
										onChanged: (value) {
											ref.read(endGameProvider.notifier).update(
												endGame.copyWith(scouterName: value),
											);
										},
									),
									const SizedBox(height: 16),
									TextField(
										controller: _commentsController,
										decoration: InputDecoration(
											labelText: _translate('comments_question'),
											border: const OutlineInputBorder(),
										),
										maxLines: 5,
										minLines: 3,
										onChanged: (value) {
											ref.read(endGameProvider.notifier).update(
												endGame.copyWith(comments: value),
											);
										},
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
