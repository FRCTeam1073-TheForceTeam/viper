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
	},
	match:{
		name: "Match",
		type: "text",
		fr:'Match',
		pt:'Partida',
	},
	team:{
		name: "Team",
		type: "text",
		fr:'Équipe',
		pt:'Equipe',
	},
	count:{
		name: 'Matches Scouted',
		type: 'num',
		fr:'Matchs repérés',
		pt:'Partidas observadas',
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
	},
	auto_leave:{
		name: "Left the Start Line During Auto",
		type: "%",
		timeline_stamp: "L",
		timeline_fill: "#888",
		timeline_outline: "#888",
		fr:'A quitté la ligne de départ pendant l\'automatisme',
		pt:'Deixou a linha de partida durante o modo automático',
	},
	auto_leave_score:{
		name: "Score for Leaving the Start Line During Auto",
		type: "avg",
		fr:'Score pour avoir quitté la ligne de départ pendant l\'automatisme',
		pt:'Pontuação por deixar a linha de partida durante o modo automático',
	},
	no_show:{
		name: "No Show",
		type: "%",
		timeline_stamp: "N",
		timeline_fill: "#F0F",
		timeline_outline: "#F0F",
		fr:'Absence',
		pt:'Não comparecimento',
	},
	defense:{
		name: "Played Defense",
		type: "%",
		fr:'Défense jouée',
		pt:'Defesa jogada',
	},
	bricked:{
		name: "Robot Disabled",
		type: "%",
		fr:'Robot désactivé',
		pt:'Robô desabilitado',
	},
	auto_algae_drop:{
		name: "Algae Dropped in Auto",
		type: "avg",
		timeline_stamp: "X",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#4eb0a4",
		fr:'Algues lâchées en automatisme',
		pt:'Algas caídas no modo automático',
	},
	auto_algae_lower:{
		name: "Algae Collected from Lower Reef in Auto",
		type: "avg",
		timeline_stamp: "R",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues collectées sur le récif inférieur en automatisme',
		pt:'Algas coletadas do recife inferior no modo automático',
	},
	auto_algae_lower_removed:{
		name: "Algae Knocked Off Lower Reef in Auto",
		type: "avg",
		timeline_stamp: "↓",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues projetées hors du récif inférieur en automatisme',
		pt:'Algas arrancadas do recife inferior no modo automático',
	},
	auto_algae_mark_1:{
		name: "Algae Collected from Mark 1 in Auto",
		type: "%",
		timeline_stamp: "G",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues collectées sur la marque 1 en automatisme',
		pt:'Algas coletadas da marca 1 no modo automático',
	},
	auto_algae_mark_2:{
		name: "Algae Collected from Mark 2 in Auto",
		type: "%",
		timeline_stamp: "G",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues collectées sur la marque 2 en automatisme',
		pt:'Algas coletadas da marca 2 no modo automático',
	},
	auto_algae_mark_3:{
		name: "Algae Collected from Mark 3 in Auto",
		type: "%",
		timeline_stamp: "G",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues collectées sur la marque 3 en automatisme',
		pt:'Algas coletadas da marca 3 no modo automático',
	},
	auto_algae_net:{
		name: "Algae Placed in Net by Robot in Auto",
		type: "avg",
		timeline_stamp: "N",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#4eb0a4",
		fr:'Algues placées dans le filet par le robot en automatisme',
		pt:'Algas colocadas na rede pelo robô no modo automático',
	},
	auto_algae_opponent_processor:{
		name: "Algae Placed in the Opponent's Processor in Auto",
		type: "avg",
		timeline_stamp: "O",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#4eb0a4",
		fr:'Algues placées dans le processeur de l\'adversaire en automatisme',
		pt:'Algas colocadas no processador do oponente no modo automático',
	},
	auto_algae_processor:{
		name: "Algae Placed in the Processor in Auto",
		type: "avg",
		timeline_stamp: "P",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#4eb0a4",
		fr:'Algues placées dans le processeur en automatisme',
		pt:'Algas colocadas no processador no modo automático',
	},
	auto_algae_upper:{
		name: "Algae Collected from Upper Reef in Auto",
		type: "avg",
		timeline_stamp: "R",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues collectées sur le récif supérieur en automatisme',
		pt:'Algas coletadas do recife superior no modo automático',
	},
	auto_algae_upper_removed:{
		name: "Algae Knocked Off Upper Reef in Auto",
		type: "avg",
		timeline_stamp: "↓",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues projetées hors du récif supérieur en automatisme',
		pt:'Algas arrancadas do recife superior no modo automático',
	},
	auto_coral_drop:{
		name: "Coral Dropped in Auto",
		type: "avg",
		timeline_stamp: "X",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Corail lâché en automatisme',
		pt:'Coral caído no modo automático',
	},
	auto_coral_mark_1:{
		name: "Coral Collected from Mark 1 in Auto",
		type: "%",
		timeline_stamp: "G",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Corail collecté sur la marque 1 en automatisme',
		pt:'Coral coletado da marca 1 no modo automático',
	},
	auto_coral_mark_2:{
		name: "Coral Collected from Mark 2 in Auto",
		type: "%",
		timeline_stamp: "G",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Corail collecté sur la marque 2 en automatisme',
		pt:'Coral coletado da marca 2 no modo Auto',
	},
	auto_coral_mark_3:{
		name: "Coral Collected from Mark 3 in Auto",
		type: "%",
		timeline_stamp: "G",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Corail Récupéré au niveau 3 en mode automatique',
		pt:'Coral coletado da marca 3 em Auto',
	},
	auto_coral_level_1:{
		name: "Coral Placed on Level 1 During Auto",
		type: "avg",
		timeline_stamp: "1",
		timeline_fill: "#FFF",
		timeline_outline: "#AAA",
		fr:'Coraux placés au niveau 1 en mode automatique',
		pt:'Coral colocado no nível 1 durante Auto',
	},
	auto_coral_level_2:{
		name: "Coral Placed on Level 2 During Auto",
		type: "avg",
		timeline_stamp: "2",
		timeline_fill: "#FFF",
		timeline_outline: "#AAA",
		fr:'Coraux placés au niveau 2 en mode automatique',
		pt:'Coral colocado no nível 2 durante Auto',
	},
	auto_coral_level_3:{
		name: "Coral Placed on Level 3 During Auto",
		type: "avg",
		timeline_stamp: "3",
		timeline_fill: "#FFF",
		timeline_outline: "#AAA",
		fr:'Coraux placés au niveau 3 en mode automatique',
		pt:'Coral colocado no nível 3 durante Auto',
	},
	auto_coral_level_4:{
		name: "Coral Placed on Level 4 During Auto",
		type: "avg",
		timeline_stamp: "4",
		timeline_fill: "#FFF",
		timeline_outline: "#AAA",
		fr:'Coraux placés au niveau 4 en mode automatique',
		pt:'Coral colocado no nível 4 durante Auto',
	},
	auto_coral_station_1:{
		name: "Coral Collected from Station 1 in Auto",
		type: "avg",
		timeline_stamp: "S",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Coraux récupérés à la station 1 en mode automatique',
		pt:'Coral coletado da estação 1 em Auto',
	},
	auto_coral_station_2:{
		name: "Coral Collected from Station 1 in Auto",
		type: "avg",
		timeline_stamp: "S",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Coraux récupérés à la station 1 en mode automatique',
		pt:'Coral coletado da estação 1 em Auto',
	},
	auto_coral_place:{
		name: "Coral Placed During Auto",
		type: "avg",
		fr:'Coraux placés en mode automatique',
		pt:'Coral colocado durante Auto',
	},
	auto_place:{
		name: "Scoring Elements Placed During Auto",
		type: "avg",
		fr:'Éléments de score placés en mode automatique',
		pt:'Elementos de pontuação colocados durante Auto',
	},
	auto_score:{
		name: "Score in Auto",
		type: "avg",
		fr:'Score en mode automatique',
		pt:'Pontuação em Auto',
	},
	coral_preload:{
		name: "Coral Preloaded Before Match",
		type: "%",
		fr:'Coraux préchargés avant le match',
		pt:'Coral pré-carregado antes da partida',
	},
	end_game_climb_fail:{
		name: "Climb Failed",
		type: "%",
		fr:'Escalade échouée',
		pt:'Escalada falhou',
	},
	end_game_position:{
		name: "End Game Position",
		type: "text",
		fr:'Position finale',
		pt:'Posição final do jogo',
	},
	tele_drop:{
		name: "Scoring Elements Dropped in Teleop",
		type: "avg",
		fr:'Éléments de score déposés en mode téléop.',
		pt:'Elementos de pontuação descartados no teleop',
	},
	tele_place:{
		name: "Scoring Elements Placed During Teleop",
		type: "avg",
		fr:'Éléments de score déposés en mode téléop.',
		pt:'Elementos de pontuação colocados durante o teleop',
	},
	opponent_human_player_team:{
		name: "Opponent Human Player Team",
		type: "text",
		fr:'Équipe adverse (joueurs humains)',
		pt:'Equipe de jogadores humanos oponentes',
	},
	place:{
		name: "Scoring Elements Placed",
		type: "avg",
		fr:'Éléments de score déposés',
		pt:'Elementos de pontuação colocados',
	},
	parked_score:{
		name: "Parking Score",
		type: "avg",
		fr:'Score de stationnement',
		pt:'Pontuação de estacionamento',
	},
	end_game_position:{
		name: "Position at End of Game",
		type: "text",
		fr:'Position en fin de partie',
		pt:'Posição no final do jogo',
	},
	timeline:{
		name: "Timeline",
		type: "timeline",
		fr:'Chronologie',
		pt:'Linha do tempo',
	},
	max_score:{
		name: "Maximum Score Contribution",
		type: "minmax",
		fr:'Contribution maximale au score',
		pt:'Contribuição máxima de pontuação',
	},
	min_score:{
		name: "Minimum Score Contribution",
		type: "minmax",
		fr:'Contribution minimale au score',
		pt:'Contribuição mínima de pontuação',
	},
	score:{
		name: "Score Contribution",
		type: "avg",
		fr:'Contribution au score',
		pt:'Contribuição de pontuação',
	},
	scouter:{
		name: "Scouter",
		type: "text",
		fr:'Scouteur',
		pt:'Patrulheiro',
	},
	comments:{
		name: "Comments",
		type: "text",
		fr:'Commentaires',
		pt:'Comentários',
	},
	created:{
		name: "Created",
		type: "datetime",
		fr:'Créé',
		pt:'Criado',
	},
	modified:{
		name: "Modified",
		type: "datetime",
		fr:'Modifié',
		pt:'Modificado',
	},
	tele_algae_drop:{
		name: "Algae Dropped in Teleop",
		type: "avg",
		timeline_stamp: "X",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#4eb0a4",
		fr:'Algues déposées en mode téléop.',
		pt:'Algas caídas no teleop',
	},
	tele_algae_ground:{
		name: "Algae Collected from Ground in Teleop",
		type: "avg",
		timeline_stamp: "G",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues collectées au sol en Téléopération',
		pt:'Algas coletadas de Solo em Teleop',
	},
	tele_algae_lower:{
		name: "Algae Collected from Lower Reef in Teleop",
		type: "",
		timeline_stamp: "R",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues collectées sur le récif inférieur en téléopération',
		pt:'Algas coletadas do recife inferior em Teleop',
	},
	tele_algae_lower_removed:{
		name: "Algae Knocked Off Lower Reef in Teleop",
		type: "avg",
		timeline_stamp: "↓",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues retirées du récif inférieur en téléopération',
		pt:'Algas derrubadas do recife inferior em Teleop',
	},
	tele_algae_net:{
		name: "Algae Placed in Net by Robot in Teleop",
		type: "avg",
		timeline_stamp: "N",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#4eb0a4",
		fr:'Algues placées dans un filet par un robot en téléopération',
		pt:'Algas colocadas na rede pelo robô em Teleop',
	},
	tele_algae_opponent_net:{
		name: "Algae Thrown in Net by Opponent Human Player in Teleop",
		type: "avg",
		timeline_stamp: "H",
		timeline_fill: "#888",
		timeline_outline: "#888",
		fr:'Algues lancées dans un filet par un joueur humain adverse en téléopération',
		pt:'Algas lançadas na rede pelo jogador humano oponente em Teleop',
	},
	tele_algae_opponent_processor:{
		name: "Algae Placed in the Opponent's Processor in Teleop",
		type: "avg",
		timeline_stamp: "O",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#4eb0a4",
		fr:'Algues placées dans le processeur adverse en téléopération',
		pt:'Algas colocadas no processador do oponente em Teleop',
	},
	tele_algae_processor:{
		name: "Algae Placed in the Processor in Teleop",
		type: "avg",
		timeline_stamp: "P",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#4eb0a4",
		fr:'Algues placées dans le processeur en téléopération',
		pt:'Algas colocadas no processador em Teleop',
	},
	tele_algae_upper:{
		name: "Algae Collected from Upper Reef in Teleop",
		type: "avg",
		timeline_stamp: "R",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues collectées sur le récif supérieur en téléopération',
		pt:'Algas coletadas do recife superior em Teleop',
	},
	tele_algae_upper_removed:{
		name: "Algae Knocked Off Upper Reef in Teleop",
		type: "avg",
		timeline_stamp: "↓",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Algues retirées du récif supérieur en téléopération',
		pt:'Algas derrubadas do recife superior em Teleop',
	},
	tele_coral_drop:{
		name: "Coral Dropped in Teleop",
		type: "avg",
		timeline_stamp: "X",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Corail déposé en téléopération',
		pt:'Coral derrubado em Teleop',
	},
	tele_coral_ground:{
		name: "Coral Collected from Ground in Teleop",
		type: "avg",
		timeline_stamp: "G",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Corail collecté au sol en téléopération',
		pt:'Coral coletado do solo em Teleop',
	},
	tele_coral_level_1:{
		name: "Coral Placed on Level 1 During Teleop",
		type: "avg",
		timeline_stamp: "1",
		timeline_fill: "#FFF",
		timeline_outline: "#AAA",
		fr:'Corail placé au niveau 1 pendant la téléopération',
		pt:'Coral colocado no nível 1 durante Teleop',
	},
	tele_coral_level_2:{
		name: "Coral Placed on Level 2 During Teleop",
		type: "avg",
		timeline_stamp: "2",
		timeline_fill: "#FFF",
		timeline_outline: "#AAA",
		fr:'Corail placé au niveau 2 pendant la téléopération',
		pt:'Coral colocado no nível 2 durante Teleop',
	},
	tele_coral_level_3:{
		name: "Coral Placed on Level 3 During Teleop",
		type: "avg",
		timeline_stamp: "3",
		timeline_fill: "#FFF",
		timeline_outline: "#AAA",
		fr:'Corail placé au niveau 3 pendant la téléopération',
		pt:'Coral colocado no nível 3 durante Teleop',
	},
	tele_coral_level_4:{
		name: "Coral Placed on Level 4 During Teleop",
		type: "avg",
		timeline_stamp: "4",
		timeline_fill: "#FFF",
		timeline_outline: "#AAA",
		fr:'Corail placé au niveau 4 pendant la téléopération',
		pt:'Coral colocado no nível 4 durante Teleop',
	},
	tele_coral_station_1:{
		name: "Coral Collected from Station 1 in Teleop",
		type: "avg",
		timeline_stamp: "S",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Corail collecté à la station 1 en téléopération',
		pt:'Coral coletado da estação 1 em Teleop',
	},
	tele_coral_station_2:{
		name: "Coral Collected from Station 2 in Teleop",
		type: "avg",
		timeline_stamp: "S",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Corail collecté à la station 2 en téléopération',
		pt:'Coral coletado da estação 2 em Teleop',
	},
	algae_collect:{
		name: 'Algae Collected',
		type: 'avg',
		fr:'Algues collectées',
		pt:'Algas coletadas',
	},
	algae_collect_reef:{
		name: 'Algae Collected from Reef',
		type: 'avg',
		fr:'Algues collectées sur le récif',
		pt:'Algas coletadas de Recife',
	},
	algae_drop:{
		name: 'Algae Dropped',
		type: 'avg',
		fr:'Algues Lâchées',
		pt:'Algas caídas',
	},
	algae_ground:{
		name: 'Algae Collected from Ground',
		type: 'avg',
		fr:'Algues collectées au sol',
		pt:'Algas coletadas do solo',
	},
	algae_lower:{
		name: 'Algae Collected from Lower Reef',
		type: 'avg',
		fr:'Algues collectées sur le récif inférieur',
		pt:'Algas coletadas do recife inferior',
	},
	algae_lower_removed:{
		name: 'Algae Knocked Off Lower Reef',
		type: 'avg',
		fr:'Algues arrachées du récif inférieur',
		pt:'Algas derrubadas do recife inferior',
	},
	algae_net:{
		name: 'Algae Placed or Shot into the Net by the Robot',
		type: 'avg',
		fr:'Algues placées ou lancées dans le filet par le robot',
		pt:'Algas colocadas ou atiradas na rede pelo robô',
	},
	algae_net_score:{
		name: 'Algae Net Score',
		type: 'avg',
		fr:'Score du filet d\'algues',
		pt:'Pontuação da rede de algas',
	},
	algae_opponent_net:{
		name: 'Algae Opponent Net',
		type: 'avg',
		fr:'Filet adverse',
		pt:'Rede do oponente de algas',
	},
	algae_opponent_net_score:{
		name: 'Algae Opponent Net Score',
		type: 'avg',
		fr:'Score du filet adverse',
		pt:'Pontuação da rede do oponente de algas',
	},
	algae_opponent_processor:{
		name: "Algae Placed in the Opponent's Processor",
		type: 'avg',
		fr:'Algues placées dans le processeur adverse',
		pt:'Algas colocadas no processador do oponente',
	},
	algae_opponent_processor_score:{
		name: 'Algae Opponent Processor Score',
		type: 'avg',
		fr:'Score du processeur adverse',
		pt:'Pontuação do processador do oponente de algas',
	},
	algae_processor:{
		name: 'Algae Placed in Processor',
		type: 'avg',
		fr:'Algues placées dans le processeur',
		pt:'Algas colocadas no processador',
	},
	algae_processor_score:{
		name: 'Algae Processor Score',
		type: 'avg',
		fr:'Score du processeur d\'algues',
		pt:'Pontuação do processador de algas',
	},
	algae_reef:{
		name: 'Algae Collected from Reef',
		type: 'avg',
		fr:'Algues collectées sur le récif',
		pt:'Algas coletadas do recife',
	},
	algae_removed_reef:{
		name: 'Algae Knocked Off Reef',
		type: 'avg',
		fr:'Algues arrachées du récif',
		pt:'Algas derrubadas do recife',
	},
	algae_score:{
		name: 'Algae Score',
		type: 'avg',
		fr:'Score des algues',
		pt:'Pontuação das algas',
	},
	algae_score_total:{
		name: 'Algae Score for FMS Comparison',
		type: 'avg',
		fr:'Score des algues pour la comparaison FMS',
		pt:'Pontuação das algas para comparação de FMS',
	},
	algae_upper:{
		name: 'Algae Collected from Upper Reef',
		type: 'avg',
		fr:'Algues collectées sur le récif supérieur',
		pt:'Algas coletadas do recife superior',
	},
	algae_upper_removed:{
		name: 'Algae Knocked Off Upper Reef',
		type: 'avg',
		fr:'Algues arrachées du récif supérieur',
		pt:'Algas derrubadas do recife superior',
	},
	auto_algae_collect:{
		name: 'Algae Collected in Auto',
		type: 'avg',
		fr:'Algues collectées en mode automatique',
		pt:'Algas coletadas em Automático',
	},
	auto_algae_collect_reef:{
		name: 'Algae Collected from Reef in Auto',
		type: 'avg',
		fr:'Algues collectées sur le récif en mode automatique',
		pt:'Algas coletadas do recife em Automático',
	},
	auto_algae_ground:{
		name: 'Algae Collected from Ground in Auto',
		type: 'avg',
		fr:'Algues collectées au sol en mode automatique',
		pt:'Algas coletadas do solo em Automático',
	},
	auto_algae_net_score:{
		name: 'Algae Net Score in Auto',
		type: 'avg',
		fr:'Score du filet d\'algues en mode automatique',
		pt:'Pontuação da rede de algas em Automático',
	},
	auto_algae_opponent_processor_score:{
		name: 'Algae Opponent Processor Score in Auto',
		type: 'avg',
		fr:'Score du processeur adverse en mode automatique',
		pt:'Pontuação do processador do oponente de algas em Automático',
	},
	auto_algae_place:{
		name: 'Algae Placed in Auto',
		type: 'avg',
		fr:'Algues placées dans Auto',
		pt:'Algas colocadas em Auto',
	},
	auto_algae_processor_net_score:{
		name: 'Algae Processor Net Score in Auto',
		type: 'avg',
		fr:'Score net du processeur d\'algues en mode Auto',
		pt:'Pontuação líquida do processador de algas em Auto',
	},
	auto_algae_processor_score:{
		name: 'Algae Processor Score in Auto',
		type: 'avg',
		fr:'Score du processeur d\'algues en mode Auto',
		pt:'Pontuação do processador de algas em Auto',
	},
	auto_algae_reef:{
		name: 'Algae Collected from Reef in Auto',
		type: 'avg',
		fr:'Algues collectées sur le récif en mode Auto',
		pt:'Algas coletadas do recife em Auto',
	},
	auto_algae_removed_reef:{
		name: 'Algae Knocked Off Reef in Auto',
		type: 'avg',
		fr:'Algues retirées du récif en mode Auto',
		pt:'Algas derrubadas do recife em Auto',
	},
	auto_algae_score:{
		name: 'Algae Score in Auto',
		type: 'avg',
		fr:'Score des algues en mode Auto',
		pt:'Pontuação das algas em Auto',
	},
	auto_collect:{
		name: 'Scoring Elements Collected in Auto',
		type: 'avg',
		fr:'Éléments collectés en mode Auto',
		pt:'Elementos de pontuação coletados em Auto',
	},
	auto_coral_collect:{
		name: 'Coral Collected in Auto',
		type: 'avg',
		fr:'Coraux collectés en mode Auto',
		pt:'Coral coletado em Auto',
	},
	auto_coral_ground:{
		name: 'Coral Collected from Ground in Auto',
		type: 'avg',
		fr:'Coraux collectés au sol en mode Auto',
		pt:'Coral coletado do solo em Auto',
	},
	auto_coral_score:{
		name: 'Coral Score in Auto',
		type: 'avg',
		fr:'Score des coraux en mode Auto',
		pt:'Pontuação dos corais em Auto',
	},
	auto_coral_station:{
		name: 'Coral Collected from Station in Auto',
		type: 'avg',
		fr:'Coraux collectés en station en mode Auto',
		pt:'Coral coletado da estação em Auto',
	},
	auto_drop:{
		name: 'Scoring Elements Dropped in Auto',
		type: 'avg',
		fr:'Éléments lâchés en mode Auto',
		pt:'Elementos de pontuação descartados em Auto',
	},
	cage_score:{
		name: 'Cage Score',
		type: 'avg',
		fr:'Score de la cage',
		pt:'Pontuação da gaiola',
	},
	collect:{
		name: 'Scoring Elements Collected',
		type: 'avg',
		fr:'Éléments collectés',
		pt:'Elementos de pontuação coletados',
	},
	coral_collect:{
		name: 'Coral Collected',
		type: 'avg',
		fr:'Coraux collectés',
		pt:'Coral coletado',
	},
	coral_drop:{
		name: 'Coral Dropped',
		type: 'avg',
		fr:'Coraux lâchés',
		pt:'Coral descartado',
	},
	coral_ground:{
		name: 'Coral Collected from Ground',
		type: 'avg',
		fr:'Coraux collectés au sol',
		pt:'Coral coletado do solo',
	},
	coral_score:{
		name: 'Coral Score',
		type: 'avg',
		fr:'Score des coraux',
		pt:'Pontuação dos corais',
	},
	coral_station:{
		name: 'Coral Collected from Station',
		type: 'avg',
		fr:'Coraux collectés en station',
		pt:'Coral coletado da estação',
	},
	deep:{
		name: 'Deep Cage',
		type: '%',
		fr:'Cage profonde',
		pt:'Gaiola funda',
	},
	deep_score:{
		name: 'Deep Cage Score',
		type: 'avg',
		fr:'Score de la cage profonde',
		pt:'Pontuação da gaiola funda',
	},
	drop:{
		name: 'Scoring Elements Dropped',
		type: 'avg',
		fr:'Éléments lâchés',
		pt:'Elementos de pontuação descartados',
	},
	end_game_score:{
		name: 'End Game Score',
		type: 'avg',
		fr:'Score final',
		pt:'Pontuação do final do jogo',
	},
	park:{
		name: 'Park',
		type: '%',
		fr:'Parc',
		pt:'Parque',
	},
	park_score:{
		name: 'Park Score',
		type: 'avg',
		fr:'Score du parc',
		pt:'Pontuação do parque',
	},
	shallow:{
		name: 'Shallow Cage',
		type: '%',
		fr:'Cage peu profonde',
		pt:'Gaiola rasa',
	},
	shallow_score:{
		name: 'Shallow Cage Score',
		type: 'avg',
		fr:'Score de la cage peu profonde',
		pt:'Pontuação da gaiola rasa',
	},
	tele_algae_collect:{
		name: 'Algae Collected in Teleop',
		type: 'avg',
		fr:'Algues collectées en mode Téléopération',
		pt:'Algas coletadas no Teleop',
	},
	tele_algae_collect_reef:{
		name: 'Algae Collected Reef in Teleop',
		type: 'avg',
		fr:'Algues collectées sur le récif en mode Téléopération',
		pt:'Algas coletadas do recife em Teleop',
	},
	tele_algae_net_score:{
		name: 'Algae Net Score in Teleop',
		type: 'avg',
		fr:'Score net des algues en mode Téléopération',
		pt:'Pontuação líquida das algas no Teleop',
	},
	tele_algae_opponent_net_score:{
		name: 'Algae Opponent Net Score in Teleop',
		type: 'avg',
		fr:'Score net de l\'adversaire en mode Téléopération',
		pt:'Algas Pontuação líquida do oponente em Teleop',
	},
	tele_algae_opponent_processor_score:{
		name: 'Algae Opponent Processor Score in Teleop',
		type: 'avg',
		fr:'Score du processeur d\'algues adverses en téléopération',
		pt:'Pontuação do processador do oponente de algas em Teleop',
	},
	tele_algae_processor_net_score:{
		name: 'Algae Processor Net Score in Teleop',
		type: 'avg',
		fr:'Score net du processeur d\'algues en téléopération',
		pt:'Pontuação líquida do processador de algas em Teleop',
	},
	tele_algae_processor_score:{
		name: 'Algae Processor Score in Teleop',
		type: 'avg',
		fr:'Score du processeur d\'algues en téléopération',
		pt:'Pontuação do processador de algas em Teleop',
	},
	tele_algae_reef:{
		name: 'Algae Collected from Reef in Teleop',
		type: 'avg',
		fr:'Algues collectées sur le récif en téléopération',
		pt:'Algas coletadas do recife em Teleop',
	},
	tele_algae_removed_reef:{
		name: 'Algae Knocked Off Reef in Teleop',
		type: 'avg',
		fr:'Algues retirées du récif en téléopération',
		pt:'Algas derrubadas do recife em Teleop',
	},
	tele_algae_score:{
		name: 'Algae Score in Teleop',
		type: 'avg',
		fr:'Score des algues en téléopération',
		pt:'Pontuação de algas em Teleop',
	},
	tele_collect:{
		name: 'Scoring Elements Collected in Teleop',
		type: 'avg',
		fr:'Éléments de notation collectés en téléopération',
		pt:'Elementos de pontuação coletados em Teleop',
	},
	tele_coral_collect:{
		name: 'Coral Collected in Teleop',
		type: 'avg',
		fr:'Coraux collectés en téléopération',
		pt:'Coral coletado em Teleop',
	},
	tele_coral_place:{
		name: 'Coral Placed in Teleop',
		type: 'avg',
		fr:'Coraux placés en téléopération',
		pt:'Coral colocado em Teleop',
	},
	tele_coral_score:{
		name: 'Coral Score in Teleop',
		type: 'avg',
		fr:'Score des coraux en téléopération',
		pt:'Pontuação de coral em Teleop',
	},
	tele_coral_station:{
		name: 'Coral Collected from Station in Teleop',
		type: 'avg',
		fr:'Coraux collectés à la station en téléopération',
		pt:'Coral coletado da estação em Teleop',
	},
	tele_score:{
		name: 'Score in Teleop',
		type: 'avg',
		fr:'Score en téléopération',
		pt:'Pontuação em Teleop',
	},
	algae_place:{
		name: 'Algae Placed',
		type: 'avg',
		fr:'Algues placées',
		pt:'Algas colocadas',
	},
	coral_place:{
		name: 'Coral Placed',
		type: 'avg',
		fr:'Coraux placés',
		pt:'Coral colocado',
	},
	tele_algae_place:{
		name: 'Algae Placed in Teleop',
		type: 'avg',
		fr:'Algues placées en téléopération',
		pt:'Algas colocadas em Teleop',
	},
	auto_coral_level_1_score:{
		name: 'Coral Score for Level 1 in Auto',
		type: 'avg',
		fr:'Score des coraux pour le niveau 1 en mode automatique',
		pt:'Pontuação de coral para nível 1 em Auto',
	},
	auto_coral_level_2_score:{
		name: 'Coral Score for Level 2 in Auto',
		type: 'avg',
		fr:'Score des coraux pour le niveau 2 en mode automatique',
		pt:'Pontuação de coral para nível 2 em Auto',
	},
	auto_coral_level_3_score:{
		name: 'Coral Score for Level 3 in Auto',
		type: 'avg',
		fr:'Score des coraux pour le niveau 3 en mode automatique',
		pt:'Pontuação de coral para nível 3 em Auto',
	},
	auto_coral_level_4_score:{
		name: 'Coral Score for Level 4 in Auto',
		type: 'avg',
		fr:'Score des coraux pour le niveau 4 en mode automatique',
		pt:'Pontuação de coral para nível 4 em Auto',
	},
	coral_level_1:{
		name: 'Coral Placed on Level 1',
		type: 'avg',
		fr:'Coraux placés au niveau 1',
		pt:'Coral colocado no nível 1',
	},
	coral_level_1_score:{
		name: 'Coral Score for Level 1',
		type: 'avg',
		fr:'Score des coraux pour le niveau 1',
		pt:'Pontuação de coral para nível 1',
	},
	coral_level_2:{
		name: 'Coral Placed on Level 2',
		type: 'avg',
		fr:'Coraux placés au niveau 2',
		pt:'Coral colocado no nível 2',
	},
	coral_level_2_score:{
		name: 'Coral Score for Level 2',
		type: 'avg',
		fr:'Score des coraux pour le niveau 2',
		pt:'Pontuação de coral para nível 2',
	},
	coral_level_3:{
		name: 'Coral Placed on Level 3',
		type: 'avg',
		fr:'Coraux placés au niveau 3',
		pt:'Coral colocado no Nível 3',
	},
	coral_level_3_score:{
		name: 'Coral Score for Level 3',
		type: 'avg',
		fr:'Score de corail pour le niveau 3',
		pt:'Pontuação de Coral para o Nível 3',
	},
	coral_level_4:{
		name: 'Coral Placed on Level 4',
		type: 'avg',
		fr:'Coraux placés au niveau 4',
		pt:'Coral Colocado no Nível 4',
	},
	coral_level_4_score:{
		name: 'Coral Score for Level 4',
		type: 'avg',
		fr:'Score de corail pour le niveau 4',
		pt:'Pontuação de Coral para o Nível 4',
	},
	coral_station_1:{
		name: 'Coral Collected from Station 1',
		type: 'avg',
		fr:'Coraux collectés à la station 1',
		pt:'Coral Coletado da Estação 1',
	},
	coral_station_2:{
		name: 'Coral Collected from Station 2',
		type: 'avg',
		fr:'Coraux collectés à la station 2',
		pt:'Coral Coletado da Estação 2',
	},
	tele_coral_level_1_score:{
		name: 'Coral Score for Level 1 in Teleop',
		type: 'avg',
		fr:'Score de corail pour le niveau 1 en mode téléop.',
		pt:'Pontuação de Coral para o Nível 1 em Teleop',
	},
	tele_coral_level_2_score:{
		name: 'Coral Score for Level 2 in Teleop',
		type: 'avg',
		fr:'Score de corail pour le niveau 2 en mode téléop.',
		pt:'Pontuação de Coral para o Nível 2 em Teleop',
	},
	tele_coral_level_3_score:{
		name: 'Coral Score for Level 3 in Teleop',
		type: 'avg',
		fr:'Score de corail pour le niveau 3 en mode téléop.',
		pt:'Pontuação de Coral para o Nível 3 em Teleop',
	},
	tele_coral_level_4_score:{
		name: 'Coral Score for Level 4 in Teleop',
		type: 'avg',
		fr:'Score de corail pour le niveau 4 en mode téléop.',
		pt:'Pontuação de Coral para o Nível 4 em Teleop',
	},
	preferred_coral_level:{
		name: 'Preferred Coral Level',
		type: 'text',
		fr:'Niveau de corail préféré',
		pt:'Nível de Coral Preferido',
	},
	preferred_algae_place:{
		name: 'Preferred Algae Placement',
		type: 'text',
		fr:'Placement d\'algues préféré',
		pt:'Posicionamento de Algas Preferido',
	},
	human_player_algae_received:{
		name: 'Human Player Shots',
		type: 'total',
		fr:'Tirs du joueur humain',
		pt:'Tiros de Jogadores Humanos',
	},
	human_player_net:{
		name: 'Human Player Shots Made',
		type: 'total',
		fr:'Tirs effectués par le joueur humain',
		pt:'Tiros de Jogadores Humanos Feitos',
	},
	human_player_accuracy:{
		name: 'Human Player Accuracy',
		type: 'ratio',
		fr:'Précision du joueur humain',
		pt:'Precisão de Jogadores Humanos',
	},
	algae_litter:{
		name: 'Algae Litter',
		type: 'avg',
		good: 'low',
		fr:'Déchets d\'algues',
		pt:'Lixo de Algas',
	},
	coral_litter:{
		name: 'Coral Litter',
		type: 'avg',
		good: 'low',
		fr:'Déchets de corail',
		pt:'Lixo de Coral',
	},
	litter:{
		name: 'Litter',
		type: 'avg',
		good: 'low',
		fr:'Déchets',
		pt:'Lixo',
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
	},
	tele_algae_theft:{
		name: 'Algae Theft in Teleop',
		type: '%',
		timeline_stamp: "T",
		timeline_fill: "#4eb0a4",
		timeline_outline: "#222",
		fr:'Vol d\'algues en mode téléop.',
		pt:'Roubo de Algas em Teleop',
	},
	tele_coral_theft:{
		name: 'Coral Theft in Teleop',
		type: '%',
		timeline_stamp: "T",
		timeline_fill: "#FFF",
		timeline_outline: "#222",
		fr:'Vol de corail en mode téléop.',
		pt:'Roubo de Coral em Teleop',
	},
	tele_theft:{
		name: 'Theft in Teleop',
		type: '%',
		fr:'Vol en mode téléop.',
		pt:'Roubo em Teleop',
	},
	coral_stuck:{
		name: 'Coral Stuck',
		type: '%',
		fr:'Corail coincé',
		pt:'Coral Preso',
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
	},
	max_algae_place:{
		name: 'Max Algae Placed',
		type: 'minmax',
		fr:'Algues max. placées',
		pt:'Máx. Algas Colocadas',
	},
	max_auto_algae_place:{
		name: 'Max Algae Placed in Auto',
		type: 'minmax',
		fr:'Algues max. placées en mode automatique',
		pt:'Máx. Algas Colocadas em Automático',
	},
	max_auto_coral_place:{
		name: 'Max Coral Placed in Auto',
		type: 'minmax',
		fr:'Coraux max. placés en mode automatique',
		pt:'Máx. Coral Colocado em Automático',
	},
	max_auto_place:{
		name: 'Max Scoring Elements Placed in Auto',
		type: 'minmax',
		fr:'Éléments de score max. placés en mode automatique',
		pt:'Máx. Elementos de Pontuação Colocados em Automático',
	},
	max_coral_place:{
		name: 'Max Coral Placed',
		type: 'minmax',
		fr:'Coraux max. Placé',
		pt:'Máx. Coral colocado',
	},
	max_place:{
		name: 'Max Scoring Elements Placed',
		type: 'minmax',
		fr:'Nombre maximal d\'éléments de score placés',
		pt:'Elementos de pontuação máxima colocados',
	},
	max_tele_algae_place:{
		name: 'Max Algae Placed in Teleop',
		type: 'minmax',
		fr:'Nombre maximal d\'algues placées en téléopération',
		pt:'Algas máximas colocadas em Teleop',
	},
	max_tele_coral_place:{
		name: 'Max Coral Placed in Teleop',
		type: 'minmax',
		fr:'Max Coral placé en téléopération',
		pt:'Max Coral Colocado em Teleop',
	},
	max_tele_place:{
		name: 'Max Scoring Elements Placed in Teleop',
		type: 'minmax',
		fr:'Max Éléments de score placés en téléopération',
		pt:'Elementos de Pontuação Máxima Colocados em Teleop',
	},
}

