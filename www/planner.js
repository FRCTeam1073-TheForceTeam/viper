"use strict"

var matchId=(location.hash.match(/^\#(?:(?:.*\&)?(?:(?:match)\=))?([a-z0-9]+)(?:\&.*)?$/)||["",""])[1],
myTeamsStats

$(document).ready(function() {
	var statsConfig = new StatsConfig({
		statsConfigKey:`${eventYear}WhiteboardStats`,
		getStatsConfig:function(){
			var s = statsConfig.getLocalStatsConfig()
			if (s) return s
			if (myTeamsStats && myTeamsStats.length) return myTeamsStats
			if (window.whiteboardStats && window.whiteboardStats.length) return window.whiteboardStats
			if (window.matchPredictorSections) return Object.keys(window.matchPredictorSections).map(k=>window.matchPredictorSections[k]).flat(1)
			return []
		},
		hasWhiteboard:true,
		drawFunction:fillStats,
		fileName:"whiteboard",
		defaultConfig:window.whiteboardStats,
		mode:"aggregate"
	})
	if (typeof eventYear !== 'undefined') $('#fieldBG').css("background-image",`url('/${eventYear}/field-whiteboard.png')`)
	if (eventCompetition=='ftc') $('.noftc').hide()
	$('button.pen').click(penButtonClicked)
	displayMatchName()

	function penButtonClicked(){
		$('button.pen').removeClass('selected')
		$(this).addClass('selected')
		setCursorImage()
	}

	$('.clear').click(function(evt){
		evt.preventDefault()
		sketcher.sketchable('clear')
	})

	$('.rotate').click(function(){
		$('#fieldBG').toggleClass('rotated')
		drawOverlays()
	})

	$('.printer').click(function(){
		window.print()
	})

	$('.clear-teams').click(function(){
		$('.team-input').val("")
		focusNext()
		fillStats()
	})

	$('.configure-stats').click(statsConfig.showConfigDialog.bind(statsConfig))

	$('.undo').click(function(evt){
		evt.preventDefault()
		sketcher.sketchable('memento.undo')
	})

	$('button.showInstructions').click(function(){
		showLightBox($('#instructions'))
		return false
	})

	function displayMatchName(){
		$('h3').text(eventName + " " + getShortMatchName(matchId))
	}

	function setLocationHash(){
		var hash = `event=${eventId}`
		if (matchId) hash += `&match=${matchId}`
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
		promiseSubjectiveScouting(),
		promiseEventMatches(),
		fetch(`/data/${eventYear}/whiteboard.json`).then(response=>{if(response.ok)return response.json()})
	]).then(values => {
		[[window.eventStats, window.eventStatsByTeam], window.pitData, window.subjectiveData, window.eventMatches, window.myTeamsStats] = values
		var teamList = Object.keys(eventStatsByTeam)
		teamList.sort((a,b) => a-b)
		for (var i=0; i<teamList.length; i++){
			var team = teamList[i]
			$('#teamButtons').append($(`<button id=team-${team} class=team>${team}</button>`).click(teamButtonClicked))
		}
		$('#matchList').append($('<option selected=1>')).change(function(){
			matchId = $(this).val()
			var match = (eventMatches.filter(m=>m.Match==matchId))[0]
			BOT_POSITIONS.forEach(function(pos){
				$(`#${pos}`).val(match[pos])
			})
			displayMatchName()
			fillStats()
			focusNext()
		})
		eventMatches.forEach(match=>{
			$('#matchList').append($('<option>').text(getMatchName(match.Match)).attr('value',match.Match))
		})
		fillStats()

		if (window.whiteboardStamps){
			window.whiteboardStamps.forEach(function(stamp){
				$('#stamps').append(" ").append($(`<button class="pen icon-button"><img src=${stamp}></button>`).click(penButtonClicked))
			})
		}
	})

	$('#statsTable input').change(fillStats).focus(function(){
		focusInput($(this))
	}).blur(function(e){
		if (!$(e.relatedTarget).is('button.team'))$('#teamButtons').toggle(focusNext())
	})

	function fillStats(){
		if (!window.statInfo) return
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
		$('.teamDataEntry').toggle(teamList.length!=BOT_POSITIONS.length)
		if(teamList.length==BOT_POSITIONS.length){
			var row = $("<tr>")
			teamList.forEach(function(team,i){
				var color = (i<BOT_POSITIONS.length/2)?"red":"blue"
				row.append($(`<td class="${color}TeamBG viewTeam" data-team=${team}>`).click(showTeamStats).html('<img src=/graph.svg>'))
				if (team == getLocalTeam() && (i<BOT_POSITIONS.length/2)) $('#fieldBG').addClass('rotated')
			})
			tbody.append(row)
			;["","-top"].forEach(function(imageSuffix){
				row = $("<tr>")
				teamList.forEach(function(team,i){
					var color = (i<BOT_POSITIONS.length/2)?"red":"blue"
					row.append($(`<td class="${color}TeamBG">`).click(showImg).html(`<img src=/data/${eventYear}/${team}${imageSuffix}.jpg>`))
				})
				tbody.append(row)
			})
			statsConfig.getStatsConfig().forEach(field=>{
				var info = statInfo[field]||{},
				name = info.name||field
				if (!info.whiteboard_end){
					row = $("<tr>")
					var best=info.good=='low'?99999999:0
					teamList.forEach(function(team,i){
						var val = getTeamValue(field,team)
						if (info.good=='low'){
							if (val<best&&val>0)best=val
						} else {
							if (val>best)best=val
						}
					})
					teamList.forEach(function(team,i){
						var color = (i<BOT_POSITIONS.length/2)?"red":"blue",
						val = getTeamValue(field,team),
						dispVal = val
						if(/^(%|fraction)$/.test(info.type)) dispVal += "%"
						row.append($(`<td class="${color}TeamBG">`).addClass(val==best?"best":"").text(dispVal))
					})
					row.append($('<th>').text(name))
					tbody.append(row)
				} else {
					var forUs = !!info.whiteboard_us
					row = $("<tr>")
					teamList.forEach(function(team,i){
						var color = (i<BOT_POSITIONS.length/2)?"red":"blue",
						checkbox = $(`<input id="${field}_${team}" type=checkbox>`).change(drawOverlays)
						if ((forUs==!$('#fieldBG').is('.rotated')) == (i<BOT_POSITIONS.length/2)) checkbox.attr('checked',"")
						row.append($(`<td class="${color}TeamBG">`).append(checkbox))
					})
					row.append($('<th>').text(name))
					tbody.append(row)
				}
			})
			drawOverlays()
		}
	}

	function drawOverlays(){
		$('.overlay').remove()
		var teamList = $('.team-input').get().map(inp=>parseInt(inp.value))
		statsConfig.getStatsConfig().forEach(field=>{
			var	fieldInfo = statInfo[field]||{}
			if (fieldInfo.whiteboard_end){
				teamList.forEach(function(team,i){
					var enabled = $(`#${field}_${team}`).prop('checked'),
					style = $(`#bot-${i}-pen`).attr('style').split(/[:;]/),
					rotated = $('#fieldBG').is('.rotated'),
					isRed = i<BOT_POSITIONS.length/2,
					atBottom = rotated != isRed,
					char = fieldInfo.whiteboard_char||"&",
					start = (fieldInfo.whiteboard_start||0)/100,
					end = (fieldInfo.whiteboard_end||100)/100,
					height = end - start,
					whiteboard = $('#field'),
					whiteboardBounds = whiteboard[0].getBoundingClientRect(),
					source = fieldInfo.source,
					type = fieldInfo.type,
					dataSource = source=='subjective'?subjectiveData:(source=='pit'?pitData:eventStatsByTeam),
					data=(dataSource[team]||{})[field]
					if (enabled){
						if (type == 'pathlist'){
							var canvas = $('<canvas class=overlay>').attr('id',`${team}-${field}`).css({width:'100%',height:whiteboardBounds.height * height + 'px'})
							if (atBottom){
								canvas.css({transform:'scaleY(-1)',bottom:start*whiteboardBounds.height})
							} else {
								canvas.css({top:start*whiteboardBounds.height})
							}
							$('#field').append(canvas)
							canvas[0].width = canvas[0].clientWidth
							canvas[0].height = canvas[0].clientHeight
							;(data||[]).forEach(path=>{
								drawPath(canvas, style[1], path)
							})
						} else {
							;(data||"").split(" ").forEach(coordinates=>{
								var top=0, left=0,
								m = coordinates.match(/^([0-9]{1,2})x([0-9]{1,2})$/)
								if (m && m.length){
									[left, top] = m.slice(1).map(x=>parseInt(x)/100)
									if (rotated) left = 1 - left
									var point = $('<div class=overlay>').html(char).css(...style)
									whiteboard.append(point)
									var pointBounds = point[0].getBoundingClientRect()
									left = Math.round(left * whiteboardBounds.width - pointBounds.width/2)
									top = Math.round(top * whiteboardBounds.height * height + start * whiteboardBounds.height - pointBounds.height/2)
									point.css(atBottom?"bottom":"top",`${top}px`).css('left',`${left}px`)
								}
							})
						}
					}
				})
			}
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
		$('.team-input').removeClass('lastFocus')
		if (next.length) focusInput(next)
		return next.length > 0
	}

	function withoutValues(i,el){
		return $(el).val() == '' && (eventCompetition!='ftc'||!$(el).closest('th').is('.noftc'))
	}

	function focusInput(input){
		if ('target' in input) input = $(input.target)
		if (input[0]==lf()[0]) return
		$('.team-input').removeClass('lastFocus')
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
		fieldR=eventCompetition=='ftc'?1:2,
		winW=$(window).width(),
		vert=winW<750,
		statsW=400,
		fieldW=vert?winW:winW-statsW,
		fieldH=fieldR*fieldW
		if (fieldH>winH){
			fieldH=winH
			fieldW=winH/fieldR
		}
		statsW=vert?winW:Math.max(400,winW-fieldW-10)
		var h3W=statsW-70,
		statsP=vert?'top':'left',
		statsO=vert?fieldH+10:fieldW+10
		$('#field,#fieldBG,#fieldDraw').css('width',`${fieldW}px`).css('height',`${fieldH}px`)
		$('#stats').css('width',`${statsW}px`).css('max-width',`${statsW}px`).css(statsP, statsO)
		$('h3').css('width',`${h3W}px`)
		$('body').css('overflow-y',vert?'visible':'hidden')
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
