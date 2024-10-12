"use strict"

$(document).ready(function(){
	$('.auto .count').click(function(){
		setTimeout(function(){
			$('#to-tele-button').addClass('pulse-bg')
		},30000)
	})

	var matchStartTime = 0

	window.onShowScouting = window.onShowScouting || []
	window.onShowScouting.push(function(){
		matchStartTime = 0
		return true
	})

	$('.auto label,.teleop label,.auto .count,.teleop .count').click(function(){
		if (!matchStartTime) matchStartTime = new Date().getTime()
		var el = $(this),
		input = findInputInEl(findParentFromButton(el)),
		order = $('#timeline'),
		text = order.val(),
		name = input.attr('name'),
		re = name,
		src = el.attr('src') || ""
		if ('radio'==input.attr('type')){
			name += `:${input.val()}`
			text = text.replace(new RegExp(`(.*(?: |^))[0-9]+\:${re}\:[a-z0-9_]*( |$)`),"$1").trim()
		}
		if (/up/.test(src) || input.is(':checked')){
			if (text) text += " "
			var seconds = Math.round((new Date().getTime() - matchStartTime)/1000)
			text += `${seconds}:${name}`
		} else {
			text = text.replace(new RegExp(`(.*(?: |^))[0-9]+\:${re}(\:[a-z0-9_]*)?( |$)`),"$1").trim()
		}
		order.val(text)
	})
})
