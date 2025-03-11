"use strict"

function aggregateStats(scout, aggregate, apiScores, subjective, pit){

	function bool_1_0(s){
		return (!s||/^0|no|false$/i.test(""+s))?0:1
	}

	var pointValues = {
		net_zone: 2,
		low_basket: 4,
		high_basket: 8,
		low_chamber: 6,
		high_chamber: 10,
		park: 3,
		ascent: 3,
		ascent_1: 3,
		ascent_2: 15,
		ascent_3: 30,
		minor_foul:-5,
		major_foul:-15
	}

	Object.keys(statInfo).forEach(function(field){
		if(/^(\%|avg|count)$/.test(statInfo[field]['type'])){
			scout[field] = scout[field]||0
			aggregate[field] = aggregate[field]||0
		}
	})

	scout.no_show = bool_1_0(scout.no_show)
	scout.auto_disabled = bool_1_0(scout.auto_disabled)
	scout.auto_yellow_card = bool_1_0(scout.auto_yellow_card)
	scout.auto_red_card = bool_1_0(scout.auto_red_card)
	scout.tele_disabled = bool_1_0(scout.tele_disabled)
	scout.tele_yellow_card = bool_1_0(scout.tele_yellow_card)
	scout.tele_red_card = bool_1_0(scout.tele_red_card)

	scout.auto_minor_foul_score = pointValues.minor_foul * scout.auto_minor_foul
	scout.tele_minor_foul_score = pointValues.minor_foul * scout.tele_minor_foul
	scout.minor_foul_score = scout.auto_minor_foul_score + scout.tele_minor_foul_score

	scout.auto_major_foul_score = pointValues.major_foul * scout.auto_major_foul
	scout.tele_major_foul_score = pointValues.major_foul * scout.tele_major_foul
	scout.major_foul_score = scout.auto_major_foul_score + scout.tele_major_foul_score

	scout.auto_net_zone_score = pointValues.net_zone*scout.auto_place_net_zone
	scout.tele_net_zone_score = pointValues.net_zone*scout.tele_place_net_zone
	scout.net_zone_score = scout.auto_net_zone_score+scout.tele_net_zone_score

	scout.auto_low_basket_score = pointValues.low_basket*scout.auto_place_low_basket
	scout.tele_low_basket_score = pointValues.low_basket*scout.tele_place_low_basket
	scout.low_basket_score = scout.auto_low_basket_score+scout.tele_low_basket_score

	scout.auto_high_basket_score = pointValues.high_basket*scout.auto_place_high_basket
	scout.tele_high_basket_score = pointValues.high_basket*scout.tele_place_high_basket
	scout.high_basket_score = scout.auto_high_basket_score+scout.tele_high_basket_score

	scout.auto_low_chamber_score = pointValues.low_chamber*scout.auto_place_low_chamber
	scout.tele_low_chamber_score = pointValues.low_chamber*scout.tele_place_low_chamber
	scout.low_chamber_score = scout.auto_low_chamber_score+scout.tele_low_chamber_score

	scout.auto_high_chamber_score = pointValues.high_chamber*scout.auto_place_high_chamber
	scout.tele_high_chamber_score = pointValues.high_chamber*scout.tele_place_high_chamber
	scout.high_chamber_score = scout.auto_high_chamber_score+scout.tele_high_chamber_score

	scout.auto_end_score = pointValues[scout.auto_end]||0
	scout.tele_end_score = pointValues[scout.tele_end]||0
	scout.end_score = scout.auto_end_score + scout.tele_end_score

	scout.auto_foul_score = scout.auto_minor_foul_score +scout.auto_major_foul_score
	scout.tele_foul_score = scout.tele_minor_foul_score +scout.tele_major_foul_score
	scout.foul_score = scout.minor_foul_score = scout.major_foul_score

	scout.auto_score = scout.auto_end_score + scout.auto_low_basket_score + scout.auto_high_basket_score + scout.auto_low_chamber_score + scout.auto_high_chamber_score + scout.auto_foul_score + scout.auto_foul_score
	scout.tele_score = scout.tele_end_score + scout.tele_low_basket_score + scout.tele_high_basket_score + scout.tele_low_chamber_score + scout.tele_high_chamber_score + scout.tele_foul_score + scout.tele_foul_score
	scout.score = scout.auto_score + scout.tele_score

	Object.keys(statInfo).forEach(function(field){
		if(/^(\%|avg|count)$/.test(statInfo[field]['type'])){
			aggregate[field] = (aggregate[field]||0)+scout[field]
			var set = `${field}_set`
			aggregate[set] = aggregate[set]||[]
			aggregate[set].push(scout[field])
		}
		if(/^text$/.test(statInfo[field]['type'])) aggregate[field] = (!aggregate[field]||aggregate[field]==scout[field])?scout[field]:"various"
	})
	aggregate.count = (aggregate.count||0)+1
	aggregate.max_score = Math.max(aggregate.max_score||0,scout.score)
	aggregate.min_score = Math.min(aggregate.min_score===undefined?999:aggregate.min_score,scout.score)
}

