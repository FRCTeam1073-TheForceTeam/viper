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

	function toAlliance(){
		$('.alliance').show()
		$('.neutral, .opponent').hide()
		$('.target').removeClass('active')
		$('.target-hub').addClass('active')
		return false
	}
	function toOpponent(){
		$('.opponent').show()
		$('.neutral, .alliance').hide()
		$('.target').removeClass('active')
		$('.target-alliance-floor').addClass('active')
		return false
	}
	function toNeutral(){
		$('.neutral').show()
		$('.alliance, .opponent').hide()
		$('.target').removeClass('active')
		$('.target-alliance-floor').addClass('active')
		return false
	}
	function activateTarget(){
		$('.target').removeClass('active')
		$(this).addClass('active')
	}
	$('.to-alliance').on('click',toAlliance)
	$('.to-neutral').on('click', toNeutral)
	$('.to-opponent').on('click', toOpponent)
	$('.target').on('click', activateTarget)
	toAlliance()
})
