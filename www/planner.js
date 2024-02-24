"use strict"
$(document).ready(function() {

	if (typeof eventYear !== 'undefined') $('#fieldBG').css("background-image",`url('/${eventYear}/field-whiteboard.png')`)

	$('button.pen').click(penButtonClicked)

	function penButtonClicked(){
		$('button.pen').removeClass('selected')
		$(this).addClass('selected')
		setCursorImage()
	}

	$('.clear').click(function(evt) {
		evt.preventDefault()
		sketcher.sketchable('clear')
	})

	$('.rotate').click(function(evt) {
		$('#fieldBG').toggleClass('rotated')
		drawOverlays()
	})

	$('.undo').click(function(evt) {
		evt.preventDefault()
		sketcher.sketchable('memento.undo')
	})

	$('button.showInstructions').click(function(){
		showLightBox($('#instructions'))
		return false
	})

	function setLocationHash(){
		var hash = `event=${eventId}`
		$('#statsTable input').each(function(){
			var val = $(this).val()
			if (/^[0-9]+$/.test(val)){
				var name = $(this).attr('id')
				hash += `&${name}=${val}`
			}
		})
		location.hash = hash
	}

	function loadFromLocationHash(){
		$('#statsTable input').each(function(){
			var name = $(this).attr('id')
			var val = (location.hash.match(new RegExp(`^\\#(?:.*\\&)?(?:${name}\\=)([0-9]+)(?:\\&.*)?$`))||["",""])[1]
			$(this).val(val)
		})
		fillStats()
	}

	loadFromLocationHash()
	$(window).on('hashchange', loadFromLocationHash)

	Promise.all([
		promiseEventStats(),
		promisePitScouting(),
		promiseSubjectiveScouting()
	]).then(values => {
		;[window.eventStatsValues, window.pitData, window.subjectiveData] = values
		;[window.eventStats, window.eventStatsByTeam] = eventStatsValues
		var teamList = Object.keys(eventStatsByTeam)
		teamList.sort((a,b) => a-b)
		for (var i=0; i<teamList.length; i++){
			var team = teamList[i]
			$('#teamButtons').append($(`<button id=team-${team} class=team>${team}</button>`).click(teamButtonClicked))
		}
		fillStats()

		if (window.whiteboardStamps){
			window.whiteboardStamps.forEach(function(stamp){
				$('#stamps').append(" ").append($(`<button class=pen><img src=${stamp}></button>`).click(penButtonClicked))
			})
		}
	})

	$('#statsTable input').change(fillStats).focus(function(){
		focusInput($(this))
		$('#teamButtons').show()
	}).blur(function(e){
		if (!$(e.relatedTarget).is('button.team'))$('#teamButtons').toggle(focusNext())
	})

	function fillStats(){
		setLocationHash()
		$('#teamButtons button').removeClass("picked")
		var teamList=[],
		tbody = $('#statsTable tbody').html("")
		$('.team-input').each(function(){
			var val = $(this).val()
			val = val?parseInt(val):0
			if (val){
				$(`#team-${val}`).addClass("picked")
				teamList.push(val)
			}
		})
		$('#teamButtons').toggle(teamList.length!=6)
		var sections = window.plannerSections||window.matchPredictorSections||{}
		var overlays = window.whiteboardOverlays||[]
		if(teamList.length==6){
			var row = $("<tr>")
			teamList.forEach(function(team,i){
				var color = i<3?"red":"blue"
				row.append($(`<td class="${color}TeamBG viewTeam" data-team=${team}>`).click(showTeamStats).html('<img src=/graph.svg>'))
			})
			tbody.append(row)
			;["","-top"].forEach(function(imageSuffix){
				row = $("<tr>")
				teamList.forEach(function(team,i){
					var color = i<3?"red":"blue"
					row.append($(`<td class="${color}TeamBG">`).click(showImg).html(`<img src=/data/${eventYear}/${team}${imageSuffix}.jpg>`))
				})
				tbody.append(row)
			})
			Object.keys(sections).forEach(section=>{
				for (var j=0; j<sections[section].length; j++){
					var field = sections[section][j]
					statInfo[field] = statInfo[field]||{}
					var statName = statInfo[field]['name']||field
					row = $("<tr>")
					var best = statInfo[field].good=='low'?99999999:0
					teamList.forEach(function(team,i){
						var val = getTeamValue(field,team)
						if (statInfo[field].good=='low'){
							if (val<best&&val>0)best=val
						} else {
							if (val>best)best=val
						}
					})
					teamList.forEach(function(team,i){
						var color = i<3?"red":"blue",
						val = getTeamValue(field,team),
						dispVal = val
						if(statInfo[field].type == '%') dispVal += "%"
						row.append($(`<td class="${color}TeamBG">`).addClass(val==best?"best":"").text(dispVal))
					})
					row.append($('<th>').text(statName))
					tbody.append(row)
				}
			})
			overlays.forEach(field=>{
				statInfo[field] = statInfo[field]||{}
				var statName = statInfo[field]['name']||field
				row = $("<tr>")
				teamList.forEach(function(team,i){
					var color = i<3?"red":"blue"
					row.append(
						$(`<td class="${color}TeamBG">`).append(
							$(`<input id="${field}_${team}" type=checkbox checked>`).change(drawOverlays)
						)
					)
				})
				row.append($('<th>').text(statName))
				tbody.append(row)
			})
			drawOverlays()
		}
	}



	function moveFloaterToPercentCoordinates(mapImage, isRed, coordinates, floatingImage){
		var m = coordinates.match(/^([0-9]{1,2})x([0-9]{1,2})$/)
		if (!m || !m.length){
			floatingImage.style.left="0px"
			floatingImage.style.top="0px"
			return
		}
		var px = parseInt(m[1]),
		py = parseInt(m[2])
		if (isRed) px = 100 - px
		var d = mapImage.getBoundingClientRect(),
		s = floatingImage.getBoundingClientRect(),
		x = Math.round(px * d.width / 100 - s.width/2),
		y = Math.round(py * d.height / 100 - s.height/2)
		floatingImage.style.left=x+"px"
		floatingImage.style.top=y+"px"
	}

	function drawOverlays(){
		$('.overlay').remove()
		var teamList = $('.team-input').get().map(inp=>parseInt(inp.value)),
		overlays = window.whiteboardOverlays||[]
		overlays.forEach(field=>{
			teamList.forEach(function(team,i){
				var enabled = $(`#${field}_${team}`).prop('checked'),
				style = $(`#bot-${i}-pen`).attr('style').split(/[:;]/),
				rotated = $('#fieldBG').is('.rotated'),
				isRed = i<3,
				atBottom = rotated != isRed,
				fieldInfo = statInfo[field]||{},
				char = fieldInfo.whiteboard_char||"&",
				start = (fieldInfo.whiteboard_start||0)/100,
				end = (fieldInfo.whiteboard_end||100)/100,
				height = end - start,
				whiteboard = $('#field'),
				whiteboardBounds = whiteboard[0].getBoundingClientRect(),
				source = fieldInfo.source,
				dataSource = source=='subjective'?subjectiveData:(source=='pit'?pitData:eventStatsByTeam)
				if (enabled){
					;((dataSource[team]||{})[field]||"").split(" ").forEach(coordinates=>{
						var top=0, left=0,
						m = coordinates.match(/^([0-9]{1,2})x([0-9]{1,2})$/)
						if (m && m.length) [left, top] = m.slice(1).map(x=>parseInt(x))
						if (rotated) left = 100 - left
						var point = $('<div class=overlay>').html(char).css(...style)
						whiteboard.append(point)
						var pointBounds = point[0].getBoundingClientRect()
						left = Math.round(left * whiteboardBounds.width / 100 - pointBounds.width/2)
						top = Math.round(top * whiteboardBounds.height * height / 100 + (rotated?-1:1) * start * whiteboardBounds.height / 100 - pointBounds.height/2)
						if (atBottom) top = whiteboardBounds.height - top
						point.css('top',`${top}px`).css('left',`${left}px`)
					})
				}
			})
		})
	}

	focusNext()

	function lf(){
		return $('#statsTable .lastFocus')
	}

	function teamButtonClicked(){
		lf().val($(this).text())
		focusNext()
		fillStats()
	}

	function focusNext(){
		var next = $('#statsTable input').filter(withoutValues).first()
		if (next.length) focusInput(next)
		return next.length > 0
	}

	function withoutValues(i,el){
		return $(el).val() == ''
	}

	function focusInput(input){
		if ('target' in input) input = $(input.target)
		if (input[0]==lf()[0]) return
		$('#statsTable input').removeClass('lastFocus')
		input.addClass('lastFocus')
	}

	function getTeamValue(field, team){
		if (!team) return ""
		if (! team in eventStatsByTeam) return ""
		var stats = eventStatsByTeam[team]
		if (! stats || ! field in stats) return ""
		if ('count' in stats && stats['count'] && statInfo[field]){
			if (statInfo[field].type == 'avg')	return Math.round((stats[field]||0) / stats['count'])
			if (statInfo[field].type == '%')	return Math.round(100 * (stats[field]||0) / stats['count'])
		}
		if (stats[field] == null) return ""
		return stats[field]
	}

	$('.viewTeam').click(showTeamStats)

	function showTeamStats(){
		var t = $(this).attr('data-team')
		if (t) t = parseInt(t)
		if (!t) return
		$('#statsLightBox iframe').attr('src',`/team.html#event=${eventId}&team=${t}`)
		window.scrollTo(0,0)
		showLightBox($('#statsLightBox'))
	}

	function showImg(){
		showLightBox($('#fullPhoto').attr('src', $(this).find('img').attr('src')))
	}
	$('#fullPhoto').click(closeLightBox)
	$('title').text($('title').text().replace("EVENT", eventName))
	$('#statsLightBox iframe').attr('src',`/team.html#event=${eventId}`)
	$('#lightBoxBG').click(function(){
		$('#statsLightBox iframe').attr('src',`/team.html#event=${eventId}`)
	})

	function sizeWhiteboard(){
		var winH = $(window).height(),
		winW = $(window).width(),
		tableW=Math.max(400,$('#statsTable').width()+10),
		w = winW<750?winW:winW-tableW,
		h=2*w
		if (h>winH){
			h=winH
			w=winH/2
		}
		$('#field,#fieldBG,#fieldDraw').css('width',`${w}px`).css('height',`${h}px`)
	}
	sizeWhiteboard()

	var sketcher = $("#fieldDraw").sketchable({
		events: {
			// We use the "before" event hook to update brush type right before drawing starts.
			mousedownBefore: function(elem, data, evt){
				var pen = $('button.pen.selected'),
				img = pen.find('img')
				if (img.length){
					data.options.graphics.fillStyle = '#fff0' // transparent
					data.options.graphics.strokeStyle = '#fff0'
					data.options.graphics.lineWidth = 3
					data.sketch.pencil()
					var bounds = $('#fieldDraw')[0].getBoundingClientRect()
					data.sketch.drawImage(img.attr('src'), evt.clientX - bounds.left, evt.clientY - bounds.top)
				} else if (pen.attr('data-type') == 'eraser'){
					// Set the brush in eraser mode.
					data.options.graphics.lineWidth = 20
					data.options.graphics.fillStyle = '#ffff'
					data.options.graphics.strokeStyle = '#ffff'
					data.sketch.eraser()
				} else {
					// Set the brush in pencil mode.
					data.options.graphics.lineWidth = 3
					data.options.graphics.firstPointSize = 3
					var color = pen.css('color')
					data.options.graphics.fillStyle = color
					data.options.graphics.strokeStyle = color
					data.sketch.pencil()
				}
			}
		}
	})
	sketcher.sketchable('handler', function(node, data){
		data.sketch.size(Math.floor(node.innerWidth()), Math.floor(node.innerHeight()))
	})

	function setCursorImage() {
		var pen = $('button.pen.selected'),
		img = pen.find('img'),
		cursor = img.length?img.attr('src'):pen.attr('data-type') + '.svg'
		sketcher.css('cursor', `url(${cursor}), auto`);
	}
	setCursorImage()
})