var statInfo = {
	match:{
		name: "Match",
		type: "text"
	},
	team:{
		name: "Team",
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
	scouter:{
		name: "Scouter",
		type: "text"
	},
	timeline:{
		name: "Timeline",
		type: "timeline"
	},
	auto_collect_alliance:{
		name: 'Alliance color samples collected',
		type: 'avg'
	},
	auto_collect_specimen:{
		name: 'Specimens collected',
		type: 'avg'
	},
	auto_collect_yellow:{
		name: 'Yellow samples collected',
		type: '%'
	},
	auto_disabled:{
		name: 'Disabled during auto',
		type: '%'
	},
	auto_end:{
		name: 'Climb at end of auto',
		type: 'text'
	},
	auto_end_score:{
		name: 'Auto climb score',
		type: 'avg'
	},
	auto_foul_major:{
		name: 'Major fouls during auto',
		type: 'avg'
	},
	auto_foul_minor:{
		name: 'Minor fouls during auto',
		type: 'avg'
	},
	auto_high_basket_score:{
		name: 'Auto high basket score',
		type: 'avg'
	},
	event:{
		name: 'Event',
		type: 'text'
	},
	tele_end:{
		name: 'Climb at end of tele',
		type: 'text'
	},
	auto_foul_score:{
		name: 'Auto foul score',
		type: 'avg'
	},
	auto_high_chamber_score:{
		name: 'Auto high chamber score',
		type: 'avg'
	},
	auto_low_basket_score:{
		name: 'Auto low basket score',
		type: 'avg'
	},
	auto_low_chamber_score:{
		name: 'Auto low chamber score',
		type: 'avg'
	},
	auto_major_foul:{
		name: 'Auto major fouls',
		type: 'avg'
	},
	auto_major_foul_score:{
		name: 'Auto major foul score',
		type: 'avg'
	},
	auto_minor_foul:{
		name: 'Auto minor fouls',
		type: 'avg'
	},
	auto_minor_foul_score:{
		name: 'Auto minor foul score',
		type: 'avg'
	},
	auto_net_zone_score:{
		name: 'Auto net zone score',
		type: 'avg'
	},
	auto_place_high_basket:{
		name: 'Auto place high basket',
		type: 'avg'
	},
	auto_place_high_chamber:{
		name: 'Auto place high chamber',
		type: 'avg'
	},
	auto_place_low_basket:{
		name: 'Auto place low basket',
		type: 'avg'
	},
	auto_place_low_chamber:{
		name: 'Auto place low chamber',
		type: 'avg'
	},
	auto_place_net_zone:{
		name: 'Auto place net zone',
		type: 'avg'
	},
	auto_place_observation:{
		name: 'Auto place observation',
		type: 'avg'
	},
	auto_red_card:{
		name: 'Auto red card',
		type: '%'
	},
	auto_score:{
		name: 'Auto score',
		type: 'avg'
	},
	auto_yellow_card:{
		name: 'Auto yellow card',
		type: '%'
	},
	foul_score:{
		name: 'Foul score',
		type: 'avg'
	},
	high_chamber_score:{
		name: 'High chamber score',
		type: 'avg'
	},
	low_basket_score:{
		name: 'Low basket score',
		type: 'avg'
	},
	low_chamber_score:{
		name: 'Low chamber score',
		type: 'avg'
	},
	major_foul_score:{
		name: 'Major foul score',
		type: 'avg'
	},
	minor_foul_score:{
		name: 'Minor foul score',
		type: 'avg'
	},
	net_zone_score:{
		name: 'Net zone score',
		type: 'avg'
	},
	no_show:{
		name: 'No show',
		type: '%'
	},
	tele_collect_alliance:{
		name: 'Tele collect alliance',
		type: '%'
	},
	tele_collect_specimen:{
		name: 'Tele collect specimen',
		type: '%'
	},
	tele_collect_yellow:{
		name: 'Tele collect yellow',
		type: '%'
	},
	tele_disabled:{
		name: 'Tele disabled',
		type: '%'
	},
	tele_end_score:{
		name: 'Tele end score',
		type: 'avg'
	},
	tele_foul_major:{
		name: 'Tele foul major',
		type: 'avg'
	},
	tele_foul_minor:{
		name: 'Tele foul minor',
		type: 'avg'
	},
	tele_foul_score:{
		name: 'Tele foul score',
		type: 'avg'
	},
	tele_high_basket_score:{
		name: 'Tele high basket score',
		type: 'avg'
	},
	tele_high_chamber_score:{
		name: 'Tele high chamber score',
		type: 'avg'
	},
	tele_low_basket_score:{
		name: 'Tele low basket score',
		type: 'avg'
	},
	tele_low_chamber_score:{
		name: 'Tele low chamber score',
		type: 'avg'
	},
	tele_major_foul:{
		name: 'Tele major foul',
		type: 'avg'
	},
	tele_major_foul_score:{
		name: 'Tele major foul score',
		type: 'avg'
	},
	tele_minor_foul:{
		name: 'Tele minor foul',
		type: 'avg'
	},
	tele_minor_foul_score:{
		name: 'Tele minor foul score',
		type: 'avg'
	},
	tele_net_zone_score:{
		name: 'Tele net zone score',
		type: 'avg'
	},
	tele_place_high_basket:{
		name: 'Tele place high basket',
		type: 'avg'
	},
	tele_place_high_chamber:{
		name: 'Tele place high chamber',
		type: 'avg'
	},
	tele_place_low_basket:{
		name: 'Tele place low basket',
		type: 'avg'
	},
	tele_place_low_chamber:{
		name: 'Tele place low chamber',
		type: 'avg'
	},
	tele_place_net_zone:{
		name: 'Tele place net zone',
		type: 'avg'
	},
	tele_place_observation:{
		name: 'Tele place observation',
		type: 'avg'
	},
	tele_red_card:{
		name: 'Tele red card',
		type: '%'
	},
	tele_score:{
		name: 'Tele score',
		type: 'avg'
	},
	tele_yellow_card:{
		name: 'Tele yellow card',
		type: '%'
	},
	count:{
		name: 'Count',
		type: 'avg'
	},
	max_score:{
		name: 'Max score contribution',
		type: 'minmax'
	},
	min_score:{
		name: 'Min score contribution',
		type: 'minmax'
	},
	end_score:{
		name: 'End score',
		type: 'avg'
	},
	high_basket_score:{
		name: 'High basket score',
		type: 'avg'
	},
	score:{
		name: 'Score contribution',
		type: 'avg'
	},
}

var teamGraphs = {
	"Match Score":{
		graph:"bar",
		data:["score"]
	},
	"Match Stages":{
		graph:"stacked",
		data:["auto_score","tele_score"]
	},
}

var aggregateGraphs = {
	"Match Score":{
		graph:"boxplot",
		data:["max_score","score","min_score"]
	},
	"Match Stages":{
		graph:"stacked",
		data:["auto_score","tele_score"]
	},
}

var matchPredictorSections = {
	Total:["score"],
}

var whiteboardStats = [
	"score",
]

// Whiteboard image from https://www.reddit.com/r/FTC/comments/1fbhxka/into_the_deep_meepmeep_custom_field_images/
var whiteboardStamps = []

var whiteboardOverlays = []
