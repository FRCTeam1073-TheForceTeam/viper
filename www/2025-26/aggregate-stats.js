"use strict"

function aggregateStats(scout, aggregate, apiScores, subjective, pit){

	function bool_1_0(s){
		return (!s||/^0|no|false$/i.test(""+s))?0:1
	}
	Object.keys(statInfo).forEach(field=>{
		if(/^enum$/.test(statInfo[field].type)){
			for(var i=0;i<statInfo[field].breakout.length;i++){
				scout[statInfo[field].breakout[i]] = (scout[field]||'')==statInfo[field].values[i]?1:0
			}
		}
	})
	Object.keys(statInfo).forEach(field=>{
		if(/^\%$/.test(statInfo[field].type)){
			scout[field] = bool_1_0(scout[field])
			aggregate[field] = aggregate[field]||0
		}
		if(/^(avg|count)$/.test(statInfo[field].type)){
			scout[field] = scout[field]||0
			aggregate[field] = aggregate[field]||0
		}
	})

	scout.auto_artifact=scout.auto_goal+scout.auto_depot
	scout.tele_artifact=scout.tele_goal+scout.tele_depot
	scout.artifact=scout.auto_artifact+scout.tele_artifact

	scout.gate=scout.auto_gate+scout.tele_gate
	scout.depot=scout.auto_depot+scout.tele_depot
	scout.goal=scout.auto_goal+scout.tele_goal
	scout.patterns=Math.min(scout.auto_patterns_obelisk+scout.tele_patterns,1)
	scout.base_return_both=scout.base_return_above+scout.base_return_under
	scout.base_return_fully=scout.base_return_both+scout.base_return_alone

	Object.keys(statInfo).forEach(field=>{
		if(/^(\%|avg|count)$/.test(statInfo[field].type)){
			aggregate[field] = (aggregate[field]||0)+scout[field]
			var set = `${field}_set`
			aggregate[set] = aggregate[set]||[]
			aggregate[set].push(scout[field])
		}
		if(/^text|enum$/.test(statInfo[field].type)) aggregate[field] = (!aggregate[field]||aggregate[field]==scout[field])?scout[field]:"various"
	})
	aggregate.count = (aggregate.count||0)+1
}

