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
	scout.algae_opponent_net=scout.auto_algae_opponent_net+scout.tele_algae_opponent_net
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
	scout.coral_station_1=scout.auto_coral_station_1+scout.tele_coral_station_1
	scout.coral_station_2=scout.auto_coral_station_2+scout.tele_coral_station_2
	scout.auto_coral_station=scout.auto_coral_station_1+scout.auto_coral_station_2
	scout.tele_coral_station=scout.tele_coral_station_1+scout.tele_coral_station_2
	scout.coral_station=scout.auto_coral_station+scout.tele_coral_station
	scout.auto_coral_collect=scout.auto_coral_ground+scout.auto_coral_station
	scout.tele_coral_collect=scout.tele_coral_ground+scout.tele_coral_station
	scout.coral_collect=scout.auto_coral_collect+scout.tele_coral_collect
	scout.auto_algae_collect_reef=scout.auto_algae_upper+scout.auto_algae_lower
	scout.auto_algae_removed_reef=scout.auto_algae_lower_removed+scout.auto_algae_upper_removed
	scout.auto_algae_reef=scout.auto_algae_collect_reef+scout.auto_algae_removed_reef
	scout.auto_algae_collect=scout.auto_algae_reef+scout.auto_algae_ground
	scout.auto_collect=scout.auto_coral_collect+scout.auto_algae_collect
	scout.tele_algae_collect_reef=scout.tele_algae_upper+scout.tele_algae_lower
	scout.tele_algae_removed_reef=scout.tele_algae_lower_removed+scout.tele_algae_upper_removed
	scout.tele_algae_reef=scout.tele_algae_collect_reef+scout.tele_algae_removed_reef
	scout.tele_algae_collect=scout.tele_algae_reef+scout.tele_algae_ground
	scout.tele_collect=scout.tele_coral_collect+scout.tele_algae_collect
	scout.algae_collect_reef=scout.auto_algae_collect_reef+scout.tele_algae_collect_reef
	scout.algae_removed_reef=scout.auto_algae_removed_reef+scout.tele_algae_removed_reef
	scout.algae_reef=scout.auto_algae_reef+scout.tele_algae_reef
	scout.algae_collect=scout.auto_algae_collect+scout.tele_algae_collect
	scout.collect=scout.auto_collect+scout.tele_collect
	scout.auto_drop=scout.auto_algae_drop+scout.auto_coral_drop
	scout.tele_drop=scout.tele_algae_drop+scout.tele_coral_drop
	scout.drop=scout.auto_drop+scout.tele_drop
	scout.park=bool_1_0(scout.end_game_position=='park')
	scout.shallow=bool_1_0(scout.end_game_position=='shallow')
	scout.deep=bool_1_0(scout.end_game_position=='deep')
	scout.algae_place=scout.auto_algae_place+scout.tele_algae_place
	scout.coral_place=scout.auto_coral_place+scout.tele_coral_place
	scout.place=scout.auto_place+scout.tele_place

	scout.auto_leave_score=pointValues.auto_leave*scout.auto_leave
	scout.auto_coral_level_1_score=pointValues.auto_l1*scout.auto_coral_level_1
	scout.auto_coral_level_2_score=pointValues.auto_l2*scout.auto_coral_level_2
	scout.auto_coral_level_3_score=pointValues.auto_l3*scout.auto_coral_level_3
	scout.auto_coral_level_4_score=pointValues.auto_l4*scout.auto_coral_level_4
	scout.auto_algae_processor_score=pointValues.processor*scout.auto_algae_processor
	scout.auto_algae_opponent_net_score=-pointValues.net*scout.auto_algae_processor
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
	scout.auto_algae_processor_net_score=scout.auto_algae_processor_score + scout.auto_algae_opponent_net_score
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
	scout.algae_opponent_net_score=scout.auto_algae_opponent_net_score+scout.tele_algae_opponent_net_score
	scout.algae_net_score=scout.auto_algae_net_score+scout.tele_algae_net_score
	scout.algae_opponent_processor_score=scout.auto_algae_opponent_processor_score+scout.tele_algae_opponent_processor_score
	scout.algae_score=scout.auto_algae_score+scout.tele_algae_score
	scout.coral_score=scout.auto_coral_score+scout.tele_coral_score
	scout.auto_score=scout.auto_coral_score+scout.auto_algae_score
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
	aggregate.preferred_coral_level=getPreferredCoralLevel(aggregate.coral_level_1,aggregate.coral_level_2,aggregate.coral_level_3,aggregate.coral_level_4)

	if(scout.algae_processor&&/^[1-9][0-9]*$/.test(scout.opponent_human_player_team)){
		var hpTeam = parseInt(scout.opponent_human_player_team),
		hpScout = eventStatsByMatchTeam[`${match}-${hpTeam}`]||={},
		hpAggregate = eventStatsByTeam[hpTeam]||={}
		hpScout.human_player_algae_received=(hpScout.human_player_algae_received||0)+scout.algae_processor+(((scout.old||{}).human_player_algae_received)||0)
		hpAggregate.human_player_algae_received=(hpAggregate.human_player_algae_received||0)+scout.algae_processor
		hpScout.human_player_net=(hpScout.human_player_net||0)+scout.algae_opponent_net+(((scout.old||{}).human_player_net)||0)
		hpAggregate.human_player_net=(hpAggregate.human_player_net||0)+scout.algae_opponent_net
		hpScout.human_player_accuracy=hpScout.human_player_algae_received>0?hpScout.human_player_net/hpScout.human_player_algae_received:0
		hpAggregate.human_player_accuracy=hpAggregate.human_player_algae_received>0?hpAggregate.human_player_net/hpAggregate.human_player_algae_received:0
	}
	if (scout.old &&(typeof scout.old.score=='undefined'))scout.old=null
}

