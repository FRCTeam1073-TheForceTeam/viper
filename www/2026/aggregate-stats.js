"use strict"

function aggregateStats(scout, aggregate, apiScores, subjective, pit, eventStatsByMatchTeam, eventStatsByTeam, match){
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
}

var teamGraphs={
	"Game Stage":{
		graph:"stacked",
		tr:'Oyun Aşaması',
		pt:'Estágio do jogo',
		fr:'Phase de jeu',
		he:'שלב המשחק',
		zh_tw:'遊戲舞台',
		data:["auto_score","tele_score","end_game_score"],
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
	"Game Stage":{
		tr:'Fase do Jogo',
		he:'שלב המשחק',
		zh_tw:'遊戲舞台',
		pt:'Fase do Jogo',
		fr:'Phase de jeu',
		data:["auto_score","tele_score","end_game_score"],
	},
}

var whiteboardStamps=[]

var fieldRotationalSymmetry=true

window.whiteboard_aspect_ratio=2.18

var whiteboardStats=[
	"score",
	"auto_score",
	"tele_score",
]

// https://www.postman.com/firstrobotics/workspace/frc-fms-public-published-workspace/example/13920602-f345156c-f083-4572-8d4a-bee22a3fdea1
var fmsMapping=[
]

function showPitScouting(el,team){
	promisePitScouting().then(pitData => {
		applyTranslations()
	})

}

function showSubjectiveScouting(el,team){
	promiseSubjectiveScouting().then(subjectiveData => {
		applyTranslations()
	})
}


var importFunctions={
}