var statInfo = {
	match:{
		en: "Match",
		type: "text",
		zh_tw:'比賽',
		he:'משחק',
		tr:'Maç',
		fr:'Match',
		pt:'Partida',
	},
	team:{
		en: "Team",
		type: "text",
		zh_tw:'隊伍',
		he:'קבוצה',
		tr:'Takım',
		fr:'Équipe',
		pt:'Equipe',
	},
	comments:{
		en: "Comments",
		type: "text",
		zh_tw:'評論',
		he:'תגובות',
		tr:'Yorumlar',
		fr:'Commentaires',
		pt:'Comentários',
	},
	created:{
		en: "Created",
		type: "datetime",
		zh_tw:'已創建',
		he:'נוצר',
		tr:'Oluşturuldu',
		fr:'Créé',
		pt:'Criado',
	},
	modified:{
		en: "Modified",
		type: "datetime",
		zh_tw:'已修改',
		he:'שונה',
		tr:'Değiştirildi',
		fr:'Modifié',
		pt:'Modificado',
	},
	scouter:{
		en: "Scouter",
		type: "text",
		zh_tw:'偵察兵',
		he:'סקאוטר',
		tr:'Scouter',
		fr:'Animateur',
		pt:'Scouter',
	},
	timeline:{
		en: "Timeline",
		type: "timeline",
		zh_tw:'時間軸',
		he:'ציר זמן',
		tr:'Zaman Çizelgesi',
		fr:'Chronologie',
		pt:'Linha do Tempo',
	},
	count:{
		en: 'Count',
		type: 'avg',
		zh_tw:'計數',
		he:'ספירה',
		tr:'Sayı',
		fr:'Nombre',
		pt:'Contagem',
	},
	artifact:{
		en: 'Artifact',
		type: 'avg',
		zh_tw:'神器',
		he:'ארטיפקט',
		tr:'Eser',
		fr:'Artefact',
		pt:'Artefato',
	},
	auto_artifact:{
		en: 'Artifact in Auto',
		type: 'avg',
		zh_tw:'自動神器',
		he:'ארטיפקט באוטו',
		tr:'Otomatikte Eser',
		fr:'Artefact en mode automatique',
		pt:'Artefacto em Automático',
	},
	auto_depot:{
		en: 'Depot in Auto',
		type: 'avg',
		zh_tw:'自動倉庫',
		he:'מחסן באוטו',
		tr:'Otomatikte Depo',
		fr:'Dépôt en mode automatique',
		pt:'Depósito em Automático',
	},
	auto_gate:{
		en: 'Gate in Auto',
		type: 'avg',
		zh_tw:'自動門',
		he:'שער באוטו',
		tr:'Otomatikte Kapı',
		fr:'Porte en mode automatique',
		pt:'Portão em Automático',
	},
	auto_goal:{
		en: 'Goal in Auto',
		type: 'avg',
		zh_tw:'自動目標',
		he:'גול באוטו',
		tr:'Otomatikte Gol',
		fr:'But en mode automatique',
		pt:'Gol em Automático',
	},
	auto_patterns:{
		en: 'Patterns in Auto',
		type: 'enum',
		zh_tw:'自動圖案',
		he:'דפוסים באוטו',
		tr:'Otomatikte Desenler',
		fr:'Motifs en mode automatique',
		pt:'Padrões em Automático',
		values:["","obelisk","purple"],
		breakout:["auto_patterns_none","auto_patterns_obelisk","auto_patterns_purple"],
	},
	auto_patterns_none:{
		en: 'Patterns None in Auto',
		type: '%',
		zh_tw:'自動圖案無',
		he:'דפוסים ללא באוטו',
		tr:'Otomatikte Desen Yok',
		fr:'Aucun motif en mode automatique',
		pt:'Padrões Nenhum em Automático',
	},
	auto_patterns_obelisk:{
		en: 'Patterns Obelisk in Auto',
		type: '%',
		zh_tw:'自動方尖碑圖案',
		he:'דפוסים אובליסק באוטו',
		tr:'Otomatikte Dikilitaş Desenleri',
		fr:'Motifs Obélisque en mode automatique',
		pt:'Padrões Obelisco em Automático',
	},
	auto_patterns_purple:{
		en: 'Patterns Purple in Auto',
		type: '%',
		zh_tw:'自動圖案紫色',
		he:'דפוסים סגולים באוטו',
		tr:'Otomatikte Mor Desenler',
		fr:'Motifs Violet en mode automatique',
		pt:'Padrões Roxo em Automático',
	},
	auto_start:{
		en: 'Start in Auto',
		type: 'enum',
		zh_tw:'自動開始',
		he:'התחלה באוטו',
		tr:'Otomatikte Başlangıç',
		fr:'Début en mode automatique',
		pt:'Início em Automático',
		values:["","goal","audience"],
		breakout:["auto_start_unknown","auto_start_goal","auto_start_audience"],
	},
	auto_start_audience:{
		en: 'Start Audience in Auto',
		type: '%',
		zh_tw:'自動開始觀眾',
		he:'קהל התחלה באוטו',
		tr:'Otomatikte Seyirci Başlangıcı',
		fr:'Début Public en mode automatique',
		pt:'Público Inicial em Automático',
	},
	auto_start_goal:{
		en: 'Start Goal in Auto',
		type: '%',
		zh_tw:'自動開始目標',
		he:'שער התחלה באוטו',
		tr:'Otomatikte Başlangıç ​​Hedefi',
		fr:'Début Objectif en mode automatique',
		pt:'Golo Inicial em Automático',
	},
	auto_start_unknown:{
		en: 'Start Unknown in Auto',
		type: '%',
		zh_tw:'自動開始未知',
		he:'התחלה לא ידוע באוטו',
		tr:'Otomatikte Başlangıç ​​Bilinmiyor',
		fr:'Début Inconnu en mode automatique',
		pt:'Início Desconhecido em Automático',
	},
	auto_took_turns:{
		en: 'Took Turns in Auto',
		type: '%',
		zh_tw:'自動輪流',
		he:'התחלפו באוטו',
		tr:'Otomatikte Sırayla',
		fr:'Tours en mode automatique',
		pt:'Revezou-se em Automático',
	},
	base_return:{
		en: 'Base Return',
		type: 'enum',
		zh_tw:'基地返回',
		he:'החזרת בסיס',
		tr:'Üs Dönüşü',
		fr:'Retour de base',
		pt:'Regresso à Base',
		values:["","partially","alone","under","above"],
		breakout:["base_return_none","base_return_partially","base_return_alone","base_return_under","base_return_above"],
	},
	base_return_above:{
		en: 'Base Return Fully Above',
		type: '%',
		zh_tw:'基地完全高於',
		he:'החזרת בסיס מעל לחלוטין',
		tr:'Üs Dönüşü Tamamen Yukarıda',
		fr:'Retour de base complètement au-dessus',
		pt:'Regresso à Base Totalmente Acima',
	},
	base_return_alone:{
		en: 'Base Return Fully Alone',
		type: '%',
		zh_tw:'基地完全單獨返回',
		he:'החזרת בסיס לבד לחלוטין',
		tr:'Üs Dönüşü Tamamen Tek Başına',
		fr:'Retour de base complètement seul',
		pt:'Regresso à Base Totalmente Sozinho',
	},
	base_return_both:{
		en: 'Base Return Fully Both',
		type: '%',
		zh_tw:'基地完全同時返回',
		he:'החזרת בסיס שניהם לחלוטין',
		tr:'Üs Dönüşü Tamamen İkisi Birlikte',
		fr:'Retour de base complètement les deux',
		pt:'Regresso à Base Totalmente Ambos',
	},
	base_return_fully:{
		en: 'Base Return Fully',
		type: '%',
		zh_tw:'基地完全返回',
		he:'החזרת בסיס מלאה',
		tr:'Üs Dönüşü Tamamen',
		fr:'Retour de base complètement',
		pt:'Regresso à Base Totalmente',
	},
	base_return_none:{
		en: 'Base Return None',
		type: '%',
		zh_tw:'基地無返回',
		he:'החזרת בסיס ללא',
		tr:'Üs Dönüşü Yok',
		fr:'Retour de base aucun',
		pt:'Regresso à Base Nenhum',
	},
	base_return_partially:{
		en: 'Base Return Partially',
		type: '%',
		zh_tw:'基地部分返回',
		he:'החזרת בסיס חלקית',
		tr:'Üs Dönüşü Kısmen',
		fr:'Retour de base partiellement',
		pt:'Regresso à Base Parcialmente',
	},
	base_return_under:{
		en: 'Base Return Fully Under',
		type: '%',
		zh_tw:'基地完全低於',
		he:'החזרת בסיס מתחת לחלוטין',
		tr:'Üs Dönüşü Tamamen Altında',
		fr:'Retour de base complètement en dessous',
		pt:'Regresso à Base Totalmente Abaixo',
	},
	depot:{
		en: 'Depot',
		type: 'avg',
		zh_tw:'倉庫',
		he:'מחסן',
		tr:'Depo',
		fr:'Dépôt',
		pt:'Depósito',
	},
	gate:{
		en: 'Gate',
		type: 'avg',
		zh_tw:'門',
		he:'שער',
		tr:'Kapı',
		fr:'Porte',
		pt:'Portão',
	},
	goal:{
		en: 'Goal',
		type: 'avg',
		zh_tw:'目標',
		he:'גול',
		tr:'Gol',
		fr:'But',
		pt:'Gol',
	},
	event:{
		en: 'Event',
		type: '%',
		zh_tw:'事件',
		he:'אירוע',
		tr:'Etkinlik',
		fr:'Événement',
		pt:'Evento',
	},
	no_show:{
		en: 'No Show',
		type: '%',
		zh_tw:'未出現',
		he:'אי הופעה',
		tr:'Gelmedi',
		fr:'Absence',
		pt:'Não Comparecimento',
	},
	patterns:{
		en: 'Patterns',
		type: '%',
		zh_tw:'圖案',
		he:'דפוסים',
		tr:'Desenler',
		fr:'Motifs',
		pt:'Padrões',
	},
	tele_artifact:{
		en: 'Artifact in Teleop',
		type: 'avg',
		zh_tw:'遠端操作神器',
		he:'ארטיפקט בטלה',
		tr:'Teleop\'ta Eser',
		fr:'Artefact en mode téléop.',
		pt:'Artefacto em Teleoperação',
	},
	tele_depot:{
		en: 'Depot in Teleop',
		type: 'avg',
		zh_tw:'遠端操作倉庫',
		he:'מחסן בטלה',
		tr:'Teleop\'ta Depo',
		fr:'Dépôt en mode téléop.',
		pt:'Depósito em Teleoperação',
	},
	tele_gate:{
		en: 'Gate in Teleop',
		type: 'avg',
		zh_tw:'遠端門',
		he:'שער בטלה',
		tr:'Kapıda Teleop',
		fr:'Porte en mode téléop.',
		pt:'Portão em Teleoperação',
	},
	tele_goal:{
		en: 'Goal in Teleop',
		type: 'avg',
		zh_tw:'遠端目標',
		he:'גול בטלה',
		tr:'Teleop\'ta Hedef',
		fr:'But en Téléopération',
		pt:'Gol em Teleop',
	},
	tele_patterns:{
		en: 'Patterns in Teleop',
		type: '%',
		zh_tw:'圖案Teleop',
		he:'דפוסים ב טלהופ',
		tr:'Teleop\'ta Desenler',
		fr:'Motifs dans Téléopération',
		pt:'Padrões em Teleop',
	},
}

