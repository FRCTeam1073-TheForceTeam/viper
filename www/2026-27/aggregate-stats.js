"use strict"

function aggregateStats(scout, aggregate, apiScores, subjective, pit, eventStatsByMatchTeam, eventStatsByTeam, match){

	function bool_1_0(s){
		return (!s||/^0|no|false$/i.test(""+s))?0:1
	}

	// Form counters arrive as strings, and a counter that was never tapped is missing entirely.
	// Make every counter a number, defaulting to 0.
	var pieceFields = ['auto_collect','tele_collect','auto_cell','tele_cell','auto_garden','tele_garden','tele_flower1','tele_flower2','tele_flower3','tele_flower4']
	pieceFields.forEach(function(field){
		['_pollen','_nectar'].forEach(function(color){
			scout[field+color] = parseInt(scout[field+color])||0
		})
	})
	scout.auto_hive_tip = parseInt(scout.auto_hive_tip)||0
	scout.tele_hive_tip = parseInt(scout.tele_hive_tip)||0

	Object.keys(statInfo).forEach(function(field){
		if(/^%$/.test(statInfo[field].type)){
			scout[field] = bool_1_0(scout[field])
			aggregate[field] = aggregate[field]||0
		}
		if(/^(avg|count)$/.test(statInfo[field].type)){
			scout[field] = scout[field]||0
			aggregate[field] = aggregate[field]||0
		}
	})

	// Piece totals (POLLEN and NECTAR combined)
	scout.auto_collect = scout.auto_collect_pollen+scout.auto_collect_nectar
	scout.tele_collect = scout.tele_collect_pollen+scout.tele_collect_nectar
	scout.collect = scout.auto_collect+scout.tele_collect

	scout.auto_cell = scout.auto_cell_pollen+scout.auto_cell_nectar
	scout.tele_cell = scout.tele_cell_pollen+scout.tele_cell_nectar
	scout.cell = scout.auto_cell+scout.tele_cell

	scout.garden = scout.auto_garden_pollen+scout.auto_garden_nectar+scout.tele_garden_pollen+scout.tele_garden_nectar

	scout.flower = [1,2,3,4].reduce(function(total,i){
		return total+scout[`tele_flower${i}_pollen`]+scout[`tele_flower${i}_nectar`]
	},0)

	scout.placed = scout.cell+scout.flower+scout.garden
	scout.tips = scout.auto_hive_tip+scout.tele_hive_tip

	// Match points from Table 10-2 of the BIOBUZZ manual
	// Estimates: FLOWER counts every teleop placement, as if the FLOWER were owned, and
	// GARDEN counts every piece placed there. Cells left-over points and the bottom NECTAR
	// bonus are not counted, since scouts do not record how many pieces remain in a CELL.
	scout.leave_park_score = 3*scout.auto_leave+5*scout.auto_park+5*scout.end_park
	scout.auto_score = 3*scout.auto_leave+5*scout.auto_park+20*scout.auto_hive_tip
	scout.tele_score = 20*scout.tele_hive_tip+5*scout.end_park+2*scout.flower+scout.garden
	scout.score = scout.auto_score+scout.tele_score

	Object.keys(statInfo).forEach(function(field){
		if(/^(\%|avg|count)$/.test(statInfo[field].type)){
			aggregate[field] = (aggregate[field]||0)+scout[field]
			var set = `${field}_set`
			aggregate[set] = aggregate[set]||[]
			aggregate[set].push(scout[field])
		}
		if(/^text$/.test(statInfo[field].type)) aggregate[field] = (!aggregate[field]||aggregate[field]==scout[field])?scout[field]:"various"
	})
	aggregate.count = (aggregate.count||0)+1
}

