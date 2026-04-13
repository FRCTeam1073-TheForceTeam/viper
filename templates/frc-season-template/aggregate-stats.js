"use strict"

function bool_1_0(s){
	return (!s||/^0|no|false$/i.test(""+s))?0:1
}

function aggregateStats(scout, aggregate, apiScores, subjective, pit, eventStatsByMatchTeam, eventStatsByTeam, match){
	var pointValues={
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

	//scout.auto_leave_score=pointValues.auto_leave*scout.auto_leave
	//scout.score=scout.auto_score+scout.tele_score

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

	pit.auto_paths=[]
	for (var i=1; i<=9; i++){
		var path=pit[`auto_${i}_path`]
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
	auto_score:{
		name: "Score in Auto",
		type: "avg",
		fr:'Score en mode automatique',
		pt:'Pontuação em Auto',
		zh_tw:'自動得分',
		tr:'Otomatik Sırasında Puan',
		he:'ציון באוטו',
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
	tele_score:{
		name: 'Score in Teleop',
		type: 'avg',
		fr:'Score en téléopération',
		pt:'Pontuação em Teleop',
		zh_tw:'遠端操作得分',
		tr:'Teleoperasyonda İstasyondan Toplanan Mercan',
		he:'ציון ב-Teleoperation',
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
}

var teamGraphs={
	"Game Stage":{
		graph:"stacked",
		tr:'Oyun Aşaması',
		pt:'Estágio do jogo',
		fr:'Phase de jeu',
		he:'שלב המשחק',
		zh_tw:'遊戲舞台',
		data:["auto_score","tele_score"],
	},
	"Match Timeline":{
		graph:"timeline",
		tr:'Maç Zaman Çizelgesi',
		pt:'Linha do tempo da partida',
		fr:'Chronologie du match',
		he:'התאם ציר זמן',
		zh_tw:'比賽時間表',
		data:['timeline'],
	},
}

var aggregateGraphs={
	"Match Score":{
		graph:"boxplot",
		tr:'Maç Puanı',
		pt:'Pontuação da partida',
		fr:'Score du match',
		he:'ציון התאמה',
		zh_tw:'比賽比分',
		data:["max_score","score","min_score"],
	},
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
}

var whiteboardStamps=[
	// "/YYYY/game-piece-stamp.png"
]

var fieldRotationalSymmetry=true

window.whiteboard_aspect_ratio=2.0

var whiteboardStats=[
	"score",
]

// https://www.postman.com/firstrobotics/workspace/frc-fms-public-published-workspace/example/13920602-f345156c-f083-4572-8d4a-bee22a3fdea1
var fmsMapping=[
	// [["autoMobilityPoints"],["auto_leave_score"]],
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
		// el.append($('<fieldset>').append($('<legend data-i18n=subjective_penalties_question>').append($('<div style=white-space:pre-wrap>').text(dat.penalties||""))))
		applyTranslations()
	})
}


var importFunctions={
	// "195":{
	// 	example:"/2025/195.csv",
	// 	convert:importScouting195,
	// },
}