var teamGraphs = {
	"Artifacts":{
		graph:"stacked",
		zh_tw:'神器',
		he:'חפצים',
		tr:'Artefaktlar',
		fr:'Artefacts',
		pt:'Artefatos',
		data:["goal",'depot']
	},
	"Match Stages":{
		graph:"stacked",
		zh_tw:'比賽階段',
		he:'שלבי משחק',
		tr:'Maç Aşamaları',
		fr:'Étapes du match',
		pt:'Fases da Partida',
		data:["auto_artifact","tele_artifact"]
	},
	"End Game":{
		graph:"bar",
		zh_tw:'遊戲結束',
		he:'סיום משחק',
		tr:'Oyun Sonu',
		fr:'Fin de partie',
		pt:'Final de Jogo',
		data:["base_return_none","base_return_partially","base_return_alone","base_return_under","base_return_above"]
	},
}

var aggregateGraphs = {
	"Artifacts":{
		graph:"boxplot",
		zh_tw:'神器',
		he:'חפצים',
		tr:'Artefaktlar',
		fr:'Artefacts',
		pt:'Artefatos',
		data:["artifact"]
	},
	"Match Stages":{
		graph:"stacked",
		zh_tw:'比賽階段',
		he:'שלבי משחק',
		tr:'Maç Aşamaları',
		fr:'Étapes du match',
		pt:'Fases da Partida',
		data:["auto_artifact","tele_artifact"]
	},
	"End Game":{
		graph:"bar",
		zh_tw:'遊戲結束',
		he:'סיום משחק',
		tr:'Oyun Sonu',
		fr:'Fin de partie',
		pt:'Final de Jogo',
		data:["base_return_none","base_return_partially","base_return_alone","base_return_under","base_return_above"]
	},
}

var matchPredictorSections = {
	Total:{
		tr:'Total',
		he:'סַך הַכֹּל',
		zh_tw:'全部的',
		pt:'Total',
		fr:'Total',
		data:["artifacts"],
	},
}

var whiteboardStats = [
	"artifacts",
]

// Whiteboard image from https://www.reddit.com/r/FTC/comments/1nalob0/decode_custom_field_images_meepmeep_compatible/
var whiteboardStamps = []

var whiteboardOverlays = []