var statInfo = {
	match:{
		name: "Match",
		en: "Match",
		type: "text",
		fr:'Match',
		pt:'Partida',
		zh_tw:'比賽',
		tr:'Maç',
		he:'משחק',
		es:'Partido',
	},
	team:{
		name: "Team",
		en: "Team",
		type: "text",
		fr:'Équipe',
		pt:'Equipe',
		zh_tw:'隊伍',
		tr:'Takım',
		he:'קבוצה',
		es:'Equipo',
	},
	scouter:{
		name: "Scouter",
		en: "Scouter",
		type: "text",
		fr:'Recruteur',
		pt:'Scouter',
		zh_tw:'偵察員',
		tr:'Scouter',
		he:'צופה',
		es:'Explorador',
	},
	comments:{
		name: "Comments",
		en: "Comments",
		type: "text",
		fr:'Commentaires',
		pt:'Comentários',
		zh_tw:'評論',
		tr:'Yorumlar',
		he:'הערות',
		es:'Comentarios',
	},
	created:{
		name: "Created",
		en: "Created",
		type: "datetime",
		fr:'Créé',
		pt:'Criado',
		zh_tw:'已創建',
		tr:'Oluşturuldu',
		he:'נוצר',
		es:'Creado',
	},
	modified:{
		name: "Modified",
		en: "Modified",
		type: "datetime",
		fr:'Modifié',
		pt:'Modificado',
		zh_tw:'已修改',
		tr:'Değiştirildi',
		he:'שונה',
		es:'Modificado',
	},
	timeline:{
		name: "Timeline",
		en: "Timeline",
		type: "timeline",
		fr:'Chronologie',
		pt:'Linha do tempo',
		zh_tw:'時間軸',
		tr:'Zaman Çizelgesi',
		he:'ציר זמן',
		es:'Cronología',
	},
	count:{
		name: 'Matches Scouted',
		en: 'Matches Scouted',
		type: 'num',
		fr:'Matchs observés',
		pt:'Partidas observadas',
		zh_tw:'已偵察的比賽',
		tr:'İzlenen Maçlar',
		he:'משחקים שנצפו',
		es:'Partidos observados',
	},
	no_show:{
		name: 'No Show',
		en: 'No Show',
		type: '%',
		fr:'Absence',
		pt:'Não comparecimento',
		zh_tw:'未出現',
		tr:'Gelmedi',
		he:'אי הופעה',
		es:'Sin presentación',
	},
	auto_leave:{
		name: 'Left Wall in Auto',
		en: 'Left Wall in Auto',
		type: '%',
		fr:'A quitté le mur en auto',
		pt:'Saiu da parede no auto',
		zh_tw:'自動運行離開周邊牆',
		tr:'Otonomda duvardan ayrıldı',
		he:'עזב את הקיר באוטומטי',
		es:'Salió de la pared en auto',
	},
	auto_park:{
		name: 'Parked in Auto',
		en: 'Parked in Auto',
		type: '%',
		fr:'Stationné en auto',
		pt:'Estacionou no auto',
		zh_tw:'自動運行停靠',
		tr:'Otonomda park etti',
		he:'חנה באוטומטי',
		es:'Estacionó en auto',
	},
	end_park:{
		name: 'Parked at End',
		en: 'Parked at End',
		type: '%',
		fr:'Stationné à la fin',
		pt:'Estacionou no fim',
		zh_tw:'比賽結束時停靠',
		tr:'Sonda park etti',
		he:'חנה בסוף',
		es:'Estacionó al final',
	},
	robot_disabled:{
		name: 'Robot Disabled or Stuck',
		en: 'Robot Disabled or Stuck',
		type: '%',
		fr:'Robot désactivé ou bloqué',
		pt:'Robô desativado ou preso',
		zh_tw:'機器人失效或卡住',
		tr:'Robot devre dışı veya sıkışmış',
		he:'הרובוט מנוטרל או תקוע',
		es:'Robot desactivado o atascado',
	},
	review_requested:{
		name: 'Review Requested (Estimated)',
		en: 'Review Requested (Estimated)',
		type: '%',
		fr:'Révision demandée (estimée)',
		pt:'Revisão solicitada (estimada)',
		zh_tw:'請求審查（估計）',
		tr:'İnceleme talebi (tahmini)',
		he:'בקשת סקירה (מוערכת)',
		es:'Revisión solicitada (estimada)',
	},
	auto_hive_tip:{
		name: 'HIVE Tips in Auto',
		en: 'HIVE Tips in Auto',
		type: 'avg',
		fr:'Basculements de la ruche en auto',
		pt:'Inclinações da colmeia no auto',
		zh_tw:'自動運行蜂巢傾倒次數',
		tr:'Otonomda KOVAN devirme sayısı',
		he:'הטיות כוורת באוטומטי',
		es:'Vuelcos de colmena en auto',
	},
	tele_hive_tip:{
		name: 'HIVE Tips in Teleop',
		en: 'HIVE Tips in Teleop',
		type: 'avg',
		fr:'Basculements de la ruche en téléop',
		pt:'Inclinações da colmeia no teleop',
		zh_tw:'遙控運轉蜂巢傾倒次數',
		tr:'Teleopta KOVAN devirme sayısı',
		he:'הטיות כוורת בטלאופ',
		es:'Vuelcos de colmena en teleop',
	},
	tips:{
		name: 'Total HIVE Tips',
		en: 'Total HIVE Tips',
		type: 'avg',
		fr:'Total des basculements',
		pt:'Total de inclinações',
		zh_tw:'蜂巢傾倒總數',
		tr:'Toplam KOVAN devirme',
		he:'סך הטיות כוורת',
		es:'Total de vuelcos',
	},
	auto_collect:{
		name: 'Pieces Collected in Auto',
		en: 'Pieces Collected in Auto',
		type: 'avg',
		fr:'Pièces collectées en auto',
		pt:'Peças coletadas no auto',
		zh_tw:'自動運行收集的物件',
		tr:'Otonomda toplanan parçalar',
		he:'חלקים שנאספו באוטומטי',
		es:'Piezas recogidas en auto',
	},
	tele_collect:{
		name: 'Pieces Collected in Teleop',
		en: 'Pieces Collected in Teleop',
		type: 'avg',
		fr:'Pièces collectées en téléop',
		pt:'Peças coletadas no teleop',
		zh_tw:'遙控運轉收集的物件',
		tr:'Teleopta toplanan parçalar',
		he:'חלקים שנאספו בטלאופ',
		es:'Piezas recogidas en teleop',
	},
	collect:{
		name: 'Pieces Collected',
		en: 'Pieces Collected',
		type: 'avg',
		fr:'Pièces collectées',
		pt:'Peças coletadas',
		zh_tw:'收集的物件',
		tr:'Toplanan parçalar',
		he:'חלקים שנאספו',
		es:'Piezas recogidas',
	},
	auto_cell:{
		name: 'Pieces into CELL in Auto',
		en: 'Pieces into CELL in Auto',
		type: 'avg',
		fr:'Pièces dans la cellule en auto',
		pt:'Peças na célula no auto',
		zh_tw:'自動運行放入房室的物件',
		tr:'Otonomda HÜCREYE konan parçalar',
		he:'חלקים שנכנסו לתא באוטומטי',
		es:'Piezas en la celda en auto',
	},
	tele_cell:{
		name: 'Pieces into CELL in Teleop',
		en: 'Pieces into CELL in Teleop',
		type: 'avg',
		fr:'Pièces dans la cellule en téléop',
		pt:'Peças na célula no teleop',
		zh_tw:'遙控運轉放入房室的物件',
		tr:'Teleopta HÜCREYE konan parçalar',
		he:'חלקים שנכנסו לתא בטלאופ',
		es:'Piezas en la celda en teleop',
	},
	cell:{
		name: 'Pieces into CELL',
		en: 'Pieces into CELL',
		type: 'avg',
		fr:'Pièces dans la cellule',
		pt:'Peças na célula',
		zh_tw:'放入房室的物件',
		tr:'HÜCREYE konan parçalar',
		he:'חלקים שנכנסו לתא',
		es:'Piezas en la celda',
	},
	garden:{
		name: 'Pieces into GARDEN',
		en: 'Pieces into GARDEN',
		type: 'avg',
		fr:'Pièces dans le jardin',
		pt:'Peças no jardim',
		zh_tw:'放入花園的物件',
		tr:'BAHÇEYE konan parçalar',
		he:'חלקים שנכנסו לגן',
		es:'Piezas en el jardín',
	},
	flower:{
		name: 'Pieces into FLOWERS (Teleop)',
		en: 'Pieces into FLOWERS (Teleop)',
		type: 'avg',
		fr:'Pièces dans les fleurs (téléop)',
		pt:'Peças nas flores (teleop)',
		zh_tw:'放入花朵的物件（遙控運轉）',
		tr:'ÇİÇEKLERE konan parçalar (Teleop)',
		he:'חלקים שנכנסו לפרחים (טלאופ)',
		es:'Piezas en las flores (teleop)',
	},
	placed:{
		name: 'Pieces Placed (CELL, FLOWER, GARDEN)',
		en: 'Pieces Placed (CELL, FLOWER, GARDEN)',
		type: 'avg',
		fr:'Pièces placées (cellule, fleur, jardin)',
		pt:'Peças colocadas (célula, flor, jardim)',
		zh_tw:'已放置的物件（房室、花、花園）',
		tr:'Yerleştirilen parçalar (HÜCRE, ÇİÇEK, BAHÇE)',
		he:'חלקים שהונחו (תא, פרח, גן)',
		es:'Piezas colocadas (celda, flor, jardín)',
	},
	leave_park_score:{
		name: 'LEAVE + PARK Points (Estimated)',
		en: 'LEAVE + PARK Points (Estimated)',
		type: 'avg',
		fr:'Points LEAVE + PARK (estimés)',
		pt:'Pontos LEAVE + PARK (estimados)',
		zh_tw:'離開＋停靠分數（估計）',
		tr:'LEAVE + PARK Puanları (Tahmini)',
		he:'נקודות LEAVE + PARK (מוערך)',
		es:'Puntos LEAVE + PARK (estimados)',
	},
	auto_score:{
		name: 'Auto Score (Estimated)',
		en: 'Auto Score (Estimated)',
		type: 'avg',
		fr:'Score en auto (estimé)',
		pt:'Pontuação no auto (estimada)',
		zh_tw:'自動運行得分（估計）',
		tr:'Otonom Skoru (Tahmini)',
		he:'ציון אוטומטי (מוערך)',
		es:'Puntuación en auto (estimada)',
	},
	tele_score:{
		name: 'Teleop Score (Estimated)',
		en: 'Teleop Score (Estimated)',
		type: 'avg',
		fr:'Score en téléop (estimé)',
		pt:'Pontuação no teleop (estimada)',
		zh_tw:'遙控運轉得分（估計）',
		tr:'Teleop Skoru (Tahmini)',
		he:'ציון טלאופ (מוערך)',
		es:'Puntuación en teleop (estimada)',
	},
	score:{
		name: 'Score Contribution (Estimated)',
		en: 'Score Contribution (Estimated)',
		type: 'avg',
		fr:'Contribution au score (estimée)',
		pt:'Contribuição para a pontuação (estimada)',
		zh_tw:'得分貢獻（估計）',
		tr:'Skor Katkısı (Tahmini)',
		he:'תרומה לציון (מוערכת)',
		es:'Contribución a la puntuación (estimada)',
	},
}

var aggregateGraphs = {
	"Score Contribution":{
		graph:"boxplot",
		data:["score"]
	},
	"Match Stages":{
		graph:"stacked",
		data:["auto_score","tele_score"]
	},
	"HIVE Tips":{
		graph:"boxplot",
		data:["tips"]
	},
	"Pieces Placed":{
		graph:"stacked",
		data:["cell","flower","garden"]
	},
	"Leave and Park":{
		graph:"bar",
		data:["auto_leave","auto_park","end_park"]
	},
}

var matchPredictorSections = {
	Total:{
		data:["score"],
	},
}
