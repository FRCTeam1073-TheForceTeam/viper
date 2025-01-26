"use strict"

$(document).ready(function(){
	const AUTO_MS=15000
	var matchStartTime = 0

	window.onShowScouting = window.onShowScouting || []
	window.onShowScouting.push(function(){
		setTimeout(initialRobotStartPosition,500)
		matchStartTime = 0
		return true
	})

	window.onInputChanged = window.onInputChanged || []
	window.onInputChanged.push(inputChanged)

	function inputChanged(input, change){

		toggleScoringElements()

		if(!input.closest('.auto,.teleop').length) return

		var leave=$('[name="auto_leave"]')
		if (input.closest('.auto')&&input.attr('name')!='auto_leave'&&!leave.is(':checked')){
			console.log(input)
			leave.prop('checked',true)
			inputChanged(leave,0)
		}
		var order = $('#timeline'),
		text = order.val(),
		name = input.attr('name'),
		re = name
		setTimeout(proceedToTeleBlink, AUTO_MS)
		if (matchStartTime==0) matchStartTime = new Date().getTime()
		if ('radio'==input.attr('type')){
			name += `:${input.val()}`
			text = text.replace(new RegExp(`(.*(?: |^))[0-9]+\:${re}(?:\:[a-z0-9_]*)?( |$)`),"$1").trim()
		}
		if ((input.is('.num') && change>0) || input.is(':checked')){
			if (text) text += " "
			var seconds = Math.round((new Date().getTime() - matchStartTime)/1000)
			text += `${seconds}:${name}`
		} else {
			text = text.replace(new RegExp(`(.*(?: |^))[0-9]+\:${re}(\:[a-z0-9_]*)?( |$)`),"$1").trim()
		}
		if (!text){
			matchStartTime = 0
			proceedToTeleBlink()
		}
		order.val(text)
		renderTimeline()
	}

	$('.undo').click(function(){
		var order = $('#timeline'),
		text = order.val(),
		m = text.match(/(.*(?: |^))[0-9]+\:([a-z0-9_]+)(?:\:[a-z0-9_]*)?$/)
		if (!m) return false
		text = m[1].trim()
		var field = m[2],
		input = $(`input[name="${field}"]`)
		if (input.is(".num")){
			input.val(parseInt(input.val())-1)
			animateChangeFloater(-1, input)
		}
		if (input.is(":checked")) input.prop('checked',false)
		if (!text) {
			matchStartTime = 0
			proceedToTeleBlink()
		}
		order.val(text)
		toggleScoringElements()
		renderTimeline()
		return false
	})

	function renderTimeline(){
		var tl = $('.timeline').html("")
		$('#timeline').val().split(/ /).forEach(entry => {
			if (!entry) return
			var [time,event] = entry.split(/:/),
			min=Math.floor(time/60),
			sec=(""+time%60).padStart(2,'0')
			event=event.replace(/_/g," ").replace(/\b\w/g, s => s.toUpperCase())
			tl.append($('<tr>').append($('<td>').text(`${min}:${sec}`)).append($('<td>').text(event)))
		})
	}

	function initialRobotStartPosition(){
		moveFloaterToPercentCoordinates(
			document.getElementById('start-area'),
			pos.startsWith('R'),
			$('#auto-start-input').val()||"16x6",
			document.getElementById('robot-starting-position')
		)
	}

	function moveFloaterToPercentCoordinates(mapImage, isRotated, coordinates, floatingImage){
		var c = getPixelCoordinates(mapImage, true, coordinates, floatingImage, false)
		if (!c) return
		floatingImage.style.left=c.x+"px"
		floatingImage.style.top=c.y+"px"
	}

	function getPercentCoordinates(event, mapImage, isRotated){
		var d = mapImage.getBoundingClientRect(),
		x = event.clientX - d.left,
		y = event.clientY - d.top,
		px = Math.min(99,Math.max(1,Math.round(100 * x / d.width))),
		py =  Math.min(99,Math.max(1,Math.round(100 * y / d.height)))
		if (!isRotated) py = 100 - py
		if (isRotated) px = 100 - px
		return px+"x"+py
	}

	function setRobotStartPosition(e){
		var mi = document.getElementById('start-area'),
		fi = document.getElementById('robot-starting-position'),
		ir = "none"==(""+getComputedStyle($('#start-area')[0]).transform),
		co = getPercentCoordinates(e,mi,ir)
		moveFloaterToPercentCoordinates(mi,ir,co,fi)
		$('#auto-start-input').val(co)
	}

	$('#start-area').mousemove(function(e){
		if (e.buttons) setRobotStartPosition(e)
	})

	$('#start-area').click(setRobotStartPosition)

	function scoringElementCount(el){
		el=$(el)
		var mul=parseInt(el.attr('data-provides')||("-"+el.attr('data-accepts'))),
		val=parseInt(el.val()||"0")
		if(el.is(':checkbox,:radio')&&!el.prop('checked'))val=0
		return(mul*val)
	}

	function hasCoral(){
		return hasScoringElement('coral')
	}
	function hasAlgae(){
		return hasScoringElement('algae')
	}
	function hasScoringElement(el){
		return sumValues($(`[data-element="${el}"]`))>0
	}
	function sumValues(el){
		return el.get().map(scoringElementCount).reduce((a,b)=>a+b,0)
	}
	function hasOpponentProcessorShots(){
		return -sumValues($('[name="auto_algae_processor"],[name="tele_algae_processor"]'))>-sumValues($('[name="auto_algae_opponent_net"],[name="tele_algae_opponent_net"]'))
	}

	function toggleScoringElements(){
		var has={
			coral:hasCoral(),
			algae:hasAlgae(),
			'opponent-algae':hasOpponentProcessorShots(),
		}
		$(`[data-element]`).each(function(){
			var el=$(this).attr('data-element'),
			show=(has[el]!=(!!$(this).attr('data-provides')))
			if($(this).attr('max')==$(this).val())show=false
			if($(this).is(':checkbox,:radio'))show=true
			$(this).closest('td').find('.disabledOverlay').toggle(!show)
			$(`[data-input="${$(this).attr('name')}"]`).toggle(show)
		})
	}

	$('.disabledOverlay').click(function(e){
		e.preventDefault()
		return false
	})

	$(`[data-element]`).each(function(){
		$(this).closest('td').prepend('<div class=disabledOverlay>')
	})
	toggleScoringElements()


	function proceedToTeleBlink(){
		$('#to-tele-button').toggleClass('pulse-bg', matchStartTime>0 && (new Date().getTime()-matchStartTime)>=AUTO_MS)
	}
})
