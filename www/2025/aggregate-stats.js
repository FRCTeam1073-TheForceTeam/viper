"use strict"

function aggregateStats(scout, aggregate, apiScores, subjective, pit, eventStatsByMatchTeam, eventStatsByTeam, match){

	function bool_1_0(s){
		return (!s||/^0|no|false$/i.test(""+s))?0:1
	}

	function getPreferredCoralLevel(l1,l2,l3,l4){
		var m=Math.max(l1,l2,l3,l4)
		if (m==0)return"-"
		if(m==l1)return"L1"
		if(m==l2)return"L2"
		if(m==l3)return"L3"
		if(m==l4)return"L4"
		return"-"
	}


	function getPreferredAlgaePlace(processor,net){
		var m=Math.max(processor,net)
		if (m==0)return"-"
		if(m==net)return"Net"
		if(m==processor)return"Pro"
		return"-"
	}

	var pointValues={
		auto_leave:3,
		auto_l1:3,
		auto_l2:4,
		auto_l3:6,
		auto_l4:7,
		processor:6,
		net:4,
		tele_l1:2,
		tele_l2:3,
		tele_l3:4,
		tele_l4:5,
		park:2,
		shallow:6,
		deep:12,
	}

	Object.keys(statInfo).forEach(function(field){
		if(/^(\%|avg|count)$/.test(statInfo[field]['type'])){
			scout[field]=scout[field]||0
			aggregate[field]=aggregate[field]||0
		}
		if(/^heatmap$/.test(statInfo[field]['type'])){
			scout[field]=scout[field]||""
			aggregate[field]=aggregate[field]||""
		}
		if(/^int-list$/.test(statInfo[field]['type'])){
			scout[field]=((scout[field]||"")+"").split(" ").map(num => parseInt(num, 10)).filter(Number)
		}
	})

	Object.keys(statInfo).forEach(function(field){
		switch(statInfo[field]['type']){
			case '%': scout[field]=bool_1_0(scout[field]); break
			case 'avg': case 'count': scout[field]||=0
		}
	})

	scout.auto_algae_place=scout.auto_algae_net+scout.auto_algae_processor
	scout.auto_coral_place=scout.auto_coral_level_1+scout.auto_coral_level_2+scout.auto_coral_level_3+scout.auto_coral_level_4
	scout.auto_place=scout.auto_algae_place+scout.auto_coral_place
	scout.tele_algae_place=scout.tele_algae_net+scout.tele_algae_processor
	scout.tele_coral_place=scout.tele_coral_level_1+scout.tele_coral_level_2+scout.tele_coral_level_3+scout.tele_coral_level_4
	scout.tele_place=scout.tele_algae_place+scout.tele_coral_place
	scout.algae_drop=scout.auto_algae_drop+scout.tele_algae_drop
	scout.algae_lower=scout.auto_algae_lower+scout.tele_algae_lower
	scout.algae_lower_removed=scout.auto_algae_lower_removed+scout.tele_algae_lower_removed
	scout.auto_algae_ground=scout.auto_algae_mark_1+scout.auto_algae_mark_2+scout.auto_algae_mark_3
	scout.algae_ground=scout.auto_algae_ground+scout.tele_algae_ground
	scout.algae_net=scout.auto_algae_net+scout.tele_algae_net
	scout.algae_opponent_net=scout.tele_algae_opponent_net
	scout.algae_opponent_processor=scout.auto_algae_opponent_processor+scout.tele_algae_opponent_processor
	scout.algae_processor=scout.auto_algae_processor+scout.tele_algae_processor
	scout.algae_upper=scout.auto_algae_upper+scout.tele_algae_upper
	scout.algae_upper_removed=scout.auto_algae_upper_removed+scout.tele_algae_upper_removed
	scout.coral_drop=scout.auto_coral_drop+scout.tele_coral_drop
	scout.auto_coral_ground=scout.auto_coral_mark_1+scout.auto_coral_mark_2+scout.auto_coral_mark_3
	scout.coral_ground=scout.tele_coral_ground+scout.tele_coral_ground
	scout.coral_level_1=scout.auto_coral_level_1+scout.tele_coral_level_1
	scout.coral_level_2=scout.auto_coral_level_2+scout.tele_coral_level_2
	scout.coral_level_3=scout.auto_coral_level_3+scout.tele_coral_level_3
	scout.coral_level_4=scout.auto_coral_level_4+scout.tele_coral_level_4
	scout.preferred_coral_level=getPreferredCoralLevel(scout.coral_level_1,scout.coral_level_2,scout.coral_level_3,scout.coral_level_4)
	scout.preferred_algae_place=getPreferredAlgaePlace(scout.algae_processor,scout.algae_net)
	scout.coral_station_1=scout.auto_coral_station_1+scout.tele_coral_station_1
	scout.coral_station_2=scout.auto_coral_station_2+scout.tele_coral_station_2
	scout.auto_coral_station=scout.auto_coral_station_1+scout.auto_coral_station_2
	scout.tele_coral_station=scout.tele_coral_station_1+scout.tele_coral_station_2
	scout.coral_station=scout.auto_coral_station+scout.tele_coral_station
	scout.auto_coral_collect=scout.auto_coral_ground+scout.auto_coral_station
	scout.tele_coral_collect=scout.tele_coral_ground+scout.tele_coral_station+scout.tele_coral_theft
	scout.coral_collect=scout.auto_coral_collect+scout.tele_coral_collect
	scout.auto_algae_collect_reef=scout.auto_algae_upper+scout.auto_algae_lower
	scout.auto_algae_removed_reef=scout.auto_algae_lower_removed+scout.auto_algae_upper_removed
	scout.auto_algae_reef=scout.auto_algae_collect_reef+scout.auto_algae_removed_reef
	scout.auto_algae_collect=scout.auto_algae_reef+scout.auto_algae_ground
	scout.auto_collect=scout.auto_coral_collect+scout.auto_algae_collect
	scout.tele_algae_collect_reef=scout.tele_algae_upper+scout.tele_algae_lower
	scout.tele_algae_removed_reef=scout.tele_algae_lower_removed+scout.tele_algae_upper_removed
	scout.tele_algae_reef=scout.tele_algae_collect_reef+scout.tele_algae_removed_reef
	scout.tele_algae_collect=scout.tele_algae_reef+scout.tele_algae_ground+scout.tele_algae_theft
	scout.tele_theft=scout.tele_coral_theft+scout.tele_algae_theft
	scout.tele_collect=scout.tele_coral_collect+scout.tele_algae_collect
	scout.algae_collect_reef=scout.auto_algae_collect_reef+scout.tele_algae_collect_reef
	scout.algae_removed_reef=scout.auto_algae_removed_reef+scout.tele_algae_removed_reef
	scout.algae_reef=scout.auto_algae_reef+scout.tele_algae_reef
	scout.algae_collect=scout.auto_algae_collect+scout.tele_algae_collect
	scout.collect=scout.auto_collect+scout.tele_collect
	scout.auto_drop=scout.auto_algae_drop+scout.auto_coral_drop
	scout.tele_drop=scout.tele_algae_drop+scout.tele_coral_drop
	scout.drop=scout.auto_drop+scout.tele_drop
	scout.park=bool_1_0(scout.end_game_position=='parked')
	scout.shallow=bool_1_0(scout.end_game_position=='shallow')
	scout.deep=bool_1_0(scout.end_game_position=='deep')
	scout.algae_place=scout.auto_algae_place+scout.tele_algae_place
	scout.coral_place=scout.auto_coral_place+scout.tele_coral_place
	scout.place=scout.auto_place+scout.tele_place
	scout.algae_litter=scout.algae_removed_reef+scout.algae_drop-scout.algae_ground
	scout.coral_litter=scout.coral_drop-scout.coral_ground
	scout.litter=scout.algae_litter+scout.coral_litter

	scout.auto_leave_score=pointValues.auto_leave*scout.auto_leave
	scout.auto_coral_level_1_score=pointValues.auto_l1*scout.auto_coral_level_1
	scout.auto_coral_level_2_score=pointValues.auto_l2*scout.auto_coral_level_2
	scout.auto_coral_level_3_score=pointValues.auto_l3*scout.auto_coral_level_3
	scout.auto_coral_level_4_score=pointValues.auto_l4*scout.auto_coral_level_4
	scout.auto_algae_processor_score=pointValues.processor*scout.auto_algae_processor
	scout.auto_algae_net_score=pointValues.net*scout.auto_algae_net
	scout.auto_algae_opponent_processor_score=(pointValues
	.net-pointValues.processor)*scout.auto_algae_opponent_processor
	scout.tele_coral_level_1_score=pointValues.tele_l1*scout.tele_coral_level_1
	scout.tele_coral_level_2_score=pointValues.tele_l2*scout.tele_coral_level_2
	scout.tele_coral_level_3_score=pointValues.tele_l3*scout.tele_coral_level_3
	scout.tele_coral_level_4_score=pointValues.tele_l4*scout.tele_coral_level_4
	scout.tele_algae_processor_score=pointValues.processor*scout.tele_algae_processor
	scout.tele_algae_opponent_net_score=-pointValues.net*scout.tele_algae_processor
	scout.tele_algae_net_score=pointValues.net*scout.tele_algae_net
	scout.tele_algae_opponent_processor_score=(pointValues
		.net-pointValues.processor)*scout.tele_algae_opponent_processor
	scout.park_score=pointValues.park*scout.park
	scout.shallow_score=pointValues.shallow*scout.shallow
	scout.deep_score=pointValues.deep*scout.deep
	scout.cage_score=scout.shallow_score+scout.deep_score
	scout.end_game_score=scout.park_score+scout.cage_score
	scout.auto_algae_processor_net_score=scout.auto_algae_processor_score
	scout.auto_algae_score=scout.auto_algae_processor_net_score+scout.auto_algae_opponent_processor_score+scout.auto_algae_net_score
	scout.auto_coral_score=scout.auto_coral_level_1_score+scout.auto_coral_level_2_score+scout.auto_coral_level_3_score+scout.auto_coral_level_4_score
	scout.tele_algae_processor_net_score=scout.tele_algae_processor_score + scout.tele_algae_opponent_net_score
	scout.tele_algae_score=scout.tele_algae_processor_net_score+scout.tele_algae_opponent_processor_score+scout.tele_algae_net_score
	scout.tele_coral_score=scout.tele_coral_level_1_score+scout.tele_coral_level_2_score+scout.tele_coral_level_3_score+scout.tele_coral_level_4_score
	scout.coral_level_1_score=scout.auto_coral_level_1_score+scout.tele_coral_level_1_score
	scout.coral_level_2_score=scout.auto_coral_level_2_score+scout.tele_coral_level_2_score
	scout.coral_level_3_score=scout.auto_coral_level_3_score+scout.tele_coral_level_3_score
	scout.coral_level_4_score=scout.auto_coral_level_4_score+scout.tele_coral_level_4_score
	scout.algae_processor_score=scout.auto_algae_processor_score+scout.tele_algae_processor_score
	scout.algae_opponent_net_score=scout.tele_algae_opponent_net_score
	scout.algae_net_score=scout.auto_algae_net_score+scout.tele_algae_net_score
	scout.algae_opponent_processor_score=scout.auto_algae_opponent_processor_score+scout.tele_algae_opponent_processor_score
	scout.algae_score=scout.auto_algae_score+scout.tele_algae_score
	scout.algae_score_total+=pointValues.processor*scout.algae_processor+pointValues.net*scout.algae_net
	scout.coral_score=scout.auto_coral_score+scout.tele_coral_score
	scout.auto_score=scout.auto_leave_score+scout.auto_coral_score+scout.auto_algae_score
	scout.tele_score=scout.tele_coral_score+scout.tele_algae_score
	scout.score=scout.auto_score+scout.tele_score+scout.end_game_score

	Object.keys(statInfo).forEach(function(field){
		if (!/human.player/i.test(statInfo.name)){
			if(/^(\%|avg|count)$/.test(statInfo[field]['type'])){
				aggregate[field]=(aggregate[field]||0)+scout[field]
				var set=`${field}_set`
				aggregate[set]=aggregate[set]||[]
				aggregate[set].push(scout[field])
			}
			if(/^capability$/.test(statInfo[field]['type'])) aggregate[field]=aggregate[field]||scout[field]||0
			if(/^text$/.test(statInfo[field]['type'])) aggregate[field]=(!aggregate[field]||aggregate[field]==scout[field])?scout[field]:"various"
			if(/^heatmap$/.test(statInfo[field]['type'])) aggregate[field] += ((aggregate[field]&&scout[field])?" ":"")+scout[field]
			if(/^int-list$/.test(statInfo[field]['type'])) aggregate[field]=(aggregate[field]||[]).concat(scout[field])
		}
	})
	aggregate.count=(aggregate.count||0)+1
	aggregate.max_score=Math.max(aggregate.max_score||0,scout.score)
	aggregate.min_score=Math.min(aggregate.min_score===undefined?999:aggregate.min_score,scout.score)

	aggregate.max_coral_place=Math.max(aggregate.max_coral_place||0,scout.coral_place)
	aggregate.max_auto_coral_place=Math.max(aggregate.max_auto_coral_place||0,scout.auto_coral_place)
	aggregate.max_tele_coral_place=Math.max(aggregate.max_tele_coral_place||0,scout.tele_coral_place)

	aggregate.max_algae_place=Math.max(aggregate.max_algae_place||0,scout.algae_place)
	aggregate.max_auto_algae_place=Math.max(aggregate.max_auto_algae_place||0,scout.auto_algae_place)
	aggregate.max_tele_algae_place=Math.max(aggregate.max_tele_algae_place||0,scout.tele_algae_place)

	aggregate.max_place=Math.max(aggregate.max_place||0,scout.place)
	aggregate.max_auto_place=Math.max(aggregate.max_auto_place||0,scout.auto_place)
	aggregate.max_tele_place=Math.max(aggregate.max_tele_place||0,scout.tele_place)

	aggregate.preferred_coral_level=getPreferredCoralLevel(aggregate.coral_level_1,aggregate.coral_level_2,aggregate.coral_level_3,aggregate.coral_level_4)
	aggregate.preferred_algae_place=getPreferredAlgaePlace(aggregate.algae_processor,aggregate.algae_net)
	aggregate.event=eventId


	if(scout.algae_processor&&/^[1-9][0-9]*$/.test(""+scout.opponent_human_player_team)){
		var hpTeam = parseInt(""+scout.opponent_human_player_team),
		hpScout = eventStatsByMatchTeam[`${match}-${hpTeam}`]||={},
		hpAggregate = eventStatsByTeam[hpTeam]||={}
		hpScout.team=hpTeam
		hpAggregate.team=hpTeam
		hpScout.event=eventId
		hpAggregate.event=eventId
		hpScout.human_player_algae_received=(hpScout.human_player_algae_received||0)+scout.algae_processor+(((scout.old||{}).human_player_algae_received)||0)
		hpAggregate.human_player_algae_received=(hpAggregate.human_player_algae_received||0)+scout.algae_processor
		hpScout.human_player_net=(hpScout.human_player_net||0)+scout.algae_opponent_net+(((scout.old||{}).human_player_net)||0)
		hpAggregate.human_player_net=(hpAggregate.human_player_net||0)+scout.algae_opponent_net
		hpScout.human_player_accuracy=hpScout.human_player_algae_received>0?hpScout.human_player_net/hpScout.human_player_algae_received:0
		hpAggregate.human_player_accuracy=hpAggregate.human_player_algae_received>0?hpAggregate.human_player_net/hpAggregate.human_player_algae_received:0

		hpScout.algae_score_total=(hpScout.algae_score_total||0)+pointValues.net*hpScout.human_player_net
		hpAggregate.algae_score_total=(hpAggregate.algae_score_total||0)+pointValues.net*hpScout.human_player_net
	}
	if (scout.old &&(typeof scout.old.score=='undefined'))scout.old=null

	pit.auto_paths = []
	for (var i=1; i<=9; i++){
		var path = pit[`auto_${i}_path`]
		if (path) pit.auto_paths.push(path)
	}
}

