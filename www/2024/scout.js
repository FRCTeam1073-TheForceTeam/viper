"use strict"

$(document).ready(function(){

	$('.onstage-state').click(toggleOnstage)

	function toggleOnstage(){
		var onstage = $('#onstage-input').prop('checked')
		$('#not-onstage').toggle(!onstage)
		$('#is-onstage').toggle(onstage)
	}

	var cycles = []
	var cycle
	cycleInterrupt()

	$('.placement').click(function(){
		cycleStage("placement")
	})

	$('.collectSource').click(function(){
		cycleStage("collect")
	})

	setInterval(function(){
		$('#currentCycleTimer').text(":" + ((""+Math.round((cycle.startTime==0?0:(Date.now()-cycle.startTime))/1000)).padStart(2, "0")))
	}, 100)

	function cycleStage(place){
		if (cycle.stage==0 || cycle.lastPlace==place){
			cycle.stage = 1
			cycle.startTime = Date.now()
		} else if (cycle.stage==1){
			cycle.stage = 2
		} else {
			var cycleTime = Math.round((Date.now() - cycle.startTime)/1000)
			if (cycleTime >= 7){ // Faster than seven seconds is not possible, scouter error.
				cycles.push(cycleTime)
				$('input[name="full_cycle_fastest_seconds"]').val(Math.min(...cycles))
				$('input[name="full_cycle_average_seconds"]').val(Math.round(cycles.reduce((a,b) => a + b, 0) / cycles.length))
				$('input[name="full_cycle_count"]').val(cycles.length)
				$('input[name="full_cycles"]').val(cycles.join(" "))
			}
			cycle.stage = 1
			cycle.startTime = Date.now()
		}
		cycle.lastPlace = place
	}

	var matchStartTime = 0

	onShowScouting.push(function(){
		cycleInterrupt()
		cycles=[]
		toggleOnstage()
		setTimeout(initialRobotStartPosition,500)
		matchStartTime = 0
		return true
	})
	onShowSubjectiveScouting.push(function(){
		setTimeout(drawAllShotLocations,500)
		return true
	})
	onShowPitScouting.push(function(){
		drawAutos()
		return true
	})

	function cycleInterrupt(){
		cycle = {
			startTime: 0,
			lastPlace: "",
			stage: 0
		}
	}

	$('.count,button,label').click(function(){
		if (!$(this).is('.placement,.collectSource')) cycleInterrupt()
	})

	$('.auto label,.teleop label,.auto .count,.teleop .count').click(function(){
		if (!matchStartTime) matchStartTime = new Date().getTime()
		var el = $(this),
		input = findInputInEl(findParentFromButton(el)),
		order = $('#timeline'),
		text = order.val(),
		name = input.attr('name'),
		src = el.attr('src') || ""
		if (/up/.test(src) || input.is(':checked')){
			if (text) text += " "
			var seconds = Math.round((new Date().getTime() - matchStartTime)/1000)
			text += `${seconds}:${name}`
		} else {
			text = text.replace(new RegExp(`(.*(?: |^))[0-9]+\:${name}( |$)`),"$1").trim()
		}
		order.val(text)
	})

	function initialRobotStartPosition(){
		moveFloaterToPercentCoordinates(
			document.getElementById('start-area'),
			pos.startsWith('R'),
			$('#auto-start-input').val(),
			document.getElementById('robot-starting-position')
		)
	}

	function moveFloaterToPercentCoordinates(mapImage, isRed, coordinates, floatingImage){
		var c = getPixelCoordinates(mapImage, isRed, coordinates, floatingImage)
		if (!c) return
		floatingImage.style.left=c.x+"px"
		floatingImage.style.top=c.y+"px"
	}

	function getPercentCoordinates(event, mapImage, isRed){
		var d = mapImage.getBoundingClientRect(),
		x = event.clientX - d.left,
		y = event.clientY - d.top,
		px = Math.round(100 * x / d.width),
		py = Math.round(100 * y / d.height)
		if (isRed) px = 100 - px
		return px+"x"+py
	}

	function setRobotStartPosition(e){
		var mi = document.getElementById('start-area'),
		fi = document.getElementById('robot-starting-position'),
		ir = pos.startsWith('R'),
		co = getPercentCoordinates(e, mi, ir)
		moveFloaterToPercentCoordinates(mi,ir,co, fi)
		$('#auto-start-input').val(co)
	}

	$('#start-area').mousemove(function(e){
		if (e.buttons) setRobotStartPosition(e)
	})

	$('#start-area').click(setRobotStartPosition)

	$('#speaker-shoot-area').click(function(e){
		var floater = $('<div class=shot-location>X</div>)'),
		ir = $('body').is('.redTeam')
		$(this).append(floater)
		var co = getPercentCoordinates(e, this, ir),
		inp = $('input[name="speaker_shot_locations"]'),
		val = inp.val()
		moveFloaterToPercentCoordinates(this,ir,co,floater[0])
		if (val) val += " "
		inp.val((val?(val+" "):"")+co)
	})

	$('#undo-last-shot-location').click(function(){
		var inp = $('input[name="speaker_shot_locations"]')
		inp.val(inp.val().replace(/[^ ]+$/,"").trim())
		drawAllShotLocations()
		return false
	})

	function drawAllShotLocations(){
		var area = $('#speaker-shoot-area').html(""),
		ir = $('body').is('.redTeam')
		$('input[name="speaker_shot_locations"]').val().split(" ").forEach(loc => {
			if (loc){
				var floater = $('<div class=shot-location>X</div>)')
				area.append(floater)
				moveFloaterToPercentCoordinates(area[0],ir,loc,floater[0])
			}
		});
		return true
	}

	$('.subjectiveColor').click(function(){
		var color = $(this).attr('class').replace(/.*(red|blue).*/i,"$1")
		$('body').toggleClass('redTeam', color=='red')
		$('body').toggleClass('blueTeam', color=='blue')
		drawAllShotLocations()
		return false
	})

	function getAutoPath(startNew){
		var chosen
		$('.auto-path').each(function(p){
			var p = $(this)
			if (!chosen) chosen = p
			if (p.val()) chosen = p
			if (startNew && chosen.val() && !p.val()) chosen = p
		})
		return chosen
	}

	var startNewAutoPath = false

	$('#auto-paths').click(function(e){
		var path = getAutoPath(startNewAutoPath),
		val = path.val()
		if (val) val += " "
		val += getPercentCoordinates(e, this)
		path.val(val)
		drawAutos()
		startNewAutoPath = false
	})

	$('#auto-path-next').click(function(){
		startNewAutoPath = true
		return false
	})

	$('#auto-path-undo').click(function(){
		var path = getAutoPath()
		path.val(path.val().replace(/ ?[^ ]+$/,""))
		drawAutos()
		return false
	})

	function drawAutos(){
		var canvas = $('#auto-paths')[0]
		sizeAndClearCanvas(canvas)
		$('.auto-path').each(function(){
			drawPath(canvas,$(this).attr('data-color'),$(this).val())
		})
	}
})