var statInfo={
	event:{
		name: 'Event',
		type: 'text'
	},
	match:{
		name: "Match",
		type: "text"
	},
	team:{
		name: "Team",
		type: "text"
	},
	count:{
		name: 'Count',
		type: 'num'
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
		whiteboard_invert: true
	},
	auto_leave:{
		name: "Left the Start Line During Auto",
		type: "%",
		timeline_stamp: "L",
		timeline_fill: "#BB0",
		timeline_outline: "#888"
	},
	auto_leave_score:{
		name: "Score for Leaving the Start Line During Auto",
		type: "avg"
	},
	no_show:{
		name: "No Show",
		type: "%",
		timeline_stamp: "N",
		timeline_fill: "#F0F",
		timeline_outline: "#F0F"
	},
	defense:{
		name: "Played Defense",
		type: "%"
	},
	bricked:{
		name: "Robot Disabled",
		type: "%"
	},
	auto_algae_drop:{
		name: "Algae Dropped in Auto",
		type: "avg",
	},
	auto_algae_lower:{
		name: "Algae Collected from Lower Reef in Auto",
		type: "avg",
	},
	auto_algae_lower_removed:{
		name: "Algae Knocked Off Lower Reef in Auto",
		type: "avg",
	},
	auto_algae_mark_1:{
		name: "Algae Collected from Mark 1 in Auto",
		type: "%",
	},
	auto_algae_mark_2:{
		name: "Algae Collected from Mark 2 in Auto",
		type: "%",
	},
	auto_algae_mark_3:{
		name: "Algae Collected from Mark 3 in Auto",
		type: "%",
	},
	auto_algae_net:{
		name: "Algae Placed in Net by Robot in Auto",
		type: "avg",
	},
	auto_algae_opponent_net:{
		name: "Algae Thrown in Net by Opponent Human Player in Auto",
		type: "avg",
	},
	auto_algae_opponent_processor:{
		name: "Algae Placed in the Opponent's Processor in Auto",
		type: "avg",
	},
	auto_algae_processor:{
		name: "Algae Placed in the Processor in Auto",
		type: "avg",
	},
	auto_algae_upper:{
		name: "Algae Collected from Upper Reef in Auto",
		type: "avg",
	},
	auto_algae_upper_removed:{
		name: "Algae Knocked Off Upper Reef in Auto",
		type: "avg",
	},
	auto_coral_drop:{
		name: "Coral Dropped in Auto",
		type: "avg",
	},
	auto_coral_mark_1:{
		name: "Coral Collected from Mark 1 in Auto",
		type: "%",
	},
	auto_coral_mark_2:{
		name: "Coral Collected from Mark 2 in Auto",
		type: "%",
	},
	auto_coral_mark_3:{
		name: "Coral Collected from Mark 3 in Auto",
		type: "%",
	},
	auto_coral_level_1:{
		name: "Level 1 Coral Placed During Auto",
		type: "avg"
	},
	auto_coral_level_2:{
		name: "Level 2 Coral Placed During Auto",
		type: "avg"
	},
	auto_coral_level_3:{
		name: "Level 3 Coral Placed During Auto",
		type: "avg"
	},
	auto_coral_level_4:{
		name: "Level 4 Coral Placed During Auto",
		type: "avg"
	},
	auto_coral_station_1:{
		name: "Coral Collected from Station 1 in Auto",
		type: "avg",
	},
	auto_coral_station_2:{
		name: "Coral Collected from Station 1 in Auto",
		type: "avg",
	},
	auto_coral_place:{
		name: "Coral Placed During Auto",
		type: "avg"
	},
	auto_place:{
		name: "Scoring Elements Placed During Auto",
		type: "avg"
	},
	auto_score:{
		name: "Score During Auto",
		type: "avg"
	},
	auto_place_percent:{
		name: "Percent of Scoring Elements Placed During Auto",
		type: "ratio"
	},
	coral_preload:{
		name: "Coral Preloaded Before Match",
		type: "%",
	},
	end_game_climb_fail:{
		name: "Climb Failed",
		type: "%"
	},
	end_game_position:{
		name: "End Game Position",
		type: "text",
	},
	tele_drop:{
		name: "Scoring Elements Dropped in Teleop",
		type: "avg",
		timeline_stamp: "D",
		timeline_fill: "#000",
		timeline_outline: "#808"
	},
	tele_place:{
		name: "Scoring Elements Placed During Teleop",
		type: "avg"
	},
	opponent_human_player_team:{
		name: "Opponent Human Player Team",
		type: "text",
	},
	place:{
		name: "Scoring Elements Placed",
		type: "avg"
	},
	parked_score:{
		name: "Parking Score",
		type: "avg"
	},
	end_game_position:{
		name: "Position at End of Game",
		type: "text"
	},
	timeline:{
		name: "Timeline",
		type: "timeline"
	},
	max_score:{
		name: "Maximum Score Contribution",
		type: "minmax"
	},
	min_score:{
		name: "Minimum Score Contribution",
		type: "minmax"
	},
	score:{
		name: "Score Contribution",
		type: "avg"
	},
	scouter:{
		name: "Scouter",
		type: "text"
	},
	comments:{
		name: "Comments",
		type: "text"
	},
	created:{
		name: "Created",
		type: "datetime"
	},
	modified:{
		name: "Modified",
		type: "datetime"
	},
	tele_algae_drop:{
		name: "Algae Dropped in Teleop",
		type: "avg",
	},
	tele_algae_ground:{
		name: "Algae Collected from Ground in Teleop",
		type: "avg",
	},
	tele_algae_lower:{
		name: "Algae Collected from Lower Reef in Teleop",
		type: "",
	},
	tele_algae_lower_removed:{
		name: "Algae Knocked Off Lower Reef in Teleop",
		type: "avg",
	},
	tele_algae_net:{
		name: "Algae Placed in Net by Robot in Teleop",
		type: "avg",
	},
	tele_algae_opponent_net:{
		name: "Algae Thrown in Net by Opponent Human Player in Teleop",
		type: "avg",
	},
	tele_algae_opponent_processor:{
		name: "Algae Placed in the Opponent's Processor in Teleop",
		type: "avg",
	},
	tele_algae_processor:{
		name: "Algae Placed in the Processor in Teleop",
		type: "avg",
	},
	tele_algae_upper:{
		name: "Algae Collected from Upper Reef in Teleop",
		type: "avg",
	},
	tele_algae_upper_removed:{
		name: "Algae Knocked Off Upper Reef in Teleop",
		type: "avg",
	},
	tele_coral_drop:{
		name: "Coral Dropped in Teleop",
		type: "avg",
	},
	tele_coral_ground:{
		name: "Coral Collected from Ground in Teleop",
		type: "avg",
	},
	tele_coral_level_1:{
		name: "Level 1 Coral Placed During Teleop",
		type: "avg",
	},
	tele_coral_level_2:{
		name: "Level 2 Coral Placed During Teleop",
		type: "avg",
	},
	tele_coral_level_3:{
		name: "Level 3 Coral Placed During Teleop",
		type: "avg",
	},
	tele_coral_level_4:{
		name: "Level 4 Coral Placed During Teleop",
		type: "avg",
	},
	tele_coral_station_1:{
		name: "Coral Collected from Station 1 in Teleop",
		type: "avg",
	},
	tele_coral_station_2:{
		name: "Coral Collected from Station 2 in Teleop",
		type: "avg",
	},
	algae_collect:{
		name: 'Algae Collected',
		type: 'avg'
	},
	algae_collect_reef:{
		name: 'Algae Collected from Reef',
		type: 'avg'
	},
	algae_drop:{
		name: 'Algae Dropped',
		type: 'avg'
	},
	algae_ground:{
		name: 'Algae Collected from Ground',
		type: 'avg'
	},
	algae_lower:{
		name: 'Algae Collected from Lower Reef',
		type: 'avg'
	},
	algae_lower_removed:{
		name: 'Algae Knocked Off Lower Reef',
		type: 'avg'
	},
	algae_net:{
		name: 'Algae Placed or Shot into the Net by the Robot',
		type: 'avg'
	},
	algae_net_score:{
		name: 'Algae Net Score',
		type: 'avg'
	},
	algae_opponent_net:{
		name: 'Algae Opponent Net',
		type: 'avg'
	},
	algae_opponent_net_score:{
		name: 'Algae Opponent Net Score',
		type: 'avg'
	},
	algae_opponent_processor:{
		name: "Algae Placed in the Opponent's Processor",
		type: 'avg'
	},
	algae_opponent_processor_score:{
		name: 'Algae Opponent Processor Score',
		type: 'avg'
	},
	algae_processor:{
		name: 'Algae Placed in Processor',
		type: 'avg'
	},
	algae_processor_score:{
		name: 'Algae Processor Score',
		type: 'avg'
	},
	algae_reef:{
		name: 'Algae Collected from Reef',
		type: 'avg'
	},
	algae_removed_reef:{
		name: 'Algae Knocked Off Reef',
		type: 'avg'
	},
	algae_score:{
		name: 'Algae Score',
		type: 'avg'
	},
	algae_upper:{
		name: 'Algae Collected from Upper Reef',
		type: 'avg'
	},
	algae_upper_removed:{
		name: 'Algae Knocked Off Upper Reef',
		type: 'avg'
	},
	auto_algae_collect:{
		name: 'Algae Collected in Auto',
		type: 'avg'
	},
	auto_algae_collect_reef:{
		name: 'Algae Collected from Reef in Auto',
		type: 'avg'
	},
	auto_algae_ground:{
		name: 'Algae Collected from Ground in Auto',
		type: 'avg'
	},
	auto_algae_net_score:{
		name: 'Algae Net Score in Auto',
		type: 'avg'
	},
	auto_algae_opponent_net_score:{
		name: 'Algae Opponent Net Score in Auto',
		type: 'avg'
	},
	auto_algae_opponent_processor_score:{
		name: 'Algae Opponent Processor Score in Auto',
		type: 'avg'
	},
	auto_algae_place:{
		name: 'Algae Placed in Auto',
		type: 'avg'
	},
	auto_algae_processor_net_score:{
		name: 'Algae Processor Net Score in Auto',
		type: 'avg'
	},
	auto_algae_processor_score:{
		name: 'Algae Processor Score in Auto',
		type: 'avg'
	},
	auto_algae_reef:{
		name: 'Algae Collected from Reef in Auto',
		type: 'avg'
	},
	auto_algae_removed_reef:{
		name: 'Algae Knocked Off Reef in Auto',
		type: 'avg'
	},
	auto_algae_score:{
		name: 'Algae Score in Auto',
		type: 'avg'
	},
	auto_collect:{
		name: 'Scoring Elements Collected in Auto',
		type: 'avg'
	},
	auto_coral_collect:{
		name: 'Coral Collected in Auto',
		type: 'avg'
	},
	auto_coral_ground:{
		name: 'Coral Collected from Ground in Auto',
		type: 'avg'
	},
	auto_coral_score:{
		name: 'Coral Score in Auto',
		type: 'avg'
	},
	auto_coral_station:{
		name: 'Coral Collected from Station in Auto',
		type: 'avg'
	},
	auto_drop:{
		name: 'Scoring Elements Dropped in Auto',
		type: 'avg'
	},
	cage_score:{
		name: 'Cage Score',
		type: 'avg'
	},
	collect:{
		name: 'Scoring Elements Collected',
		type: 'avg'
	},
	coral_collect:{
		name: 'Coral Collected',
		type: 'avg'
	},
	coral_drop:{
		name: 'Coral Dropped',
		type: 'avg'
	},
	coral_ground:{
		name: 'Coral Collected from Ground',
		type: 'avg'
	},
	coral_score:{
		name: 'Coral Score',
		type: 'avg'
	},
	coral_station:{
		name: 'Coral Collected from Station',
		type: 'avg'
	},
	deep:{
		name: 'Deep Cage',
		type: '%'
	},
	deep_score:{
		name: 'Deep Cage Score',
		type: 'avg'
	},
	drop:{
		name: 'Scoring Elements Dropped',
		type: 'avg'
	},
	end_game_score:{
		name: 'End Game Score',
		type: 'avg'
	},
	park:{
		name: 'Park',
		type: '%'
	},
	park_score:{
		name: 'Park Score',
		type: 'avg'
	},
	shallow:{
		name: 'Shallow Cage',
		type: '%'
	},
	shallow_score:{
		name: 'Shallow Cage Score',
		type: 'avg'
	},
	tele_algae_collect:{
		name: 'Algae Collected in Teleop',
		type: 'avg'
	},
	tele_algae_collect_reef:{
		name: 'Algae Collected Reef in Teleop',
		type: 'avg'
	},
	tele_algae_net_score:{
		name: 'Algae Net Score in Teleop',
		type: 'avg'
	},
	tele_algae_opponent_net_score:{
		name: 'Algae Opponent Net Score in Teleop',
		type: 'avg'
	},
	tele_algae_opponent_processor_score:{
		name: 'Algae Opponent Processor Score in Teleop',
		type: 'avg'
	},
	tele_algae_processor_net_score:{
		name: 'Algae Processor Net Score in Teleop',
		type: 'avg'
	},
	tele_algae_processor_score:{
		name: 'Algae Processor Score in Teleop',
		type: 'avg'
	},
	tele_algae_reef:{
		name: 'Algae Collected from Reef in Teleop',
		type: 'avg'
	},
	tele_algae_removed_reef:{
		name: 'Algae Knocked Off Reef in Teleop',
		type: 'avg'
	},
	tele_algae_score:{
		name: 'Algae Score in Teleop',
		type: 'avg'
	},
	tele_collect:{
		name: 'Scoring Elements Collected in Teleop',
		type: 'avg'
	},
	tele_coral_collect:{
		name: 'Coral Collected in Teleop',
		type: 'avg'
	},
	tele_coral_place:{
		name: 'Coral Placed in Teleop',
		type: 'avg'
	},
	tele_coral_score:{
		name: 'Coral Score in Teleop',
		type: 'avg'
	},
	tele_coral_station:{
		name: 'Coral Collected from Station in Teleop',
		type: 'avg'
	},
	tele_score:{
		name: 'Score in Teleop',
		type: 'avg'
	},
	algae_place:{
		name: 'Algae Placed',
		type: 'avg'
	},
	coral_place:{
		name: 'Coral Placed',
		type: 'avg'
	},
	tele_algae_place:{
		name: 'Algae Placed in Teleop',
		type: 'avg'
	},
	auto_coral_level_1_score:{
		name: 'Coral Level 1 Score in Auto',
		type: 'avg'
	},
	auto_coral_level_2_score:{
		name: 'Coral Level 2 Score in Auto',
		type: 'avg'
	},
	auto_coral_level_3_score:{
		name: 'Coral Level 3 Score in Auto',
		type: 'avg'
	},
	auto_coral_level_4_score:{
		name: 'Coral Level 4 Score in Auto',
		type: 'avg'
	},
	coral_level_1:{
		name: 'Coral Placed on Level 1',
		type: 'avg'
	},
	coral_level_1_score:{
		name: 'Coral Level 1 Score',
		type: 'avg'
	},
	coral_level_2:{
		name: 'Coral Placed on Level 2',
		type: 'avg'
	},
	coral_level_2_score:{
		name: 'Coral Level 2 Score',
		type: 'avg'
	},
	coral_level_3:{
		name: 'Coral Placed on Level 3',
		type: 'avg'
	},
	coral_level_3_score:{
		name: 'Coral Level 3 Score',
		type: 'avg'
	},
	coral_level_4:{
		name: 'Coral Placed on Level 4',
		type: 'avg'
	},
	coral_level_4_score:{
		name: 'Coral Level 4 Score',
		type: 'avg'
	},
	coral_station_1:{
		name: 'Coral Collected from Station 1',
		type: 'avg'
	},
	coral_station_2:{
		name: 'Coral Collected from Station 2',
		type: 'avg'
	},
	tele_coral_level_1_score:{
		name: 'Coral Level 1 Score in Teleop',
		type: 'avg'
	},
	tele_coral_level_2_score:{
		name: 'Coral Level 2 Score in Teleop',
		type: 'avg'
	},
	tele_coral_level_3_score:{
		name: 'Coral Level 3 Score in Teleop',
		type: 'avg'
	},
	tele_coral_level_4_score:{
		name: 'Coral Level 4 Score in Teleop',
		type: 'avg'
	},
	preferred_coral_level:{
		name: 'Preferred Coral Level',
		type: 'text'
	},
	human_player_algae_received:{
		name: 'Human Player Shots',
		type: 'total'
	},
	human_player_net:{
		name: 'Human Player Shots Made',
		type: 'total'
	},
	human_player_accuracy:{
		name: 'Human Player Accuracy',
		type: 'ratio'
	}
}


