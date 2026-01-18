"use strict"

addI18n({
})

$(document).ready(function(){
	const AUTO_MS=15000,
	AUTO_GAP_MS=3000,
	TELE_START_MS=AUTO_MS+AUTO_GAP_MS,
	TELE_MS=135000,
	MATCH_LENGTH_MS=TELE_START_MS+TELE_MS
	var matchStartTime = 0

	window.onBeforeShowScouting = window.onBeforeShowScouting || []
	window.onBeforeShowScouting.push(function(){
		return true
	})
	window.onShowScouting = window.onShowScouting || []
	window.onShowScouting.push(function(){
		return true
	})
	window.onShowPitScouting = window.onShowPitScouting || []
	window.onShowPitScouting.push(function(){
		return true
	})

	window.onInputChanged = window.onInputChanged || []
	window.onInputChanged.push(inputChanged)
})