var statInfo={
	event:{
		name: 'Event',
		type: 'text',
		fr:'Événement',
		pt:'Evento',
		zh_tw:'事件',
		tr:'Etkinlik',
		he:'מִקרֶה',
	},
	match:{
		name: "Match",
		type: "text",
		fr:'Match',
		pt:'Partida',
		zh_tw:'匹配',
		tr:'Maç',
		he:'לְהַתְאִים',
	},
	team:{
		name: "Team",
		type: "text",
		fr:'Équipe',
		pt:'Equipe',
		zh_tw:'團隊',
		tr:'Takım',
		he:'קְבוּצָה',
	},
	count:{
		name: 'Matches Scouted',
		type: 'num',
		fr:'Matchs repérés',
		pt:'Partidas observadas',
		zh_tw:'已偵察的比賽',
		tr:'İzlenen Maçlar',
		he:'גפרורים בצופים',
	},
	auto_start:{
		name: "Location where the robot starts",
		type: "heatmap",
		image: "/2025/start-area-blue.png",
		aspect_ratio: 3.375,
		whiteboard_start: 35.8,
		whiteboard_end: 50,
		whiteboard_char: "□",
		whiteboard_us: true,
		fr:'Lieu de départ du robot',
		pt:'Local onde o robô começa',
		zh_tw:'機器人啟動的位置',
		tr:'Robotun başladığı yer',
		he:'המיקום שבו הרובוט מתחיל',
	},
	auto_leave:{
		name: "Left the Start Line During Auto",
		type: "%",
		timeline_stamp: "L",
		timeline_fill: "#888",
		timeline_outline: "#888",
		fr:'A quitté la ligne de départ pendant l\'automatisme',
		pt:'Deixou a linha de partida durante o modo automático',
		zh_tw:'自動擋汽車行駛過程中離開起跑線',
		tr:'Auto sırasında Başlangıç ​​Çizgisinden Ayrılma',
		he:'עזב את קו ההתחלה במהלך אוטומטי',
	},
	auto_leave_score:{
		name: "Score for Leaving the Start Line During Auto",
		type: "avg",
		fr:'Score pour avoir quitté la ligne de départ pendant l\'automatisme',
		pt:'Pontuação por deixar a linha de partida durante o modo automático',
		zh_tw:'自動擋賽車過程中離開起跑線的得分',
		tr:'Auto sırasında Başlangıç ​​Çizgisinden Ayrılma Puanı',
		he:'ציון עבור עזיבת קו ההתחלה במהלך אוטומטי',
	},
	no_show:{
		name: "No Show",
		type: "%",
		timeline_stamp: "N",
		timeline_fill: "#F0F",
		timeline_outline: "#F0F",
		fr:'Absence',
		pt:'Não comparecimento',
		zh_tw:'沒有出席',
		tr:'Gelmedi',
		he:'אין הופעה',
	},
	defense:{
		name: "Played Defense",
		type: "%",
		fr:'Défense jouée',
		pt:'Defesa jogada',
		zh_tw:'防守',
		tr:'Savunma Oynandı',
		he:'שיחק הגנה',
	},
	bricked:{
		name: "Robot Disabled",
		type: "%",
		fr:'Robot désactivé',
		pt:'Robô desabilitado',
		zh_tw:'機器人已停用',
		tr:'Robot Devre Dışı',
		he:'רובוט מושבת',
	},
	auto_algae_drop:{
		name: "Algae Dropped in Auto",
		type: "avg",
		timeline_stamp: "X",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#4eb0a4",
		fr:'Algues lâchées en automatisme',
		pt:'Algas caídas no modo automático',
		zh_tw:'汽車內藻類減少',
		tr:'Auto modunda Yosun Düştü',
		he:'אצות נפלו באוטו',
	},
	auto_algae_lower:{
		name: "Algae Collected from Lower Reef in Auto",
		type: "avg",
		timeline_stamp: "R",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues collectées sur le récif inférieur en automatisme',
		pt:'Algas coletadas do recife inferior no modo automático',
		zh_tw:'從下層珊瑚礁中收集的藻類',
		tr:'Auto modunda Alt Resif\'ten Toplanan Yosun',
		he:'אצות שנאספו מהשונית התחתונה באוטו',
	},
	auto_algae_lower_removed:{
		name: "Algae Knocked Off Lower Reef in Auto",
		type: "avg",
		timeline_stamp: "↓",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues projetées hors du récif inférieur en automatisme',
		pt:'Algas arrancadas do recife inferior no modo automático',
		zh_tw:'藻類從汽車下部珊瑚礁中脫落',
		tr:'Auto modunda Alt Resif\'ten Düşen Yosun',
		he:'אצות נפלו מהשונית התחתונה אוטומטית',
	},
	auto_algae_mark_1:{
		name: "Algae Collected from Mark 1 in Auto",
		type: "%",
		timeline_stamp: "G",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues collectées sur la marque 1 en automatisme',
		pt:'Algas coletadas da marca 1 no modo automático',
		zh_tw:'從汽車中的 Mark 1 收集的藻類',
		tr:'Auto modunda Mark 1\'den Toplanan Yosun',
		he:'אצות שנאספו מסימן 1 באוטו',
	},
	auto_algae_mark_2:{
		name: "Algae Collected from Mark 2 in Auto",
		type: "%",
		timeline_stamp: "G",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues collectées sur la marque 2 en automatisme',
		pt:'Algas coletadas da marca 2 no modo automático',
		zh_tw:'從 Mark 2 號汽車收集的藻類',
		tr:'Auto modunda Mark 2\'den Toplanan Yosun',
		he:'אצות שנאספו מסימן 2 באוטו',
	},
	auto_algae_mark_3:{
		name: "Algae Collected from Mark 3 in Auto",
		type: "%",
		timeline_stamp: "G",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues collectées sur la marque 3 en automatisme',
		pt:'Algas coletadas da marca 3 no modo automático',
		zh_tw:'從 Mark 3 號汽車收集的藻類',
		tr:'Auto modunda Mark 3\'ten Toplanan Yosun',
		he:'אצות שנאספו מסימן 3 באוטו',
	},
	auto_algae_net:{
		name: "Algae Placed in Net by Robot in Auto",
		type: "avg",
		timeline_stamp: "N",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#4eb0a4",
		fr:'Algues placées dans le filet par le robot en automatisme',
		pt:'Algas colocadas na rede pelo robô no modo automático',
		zh_tw:'機器人自動將藻類放入網中',
		tr:'Auto modunda Robot tarafından Ağa Yerleştirilen Yosun',
		he:'אצות הוצבו ברשת על ידי רובוט באוטו',
	},
	auto_algae_opponent_processor:{
		name: "Algae Placed in the Opponent's Processor in Auto",
		type: "avg",
		timeline_stamp: "O",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#4eb0a4",
		fr:'Algues placées dans le processeur de l\'adversaire en automatisme',
		pt:'Algas colocadas no processador do oponente no modo automático',
		zh_tw:'藻類被放置在對手的汽車處理器中',
		tr:'Auto modunda Rakibin İşlemcisine Yerleştirilen Yosun',
		he:'אצות ממוקמות במעבד של היריב באופן אוטומטי',
	},
	auto_algae_processor:{
		name: "Algae Placed in the Processor in Auto",
		type: "avg",
		timeline_stamp: "P",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#4eb0a4",
		fr:'Algues placées dans le processeur en automatisme',
		pt:'Algas colocadas no processador no modo automático',
		zh_tw:'藻類放置在自動處理器中',
		tr:'Auto modunda İşlemciye Yerleştirilen Yosun',
		he:'אצות ממוקמות במעבד באופן אוטומטי',
	},
	auto_algae_upper:{
		name: "Algae Collected from Upper Reef in Auto",
		type: "avg",
		timeline_stamp: "R",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues collectées sur le récif supérieur en automatisme',
		pt:'Algas coletadas do recife superior no modo automático',
		zh_tw:'從上層珊瑚礁中收集的藻類',
		tr:'Auto modunda Üst Resif\'ten Toplanan Yosun',
		he:'אצות שנאספו מהשונית העליונה באוטו',
	},
	auto_algae_upper_removed:{
		name: "Algae Knocked Off Upper Reef in Auto",
		type: "avg",
		timeline_stamp: "↓",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues projetées hors du récif supérieur en automatisme',
		pt:'Algas arrancadas do recife superior no modo automático',
		zh_tw:'藻類從汽車上部珊瑚礁中脫落',
		tr:'Auto modunda Üst Resif\'ten Düşen Yosun',
		he:'אצות נפלו מהשונית העליונה אוטומטית',
	},
	auto_coral_drop:{
		name: "Coral Dropped in Auto",
		type: "avg",
		timeline_stamp: "X",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Corail lâché en automatisme',
		pt:'Coral caído no modo automático',
		zh_tw:'珊瑚掉入汽車',
		tr:'Auto modunda Mercan Düştü',
		he:'אלמוג ירד באוטו',
	},
	auto_coral_mark_1:{
		name: "Coral Collected from Mark 1 in Auto",
		type: "%",
		timeline_stamp: "G",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Corail collecté sur la marque 1 en automatisme',
		pt:'Coral coletado da marca 1 no modo automático',
		zh_tw:'從 Mark 1 號汽車上採集的珊瑚',
		tr:'Auto modunda Mark 1\'den Toplanan Mercan',
		he:'אלמוגים שנאספו מסימן 1 באוטו',
	},
	auto_coral_mark_2:{
		name: "Coral Collected from Mark 2 in Auto",
		type: "%",
		timeline_stamp: "G",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Corail collecté sur la marque 2 en automatisme',
		pt:'Coral coletado da marca 2 no modo Auto',
		zh_tw:'從 Mark 2 號車上採集的珊瑚',
		tr:'Auto modunda Mark 2\'den Toplanan Mercan Otomatik',
		he:'אלמוגים שנאספו מסימן 2 באוטו',
	},
	auto_coral_mark_3:{
		name: "Coral Collected from Mark 3 in Auto",
		type: "%",
		timeline_stamp: "G",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Corail Récupéré au niveau 3 en mode automatique',
		pt:'Coral coletado da marca 3 em Auto',
		zh_tw:'從 Mark 3 號車上採集的珊瑚',
		tr:'Otomatikte Mark 3\'ten Toplanan Mercan',
		he:'אלמוגים שנאספו מסימן 3 באוטו',
	},
	auto_coral_level_1:{
		name: "Coral Placed on Level 1 During Auto",
		type: "avg",
		timeline_stamp: "1",
		timeline_fill: "#FFF",
		timeline_outline: "#AAA",
		fr:'Coraux placés au niveau 1 en mode automatique',
		pt:'Coral colocado no nível 1 durante Auto',
		zh_tw:'珊瑚在自動期間放置在 1 級',
		tr:'Otomatik Sırasında Seviye 1\'e Yerleştirilen Mercan',
		he:'אלמוג מוצב ברמה 1 במהלך אוטומטי',
	},
	auto_coral_level_2:{
		name: "Coral Placed on Level 2 During Auto",
		type: "avg",
		timeline_stamp: "2",
		timeline_fill: "#FFF",
		timeline_outline: "#AAA",
		fr:'Coraux placés au niveau 2 en mode automatique',
		pt:'Coral colocado no nível 2 durante Auto',
		zh_tw:'珊瑚在自動期間放置在第 2 層',
		tr:'Otomatik Sırasında Seviye 2\'ye Yerleştirilen Mercan',
		he:'אלמוג מוצב ברמה 2 במהלך אוטומטי',
	},
	auto_coral_level_3:{
		name: "Coral Placed on Level 3 During Auto",
		type: "avg",
		timeline_stamp: "3",
		timeline_fill: "#FFF",
		timeline_outline: "#AAA",
		fr:'Coraux placés au niveau 3 en mode automatique',
		pt:'Coral colocado no nível 3 durante Auto',
		zh_tw:'珊瑚在自動期間放置在第 3 層',
		tr:'Otomatik Sırasında Seviye 3\'e Yerleştirilen Mercan',
		he:'אלמוג מוצב ברמה 3 במהלך אוטומטי',
	},
	auto_coral_level_4:{
		name: "Coral Placed on Level 4 During Auto",
		type: "avg",
		timeline_stamp: "4",
		timeline_fill: "#FFF",
		timeline_outline: "#AAA",
		fr:'Coraux placés au niveau 4 en mode automatique',
		pt:'Coral colocado no nível 4 durante Auto',
		zh_tw:'珊瑚在自動期間放置在第 4 層',
		tr:'Otomatik Sırasında Seviye 4\'e Yerleştirilen Mercan',
		he:'אלמוג מוצב ברמה 4 במהלך אוטומטי',
	},
	auto_coral_station_1:{
		name: "Coral Collected from Station 1 in Auto",
		type: "avg",
		timeline_stamp: "S",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Coraux récupérés à la station 1 en mode automatique',
		pt:'Coral coletado da estação 1 em Auto',
		zh_tw:'從 1 號站自動收集的珊瑚',
		tr:'Otomatik Sırasında İstasyon 1\'den Toplanan Mercan',
		he:'אלמוגים שנאספו מתחנה 1 באוטו',
	},
	auto_coral_station_2:{
		name: "Coral Collected from Station 1 in Auto",
		type: "avg",
		timeline_stamp: "S",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Coraux récupérés à la station 1 en mode automatique',
		pt:'Coral coletado da estação 1 em Auto',
		zh_tw:'從 1 號站自動收集的珊瑚',
		tr:'Otomatik Sırasında İstasyon 1\'den Toplanan Mercan',
		he:'אלמוגים שנאספו מתחנה 1 באוטו',
	},
	auto_coral_place:{
		name: "Coral Placed During Auto",
		type: "avg",
		fr:'Coraux placés en mode automatique',
		pt:'Coral colocado durante Auto',
		zh_tw:'珊瑚在汽車中放置',
		tr:'Otomatik Sırasında Mercan',
		he:'אלמוג ממוקם במהלך אוטו',
	},
	auto_place:{
		name: "Scoring Elements Placed During Auto",
		type: "avg",
		fr:'Éléments de score placés en mode automatique',
		pt:'Elementos de pontuação colocados durante Auto',
		zh_tw:'自動放置的得分元素',
		tr:'Otomatik Sırasında Puanlama Elemanları Yerleştirildi',
		he:'רכיבי ניקוד שהוצבו במהלך אוטומטי',
	},
	auto_score:{
		name: "Score in Auto",
		type: "avg",
		fr:'Score en mode automatique',
		pt:'Pontuação em Auto',
		zh_tw:'自動得分',
		tr:'Otomatik Sırasında Puan',
		he:'ציון באוטו',
	},
	coral_preload:{
		name: "Coral Preloaded Before Match",
		type: "%",
		fr:'Coraux préchargés avant le match',
		pt:'Coral pré-carregado antes da partida',
		zh_tw:'比賽前預載 Coral',
		tr:'Maçtan Önce Mercan Önceden Yüklendi',
		he:'קורל נטען מראש לפני המשחק',
	},
	end_game_climb_fail:{
		name: "Climb Failed",
		type: "%",
		fr:'Escalade échouée',
		pt:'Escalada falhou',
		zh_tw:'攀爬失敗',
		tr:'Tırmanma Başarısız Oldu',
		he:'הטיפוס נכשל',
	},
	end_game_position:{
		name: "End Game Position",
		type: "text",
		fr:'Position finale',
		pt:'Posição final do jogo',
		zh_tw:'遊戲結束位置',
		tr:'Oyun Sonu Pozisyonu',
		he:'עמדת סיום משחק',
	},
	tele_drop:{
		name: "Scoring Elements Dropped in Teleop",
		type: "avg",
		fr:'Éléments de score déposés en mode téléop.',
		pt:'Elementos de pontuação descartados no teleop',
		zh_tw:'遠端操作中被放棄的評分要素',
		tr:'Teleoperasyonda Düşen Puanlama Elemanları',
		he:'רכיבי ניקוד נפלו ב-Teleoperation',
	},
	tele_place:{
		name: "Scoring Elements Placed During Teleop",
		type: "avg",
		fr:'Éléments de score déposés en mode téléop.',
		pt:'Elementos de pontuação colocados durante o teleop',
		zh_tw:'遠端操作期間放置的得分元素',
		tr:'Teleoperasyon Sırasında Yerleştirilen Puanlama Elemanları',
		he:'רכיבי ניקוד שהונחו במהלך ניתוח טלפוני',
	},
	opponent_human_player_team:{
		name: "Opponent Human Player Team",
		type: "text",
		fr:'Équipe adverse (joueurs humains)',
		pt:'Equipe de jogadores humanos oponentes',
		zh_tw:'對手人類玩家隊伍',
		tr:'Rakip İnsan Oyuncu Takımı',
		he:'צוות שחקן אנושי יריב',
	},
	place:{
		name: "Scoring Elements Placed",
		type: "avg",
		fr:'Éléments de score déposés',
		pt:'Elementos de pontuação colocados',
		zh_tw:'放置得分元素',
		tr:'Yerleştirilen Puanlama Elemanları',
		he:'ניקוד אלמנטים ממוקמים',
	},
	parked_score:{
		name: "Parking Score",
		type: "avg",
		fr:'Score de stationnement',
		pt:'Pontuação de estacionamento',
		zh_tw:'停車積分',
		tr:'Park Puanı',
		he:'ציון חניה',
	},
	end_game_position:{
		name: "Position at End of Game",
		type: "text",
		fr:'Position en fin de partie',
		pt:'Posição no final do jogo',
		zh_tw:'遊戲結束時的位置',
		tr:'Oyun Sonundaki Pozisyon',
		he:'מיקום בסוף המשחק',
	},
	timeline:{
		name: "Timeline",
		type: "timeline",
		fr:'Chronologie',
		pt:'Linha do tempo',
		zh_tw:'時間軸',
		tr:'Zaman Çizelgesi',
		he:'ציר זמן',
	},
	max_score:{
		name: "Maximum Score Contribution",
		type: "minmax",
		fr:'Contribution maximale au score',
		pt:'Contribuição máxima de pontuação',
		zh_tw:'最大分數貢獻',
		tr:'Maksimum Puan Katkısı',
		he:'תרומת ציון מקסימלי',
	},
	min_score:{
		name: "Minimum Score Contribution",
		type: "minmax",
		fr:'Contribution minimale au score',
		pt:'Contribuição mínima de pontuação',
		zh_tw:'最低分數貢獻',
		tr:'Minimum Puan Katkısı',
		he:'תרומת ציון מינימלי',
	},
	score:{
		name: "Score Contribution",
		type: "avg",
		fr:'Contribution au score',
		pt:'Contribuição de pontuação',
		zh_tw:'分數貢獻',
		tr:'Puan Katkısı',
		he:'תרומה של ציון',
	},
	scouter:{
		name: "Scouter",
		type: "text",
		fr:'Scouteur',
		pt:'Patrulheiro',
		zh_tw:'偵察兵',
		tr:'Scouter',
		he:'צופית',
	},
	comments:{
		name: "Comments",
		type: "text",
		fr:'Commentaires',
		pt:'Comentários',
		zh_tw:'評論',
		tr:'Yorumlar',
		he:'הערות',
	},
	created:{
		name: "Created",
		type: "datetime",
		fr:'Créé',
		pt:'Criado',
		zh_tw:'創建',
		tr:'Oluşturuldu',
		he:'נוצר',
	},
	modified:{
		name: "Modified",
		type: "datetime",
		fr:'Modifié',
		pt:'Modificado',
		zh_tw:'修改的',
		tr:'Değiştirildi',
		he:'שונה',
	},
	tele_algae_drop:{
		name: "Algae Dropped in Teleop",
		type: "avg",
		timeline_stamp: "X",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#4eb0a4",
		fr:'Algues déposées en mode téléop.',
		pt:'Algas caídas no teleop',
		zh_tw:'藻類在遠端操作中被丟棄',
		tr:'Algler Teleoperasyonda Bırakılan',
		he:'אצות נפלו ב-Teleoperation',
	},
	tele_algae_ground:{
		name: "Algae Collected from Ground in Teleop",
		type: "avg",
		timeline_stamp: "G",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues collectées au sol en Téléopération',
		pt:'Algas coletadas de Solo em Teleop',
		zh_tw:'遠端操作從地面收集藻類',
		tr:'Teleoperasyonda Yerden Toplanan Yosun',
		he:'אצות שנאספו מהקרקע ב-Teleoperation',
	},
	tele_algae_lower:{
		name: "Algae Collected from Lower Reef in Teleop",
		type: "",
		timeline_stamp: "R",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues collectées sur le récif inférieur en téléopération',
		pt:'Algas coletadas do recife inferior em Teleop',
		zh_tw:'透過遠端操作從下層珊瑚礁收集藻類',
		tr:'Teleoperasyonda Alt Resiften Toplanan Yosun',
		he:'אצות שנאספו מהשונית התחתונה ב-Teleoperation',
	},
	tele_algae_lower_removed:{
		name: "Algae Knocked Off Lower Reef in Teleop",
		type: "avg",
		timeline_stamp: "↓",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues retirées du récif inférieur en téléopération',
		pt:'Algas derrubadas do recife inferior em Teleop',
		zh_tw:'遠端操作清除下層珊瑚礁中的藻類',
		tr:'Teleoperasyonda Alt Resiften Düşürülen Yosun',
		he:'אצות נפלו מהשונית התחתונה ב-Teleoperation',
	},
	tele_algae_net:{
		name: "Algae Placed in Net by Robot in Teleop",
		type: "avg",
		timeline_stamp: "N",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#4eb0a4",
		fr:'Algues placées dans un filet par un robot en téléopération',
		pt:'Algas colocadas na rede pelo robô em Teleop',
		zh_tw:'機器人透過遠端操作將藻類放入網中',
		tr:'Teleoperasyonda Robot Tarafından Ağa Yerleştirilen Yosun',
		he:'אצות הוצבו ברשת על ידי רובוט ב-Teleoperation',
	},
	tele_algae_opponent_net:{
		name: "Algae Thrown in Net by Opponent Human Player in Teleop",
		type: "avg",
		timeline_stamp: "H",
		timeline_fill: "#888",
		timeline_outline: "#888",
		fr:'Algues lancées dans un filet par un joueur humain adverse en téléopération',
		pt:'Algas lançadas na rede pelo jogador humano oponente em Teleop',
		zh_tw:'遠程操作中對手人類玩家將藻類丟進網中',
		tr:'Teleoperasyonda Rakip İnsan Oyuncu Tarafından Ağa Atılan Yosun',
		he:'אצות זרקו ברשת על ידי שחקן יריב אנושי ב-Teleoperation',
	},
	tele_algae_opponent_processor:{
		name: "Algae Placed in the Opponent's Processor in Teleop",
		type: "avg",
		timeline_stamp: "O",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#4eb0a4",
		fr:'Algues placées dans le processeur adverse en téléopération',
		pt:'Algas colocadas no processador do oponente em Teleop',
		zh_tw:'在遠端操作中將藻類放置在對手的處理器中',
		tr:'Teleoperasyonda Rakibin İşlemcisine Yerleştirilen Yosun',
		he:'אצות ממוקמות במעבד של היריב ב-Teleoperation',
	},
	tele_algae_processor:{
		name: "Algae Placed in the Processor in Teleop",
		type: "avg",
		timeline_stamp: "P",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#4eb0a4",
		fr:'Algues placées dans le processeur en téléopération',
		pt:'Algas colocadas no processador em Teleop',
		zh_tw:'藻類在遠端操作中放置在處理器中',
		tr:'Teleoperasyonda İşlemciye Yerleştirilen Yosun',
		he:'אצות ממוקמות במעבד ב-Teleoperation',
	},
	tele_algae_upper:{
		name: "Algae Collected from Upper Reef in Teleop",
		type: "avg",
		timeline_stamp: "R",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues collectées sur le récif supérieur en téléopération',
		pt:'Algas coletadas do recife superior em Teleop',
		zh_tw:'遠端操作從上層珊瑚礁收集藻類',
		tr:'Teleoperasyonda Üst Resiften Toplanan Yosun',
		he:'אצות שנאספו מהשונית העליונה ב-Teleoperation',
	},
	tele_algae_upper_removed:{
		name: "Algae Knocked Off Upper Reef in Teleop",
		type: "avg",
		timeline_stamp: "↓",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues retirées du récif supérieur en téléopération',
		pt:'Algas derrubadas do recife superior em Teleop',
		zh_tw:'遠端操作清除上層珊瑚礁中的藻類',
		tr:'Teleoperasyonda Üst Resiften Düşürülen Yosun',
		he:'אצות נפלו מהשונית העליונה ב-Teleoperation',
	},
	tele_coral_drop:{
		name: "Coral Dropped in Teleop",
		type: "avg",
		timeline_stamp: "X",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Corail déposé en téléopération',
		pt:'Coral derrubado em Teleop',
		zh_tw:'珊瑚在遠端操作中掉落',
		tr:'Teleoperasyonda Mercan Bırakıldı',
		he:'אלמוג ירד ב-Teleoperation',
	},
	tele_coral_ground:{
		name: "Coral Collected from Ground in Teleop",
		type: "avg",
		timeline_stamp: "G",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Corail collecté au sol en téléopération',
		pt:'Coral coletado do solo em Teleop',
		zh_tw:'遠端操作從地面收集珊瑚',
		tr:'Teleoperasyonda Yerden Toplanan Mercan',
		he:'אלמוגים שנאספו מהקרקע ב-Teleoperation',
	},
	tele_coral_level_1:{
		name: "Coral Placed on Level 1 During Teleop",
		type: "avg",
		timeline_stamp: "1",
		timeline_fill: "#FFF",
		timeline_outline: "#AAA",
		fr:'Corail placé au niveau 1 pendant la téléopération',
		pt:'Coral colocado no nível 1 durante Teleop',
		zh_tw:'遠端操作期間將珊瑚放置在 1 級',
		tr:'Teleoperasyon Sırasında Seviye 1\'e Yerleştirilen Mercan',
		he:'אלמוג מוצב ברמה 1 במהלך ניתוח טלפוני',
	},
	tele_coral_level_2:{
		name: "Coral Placed on Level 2 During Teleop",
		type: "avg",
		timeline_stamp: "2",
		timeline_fill: "#FFF",
		timeline_outline: "#AAA",
		fr:'Corail placé au niveau 2 pendant la téléopération',
		pt:'Coral colocado no nível 2 durante Teleop',
		zh_tw:'遠端操作期間將珊瑚放置在第 2 層',
		tr:'Teleoperasyon Sırasında Seviye 2\'ye Yerleştirilen Mercan',
		he:'אלמוג הונח על רמה 2 במהלך ניתוח טלפוני',
	},
	tele_coral_level_3:{
		name: "Coral Placed on Level 3 During Teleop",
		type: "avg",
		timeline_stamp: "3",
		timeline_fill: "#FFF",
		timeline_outline: "#AAA",
		fr:'Corail placé au niveau 3 pendant la téléopération',
		pt:'Coral colocado no nível 3 durante Teleop',
		zh_tw:'遠端操作期間將珊瑚放置在第 3 層',
		tr:'Teleoperasyon Sırasında Seviye 3\'e Yerleştirilen Mercan',
		he:'אלמוג מוצב ברמה 3 במהלך ניתוח טלפוני',
	},
	tele_coral_level_4:{
		name: "Coral Placed on Level 4 During Teleop",
		type: "avg",
		timeline_stamp: "4",
		timeline_fill: "#FFF",
		timeline_outline: "#AAA",
		fr:'Corail placé au niveau 4 pendant la téléopération',
		pt:'Coral colocado no nível 4 durante Teleop',
		zh_tw:'遠端操作期間將珊瑚放置在第 4 層',
		tr:'Teleoperasyon Sırasında Seviye 4\'e Yerleştirilen Mercan',
		he:'אלמוג הונח על רמה 4 במהלך ניתוח טלפוני',
	},
	tele_coral_station_1:{
		name: "Coral Collected from Station 1 in Teleop",
		type: "avg",
		timeline_stamp: "S",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Corail collecté à la station 1 en téléopération',
		pt:'Coral coletado da estação 1 em Teleop',
		zh_tw:'遠端操作從 1 號站收集的珊瑚',
		tr:'İstasyon 1\'den Toplanan Mercan Teleoperasyon',
		he:'אלמוגים שנאספו מתחנה 1 ב-Teleoperation',
	},
	tele_coral_station_2:{
		name: "Coral Collected from Station 2 in Teleop",
		type: "avg",
		timeline_stamp: "S",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Corail collecté à la station 2 en téléopération',
		pt:'Coral coletado da estação 2 em Teleop',
		zh_tw:'遠端操作中從 2 號站收集的珊瑚',
		tr:'Teleoperasyonda İstasyon 2\'den Toplanan Mercan',
		he:'קורל שנאסף מתחנה 2 ב-Teleoperation',
	},
	algae_collect:{
		name: 'Algae Collected',
		type: 'avg',
		fr:'Algues collectées',
		pt:'Algas coletadas',
		zh_tw:'收集藻類',
		tr:'Toplanan Yosun',
		he:'אצות נאספו',
	},
	algae_collect_reef:{
		name: 'Algae Collected from Reef',
		type: 'avg',
		fr:'Algues collectées sur le récif',
		pt:'Algas coletadas de Recife',
		zh_tw:'從珊瑚礁收集的藻類',
		tr:'Resiften Toplanan Yosun',
		he:'אצות שנאספו משונית',
	},
	algae_drop:{
		name: 'Algae Dropped',
		type: 'avg',
		fr:'Algues Lâchées',
		pt:'Algas caídas',
		zh_tw:'藻類掉落',
		tr:'Atılan Yosun',
		he:'אצות נשמטו',
	},
	algae_ground:{
		name: 'Algae Collected from Ground',
		type: 'avg',
		fr:'Algues collectées au sol',
		pt:'Algas coletadas do solo',
		zh_tw:'從地面收集的藻類',
		tr:'Yerden Toplanan Yosun',
		he:'אצות שנאספו מהאדמה',
	},
	algae_lower:{
		name: 'Algae Collected from Lower Reef',
		type: 'avg',
		fr:'Algues collectées sur le récif inférieur',
		pt:'Algas coletadas do recife inferior',
		zh_tw:'從下層珊瑚礁收集的藻類',
		tr:'Alt Resiften Toplanan Yosun',
		he:'אצות שנאספו מהשונית התחתונה',
	},
	algae_lower_removed:{
		name: 'Algae Knocked Off Lower Reef',
		type: 'avg',
		fr:'Algues arrachées du récif inférieur',
		pt:'Algas derrubadas do recife inferior',
		zh_tw:'珊瑚礁下部藻類被清除',
		tr:'Alt Resiften Düşen Yosun',
		he:'אצות נפלו מהשונית התחתונה',
	},
	algae_net:{
		name: 'Algae Placed or Shot into the Net by the Robot',
		type: 'avg',
		fr:'Algues placées ou lancées dans le filet par le robot',
		pt:'Algas colocadas ou atiradas na rede pelo robô',
		zh_tw:'機器人將藻類放入或射入網中',
		tr:'Robot Tarafından Ağa Yerleştirilen veya Atılan Yosun',
		he:'אצות שהונחו או ירו ברשת על ידי הרובוט',
	},
	algae_net_score:{
		name: 'Algae Net Score',
		type: 'avg',
		fr:'Score du filet d\'algues',
		pt:'Pontuação da rede de algas',
		zh_tw:'藻類淨評分',
		tr:'Yosun Net Puanı',
		he:'ציון נטו של אצות',
	},
	algae_opponent_net:{
		name: 'Algae Opponent Net',
		type: 'avg',
		fr:'Filet adverse',
		pt:'Rede do oponente de algas',
		zh_tw:'藻類對抗網',
		tr:'Rakip Yosun Net Puanı',
		he:'יריב אצות נטו',
	},
	algae_opponent_net_score:{
		name: 'Algae Opponent Net Score',
		type: 'avg',
		fr:'Score du filet adverse',
		pt:'Pontuação da rede do oponente de algas',
		zh_tw:'海藻對手淨得分',
		tr:'Rakip Yosun Net Puanı',
		he:'ציון נטו של יריב אצות',
	},
	algae_opponent_processor:{
		name: "Algae Placed in the Opponent's Processor",
		type: 'avg',
		fr:'Algues placées dans le processeur adverse',
		pt:'Algas colocadas no processador do oponente',
		zh_tw:'放置在對手處理器中的藻類',
		tr:'Rakip Yosun Net Puanı',
		he:'אצות ממוקמות במעבד של היריב',
	},
	algae_opponent_processor_score:{
		name: 'Algae Opponent Processor Score',
		type: 'avg',
		fr:'Score du processeur adverse',
		pt:'Pontuação do processador do oponente de algas',
		zh_tw:'藻類對手處理器得分',
		tr:'Rakibin İşlemcisine Yerleştirilen Yosun',
		he:'ציון מעבד יריב אצות',
	},
	algae_processor:{
		name: 'Algae Placed in Processor',
		type: 'avg',
		fr:'Algues placées dans le processeur',
		pt:'Algas colocadas no processador',
		zh_tw:'藻類放入處理器',
		tr:'Rakip Yosun İşlemci Puanı',
		he:'אצות ממוקמות במעבד',
	},
	algae_processor_score:{
		name: 'Algae Processor Score',
		type: 'avg',
		fr:'Score du processeur d\'algues',
		pt:'Pontuação do processador de algas',
		zh_tw:'藻類處理器評分',
		tr:'İşlemciye Yerleştirilen Yosun',
		he:'ציון מעבד אצות',
	},
	algae_reef:{
		name: 'Algae Collected from Reef',
		type: 'avg',
		fr:'Algues collectées sur le récif',
		pt:'Algas coletadas do recife',
		zh_tw:'從珊瑚礁收集的藻類',
		tr:'Yosun İşlemci Puanı',
		he:'אצות שנאספו משונית',
	},
	algae_removed_reef:{
		name: 'Algae Knocked Off Reef',
		type: 'avg',
		fr:'Algues arrachées du récif',
		pt:'Algas derrubadas do recife',
		zh_tw:'珊瑚礁上的藻類被清除',
		tr:'Resiften Toplanan Yosun',
		he:'אצות נפלו מהשונית',
	},
	algae_score:{
		name: 'Algae Score',
		type: 'avg',
		fr:'Score des algues',
		pt:'Pontuação das algas',
		zh_tw:'藻類評分',
		tr:'Resiften Düşen Yosun',
		he:'ציון אצות',
	},
	algae_score_total:{
		name: 'Algae Score for FMS Comparison',
		type: 'avg',
		fr:'Score des algues pour la comparaison FMS',
		pt:'Pontuação das algas para comparação de FMS',
		zh_tw:'FMS 比較的藻類評分',
		tr:'Yosun Puanı',
		he:'ציון אצות עבור השוואת FMS',
	},
	algae_upper:{
		name: 'Algae Collected from Upper Reef',
		type: 'avg',
		fr:'Algues collectées sur le récif supérieur',
		pt:'Algas coletadas do recife superior',
		zh_tw:'從上層珊瑚礁收集的藻類',
		tr:'FMS Karşılaştırması İçin Yosun Puanı',
		he:'אצות שנאספו מהשונית העליונה',
	},
	algae_upper_removed:{
		name: 'Algae Knocked Off Upper Reef',
		type: 'avg',
		fr:'Algues arrachées du récif supérieur',
		pt:'Algas derrubadas do recife superior',
		zh_tw:'珊瑚礁上部的藻類被清除',
		tr:'Üst Resiften Toplanan Yosun',
		he:'אצות נפלו מהשונית העליונה',
	},
	auto_algae_collect:{
		name: 'Algae Collected in Auto',
		type: 'avg',
		fr:'Algues collectées en mode automatique',
		pt:'Algas coletadas em Automático',
		zh_tw:'汽車內收集的藻類',
		tr:'Üst Resiften Düşen Yosun',
		he:'אצות שנאספו אוטומטית',
	},
	auto_algae_collect_reef:{
		name: 'Algae Collected from Reef in Auto',
		type: 'avg',
		fr:'Algues collectées sur le récif en mode automatique',
		pt:'Algas coletadas do recife em Automático',
		zh_tw:'從珊瑚礁中自動收集的藻類',
		tr:'Otomatikte Toplanan Yosun',
		he:'אצות שנאספו משונית באוטו',
	},
	auto_algae_ground:{
		name: 'Algae Collected from Ground in Auto',
		type: 'avg',
		fr:'Algues collectées au sol en mode automatique',
		pt:'Algas coletadas do solo em Automático',
		zh_tw:'從汽車地面收集的藻類',
		tr:'Yosun Auto\'da Resiften Toplanan',
		he:'אצות שנאספו מהקרקע באוטו',
	},
	auto_algae_net_score:{
		name: 'Algae Net Score in Auto',
		type: 'avg',
		fr:'Score du filet d\'algues en mode automatique',
		pt:'Pontuação da rede de algas em Automático',
		zh_tw:'汽車中的藻類淨得分',
		tr:'Auto\'da Zeminden Toplanan Yosun',
		he:'ציון נטו אצות באוטומטי',
	},
	auto_algae_opponent_processor_score:{
		name: 'Algae Opponent Processor Score in Auto',
		type: 'avg',
		fr:'Score du processeur adverse en mode automatique',
		pt:'Pontuação do processador do oponente de algas em Automático',
		zh_tw:'藻類對手處理器自動得分',
		tr:'Auto\'da Yosun Net Puanı',
		he:'ציון מעבד יריב אצות באוטומטי',
	},
	auto_algae_place:{
		name: 'Algae Placed in Auto',
		type: 'avg',
		fr:'Algues placées dans Auto',
		pt:'Algas colocadas em Auto',
		zh_tw:'藻類放置在汽車',
		tr:'Auto\'da Yosun Rakip İşlemci Puanı',
		he:'אצות מונחת באוטו',
	},
	auto_algae_processor_net_score:{
		name: 'Algae Processor Net Score in Auto',
		type: 'avg',
		fr:'Score net du processeur d\'algues en mode Auto',
		pt:'Pontuação líquida do processador de algas em Auto',
		zh_tw:'藻類處理器淨得分',
		tr:'Auto\'da Yerleştirilen Yosun',
		he:'ציון נטו של מעבד אצות באוטומטי',
	},
	auto_algae_processor_score:{
		name: 'Algae Processor Score in Auto',
		type: 'avg',
		fr:'Score du processeur d\'algues en mode Auto',
		pt:'Pontuação do processador de algas em Auto',
		zh_tw:'藻類處理器自動評分',
		tr:'Auto\'da Yosun İşlemci Net Puanı',
		he:'ציון מעבד אצות באוטומטי',
	},
	auto_algae_reef:{
		name: 'Algae Collected from Reef in Auto',
		type: 'avg',
		fr:'Algues collectées sur le récif en mode Auto',
		pt:'Algas coletadas do recife em Auto',
		zh_tw:'從珊瑚礁中自動收集的藻類',
		tr:'Auto\'da Yosun İşlemci Puanı',
		he:'אצות שנאספו משונית באוטו',
	},
	auto_algae_removed_reef:{
		name: 'Algae Knocked Off Reef in Auto',
		type: 'avg',
		fr:'Algues retirées du récif en mode Auto',
		pt:'Algas derrubadas do recife em Auto',
		zh_tw:'藻類從汽車中衝出珊瑚礁',
		tr:'Auto\'da Resiften Toplanan Yosun',
		he:'אצות נפלו מהשונית אוטומטית',
	},
	auto_algae_score:{
		name: 'Algae Score in Auto',
		type: 'avg',
		fr:'Score des algues en mode Auto',
		pt:'Pontuação das algas em Auto',
		zh_tw:'自動藻類評分',
		tr:'Auto\'da Resiften Düşürülen Yosun',
		he:'ציון אצות באוטומטי',
	},
	auto_collect:{
		name: 'Scoring Elements Collected in Auto',
		type: 'avg',
		fr:'Éléments collectés en mode Auto',
		pt:'Elementos de pontuação coletados em Auto',
		zh_tw:'自動收集的評分元素',
		tr:'Auto\'da Yosun Puanı',
		he:'רכיבי ניקוד שנאספו אוטומטית',
	},
	auto_coral_collect:{
		name: 'Coral Collected in Auto',
		type: 'avg',
		fr:'Coraux collectés en mode Auto',
		pt:'Coral coletado em Auto',
		zh_tw:'汽車收集的珊瑚',
		tr:'Auto\'da Toplanan Puanlama Elemanları',
		he:'אלמוגים שנאספו באוטו',
	},
	auto_coral_ground:{
		name: 'Coral Collected from Ground in Auto',
		type: 'avg',
		fr:'Coraux collectés au sol en mode Auto',
		pt:'Coral coletado do solo em Auto',
		zh_tw:'汽車從地面收集的珊瑚',
		tr:'Auto\'da Toplanan Mercan',
		he:'אלמוגים שנאספו מהקרקע באוטו',
	},
	auto_coral_score:{
		name: 'Coral Score in Auto',
		type: 'avg',
		fr:'Score des coraux en mode Auto',
		pt:'Pontuação dos corais em Auto',
		zh_tw:'汽車中的珊瑚評分',
		tr:'Auto\'da Zeminden Toplanan Mercan',
		he:'ציון קורל באוטו',
	},
	auto_coral_station:{
		name: 'Coral Collected from Station in Auto',
		type: 'avg',
		fr:'Coraux collectés en station en mode Auto',
		pt:'Coral coletado da estação em Auto',
		zh_tw:'從汽車站收集的珊瑚',
		tr:'Auto\'da Mercan Puanı',
		he:'אלמוגים שנאספו מהתחנה באוטו',
	},
	auto_drop:{
		name: 'Scoring Elements Dropped in Auto',
		type: 'avg',
		fr:'Éléments lâchés en mode Auto',
		pt:'Elementos de pontuação descartados em Auto',
		zh_tw:'自動放棄的得分元素',
		tr:'Auto\'da İstasyondan Toplanan Mercan',
		he:'רכיבי ניקוד נפלו באוטומט',
	},
	cage_score:{
		name: 'Cage Score',
		type: 'avg',
		fr:'Score de la cage',
		pt:'Pontuação da gaiola',
		zh_tw:'籠中得分',
		tr:'Auto\'da Düşen Puanlama Elemanları',
		he:'ציון כלוב',
	},
	collect:{
		name: 'Scoring Elements Collected',
		type: 'avg',
		fr:'Éléments collectés',
		pt:'Elementos de pontuação coletados',
		zh_tw:'收集的評分要素',
		tr:'Kafes Puanı',
		he:'רכיבי ניקוד שנאספו',
	},
	coral_collect:{
		name: 'Coral Collected',
		type: 'avg',
		fr:'Coraux collectés',
		pt:'Coral coletado',
		zh_tw:'收集珊瑚',
		tr:'Toplanan Puanlama Elemanları',
		he:'אלמוגים אספו',
	},
	coral_drop:{
		name: 'Coral Dropped',
		type: 'avg',
		fr:'Coraux lâchés',
		pt:'Coral descartado',
		zh_tw:'珊瑚掉落',
		tr:'Toplanan Mercan',
		he:'אלמוג ירד',
	},
	coral_ground:{
		name: 'Coral Collected from Ground',
		type: 'avg',
		fr:'Coraux collectés au sol',
		pt:'Coral coletado do solo',
		zh_tw:'從地面採集的珊瑚',
		tr:'Düşen Mercan',
		he:'אלמוגים שנאספו מהאדמה',
	},
	coral_score:{
		name: 'Coral Score',
		type: 'avg',
		fr:'Score des coraux',
		pt:'Pontuação dos corais',
		zh_tw:'珊瑚評分',
		tr:'Yerden Toplanan Mercan',
		he:'ציון קורל',
	},
	coral_station:{
		name: 'Coral Collected from Station',
		type: 'avg',
		fr:'Coraux collectés en station',
		pt:'Coral coletado da estação',
		zh_tw:'從遺址收集的珊瑚',
		tr:'Mercan Puanı',
		he:'אלמוגים שנאספו מהתחנה',
	},
	deep:{
		name: 'Deep Cage',
		type: '%',
		fr:'Cage profonde',
		pt:'Gaiola funda',
		zh_tw:'深籠',
		tr:'İstasyondan Toplanan Mercan',
		he:'כלוב עמוק',
	},
	deep_score:{
		name: 'Deep Cage Score',
		type: 'avg',
		fr:'Score de la cage profonde',
		pt:'Pontuação da gaiola funda',
		zh_tw:'深籠得分',
		tr:'Derin Kafes',
		he:'ציון כלוב עמוק',
	},
	drop:{
		name: 'Scoring Elements Dropped',
		type: 'avg',
		fr:'Éléments lâchés',
		pt:'Elementos de pontuação descartados',
		zh_tw:'得分要素被刪除',
		tr:'Derin Kafes Puanı',
		he:'רכיבי ניקוד נשמטו',
	},
	end_game_score:{
		name: 'End Game Score',
		type: 'avg',
		fr:'Score final',
		pt:'Pontuação do final do jogo',
		zh_tw:'遊戲結束分數',
		tr:'Düşen Puanlama Elemanları',
		he:'ציון משחק סיום',
	},
	park:{
		name: 'Park',
		type: '%',
		fr:'Parc',
		pt:'Parque',
		zh_tw:'公園',
		tr:'Oyun Sonu Puan',
		he:'פַּארק',
	},
	park_score:{
		name: 'Park Score',
		type: 'avg',
		fr:'Score du parc',
		pt:'Pontuação do parque',
		zh_tw:'公園評分',
		tr:'Park',
		he:'ציון פארק',
	},
	shallow:{
		name: 'Shallow Cage',
		type: '%',
		fr:'Cage peu profonde',
		pt:'Gaiola rasa',
		zh_tw:'淺籠',
		tr:'Park Puanı',
		he:'כלוב רדוד',
	},
	shallow_score:{
		name: 'Shallow Cage Score',
		type: 'avg',
		fr:'Score de la cage peu profonde',
		pt:'Pontuação da gaiola rasa',
		zh_tw:'淺籠評分',
		tr:'Sığ Kafes',
		he:'ציון כלוב רדוד',
	},
	tele_algae_collect:{
		name: 'Algae Collected in Teleop',
		type: 'avg',
		fr:'Algues collectées en mode Téléopération',
		pt:'Algas coletadas no Teleop',
		zh_tw:'遠端操作收集藻類',
		tr:'Sığ Kafes Puanı',
		he:'אצות שנאספו ב-Teleoperation',
	},
	tele_algae_collect_reef:{
		name: 'Algae Collected Reef in Teleop',
		type: 'avg',
		fr:'Algues collectées sur le récif en mode Téléopération',
		pt:'Algas coletadas do recife em Teleop',
		zh_tw:'遠端操作採集珊瑚礁中的藻類',
		tr:'Teleoperasyonda Toplanan Yosun',
		he:'אצות אסוף ריף ב-Teleoperation',
	},
	tele_algae_net_score:{
		name: 'Algae Net Score in Teleop',
		type: 'avg',
		fr:'Score net des algues en mode Téléopération',
		pt:'Pontuação líquida das algas no Teleop',
		zh_tw:'遠端操作中的藻類網路得分',
		tr:'Teleoperasyonda Resifte Toplanan Yosun',
		he:'ציון נטו אצות ב-Teleoperation',
	},
	tele_algae_opponent_net_score:{
		name: 'Algae Opponent Net Score in Teleop',
		type: 'avg',
		fr:'Score net de l\'adversaire en mode Téléopération',
		pt:'Algas Pontuação líquida do oponente em Teleop',
		zh_tw:'藻類對手遠程操作淨得分',
		tr:'Teleoperasyonda Yosun Net Puanı',
		he:'ציון נטו של יריב אצות ב-Teleoperation',
	},
	tele_algae_opponent_processor_score:{
		name: 'Algae Opponent Processor Score in Teleop',
		type: 'avg',
		fr:'Score du processeur d\'algues adverses en téléopération',
		pt:'Pontuação do processador do oponente de algas em Teleop',
		zh_tw:'藻類對手處理器在遠端操作的得分',
		tr:'Teleoperasyonda Yosun Rakibi Net Puanı',
		he:'ציון מעבד יריב אצות ב-Teleoperation',
	},
	tele_algae_processor_net_score:{
		name: 'Algae Processor Net Score in Teleop',
		type: 'avg',
		fr:'Score net du processeur d\'algues en téléopération',
		pt:'Pontuação líquida do processador de algas em Teleop',
		zh_tw:'藻類處理器遠端操作淨得分',
		tr:'Teleoperasyonda Yosun Rakibi İşlemci Puanı',
		he:'ציון נטו של מעבד אצות ב-Teleoperation',
	},
	tele_algae_processor_score:{
		name: 'Algae Processor Score in Teleop',
		type: 'avg',
		fr:'Score du processeur d\'algues en téléopération',
		pt:'Pontuação do processador de algas em Teleop',
		zh_tw:'藻類處理器在遠端操作的得分',
		tr:'Teleoperasyonda Yosun İşlemci Net Puanı',
		he:'ציון מעבד אצות ב-Teleoperation',
	},
	tele_algae_reef:{
		name: 'Algae Collected from Reef in Teleop',
		type: 'avg',
		fr:'Algues collectées sur le récif en téléopération',
		pt:'Algas coletadas do recife em Teleop',
		zh_tw:'遠端操作從珊瑚礁中收集藻類',
		tr:'Teleoperasyonda Yosun İşlemci Puanı',
		he:'אצות שנאספו משונית ב-Teleoperation',
	},
	tele_algae_removed_reef:{
		name: 'Algae Knocked Off Reef in Teleop',
		type: 'avg',
		fr:'Algues retirées du récif en téléopération',
		pt:'Algas derrubadas do recife em Teleop',
		zh_tw:'遠端操作清除珊瑚礁上的藻類',
		tr:'Teleoperasyonda Resiften Toplanan Yosun',
		he:'אצות נפלו מהשונית ב-Teleoperation',
	},
	tele_algae_score:{
		name: 'Algae Score in Teleop',
		type: 'avg',
		fr:'Score des algues en téléopération',
		pt:'Pontuação de algas em Teleop',
		zh_tw:'遠端操作中的藻類評分',
		tr:'Teleoperasyonda Resiften Düşen Yosun',
		he:'ציון אצות ב-Teleoperation',
	},
	tele_collect:{
		name: 'Scoring Elements Collected in Teleop',
		type: 'avg',
		fr:'Éléments de notation collectés en téléopération',
		pt:'Elementos de pontuação coletados em Teleop',
		zh_tw:'遠端操作中收集的評分要素',
		tr:'Teleoperasyonda Yosun Puanı',
		he:'רכיבי ניקוד שנאספו ב-Teleoperation',
	},
	tele_coral_collect:{
		name: 'Coral Collected in Teleop',
		type: 'avg',
		fr:'Coraux collectés en téléopération',
		pt:'Coral coletado em Teleop',
		zh_tw:'遠端操作採集珊瑚',
		tr:'Teleoperasyonda Toplanan Puanlama Elemanları',
		he:'אלמוגים שנאספו ב-Teleoperation',
	},
	tele_coral_place:{
		name: 'Coral Placed in Teleop',
		type: 'avg',
		fr:'Coraux placés en téléopération',
		pt:'Coral colocado em Teleop',
		zh_tw:'珊瑚被置於遠端操作中',
		tr:'Teleoperasyonda Toplanan Mercan',
		he:'אלמוג מוצב ב-Teleoperation',
	},
	tele_coral_score:{
		name: 'Coral Score in Teleop',
		type: 'avg',
		fr:'Score des coraux en téléopération',
		pt:'Pontuação de coral em Teleop',
		zh_tw:'遠端操作中的珊瑚分數',
		tr:'Teleoperasyonda Yerleştirilen Mercan',
		he:'ציון אלמוגים בטלאופציה',
	},
	tele_coral_station:{
		name: 'Coral Collected from Station in Teleop',
		type: 'avg',
		fr:'Coraux collectés à la station en téléopération',
		pt:'Coral coletado da estação em Teleop',
		zh_tw:'從遠端操作站收集的珊瑚',
		tr:'Teleoperasyonda Mercan Puanı',
		he:'אלמוגים שנאספו מתחנה ב-Teleoperation',
	},
	tele_score:{
		name: 'Score in Teleop',
		type: 'avg',
		fr:'Score en téléopération',
		pt:'Pontuação em Teleop',
		zh_tw:'遠端操作得分',
		tr:'Teleoperasyonda İstasyondan Toplanan Mercan',
		he:'ציון ב-Teleoperation',
	},
	algae_place:{
		name: 'Algae Placed',
		type: 'avg',
		fr:'Algues placées',
		pt:'Algas colocadas',
		zh_tw:'放置藻類',
		tr:'Teleoperasyonda Puan',
		he:'אצות מונחות',
	},
	coral_place:{
		name: 'Coral Placed',
		type: 'avg',
		fr:'Coraux placés',
		pt:'Coral colocado',
		zh_tw:'珊瑚放置',
		tr:'Yerleştirilen Yosun',
		he:'קורל ממוקם',
	},
	tele_algae_place:{
		name: 'Algae Placed in Teleop',
		type: 'avg',
		fr:'Algues placées en téléopération',
		pt:'Algas colocadas em Teleop',
		zh_tw:'藻類用於遠端操作',
		tr:'Yerleştirilen Mercan',
		he:'אצות שהוכנסו לטלאופציה',
	},
	auto_coral_level_1_score:{
		name: 'Coral Score for Level 1 in Auto',
		type: 'avg',
		fr:'Score des coraux pour le niveau 1 en mode automatique',
		pt:'Pontuação de coral para nível 1 em Auto',
		zh_tw:'汽車 1 級珊瑚評分',
		tr:'Yerleştirilen Yosun Teleoperasyonda',
		he:'ציון קורל לרמה 1 באוטו',
	},
	auto_coral_level_2_score:{
		name: 'Coral Score for Level 2 in Auto',
		type: 'avg',
		fr:'Score des coraux pour le niveau 2 en mode automatique',
		pt:'Pontuação de coral para nível 2 em Auto',
		zh_tw:'汽車 2 級珊瑚評分',
		tr:'Otomatikte Seviye 1 için Coral Puanı',
		he:'ציון קורל לרמה 2 באוטו',
	},
	auto_coral_level_3_score:{
		name: 'Coral Score for Level 3 in Auto',
		type: 'avg',
		fr:'Score des coraux pour le niveau 3 en mode automatique',
		pt:'Pontuação de coral para nível 3 em Auto',
		zh_tw:'汽車 3 級珊瑚評分',
		tr:'Otomatikte Seviye 2 için Coral Puanı',
		he:'ציון קורל לרמה 3 באוטו',
	},
	auto_coral_level_4_score:{
		name: 'Coral Score for Level 4 in Auto',
		type: 'avg',
		fr:'Score des coraux pour le niveau 4 en mode automatique',
		pt:'Pontuação de coral para nível 4 em Auto',
		zh_tw:'汽車 4 級珊瑚評分',
		tr:'Otomatikte Seviye 3 için Coral Puanı',
		he:'ציון קורל לרמה 4 באוטו',
	},
	coral_level_1:{
		name: 'Coral Placed on Level 1',
		type: 'avg',
		fr:'Coraux placés au niveau 1',
		pt:'Coral colocado no nível 1',
		zh_tw:'珊瑚放置在第 1 層',
		tr:'Otomatikte Seviye 4 için Coral Puanı',
		he:'אלמוג מוצב ברמה 1',
	},
	coral_level_1_score:{
		name: 'Coral Score for Level 1',
		type: 'avg',
		fr:'Score des coraux pour le niveau 1',
		pt:'Pontuação de coral para nível 1',
		zh_tw:'1 級珊瑚評分',
		tr:'Seviye 1\'e Yerleştirilen Coral',
		he:'ציון קורל לרמה 1',
	},
	coral_level_2:{
		name: 'Coral Placed on Level 2',
		type: 'avg',
		fr:'Coraux placés au niveau 2',
		pt:'Coral colocado no nível 2',
		zh_tw:'珊瑚放置在第 2 層',
		tr:'Seviye 1 için Coral Puanı',
		he:'אלמוג מוצב ברמה 2',
	},
	coral_level_2_score:{
		name: 'Coral Score for Level 2',
		type: 'avg',
		fr:'Score des coraux pour le niveau 2',
		pt:'Pontuação de coral para nível 2',
		zh_tw:'2 級珊瑚評分',
		tr:'Seviye 2\'ye Yerleştirilen Coral',
		he:'ציון קורל לרמה 2',
	},
	coral_level_3:{
		name: 'Coral Placed on Level 3',
		type: 'avg',
		fr:'Coraux placés au niveau 3',
		pt:'Coral colocado no Nível 3',
		zh_tw:'珊瑚放置在第 3 層',
		tr:'Seviye 2 için Coral Puanı',
		he:'אלמוג מוצב ברמה 3',
	},
	coral_level_3_score:{
		name: 'Coral Score for Level 3',
		type: 'avg',
		fr:'Score de corail pour le niveau 3',
		pt:'Pontuação de Coral para o Nível 3',
		zh_tw:'3 級珊瑚評分',
		tr:'Seviye 3\'e Yerleştirilen Coral',
		he:'ציון קורל לרמה 3',
	},
	coral_level_4:{
		name: 'Coral Placed on Level 4',
		type: 'avg',
		fr:'Coraux placés au niveau 4',
		pt:'Coral Colocado no Nível 4',
		zh_tw:'珊瑚放置在第 4 層',
		tr:'Seviye 3 için Coral Puanı',
		he:'אלמוג ממוקם ברמה 4',
	},
	coral_level_4_score:{
		name: 'Coral Score for Level 4',
		type: 'avg',
		fr:'Score de corail pour le niveau 4',
		pt:'Pontuação de Coral para o Nível 4',
		zh_tw:'4 級珊瑚評分',
		tr:'Seviye 4\'e Yerleştirilen Coral',
		he:'ציון קורל לרמה 4',
	},
	coral_station_1:{
		name: 'Coral Collected from Station 1',
		type: 'avg',
		fr:'Coraux collectés à la station 1',
		pt:'Coral Coletado da Estação 1',
		zh_tw:'從 1 號站收集的珊瑚',
		tr:'İstasyon 1\'den Toplanan Coral',
		he:'אלמוגים שנאספו מתחנה 1',
	},
	coral_station_2:{
		name: 'Coral Collected from Station 2',
		type: 'avg',
		fr:'Coraux collectés à la station 2',
		pt:'Coral Coletado da Estação 2',
		zh_tw:'從 2 號站收集的珊瑚',
		tr:'İstasyon 2\'den Toplanan Coral',
		he:'אלמוגים שנאספו מתחנה 2',
	},
	tele_coral_level_1_score:{
		name: 'Coral Score for Level 1 in Teleop',
		type: 'avg',
		fr:'Score de corail pour le niveau 1 en mode téléop.',
		pt:'Pontuação de Coral para o Nível 1 em Teleop',
		zh_tw:'遠端操作一級珊瑚評分',
		tr:'Teleoperasyonda Seviye 1 için Coral Puanı',
		he:'ציון קורל לרמה 1 ב-Teleoperation',
	},
	tele_coral_level_2_score:{
		name: 'Coral Score for Level 2 in Teleop',
		type: 'avg',
		fr:'Score de corail pour le niveau 2 en mode téléop.',
		pt:'Pontuação de Coral para o Nível 2 em Teleop',
		zh_tw:'遠端操作 2 級 Coral 評分',
		tr:'Teleoperasyonda Seviye 2 için Coral Puanı',
		he:'ציון קורל לרמה 2 ב-Teleoperation',
	},
	tele_coral_level_3_score:{
		name: 'Coral Score for Level 3 in Teleop',
		type: 'avg',
		fr:'Score de corail pour le niveau 3 en mode téléop.',
		pt:'Pontuação de Coral para o Nível 3 em Teleop',
		zh_tw:'遠端操作 3 級 Coral 評分',
		tr:'Teleoperasyonda Seviye 3 için Coral Puanı',
		he:'ציון קורל לרמה 3 ב-Teleoperation',
	},
	tele_coral_level_4_score:{
		name: 'Coral Score for Level 4 in Teleop',
		type: 'avg',
		fr:'Score de corail pour le niveau 4 en mode téléop.',
		pt:'Pontuação de Coral para o Nível 4 em Teleop',
		zh_tw:'遠端操作 4 級 Coral 評分',
		tr:'Teleoperasyonda Seviye 4 için Coral Puanı',
		he:'ציון קורל לרמה 4 ב-Teleoperation',
	},
	preferred_coral_level:{
		name: 'Preferred Coral Level',
		type: 'text',
		fr:'Niveau de corail préféré',
		pt:'Nível de Coral Preferido',
		zh_tw:'首選珊瑚等級',
		tr:'Tercih Edilen Coral Seviyesi',
		he:'רמת קורל מועדפת',
	},
	preferred_algae_place:{
		name: 'Preferred Algae Placement',
		type: 'text',
		fr:'Placement d\'algues préféré',
		pt:'Posicionamento de Algas Preferido',
		zh_tw:'首選藻類放置位置',
		tr:'Tercih Edilen Yosun Yerleşimi',
		he:'מיקום אצות מועדף',
	},
	human_player_algae_received:{
		name: 'Human Player Shots',
		type: 'total',
		fr:'Tirs du joueur humain',
		pt:'Tiros de Jogadores Humanos',
		zh_tw:'人類球員射門',
		tr:'İnsan Oyuncu Atışları',
		he:'יריות שחקן אנושי',
	},
	human_player_net:{
		name: 'Human Player Shots Made',
		type: 'total',
		fr:'Tirs effectués par le joueur humain',
		pt:'Tiros de Jogadores Humanos Feitos',
		zh_tw:'人類球員射門次數',
		tr:'Yapılan İnsan Oyuncu Atışları',
		he:'יריות של שחקן אנושי',
	},
	human_player_accuracy:{
		name: 'Human Player Accuracy',
		type: 'ratio',
		fr:'Précision du joueur humain',
		pt:'Precisão de Jogadores Humanos',
		zh_tw:'人類玩家準確度',
		tr:'İnsan Oyuncu Doğruluk',
		he:'דיוק שחקן אנושי',
	},
	algae_litter:{
		name: 'Algae Litter',
		type: 'avg',
		good: 'low',
		fr:'Déchets d\'algues',
		pt:'Lixo de Algas',
		zh_tw:'藻類垃圾',
		tr:'Alg Çöpü',
		he:'המלטה של ​​אצות',
	},
	coral_litter:{
		name: 'Coral Litter',
		type: 'avg',
		good: 'low',
		fr:'Déchets de corail',
		pt:'Lixo de Coral',
		zh_tw:'珊瑚垃圾',
		tr:'Mercan Çöpü',
		he:'המלטה של ​​אלמוגים',
	},
	litter:{
		name: 'Litter',
		type: 'avg',
		good: 'low',
		fr:'Déchets',
		pt:'Lixo',
		zh_tw:'垃圾',
		tr:'Çöp',
		he:'אַשׁפָּה',
	},
	auto_paths:{
		name: "Auto Paths",
		type: "pathlist",
		aspect_ratio: .916,
		whiteboard_start: 0,
		whiteboard_end: 50,
		whiteboard_us: true,
		source: "pit",
		fr:'Trajectoires automatiques',
		pt:'Caminhos Automáticos',
		zh_tw:'自動路徑',
		tr:'Otomatik Yollar',
		he:'נתיבים אוטומטיים',
	},
	tele_algae_theft:{
		name: 'Algae Theft in Teleop',
		type: '%',
		timeline_stamp: "T",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Vol d\'algues en mode téléop.',
		pt:'Roubo de Algas em Teleop',
		zh_tw:'遠端操作中的藻類盜竊',
		tr:'Teleoperasyonda Yosun Hırsızlığı',
		he:'גניבת אצות ב-Teleoperation',
	},
	tele_coral_theft:{
		name: 'Coral Theft in Teleop',
		type: '%',
		timeline_stamp: "T",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Vol de corail en mode téléop.',
		pt:'Roubo de Coral em Teleop',
		zh_tw:'遠端操作中的珊瑚盜竊',
		tr:'Teleoperasyonda Mercan Hırsızlığı',
		he:'גניבת אלמוגים ב-Teleoperation',
	},
	tele_theft:{
		name: 'Theft in Teleop',
		type: '%',
		fr:'Vol en mode téléop.',
		pt:'Roubo em Teleop',
		zh_tw:'遠端操作中的盜竊',
		tr:'Teleoperasyonda Hırsızlık',
		he:'גניבה ב-Teleoperation',
	},
	coral_stuck:{
		name: 'Coral Stuck',
		type: '%',
		fr:'Corail coincé',
		pt:'Coral Preso',
		zh_tw:'珊瑚卡住了',
		tr:'Mercan Sıkışması',
		he:'קורל תקוע',
	},
	climb_time:{
		name: 'Climb Time (seconds)',
		type: 'num',
		good: 'low',
		timeline_stamp: "C",
		timeline_fill: "#888",
		timeline_outline: "#888",
		fr:'Temps d\'ascension (secondes)',
		pt:'Tempo de Escalada (segundos)',
		zh_tw:'爬升時間（秒）',
		tr:'Tırmanma Süresi (saniye)',
		he:'זמן טיפוס (שניות)',
	},
	max_algae_place:{
		name: 'Max Algae Placed',
		type: 'minmax',
		fr:'Algues max. placées',
		pt:'Máx. Algas Colocadas',
		zh_tw:'最大藻類投放量',
		tr:'Yerleştirilen Maksimum Yosun',
		he:'מקסימום אצות הוצבו',
	},
	max_auto_algae_place:{
		name: 'Max Algae Placed in Auto',
		type: 'minmax',
		fr:'Algues max. placées en mode automatique',
		pt:'Máx. Algas Colocadas em Automático',
		zh_tw:'自動放置的最大藻類',
		tr:'Otomatikte Yerleştirilen Maksimum Yosun',
		he:'מקסימום אצות מוצבות באוטו',
	},
	max_auto_coral_place:{
		name: 'Max Coral Placed in Auto',
		type: 'minmax',
		fr:'Coraux max. placés en mode automatique',
		pt:'Máx. Coral Colocado em Automático',
		zh_tw:'自動放置最大珊瑚',
		tr:'Otomatikte Yerleştirilen Maksimum Mercan',
		he:'מקסימום אלמוגים ממוקם באוטו',
	},
	max_auto_place:{
		name: 'Max Scoring Elements Placed in Auto',
		type: 'minmax',
		fr:'Éléments de score max. placés en mode automatique',
		pt:'Máx. Elementos de Pontuação Colocados em Automático',
		zh_tw:'自動放置的最大得分元素',
		tr:'Otomatikte Yerleştirilen Maksimum Puanlama Elemanları',
		he:'רכיבי ניקוד מקסימליים ממוקמים אוטומטית',
	},
	max_coral_place:{
		name: 'Max Coral Placed',
		type: 'minmax',
		fr:'Coraux max. Placé',
		pt:'Máx. Coral colocado',
		zh_tw:'放置的最大珊瑚數量',
		tr:'Yerleştirilen Maksimum Mercan',
		he:'מקסימום קורל ממוקם',
	},
	max_place:{
		name: 'Max Scoring Elements Placed',
		type: 'minmax',
		fr:'Nombre maximal d\'éléments de score placés',
		pt:'Elementos de pontuação máxima colocados',
		zh_tw:'放置的最高得分元素',
		tr:'Yerleştirilen Maksimum Puanlama Elemanları',
		he:'רכיבי ניקוד מקסימליים ממוקמים',
	},
	max_tele_algae_place:{
		name: 'Max Algae Placed in Teleop',
		type: 'minmax',
		fr:'Nombre maximal d\'algues placées en téléopération',
		pt:'Algas máximas colocadas em Teleop',
		zh_tw:'遠端操作中放置的最大藻類',
		tr:'Teleoperasyonda Yerleştirilen Maksimum Yosun',
		he:'מקסימום אצות מוצבות ב-Teleoperation',
	},
	max_tele_coral_place:{
		name: 'Max Coral Placed in Teleop',
		type: 'minmax',
		fr:'Max Coral placé en téléopération',
		pt:'Max Coral Colocado em Teleop',
		zh_tw:'遠端操作中放置的最大珊瑚數量',
		tr:'Teleoperasyonda Yerleştirilen Maksimum Mercan',
		he:'מקסימום אלמוג ממוקם ב-Teleoperation',
	},
	max_tele_place:{
		name: 'Max Scoring Elements Placed in Teleop',
		type: 'minmax',
		fr:'Max Éléments de score placés en téléopération',
		pt:'Elementos de Pontuação Máxima Colocados em Teleop',
		zh_tw:'遠端操作中的最大得分元素',
		tr:'Teleoperasyonda Yerleştirilen Maksimum Puanlama Elemanları',
		he:'רכיבי ניקוד מקסימליים ממוקמים ב-Teleoperation',
	},
}