var teamGraphs={
	"Game Stage":{
		graph:"stacked",
		data:["auto_score","tele_score","end_game_score"],
	},
	"Match Timeline":{
		graph:"timeline",
		data:['timeline']
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
	Total:["score"],
	"Game Stage":["auto_score","tele_score","end_game_score"],
	"Scoring Element":["coral_score","algae_score"],
	"Placement":["coral_level_1_score","coral_level_2_score","coral_level_3_score","coral_level_4_score","algae_processor_score","algae_net_score"]
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
		var dat=pitData[team]||{}
		if (dat.team_name) el.append($("<p>").text("Team name: " + dat.team_name))
		if (dat.team_location) el.append($("<p>").text("Location: " + dat.team_location))
		if (dat.bot_name) el.append($("<p>").text("Bot name: " + dat.bot_name))

		el.append($("<h4>").text("Robot"))
		var list=$("<ul>")
		list.append($("<li>").text("Dimensions (inches without bumpers): " + format(dat.frame_length+'x'+dat.frame_width+'"')))
		list.append($("<li>").text("Weight (pounds): "+ format(dat.weight)))
		list.append($("<li>").text("Drivetrain: " + format(dat.drivetrain)))
		list.append($("<li>").text("Swerve: " + format(dat.swerve)))
		list.append($("<li>").text("Drivetrain motors: " + (dat.motor_count||"")+" "+format(dat.motors)))
		list.append($("<li>").text("Wheels: " + (dat.wheel_count||"")+" "+format(dat.wheels)))
		el.append(list)

		el.append($("<h4>").text("Computer Vision"))
		list=$("<ul>")
		list.append((dat.vision_auto?$('<li>'):$('<li style=text-decoration:line-through>')).text("Auto"))
		list.append((dat.vision_collecting?$('<li>'):$('<li style=text-decoration:line-through>')).text("Collecting"))
		list.append((dat.vision_placing?$('<li>'):$('<li style=text-decoration:line-through>')).text("Placing, shooting or aiming"))
		list.append((dat.vision_localization?$('<li>'):$('<li style=text-decoration:line-through>')).text("Localization"))
		el.append(list)
	})

	function format(s){
		s=""+s
		if (!s||s=="0"||/^undefined/.test(s)) s="Unknown"
		s=s[0].toUpperCase() + s.slice(1)
		return s.replace(/_/g," ")
	}
}

function showSubjectiveScouting(el,team){
	promiseSubjectiveScouting().then(subjectiveData => {
		var dat=subjectiveData[team]||{},
		graph=$('<div class=graph>'),
		f=dat.penalties||""
		el.append(graph)
		if (f){
			el.append('<h4>Penalties</h4>')
			el.append($('<div style=white-space:pre-wrap>').text(f))
		}
		f=dat.defense_tips||""
		if (f){
			el.append('<h4>Defense Tips</h4>')
			el.append($('<div style=white-space:pre-wrap>').text(f))
		}
		f=dat.notes||""
		if (f){
			el.append('<h4>Other</h4>')
			el.append($('<div style=white-space:pre-wrap>').text(f))
		}
	})
}
