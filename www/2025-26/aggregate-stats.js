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
		type: "text"
	},
	team:{
		en: "Team",
		type: "text"
	},
	comments:{
		en: "Comments",
		type: "text"
	},
	created:{
		en: "Created",
		type: "datetime"
	},
	modified:{
		en: "Modified",
		type: "datetime"
	},
	scouter:{
		en: "Scouter",
		type: "text"
	},
	timeline:{
		en: "Timeline",
		type: "timeline"
	},
	count:{
		en: 'Count',
		type: 'avg'
	},
	artifact:{
		en: 'Artifact',
		type: 'avg'
	},
	auto_artifact:{
		en: 'Artifact in Auto',
		type: 'avg'
	},
	auto_depot:{
		en: 'Depot in Auto',
		type: 'avg'
	},
	auto_gate:{
		en: 'Gate in Auto',
		type: 'avg'
	},
	auto_goal:{
		en: 'Goal in Auto',
		type: 'avg'
	},
	auto_patterns:{
		en: 'Patterns in Auto',
		type: 'enum',
		values:["","obelisk","purple"],
		breakout:["auto_patterns_none","auto_patterns_obelisk","auto_patterns_purple"]
	},
	auto_patterns_none:{
		en: 'Patterns None in Auto',
		type: '%'
	},
	auto_patterns_obelisk:{
		en: 'Patterns Obelisk in Auto',
		type: '%'
	},
	auto_patterns_purple:{
		en: 'Patterns Purple in Auto',
		type: '%'
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
		values:["","goal","audience"],
		breakout:["auto_start_unknown","auto_start_goal","auto_start_audience"]
	},
	auto_start_audience:{
		en: 'Start Audience in Auto',
		type: '%'
	},
	auto_start_goal:{
		en: 'Start Goal in Auto',
		type: '%'
	},
	auto_start_unknown:{
		en: 'Start Unknown in Auto',
		type: '%'
	},
	auto_took_turns:{
		en: 'Took Turns in Auto',
		type: '%'
	},
	base_return:{
		en: 'Base Return',
		type: 'enum',
		values:["","partially","alone","under","above"],
		breakout:["base_return_none","base_return_partially","base_return_alone","base_return_under","base_return_above"]
	},
	base_return_above:{
		en: 'Base Return Fully Above',
		type: '%'
	},
	base_return_alone:{
		en: 'Base Return Fully Alone',
		type: '%'
	},
	base_return_both:{
		en: 'Base Return Fully Both',
		type: '%'
	},
	base_return_fully:{
		en: 'Base Return Fully',
		type: '%'
	},
	base_return_none:{
		en: 'Base Return None',
		type: '%'
	},
	base_return_partially:{
		en: 'Base Return Partially',
		type: '%'
	},
	base_return_under:{
		en: 'Base Return Fully Under',
		type: '%'
	},
	depot:{
		en: 'Depot',
		type: 'avg'
	},
	gate:{
		en: 'Gate',
		type: 'avg'
	},
	goal:{
		en: 'Goal',
		type: 'avg'
	},
	event:{
		en: 'Event',
		type: '%'
	},
	no_show:{
		en: 'No Show',
		type: '%'
	},
	patterns:{
		en: 'Patterns',
		type: '%'
	},
	tele_artifact:{
		en: 'Artifact in Teleop',
		type: 'avg'
	},
	tele_depot:{
		en: 'Depot in Teleop',
		type: 'avg'
	},
	tele_gate:{
		en: 'Gate in Teleop',
		type: 'avg'
	},
	tele_goal:{
		en: 'Goal in Teleop',
		type: 'avg'
	},
	tele_patterns:{
		en: 'Patterns in Teleop',
		type: '%'
	},
}

var teamGraphs = {
	"Artifacts":{
		graph:"stacked",
		data:["goal",'depot']
	},
	"Match Stages":{
		graph:"stacked",
		data:["auto_artifact","tele_artifact"]
	},
	"Presets":{
		graph:"stacked",
		data:["auto_preset_1","auto_preset_2","auto_preset_3","auto_preset_4"]
	},
	"End Game":{
		graph:"bar",
		data:["base_return_none","base_return_partially","base_return_alone","base_return_under","base_return_above"]
	},
}

var aggregateGraphs = {
	"Artifacts":{
		graph:"boxplot",
		data:["artifact"]
	},
	"Match Stages":{
		graph:"stacked",
		data:["auto_artifact","tele_artifact"]
	},
	"Presets":{
		graph:"bar",
		data:["auto_preset_1","auto_preset_2","auto_preset_3","auto_preset_4"]
	},
	"End Game":{
		graph:"bar",
		data:["base_return_none","base_return_partially","base_return_alone","base_return_under","base_return_above"]
	},
}

var matchPredictorSections = {
	Total:["artifacts"],
}

var whiteboardStats = [
	"artifacts",
]

// Whiteboard image from https://www.reddit.com/r/FTC/comments/1nalob0/decode_custom_field_images_meepmeep_compatible/
var whiteboardStamps = []

var whiteboardOverlays = []
