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
		initScouting2026()
		return true
	})
	window.onShowPitScouting = window.onShowPitScouting || []
	window.onShowPitScouting.push(function(){
		return true
	})

	window.onInputChanged = window.onInputChanged || []
	window.onInputChanged.push(inputChanged2026)

	function initScouting2026(){
		matchStartTime = 0
		$('.field-actions').find('[style]').each(function(){
			var c = $(this).attr('class'),
			isBlue = pos.startsWith('B'),
			side = $(this).attr('data-side'),
			end = $(this).attr('data-end'),
			lOrR = ((!isBlue && end=='alliance') || (isBlue && end=='opponent'))?'right':'left'
			if (end) $(this).attr('style', $(this).attr('style').replace(/left|right/g,lOrR))
			if (side) $(this).attr('data-input', $(this).attr('data-input').replace(/depot|outpost/g,side))
		})
	}

	$('.fieldRotateBtn').click(initScouting2026)

	function inputChanged2026(input, change){
		if(input.closest('.auto,.teleop').length){
			var order = $('[name="timeline"]'),
			text = order.val(),
			name = input.attr('name'),
			re = name
			if (matchStartTime==0) matchStartTime = new Date().getTime() - (input.closest('.teleop').length?TELE_START_MS:0)
			if ('radio'==input.attr('type')){
				name += `:${input.val()}`
				text = text.replace(new RegExp(`(.*(?: |^))[0-9]+\:${re}(?:\:[a-z0-9_]*)?( |$)`),"$1").trim()
			}
			if ((input.is('.num') && change>0) || input.is(':checked')){
				if (text) text += " "
				var seconds = Math.floor((new Date().getTime() - matchStartTime)/1000)
				text += `${seconds}:${name}`
				if (change>1) text += `:${change}`
			} else {
				if(input.val()=="0"){
					text = text.replace(new RegExp(`((?<= |^))[0-9]+\:${re}(\:[a-z0-9_]*)?( |$)`,'g'),"").trim()
				} else {
					text = text.replace(new RegExp(`(.*(?: |^))[0-9]+\:${re}(\:[a-z0-9_]*)?( |$)`),"$1").trim()
				}
			}
			if (!text)initScouting2026()
			order.val(text)
		}
	}

	function toAlliance(e){
		$('.alliance').show()
		$('.neutral, .opponent').hide()
		$('.target').removeClass('active')
		$('.target-hub').addClass('active')
		return countHandler.call(this,e)
	}
	function toOpponent(e){
		$('.opponent').show()
		$('.neutral, .alliance').hide()
		$('.target').removeClass('active')
		$('.target-alliance').addClass('active')
		return countHandler.call(this,e)
	}
	function toNeutral(e){
		$('.neutral').show()
		$('.alliance, .opponent').hide()
		$('.target').removeClass('active')
		$('.target-alliance').addClass('active')
		return countHandler.call(this,e)
	}
	function activateTarget(){
		$('.target').removeClass('active')
		$(this).addClass('active')
		return false
	}
	$('.to-alliance').on('click',toAlliance)
	$('.to-neutral').on('click', toNeutral)
	$('.to-opponent').on('click', toOpponent)
	$('.target').on('click', activateTarget)
	toAlliance()

	$('.fuel').on('click', function(e){
		var target = $('.target.active:visible'),
		offset = target.offset()
		e.pageX = offset.left + target.width() / 2
		e.pageY = offset.top + target.height() / 2
		target.attr('data-value',$(this).attr('data-value'))
		return countHandler.call(target[0],e)
	})
})
