"use strict"
$(document).ready(function() {
	var field = $('#field')
	if (typeof eventYear !== 'undefined') field.css("background-image",`url('/${eventYear}/field-whiteboard.png')`)

	var sketcher = field.sketchable({
		events: {
			// We use the "before" event hook to update brush type right before drawing starts.
			mousedownBefore: function(elem, data, evt){
				if ($('button.pen.selected').attr('data-type') == 'eraser'){
					// There is a method to set the brush in eraser mode.
					data.options.graphics.lineWidth = 20
					data.sketch.eraser()
				} else {
					// There is a method to get the default mode (pencil) back.
					data.options.graphics.lineWidth = 3
					data.options.graphics.firstPointSize = 3
					var color = $('button.pen.selected').css('color')
					data.options.graphics.fillStyle = color
					data.options.graphics.strokeStyle = color
					data.sketch.pencil()
				}
			}
		}
	})

	sketcher.sketchable('handler', sizeHandler)

	$(window).resize(function(ev) {
		sketcher.sketchable('handler', sizeHandler)
	})

	function sizeHandler(node, data){
		data.sketch.size(Math.floor(node.innerWidth()), Math.floor(node.innerHeight()))
	}

	$('button.pen').click(function(){
		$('button.pen').removeClass('selected')
		$(this).addClass('selected')
		setIcon()
	})

	$('.clear').click(function(evt) {
		evt.preventDefault()
		sketcher.sketchable('clear')
	})

	$('.undo').click(function(evt) {
		evt.preventDefault()
		sketcher.sketchable('memento.undo')
	})

	$('button.showInstructions').click(function(){
		showLightBox($('#instructions'))
		return false
	})

	function setIcon() {
		var cursor = $('button.pen.selected').attr('data-type')
		sketcher.css('cursor', `url(${cursor}.svg), auto`);
	}
	setIcon()

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

	loadEventStats(function(){
		var teamList = Object.keys(eventStatsByTeam)
		teamList.sort((a,b) => a-b)
		for (var i=0; i<teamList.length; i++){
			var team = teamList[i]
			$('#teamButtons').append($(`<button id=team-${team} class=team>${team}</button>`).click(teamButtonClicked))
		}
		fillStats()
	})

	$('#statsTable input').change(fillStats)

	function fillStats(){
		setLocationHash()
		$('#teamButtons button').removeClass("picked")
		var teamList=[],
		tbody = $('#statsTable tbody').html("")
		$('#statsTable input').each(function(){
			var val = $(this).val()
			val = val?parseInt(val):0
			if (val){
				$(`#team-${val}`).addClass("picked")
				teamList.push(val)
			}
		})
		$('#teamButtons').toggle(teamList.length!=6)
		var sections = window.plannerSections||window.matchPredictorSections
		if (!sections) return
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
			Object.keys(sections).forEach(function(section){
				for (var j=0; j<sections[section].length; j++){
					var field = sections[section][j]
					statInfo[field] = statInfo[field]||{}
					var statName = statInfo[field]['name']||field
					row = $("<tr>")
					teamList.forEach(function(team,i){
						var color = i<3?"red":"blue"
						row.append($(`<td class="${color}TeamBG">`).text(getTeamValue(field,team)))
					})
					row.append($('<th>').text(statName))
					tbody.append(row)
				}
			})
		}
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
		if ('count' in stats && stats['count'] && statInfo[field] && statInfo[field].type == 'avg'){
			return Math.round((stats[field]||0) / stats['count'])
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
})