var teamGraphs={
	"Match Score":{
		graph:"bar",
		data:["score"]
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
}

var whiteboardStamps=[]

window.whiteboard_aspect_ratio=2.18

var whiteboardStats=[
	"score",
	"auto_score",
	"algae_place",
	"coral_place",
	"preferred_coral_level",
	"human_player_accuracy",
	"human_player_algae_received",
	"algae_removed_reef",
	"auto_start",
]

// https://www.postman.com/firstrobotics/workspace/frc-fms-public-published-workspace/example/13920602-f345156c-f083-4572-8d4a-bee22a3fdea1
var fmsMapping=[
]

function showPitScouting(el,team){
	promisePitScouting().then(pitData => {
		var dat=pitData[team]||{}
		if (dat.team_name) el.append($("<p>").text("Team name: " + dat.team_name))
		if (dat.team_location) el.append($("<p>").text("Location: " + dat.team_location))
		if (dat.bot_name) el.append($("<p>").text("Bot name: " + dat.bot_name))
		el.append($("<h4>").text("Autos"))
		var list=$("<ul>")
		for (var i=1; i<=9; i++){
			var desc=dat[`auto_${i}_description`]||""
			var tested=dat[`auto_${i}_testing`]||'no'
			if (tested == 'no') tested=($('<span style=color:red>').text("Not tested"))
			if (tested == 'practice') tested=($('<span style=color:yellow>').text("Tested in practice only"))
			if (tested == 'match') tested=($('<span style=color:green>').text("Test in a match"))
			if (desc.length) list.append($('<li style=white-space:pre-wrap>').append(tested).append(": ").append(desc))
		}
		el.append(list)

		el.append('<h4>Capabilities</h4>')
		list=$("<ul>")
		list.append((dat.notes_amp?$('<li>'):$('<li style=text-decoration:line-through>')).text("Amp"))
		list.append((dat.notes_speaker?$('<li>'):$('<li style=text-decoration:line-through>')).text("Speaker"))
		list.append((dat.notes_trap?$('<li>'):$('<li style=text-decoration:line-through>')).text("Trap"))
		list.append((dat.onstage?$('<li>'):$('<li style=text-decoration:line-through>')).text("Onstage"))
		el.append(list)

		el.append($("<h4>").text("Robot"))
		list=$("<ul>")
		list.append($("<li>").text("Dimensions (inches without bumpers): " + format(dat.frame_length+'x'+dat.frame_width+'"')))
		list.append($("<li>").text("Weight (pounds): "+ format(dat.weight)))
		list.append($("<li>").text("Drivetrain: " + format(dat.drivetrain)))
		list.append($("<li>").text("Swerve: " + format(dat.swerve)))
		list.append($("<li>").text("Drivetrain motors: " +  (dat.motor_count||"")+" "+format(dat.motors)))
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
		f
		el.append(graph)
		f=dat.penalties||""
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
