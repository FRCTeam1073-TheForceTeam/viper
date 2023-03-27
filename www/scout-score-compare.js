"use strict"

var scouterStats = {}
var matchStats = []

function loadScoutScoreCompare(callback){
	loadEventScores(function(){
		loadEventStats(function(){
			eventMatches.forEach(match => {
				var thisMatch
				;["Red","Blue"].forEach(alliance=>{
					var scoutData = [],
					scoreData
					for (var i=0; i<=3; i++){
						var team = match[alliance.charAt(0)+""+i],
						matchTeam = `${match.Match}-${team}`
						if (eventStatsByMatchTeam[matchTeam])scoutData.push(eventStatsByMatchTeam[matchTeam])
					}
					if (eventScores[match.Match]) eventScores[match.Match].alliances.forEach(dat=>{
						if (dat.alliance.toLowerCase() == alliance.toLowerCase()) scoreData = dat
					})
					if (!thisMatch) thisMatch = {}
					if (scoreData && scoutData.length == 3){
						thisMatch[alliance]=getScoreDifference(scoutData, scoreData)
						thisMatch[alliance].alliance=alliance
						thisMatch.match=match.Match
						thisMatch[alliance].match=match.Match
					}
					scoutData.forEach(scout=>{
						var scouter = scout.scouter.trim(),
						key = scouter.toLowerCase().replace(/[^0-9a-z]/g,"")
						if (!scouter) scouter="Unknown"
						if (!key) key="unknown"
						if (!scouterStats[key]) scouterStats[key] = {name:scouter,matches:0,scoredMatches:0,error:0}
						scouterStats[key].matches++
						if (thisMatch[alliance]){
							scouterStats[key].scoredMatches++
							scouterStats[key].error+=thisMatch[alliance].diff/3
							scouterStats[key].avgError=Math.round(scouterStats[key].error/scouterStats[key].scoredMatches)
						}
					})
				})
				if (thisMatch.Red) matchStats.push(thisMatch)
			})
			callback()
		})
	})
}

function getScoreDifference(scoutData, scoreData){
	if (!window.fmsMapping) return 0
	var diff = {diff:0,dat:[],teams:[],scouters:[]}
	scoutData.forEach(scoutDat => {
		diff.teams.push(scoutDat.team)
		diff.scouters.push(scoutDat.scouter)
	})
	window.fmsMapping.forEach(map=>{
		var dat = {fms:{},scout:{},diff:0}
		map[0].forEach(fms=>{
			dat.fms[fms]=scoreData[fms]||0
			dat.diff+=scoreData[fms]||0
		})
		map[1].forEach(scout=>{
			dat.scout[scout]={total:0,teams:[]}
			scoutData.forEach(scoutDat => {
				dat.scout[scout].teams.push({
					points:scoutDat[scout]||0,
					team:scoutDat.team,
					scouter:scoutDat.scouter
				})
				dat.scout[scout].total+=scoutDat[scout]||0
				dat.diff-=scoutDat[scout]||0
			})
		})
		dat.diff=Math.abs(dat.diff)
		diff.dat.push(dat)
		diff.diff+=dat.diff
	})
	return diff
}
