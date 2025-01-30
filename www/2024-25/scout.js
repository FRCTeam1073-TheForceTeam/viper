"use strict"

$(document).ready(function(){
	const AUTO_MS=30000

	var matchStartTime = 0

	window.onShowScouting = window.onShowScouting || []
	window.onShowScouting.push(function(){
		matchStartTime = 0
		setCargo('')
		return true
	})
	window.onInputChanged = window.onInputChanged || []
	window.onInputChanged.push(function(input){
		setTimeout(proceedToTeleBlink, AUTO_MS)
		var order = $('#timeline'),
		text = order.val(),
		name = input.attr('name'),
		re = name
		if (matchStartTime==0) matchStartTime = new Date().getTime()
		if ('radio'==input.attr('type')){
			name += `:${input.val()}`
			text = text.replace(new RegExp(`(.*(?: |^))[0-9]+\:${re}\:[a-z0-9_]*( |$)`),"$1").trim()
		}
		if (input.is('.num') || input.is(':checked')){
			if (text) text += " "
			var seconds = Math.round((new Date().getTime() - matchStartTime)/1000)
			text += `${seconds}:${name}`
		} else {
			text = text.replace(new RegExp(`(.*(?: |^))[0-9]+\:${re}(\:[a-z0-9_]*)?( |$)`),"$1").trim()
		}
		order.val(text)
		if (input.attr('data-provides')||input.attr('data-accepts')){
			setCargo(input.attr('data-provides')||"")
		}
	})

	$('.undo').click(function(){
		var order = $('#timeline'),
		text = order.val(),
		m = text.match(/(.*(?: |^))[0-9]+\:([a-z0-9_]+)(?:\:[a-z0-9_]*)?$/)
		if (!m) return false
		text = m[1].trim()
		var field = m[2],
		input = $(`input[name="${field}"]`)
		if (input.is(".nu m")){
			input.val(parseInt(input.val())-1)
			animateChangeFloater(-1, input)
		}
		if (input.is(":checked")) input.prop('checked',false)
		setCargo('')
		if (!text) {
			matchStartTime = 0
			proceedToTeleBlink()
		} else {
			var history = text.split(/ /)
			for (var i=history.length-1; i>=0; i--){
				var input = $(`input[name="${(history[i].match(/^[0-9]+\:([a-z0-9_]+)(?:\:[a-z0-9_]*)?$/)||["",""])[1]}"]`)
				if (input.attr('data-provides')||input.attr('data-accepts')){
					setCargo(input.attr('data-provides')||"")
					break
				}
			}
		}
		order.val(text)
		return false
	})

	function proceedToTeleBlink(){
		$('#to-tele-button').toggleClass('pulse-bg', matchStartTime>0 && (new Date().getTime()-matchStartTime)>=AUTO_MS)
	}

	$('.disabledOverlay').click(function(e){
		e.preventDefault()
		return false
	})

	$('[data-accepts],[data-provides]').each(function(){
		if ($(this).attr('data-provides')||$(this).attr('data-accepts')){
			$(this).closest('td').prepend('<div class=disabledOverlay>')
		}
	})

	function setCargo(cargo){
		$('[data-accepts],[data-provides]').each(function(){
			var accepts = $(this).attr('data-accepts')||""
			var show = (
				cargo==accepts ||
				(cargo=='sample' && /^sample|yellow|alliance$/.test(accepts)) ||
				(accepts=='sample' && /^sample|yellow|alliance$/.test(cargo)) ||
				(accepts=='any' && cargo!="")
			)
			$(this).closest('td').find('.disabledOverlay').toggle(!show)
		})
	}
})
