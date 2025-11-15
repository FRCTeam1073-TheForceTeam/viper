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

	var pointValues={
		leave: 3,
		classified: 3,
		overflow: 1,
		depot: 1,
		motif: 2,
		return_partially: 5,
		return_fully: 10,
		return_both_fully: 15,
	},
	ramp_size=9,
	half_ramp=ramp_size/2

	scout.auto_artifact=scout.auto_goal+scout.auto_depot
	scout.tele_artifact=scout.tele_goal+scout.tele_depot
	scout.artifact=scout.auto_artifact+scout.tele_artifact

	scout.gate=scout.auto_gate+scout.tele_gate
	scout.depot=scout.auto_depot+scout.tele_depot
	scout.goal=scout.auto_goal+scout.tele_goal
	scout.base_return_both=scout.base_return_above+scout.base_return_under
	scout.base_return_fully=scout.base_return_both+scout.base_return_alone

	// Scores are all estimates based on heuristics
	// Not collecting enough scouting data to be precise
	scout.auto_classified=Math.round(Math.min(scout.auto_goal,((scout.auto_gate+1)*half_ramp)))
	scout.auto_overflow=scout.auto_goal-scout.auto_classified
	scout.auto_motif=Math.round(Math.min(scout.auto_classified,half_ramp)*(scout.auto_patterns_obelisk?1:(scout.auto_patterns_purple?(2/3):(1/3))))
	scout.tele_classified=Math.round(Math.min(scout.tele_goal,((scout.tele_gate)*half_ramp)))
	scout.tele_overflow=scout.tele_goal-scout.tele_classified
	scout.tele_motif=Math.round(Math.min(scout.tele_classified,half_ramp)*(scout.tele_patterns?1:(1/3)))

	scout.auto_leave_score=pointValues.leave*scout.auto_leave
	scout.auto_classified_score=pointValues.classified*scout.auto_classified
	scout.auto_overflow_score=pointValues.overflow*scout.auto_overflow
	scout.auto_depot_score=pointValues.depot*scout.auto_depot
	scout.auto_motif_score=pointValues.motif*scout.auto_motif

	scout.tele_classified_score=pointValues.classified*scout.tele_classified
	scout.tele_overflow_score=pointValues.overflow*scout.tele_overflow
	scout.tele_depot_score=pointValues.depot*scout.tele_depot
	scout.tele_motif_score=pointValues.motif*scout.tele_motif

	scout.classified_score=scout.auto_classified_score+scout.tele_classified_score
	scout.overflow_score=scout.auto_overflow_score+scout.tele_overflow_score
	scout.depot_score=scout.auto_depot_score+scout.tele_depot_score
	scout.motif_score=scout.auto_motif_score+scout.tele_motif_score

	scout.auto_score=scout.auto_leave_score+scout.auto_classified_score+scout.auto_overflow_score+scout.auto_depot_score+scout.auto_motif_score
	scout.tele_score=scout.tele_classified_score+scout.tele_overflow_score+scout.tele_depot_score+scout.tele_motif_score
	scout.base_return_score=scout.base_return_both?pointValues.return_both_fully:(scout.base_return_alone?pointValues.return_fully:(scout.base_return_partially?pointValues.return_partially:0))
	scout.score=scout.auto_score+scout.tele_score+scout.base_return_score

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
	auto_leave:{
		en:'Left Starting Line',
		type: '%',
		zh_tw:'自動離開起始線',
		he:'עזב את קו ההתחלה',
		tr:'Otomatikte Başlangıç Çizgisinden Ayrıldı',
		fr:'A quitté la ligne de départ',
		pt:'Saiu da linha de partida',
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
	auto_preset_1:{
		en: 'Preset 1 in Auto',
		type: '%'
	},
	auto_preset_2:{
		en: 'Preset 2 in Auto',
		type: '%'
	},
	auto_preset_3:{
		en: 'Preset 3 in Auto',
		type: '%'
	},
	auto_preset_4:{
		en: 'Preset 4 in Auto',
		type: '%'
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
	auto_classified:{
		en: 'Classified in Auto (Estimated)',
		fr:'Classifié en Auto (Estimé)',
		he:'סווג באוטו (מוערך)',
		pt:'Classificado em Automático (Estimado)',
		tr:'Otomatikte Sınıflandırıldı (Tahmini)',
		zh_tw:'自動分類（估計）',
		type: 'avg'
	},
	auto_classified_score:{
		en: 'Classified Score in Auto (Estimated)',
		fr:'Score classifié en Auto (Estimé)',
		he:'ציון סיווג באוטו (מוערך)',
		pt:'Pontuação Classificada em Automático (Estimado)',
		tr:'Otomatikte Sınıflandırma Puanı (Tahmini)',
		zh_tw:'自動分類得分（估計）',
		type: 'avg'
	},
	auto_depot_score:{
		en: 'Depot Score in Auto (Estimated)',
		fr:'Score du dépôt en Auto (Estimé)',
		he:'ציון מחסן באוטו (מוערך)',
		pt:'Pontuação do Depósito em Automático (Estimado)',
		tr:'Otomatikte Depo Puanı (Tahmini)',
		zh_tw:'自動倉庫得分（估計）',
		type: 'avg'
	},
	auto_leave_score:{
		en: 'Leave Score in Auto (Estimated)',
		fr:'Score de départ en Auto (Estimé)',
		he:'ציון עזיבה באוטו (מוערך)',
		pt:'Pontuação de Saída em Automático (Estimado)',
		tr:'Otomatikte Ayrılma Puanı (Tahmini)',
		zh_tw:'自動離開得分（估計）',
		type: 'avg'
	},
	auto_motif:{
		en: 'Motif in Auto (Estimated)',
		fr:'Motif en Auto (Estimé)',
		he:'דפוס באוטו (מוערך)',
		pt:'Motivo em Automático (Estimado)',
		tr:'Otomatikte Motif (Tahmini)',
		zh_tw:'自動圖案（估計）',
		type: 'avg'
	},
	auto_motif_score:{
		en: 'Motif Score in Auto (Estimated)',
		fr:'Score du motif en Auto (Estimé)',
		he:'ציון דפוס באוטו (מוערך)',
		pt:'Pontuação do Motivo em Automático (Estimado)',
		tr:'Otomatikte Motif Puanı (Tahmini)',
		zh_tw:'自動圖案得分（估計）',
		type: 'avg'
	},
	auto_overflow:{
		en: 'Overflow in Auto (Estimated)',
		fr:'Débordement en Auto (Estimé)',
		he:'עודף באוטו (מוערך)',
		pt:'Excesso em Automático (Estimado)',
		tr:'Otomatikte Taşma (Tahmini)',
		zh_tw:'自動溢出（估計）',
		type: '%'
	},
	auto_overflow_score:{
		en: 'Overflow Score in Auto (Estimated)',
		fr:'Score de débordement en Auto (Estimé)',
		he:'ציון עודף באוטו (מוערך)',
		pt:'Pontuação de Excesso em Automático (Estimado)',
		tr:'Otomatikte Taşma Puanı (Tahmini)',
		zh_tw:'自動溢出得分（估計）',
		type: 'avg'
	},
	auto_score:{
		en: 'Score in Auto (Estimated)',
		fr:'Score en Auto (Estimé)',
		he:'ציון באוטו (מוערך)',
		pt:'Pontuação em Automático (Estimado)',
		tr:'Otomatikte Puan (Tahmini)',
		zh_tw:'自動得分（估計）',
		type: 'avg'
	},
	base_return_score:{
		en: 'Base Return Score (Estimated)',
		zh_tw:'基地返回得分（估計）',
		he:'ציון החזרת בסיס (מוערך)',
		tr:'Üs Dönüşü Puanı (Tahmini)',
		fr:'Score de retour de base (Estimé)',
		pt:'Pontuação de Regresso à Base (Estimado)',
		type: 'avg'
	},
	classified_score:{
		en: 'Classified Score (Estimated)',
		fr:'Score classifié (Estimé)',
		he:'ציון סיווג (מוערך)',
		pt:'Pontuação Classificada (Estimada)',
		tr:'Sınıflandırma Puanı (Tahmini)',
		zh_tw:'分類得分（估計）',
		type: 'avg'
	},
	depot_score:{
		en: 'Depot Score (Estimated)',
		fr:'Score du dépôt (Estimé)',
		he:'ציון מחסן (מוערך)',
		pt:'Pontuação do Depósito (Estimada)',
		tr:'Depo Puanı (Tahmini)',
		zh_tw:'倉庫得分（估計）',
		type: 'avg'
	},
	motif_score:{
		en: 'Motif Score (Estimated)',
		fr:'Score du motif (Estimé)',
		he:'ציון דפוס (מוערך)',
		pt:'Pontuação do Motivo (Estimada)',
		tr:'Motif Puanı (Tahmini)',
		zh_tw:'圖案得分（估計）',
		type: 'avg'
	},
	overflow_score:{
		en: 'Overflow Score (Estimated)',
		fr:'Score de débordement (Estimé)',
		he:'ציון עודף (מוערך)',
		pt:'Pontuação de Excesso (Estimada)',
		tr:'Taşma Puanı (Tahmini)',
		zh_tw:'溢出得分（估計）',
		type: 'avg'
	},
	review_requested:{
		en: 'Review Requested (Estimated)',
		fr:'Revue demandée (Estimée)',
		he:'סקירה מבקשת (מוערכת)',
		pt:'Revisão Solicitada (Estimada)',
		tr:'İnceleme Talebi (Tahmini)',
		zh_tw:'請求審查（估計）',
		type: '%'
	},
	score:{
		en: 'Score Contribution (Estimated)',
		fr:'Contribution au score (Estimée)',
		he:'תרומת ציון (מוערכת)',
		pt:'Contribuição de Pontuação (Estimada)',
		tr:'Puan Katkısı (Tahmini)',
		zh_tw:'得分貢獻（估計）',
		type: 'avg'
	},
	tele_classified:{
		en: 'Classified in Teleop (Estimated)',
		fr:'Classifié en Téléopération (Estimé)',
		he:'סווג בטלהופ (מוערך)',
		pt:'Classificado em Teleoperação (Estimado)',
		tr:'Teleop\'ta Sınıflandırıldı (Tahmini)',
		zh_tw:'遠端操作分類（估計）',
		type: 'avg'
	},
	tele_classified_score:{
		en: 'Classified Score in Teleop (Estimated)',
		fr:'Score classifié en Téléopération (Estimé)',
		he:'ציון סיווג בטלהופ (מוערך)',
		pt:'Pontuação Classificada em Teleoperação (Estimado)',
		tr:'Teleop\'ta Sınıflandırma Puanı (Tahmini)',
		zh_tw:'遠端操作分類得分（估計）',
		type: 'avg'
	},
	tele_depot_score:{
		en: 'Depot Score in Teleop (Estimated)',
		fr:'Score du dépôt en Téléopération (Estimé)',
		he:'ציון מחסן בטלהופ (מוערך)',
		pt:'Pontuação do Depósito em Teleoperação (Estimado)',
		tr:'Teleop\'ta Depo Puanı (Tahmini)',
		zh_tw:'遠端操作倉庫得分（估計）',
		type: 'avg'
	},
	tele_motif:{
		en: 'Motif in Teleop (Estimated)',
		fr:'Motif en Téléopération (Estimé)',
		he:'דפוס בטלהופ (מוערך)',
		pt:'Motivo em Teleoperação (Estimado)',
		tr:'Teleop\'ta Motif (Tahmini)',
		zh_tw:'遠端操作圖案（估計）',
		type: 'avg'
	},
	tele_motif_score:{
		en: 'Motif Score in Teleop (Estimated)',
		fr:'Score du motif en Téléopération (Estimé)',
		he:'ציון דפוס בטלהופ (מוערך)',
		pt:'Pontuação do Motivo em Teleoperação (Estimado)',
		tr:'Teleop\'ta Motif Puanı (Tahmini)',
		zh_tw:'遠端操作圖案得分（估計）',
		type: 'avg'
	},
	tele_overflow:{
		en: 'Overflow in Teleop (Estimated)',
		fr:'Débordement en Téléopération (Estimé)',
		he:'עודף בטלהופ (מוערך)',
		pt:'Excesso em Teleoperação (Estimado)',
		tr:'Teleop\'ta Taşma (Tahmini)',
		zh_tw:'遠端操作溢出（估計）',
		type: 'avg'
	},
	tele_overflow_score:{
		en: 'Overflow Score in Teleop (Estimated)',
		fr:'Score de débordement en Téléopération (Estimé)',
		he:'ציון עודף בטלהופ (מוערך)',
		pt:'Pontuação de Excesso em Teleoperação (Estimado)',
		tr:'Teleop\'ta Taşma Puanı (Tahmini)',
		zh_tw:'遠端操作溢出得分（估計）',
		type: 'avg'
	},
	tele_score:{
		en: 'Score in Teleop (Estimated)',
		fr:'Score en Téléopération (Estimé)',
		he:'ציון בטלהופ (מוערך)',
		pt:'Pontuação em Teleoperação (Estimado)',
		tr:'Teleop\'ta Puan (Tahmini)',
		zh_tw:'遠端操作得分（估計）',
		type: 'avg'
	},
}

var teamGraphs = {
	"Score Contribution":{
		graph:"stacked",
		zh_tw:'得分貢獻',
		he:'תרומת ציון',
		tr:'Puan Katkısı',
		fr:'Contribution au score',
		pt:'Contribuição de Pontuação',
		data:["auto_score","tele_score","base_return_score"]
	},
	"Artifacts":{
		graph:"stacked",
		zh_tw:'神器',
		he:'חפצים',
		tr:'Artefaktlar',
		fr:'Artefacts',
		pt:'Artefatos',
		data:["goal",'depot']
	},
	"Presets":{
		graph:"stacked",
		data:["auto_preset_1","auto_preset_2","auto_preset_3","auto_preset_4"]
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
	"Score Contribution":{
		graph:"boxplot",
		zh_tw:'得分貢獻',
		he:'תרומת ציון',
		tr:'Puan Katkısı',
		fr:'Contribution au score',
		pt:'Contribuição de Pontuação',
		data:["score"]
	},
	"Match Stages":{
		graph:"stacked",
		zh_tw:'比賽階段',
		he:'שלבי משחק',
		tr:'Maç Aşamaları',
		fr:'Étapes du match',
		data:["auto_score","tele_score","base_return_score"]
	},
	"Artifacts":{
		graph:"boxplot",
		zh_tw:'神器',
		he:'חפצים',
		tr:'Artefaktlar',
		fr:'Artefacts',
		pt:'Artefatos',
		data:["artifact"]
	},
	"Presets":{
		graph:"bar",
		data:["auto_preset_1","auto_preset_2","auto_preset_3","auto_preset_4"]
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
