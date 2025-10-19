"use strict"

$(document).ready(function(){
	const AUTO_MS=30000

	var matchStartTime = 0

	window.onShowScouting = window.onShowScouting || []
	window.onShowScouting.push(function(){
		matchStartTime = 0
		return true
	})
	window.onInputChanged = window.onInputChanged || []
	window.onInputChanged.push(function(input, change){
		var order = $('#timeline'),
		text = order.val(),
		name = input.attr('name'),
		re = name,
		tab = input.closest('.tab-content')
		if (!tab.is('.auto,.teleop')) return
		if (tab.is('.auto')) setTimeout(proceedToTeleBlink, AUTO_MS)
		if (matchStartTime==0) matchStartTime = new Date().getTime()
		if ('radio'==input.attr('type')){
			name += `:${input.val()}`
			text = text.replace(new RegExp(`(.*(?: |^))[0-9]+\:${re}\:[a-z0-9_]*( |$)`),"$1").trim()
		}
		if (input.is('.num') || input.is(':checked')){
			if (text) text += " "
			var seconds = Math.round((new Date().getTime() - matchStartTime)/1000)
			text += `${seconds}:${name}`
			if (change > 1) text += `:${change}`
		} else {
			text = text.replace(new RegExp(`(.*(?: |^))[0-9]+\:${re}(\:[a-z0-9_]*)?( |$)`),"$1").trim()
		}
		order.val(text)
	})

	$('.undo').click(function(){
		var order = $('#timeline'),
		text = order.val(),
		m = text.match(/(.*(?: |^))[0-9]+\:([a-z0-9_]+)(?:\:([a-z0-9_]*))?$/)
		if (!m) return false
		text = m[1].trim()
		var field = m[2],
		change = m[3] ?? 1
		input = $(`input[name="${field}"]`)
		if (input.is(".num")){
			input.val(parseInt(input.val())-change)
			animateChangeFloater(-change, input)
		}
		if (input.is(":checked")) input.prop('checked',false)
		if (!text) {
			matchStartTime = 0
			proceedToTeleBlink()
		} else {
			var history = text.split(/ /)
			for (var i=history.length-1; i>=0; i--){
				var input = $(`input[name="${(history[i].match(/^[0-9]+\:([a-z0-9_]+)(?:\:[a-z0-9_]*)?$/)||["",""])[1]}"]`)
			}
		}
		order.val(text)
		return false
	})

	function proceedToTeleBlink(){
		var teleTime=(new Date().getTime()-matchStartTime)>=AUTO_MS
		$('#to-tele-button').toggleClass('pulse-bg', matchStartTime>0 && teleTime)
		if (teleTime)setTimeout(function(){showTab({},$('.tab[data-content="teleop"]'))},5000)
	}
})