var teamGraphs={
	"Game Stage":{
		graph:"stacked",
		data:["auto_score","tele_score","end_game_score"],
	},
	"Match Timeline":{
		graph:"timeline",
		data:['timeline'],
	},
	"Scoring Element Cycles":{
		graph:"stacked",
		data:["algae_place","coral_place"],
	},
	"Scoring Locations":{
		graph:"stacked",
		data:["algae_processor","algae_net","coral_level_1","coral_level_2","coral_level_3","coral_level_4"],
	},
}

var aggregateGraphs = {
	"Match Score":{
		graph:"boxplot",
		data:["max_score","score","min_score"],
	},
	"Game Stage":{
		graph:"stacked",
		data:["auto_score","tele_score","end_game_score"],
	},
	"Scoring Element Cycles":{
		graph:"stacked",
		data:["algae_place","coral_place"],
	},
	"Scoring Locations":{
		graph:"stacked",
		data:["algae_processor","algae_net","coral_level_1","coral_level_2","coral_level_3","coral_level_4"],
	},
	"Human Player":{
		graph:"bar",
		data:["human_player_algae_received","human_player_net"],
	},
	"Human Player Accuracy":{
		graph:"bar",
		data:["human_player_accuracy"],
	}
}

var matchPredictorSections={
	Total:{
		tr:'Total',
		he:'סַך הַכֹּל',
		zh_tw:'全部的',
		pt:'Total',
		fr:'Total',
		data:["score"],
	},
	"Game Stage":{
		tr:'Fase do Jogo',
		he:'שלב המשחק',
		zh_tw:'遊戲舞台',
		pt:'Fase do Jogo',
		fr:'Phase de jeu',
		data:["auto_score","tele_score","end_game_score"],
	},
	"Scoring Element":{
		tr:'Elemento de Pontuação',
		he:'אלמנט ניקוד',
		zh_tw:'評分要素',
		pt:'Elemento de Pontuação',
		fr:'Élément de score',
		data:["coral_score","algae_score"],
	},
	"Placement":{
		tr:'Colocação',
		he:'מיקום',
		zh_tw:'放置',
		pt:'Colocação',
		fr:'Placement',
		data:["coral_level_1_score","coral_level_2_score","coral_level_3_score","coral_level_4_score","algae_processor_score","algae_net_score"],
	},
}

var whiteboardStamps=[]

var fieldRotationalSymmetry=true

window.whiteboard_aspect_ratio=2.18

var whiteboardStats=[
	"score",
	"auto_score",
	"tele_score",
	"end_game_score",
	"algae_place",
	"preferred_algae_place",
	"algae_litter",
	"coral_place",
	"preferred_coral_level",
	"coral_litter",
	"human_player_accuracy",
	"human_player_algae_received",
	"auto_start",
	"auto_paths",
]

// https://www.postman.com/firstrobotics/workspace/frc-fms-public-published-workspace/example/13920602-f345156c-f083-4572-8d4a-bee22a3fdea1
var fmsMapping=[
	[["autoMobilityPoints"],["auto_leave_score"]],
	[["autoCoralPoints"],["auto_coral_score"]],
	[["teleopCoralPoints"],["tele_coral_score"]],
	[["algaePoints"],["algae_score_total"]],
	[["endGameBargePoints"],["end_game_score"]],
]

function showPitScouting(el,team){
	promisePitScouting().then(pitData => {
		var dat=pitData[team]||{},
		section=$('<fieldset>').append($('<legend>').attr('data-i18n','team_info_legend')),
		ti=(window.eventTeamsInfo||{})[team]||{}
		dlText(section,'team_name_label',dat.team_name||ti.nameShort)
		dlText(section,'team_location_label',dat.team_location||ti.city?`${ti.city}, ${ti.stateProv}, ${ti.country}`:'')
		dlText(section,'bot_name_label',dat.bot_name||ti.robotName)
		el.append(section)

		section=$('<fieldset>').append($('<legend>').attr('data-i18n','robot_legend'))
		dlText(section,'robot_size_question',`${dat.frame_length}x${dat.frame_width}`,'robot_size_unit')
		dlText(section,'robot_weight_question',dat.weight,'robot_weight_unit')
		dlTranslation(section,'robot_drivetrain_question',dat.drivetrain,'robot_drivetrain_')
		dlTranslation(section,'robot_swerve_question',dat.swerve,'robot_swerve_')
		dlText(section,'drivetrain_motor_count_question',dat.motor_count)
		dlTranslation(section,'drivetrain_motor_type_question',dat.motors,'motor_type_')
		dlText(section,'wheel_count_question',dat.wheel_count)
		dlTranslation(section,'wheel_type_question',dat.wheels,'wheel_type_')
		el.append(section)

		section=$('<fieldset>').append($('<legend>').attr('data-i18n','vision_question'))
		divCheckbox(section,'vision_collecting',dat.vision_auto)
		divCheckbox(section,'vision_auto',dat.vision_collecting)
		divCheckbox(section,'vision_placing',dat.vision_placing)
		divCheckbox(section,'vision_localization',dat.vision_localization)
		el.append(section)

		applyTranslations()
	})

	function divCheckbox(parent,key,value){
		parent.append($('<div>').attr('data-i18n',key).toggleClass('unused',!is(value)))
	}

	function dlText(parent,question,s,unit){
		parent.append($("<dl>").append($('<dt>').attr('data-i18n',question)).append(text($('<dd>'),s,unit)))
	}

	function text(node,s,unit){
		if (is(s)){
			node.text(s)
			if (unit)node.append(' ').append($('<span>').attr('data-i18n',unit))
		}else node.attr('data-i18n','pit_scout_not_answered')
		return node
	}

	function dlTranslation(parent,question,s,prefix){
		parent.append($("<dl>").append($('<dt>').attr('data-i18n',question)).append(translation($('<dd>'),s,prefix)))
	}

	function translation(node,s,prefix){
		return node.attr('data-i18n',is(s)?`${prefix}${s}`.replace(/-/g,'_'):'pit_scout_not_answered')
	}

	function is(s){
		return s&&s!="0"&&!/^undefined/.test(s)
	}
}

function showSubjectiveScouting(el,team){
	promiseSubjectiveScouting().then(subjectiveData => {
		var dat=subjectiveData[team]||{}
		el.append($('<fieldset>').append($('<legend data-i18n=subjective_penalties_question>').append($('<div style=white-space:pre-wrap>').text(dat.penalties||""))))
		el.append($('<fieldset>').append($('<legend data-i18n=subjective_defense_question>').append($('<div style=white-space:pre-wrap>').text(dat.defense_tips||""))))
		el.append($('<fieldset>').append($('<legend data-i18n=subjective_notes_question>').append($('<div style=white-space:pre-wrap>').text(dat.notes||""))))
		applyTranslations()
	})
}
