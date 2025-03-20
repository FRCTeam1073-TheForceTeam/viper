"use strict"

addI18n({
	eraser_tooltip:{
		en:'Whiteboard eraser',
		tr:'Beyaz tahta silgisi',
		he:'מחק לוח לבן',
		pt:'Apagador de quadro branco',
		zh_tw:'白板擦',
		fr:'Effaceur de tableau blanc',
	},
	undo_tooltip:{
		en:'Whiteboard undo',
		tr:'Beyaz tahta geri al',
		he:'בטל לוח לבן',
		pt:'Desfazer quadro branco',
		zh_tw:'白板撤銷',
		fr:'Annulation du tableau blanc',
	},
	clear_tooltip:{
		en:'Whiteboard clear',
		tr:'Beyaz tahta temizle',
		he:'לוח לבן ברור',
		pt:'Limpar quadro branco',
		zh_tw:'白板清除',
		fr:'Effacement du tableau blanc',
	},
	rotate_tooltip:{
		en:'Whiteboard rotate',
		tr:'Beyaz tahta döndür',
		he:'סיבוב לוח לבן',
		pt:'Girar quadro branco',
		zh_tw:'白板旋轉',
		fr:'Rotation du tableau blanc',
	},
	print_tooltip:{
		en:'Print, save page',
		tr:'Sayfayı yazdır, kaydet',
		he:'הדפס, שמור עמוד',
		pt:'Imprimir, salvar página',
		zh_tw:'列印、儲存頁面',
		fr:'Imprimer, enregistrer la page',
	},
	choose_teams_tooltip:{
		en:'Choose teams',
		tr:'Takımları seç',
		he:'בחר צוותים',
		pt:'Escolher equipes',
		zh_tw:'選擇團隊',
		fr:'Choisir les équipes',
	},
	configure_tooltip:{
		en:'Configure stats',
		tr:'İstatistikleri yapılandır',
		he:'הגדר סטטיסטיקה',
		pt:'Configurar estatísticas',
		zh_tw:'配置統計數據',
		fr:'Configurer les statistiques',
	},
	instructions_tooltip:{
		en:'Show instructions',
		tr:'Talimatları göster',
		he:'הצג הוראות',
		pt:'Mostrar instruções',
		zh_tw:'顯示說明',
		fr:'Afficher les instructions',
	},
	black_pen_tooltip:{
		en:'Whiteboard pen, black',
		tr:'Beyaz tahta kalemi, siyah',
		he:'עט לוח לבן, שחור',
		pt:'Caneta de quadro branco, preta',
		zh_tw:'白板筆 黑色',
		fr:'Stylo pour tableau blanc, noir',
	},
	robot_pen_tooltip:{
		en:'Whiteboard pen, colored for this robot',
		tr:'Beyaz tahta kalemi, bu robot için renkli',
		he:'עט לוח לבן, צבעוני לרובוט הזה',
		pt:'Caneta de quadro branco, colorida para este robô',
		zh_tw:'為這款機器人配色的白板筆',
		fr:'Stylo pour tableau blanc, couleur pour ce robot',
	},
	stamp_tooltip:{
		en:'Whiteboard stamp',
		tr:'Beyaz tahta damgası',
		he:'חותמת לוח לבן',
		pt:'Carimbo de quadro branco',
		zh_tw:'白板圖章',
		fr:'Tampon pour tableau blanc',
	},
	team_stats_tooltip:{
		en:'View team stats',
		tr:'Takım istatistiklerini görüntüle',
		he:'הצג נתונים סטטיסטיים של הצוות',
		pt:'Exibir estatísticas de equipe',
		zh_tw:'查看球隊統計數據',
		fr:'Afficher les statistiques de l\'équipe',
	},
	planner_title:{
		en:'Match Planner _EVENT_',
		tr:'Maç Planlayıcısı _EVENT_',
		he:'מתכנן התאמה _EVENT_',
		pt:'Planejador de Partidas _EVENT_',
		zh_tw:'比賽規劃師 _EVENT_',
		fr:'Planificateur de match _EVENT_',
	},
	planner_heading:{
		en:'_EVENT_ _MATCHSHORT_',
		fr:'_EVENT_ _MATCHSHORT_',
		pt:'_EVENT_ _MATCHSHORT_',
		tr:'_EVENT_ _MATCHSHORT_',
		he:'_EVENT_ _MATCHSHORT_',
		zh_tw:'_EVENT_ _MATCHSHORT_',
	},
})

var matchId=(location.hash.match(/^\#(?:(?:.*\&)?(?:(?:match)\=))?([a-z0-9]+)(?:\&.*)?$/)||["",""])[1],
myTeamsStats
onApplyTranslation.push(function(){
	addTranslationContext({
		event:eventName,
		matchShort:getShortMatchName(matchId)
	})
})

$(document).ready(function(){
	onApplyTranslation.push(fillStats)
	var statsConfig = new StatsConfig({
		statsConfigKey:`${eventYear}WhiteboardStats`,
		getStatsConfig:function(){
			var s = statsConfig.getLocalStatsConfig()
			if (s) return s
			if (myTeamsStats && myTeamsStats.length) return myTeamsStats
			if (window.whiteboardStats && window.whiteboardStats.length) return window.whiteboardStats
			return []
		},
		hasWhiteboard:true,
		drawFunction:fillStats,
		fileName:"whiteboard",
		defaultConfig:window.whiteboardStats,
		mode:"aggregate"
	})
	if (typeof eventYear !== 'undefined') $('#field').prepend($('<img id=fieldBG>').attr('src',`/${eventYear}/field-whiteboard.png`))
	if (eventCompetition=='ftc') $('.noftc').hide()

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

	$('button.showInstructions').click(function(){
		showLightBox($('#instructions'))
		return false
	})

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


	window.addEventListener("resize",sizeWhiteboard)

	function sizeWhiteboard(){
		var winH = $(window).height(),
		fieldR=window.whiteboard_aspect_ratio||(eventCompetition=='ftc'?1:2),
		winW=$(window).width(),
		margin=winW<500?0:winW/150,
		spacing=winW/100,
		vert=winW<750,
		statsW=vert?winW-margin-margin:Math.max(400,winW/3),
		fieldW=vert?winW-margin-margin:winW-statsW-spacing-margin-margin,
		fieldH=fieldR*fieldW
		if (fieldH>winH-margin-margin){
			fieldH=winH-margin-margin
			fieldW=fieldH/fieldR
		}
		if(!vert)statsW=Math.max(statsW,winW-fieldW-margin-margin-spacing)
		var h3W=statsW-70,
		statsL=vert?0:fieldW+spacing+margin,
		statsT=vert?fieldH+spacing+margin:0
		$('#field,#fieldBG,#fieldDraw').css('width',`${fieldW}px`).css('height',`${fieldH}px`)
		$('#field').css('top',margin).css('left',margin)
		$('#stats').css('width',`${statsW}px`).css('max-width',`${statsW}px`).css('left',statsL).css('top',statsT)
		$('h3').css('width',`${h3W}px`)
		$('body').css('overflow-y',vert?'visible':'hidden')
		if(!whiteboard) whiteboard = new Whiteboard($('#fieldDraw')[0])
		drawOverlays()
	}

	Promise.all([
		promiseEventStats(),
		promisePitScouting(),
		promiseSubjectiveScouting(),
		promiseEventMatches(),
		promiseTeamsInfo(),
		fetch(`/data/${eventYear}/whiteboard.json`).then(response=>{if(response.ok)return response.json()})
	]).then(values => {
		;[[window.eventStats, window.eventStatsByTeam], window.pitData, window.subjectiveData, window.eventMatches, window.eventTeamsInfo, window.myTeamsStats] = values
		var teamList = Object.keys(eventStatsByTeam)
		teamList.sort((a,b) => a-b)
		for (var i=0; i<teamList.length; i++){
			var team = teamList[i]
			$('#teamButtons').append($(`<button id=team-${team} class=team>${team}</button>`).attr('data-tooltip',getTeamInfo(team)).click(teamButtonClicked))
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
				$('#stamps').append(" ").append($(`<button class="stamp icon-button draw-mode" data-i18n-tooltip=stamp_tooltip><img src=${stamp}></button>`).click(stampWhiteboard).click(showDrawMode))
			})
		}
		sizeWhiteboard()
	})

	$('#statsTable input').change(fillStats).focus(function(){
		focusInput($(this))
	}).blur(function(e){
		if (!$(e.relatedTarget).is('button.team'))$('#teamButtons').toggle(focusNext())
	})

	function getTeamInfo(teamNum){
		var info=eventTeamsInfo[teamNum]
		if (!info)return null
		var name=info.nameShort||""
		if (info.city)name+=`, ${info.city}`
		if (info.stateProv)name+=`, ${info.stateProv}`
		if (info.country)name+=`, ${info.country}`
		return name
	}

	function fillStats(){
		if (!window.statInfo||!window.eventTeamsInfo) return
		setLocationHash()
		$('#teamButtons button').removeClass("picked")
		var teamList=[],
		tbody = $('#statsTable tbody').html("")
		$('.team-input').each(function(){
			var val = $(this).val(),
			tooltip=null
			val = val?parseInt(val):0
			if (val){
				tooltip=getTeamInfo(""+val)
				$(`#team-${val}`).addClass("picked")
				teamList.push(val)
			}
			$(this).parent().attr('data-tooltip',tooltip)
		})
		$('.teamDataEntry').toggle(teamList.length!=BOT_POSITIONS.length)
		if(teamList.length==BOT_POSITIONS.length){
			var row = $("<tr>")
			teamList.forEach(function(team,i){
				var color = (i<BOT_POSITIONS.length/2)?"red":"blue"
				row.append($(`<td class="${color}TeamBG viewTeam" data-team=${team} data-i18n-tooltip=team_stats_tooltip>`).click(showTeamStats).html('<img src=/graph.svg>'))
				if (team == getLocalTeam() && (i>=BOT_POSITIONS.length/2)) $('#fieldBG').addClass('rotated')
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
				name = translate(field)
				if (!info.whiteboard_end){
					row = $("<tr>")
					var best=info.good=='low'?99999999:-99999999,
					worst=-best
					teamList.forEach(function(team,i){
						var val = getTeamValue(field,team)
						if (info.good=='low'){
							if (val<best)best=val
							if (val>worst)worst=val
						} else {
							if (val>best)best=val
							if (val<worst)worst=val
						}
					})
					if (worst==best)best=99999999
					teamList.forEach(function(team,i){
						var color = (i<BOT_POSITIONS.length/2)?"red":"blue",
						val = getTeamValue(field,team),
						dispVal = val
						if(/^(%|fraction|ratio)$/.test(info.type)&&(typeof dispVal==='number')) dispVal += "%"
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
			applyTranslations(tbody)
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
					invert = !!fieldInfo.whiteboard_invert,
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
								drawPath(canvas, style[1], path, !atBottom && window.fieldRotationalSymmetry)
							})
						} else {
							;(data||"").split(" ").forEach(coordinates=>{
								var top=0, left=0,
								m = coordinates.match(/^([0-9]{1,2})x([0-9]{1,2})$/)
								if (m && m.length){
									[left, top] = m.slice(1).map(x=>parseInt(x)/100)
									if (invert)[left, top] = [top, left]
									if (!atBottom && window.fieldRotationalSymmetry) left = 1 - left
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

	$('.team-input').click(function(){
		$(this).val("")
		fillStats()
	})

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
			if (statInfo[field].type == 'avg') return Math.round((stats[field]||0) / stats['count'])
			if (statInfo[field].type == '%') return Math.round(100 * (stats[field]||0) / stats['count'])
		}
		if (stats[field] == null) return ""
		if (statInfo[field].type == 'ratio') return Math.round(100 * (stats[field]))
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


	var whiteboard

	$('.clear').click(()=>whiteboard.clear.call(whiteboard))
	$('.eraser').click(()=>whiteboard.eraserMode.call(whiteboard))
	$('.pen').click(function(){whiteboard.penMode.call(whiteboard,this.style.color)})
	$('.undo').click(()=>whiteboard.undo.call(whiteboard))

	function stampWhiteboard(){
		whiteboard.stampMode.call(whiteboard,this.querySelector('img'))
	}

	function showDrawMode(){
		$('.draw-mode').removeClass('selected')
		$(this).addClass('selected')
	}

	$('.draw-mode').click(showDrawMode)
})


class Whiteboard {
	constructor(canvas){
		this.canvas = canvas
		if(this.canvas.clientWidth>this.canvas.clientHeight){
			this.maxDimension=this.canvas.width=Math.max(window.screen.width,window.screen.height,2000)
			this.canvas.height=this.canvas.width/this.canvas.clientWidth*this.canvas.clientHeight
		} else {
			this.maxDimension=this.canvas.height=Math.max(window.screen.width,window.screen.height,2000)
			this.canvas.width=this.canvas.height/this.canvas.clientHeight*this.canvas.clientWidth
		}
		this.ctx = canvas.getContext('2d')
		document.addEventListener("mousemove",e=>this.moused.call(this,e),{passive:false})
		document.addEventListener("mousedown",e=>this.moused.call(this,e),{passive:false})
		document.addEventListener("mouseup",e=>this.moused.call(this,e),{passive:false})
		document.addEventListener("touchstart",e=>this.moused.call(this,e),{passive:false})
		document.addEventListener("touchend",e=>this.moused.call(this,e),{passive:false})
		document.addEventListener("touchcancel",e=>this.moused.call(this,e),{passive:false})
		document.addEventListener("touchmove",e=>this.moused.call(this,e),{passive:false})
		window.addEventListener("resize",e=>this.size.call(this),{passive:true})
		this.size()
		this.drawClear()
		this.penMode('#000')
		this.history=[]
	}

	stampMode(image){
		this.mode='stamp'
		this.canvas.style.cursor=`url('${image.src}'),cell`
		this.stampImage=image
	}

	penMode(color){
		this.color=color
		this.mode='pen'
		this.canvas.style.cursor="url('/pencil.svg'),crosshair"
	}

	eraserMode(){
		this.mode='eraser'
		this.canvas.style.cursor="url('/eraser.svg'),grab"
	}

	size(){
		this.width=this.canvas.clientWidth
		this.height=this.canvas.clientHeight
		this.left=this.canvas.getBoundingClientRect().left
		this.right=this.canvas.getBoundingClientRect().right
		this.top=this.canvas.getBoundingClientRect().top
		this.bottom=this.canvas.getBoundingClientRect().bottom
	}

	clear(){
		this.current=new ClearStroke()
		this.history.push(this.current)
		this.current.draw(this)
	}

	drawClear(){
		this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height)
	}

	undo(){
		this.history.pop()
		this.redraw()
	}

	redraw(){
		this.drawClear()
		for (var i=0; i<this.history.length; i++){
			this.history[i].draw(this)
		}
	}

	moused(e){
		var drawing = (e.buttons&1)==1||/^touchstart|touchmove$/.test(e.type)
		if ((this.current && this.current.mode != this.mode) || !drawing){
			this.current=null
			this.lastPoint=null
		}
		var touch=e.touches&&e.touches.length?e.touches[0]:{pageX:e.clientX||-1,pageY:e.clientY||[-1]},
		x=touch.pageX,
		y=touch.pageY,
		point=[
			Math.max(0,Math.min((x-this.left)*(this.canvas.width/this.width),this.canvas.width)),
			Math.max(0,Math.min((y-this.top)*(this.canvas.height/this.height),this.canvas.height))
		]
		if (x<this.left||y<this.top||x>this.right||y>this.bottom){
			if (x>=0&&y>=0&&!/^mouseup|mousedown$/.test(e.type)){
				if (this.current){
					this.current.addPoint(point)
					this.current.draw(this)
					this.current=null
				}
				this.lastPoint=point
			}
			return
		}
		if(e.target!=this.canvas)return
		e.preventDefault()
		if(!drawing)return
		if (!this.current){
			switch(this.mode){
				case "pen":
					this.current=new PenStroke(this.color)
					break
				case "eraser":
					this.current=new EraserStroke()
					break
				case "stamp":
					this.current=new StampStroke(this.stampImage)
					break
			}
			this.history.push(this.current)
		}
		this.current.addPoint(point,this.lastPoint)
		this.lastPoint=null
		this.current.draw(this)
	}
}

class WhiteboardStroke {
	constructor(){
		this.points=[]
		this.composite="source-over"
		this.lineScale=0.003
		this.maxPoints=99999
	}

	addPoint(point,prePoint){
		if (this.points.length>=this.maxPoints)return
		if (this.points.length&&(this.points[this.points.length-1][0]==point[0]&&this.points[this.points.length-1][1]==point[1]))return
		if (this.maxPoints>1&&prePoint)this.points.push(prePoint)
		this.points.push(point)
	}

	drawStart(whiteboard){
		whiteboard.ctx.beginPath()
		whiteboard.ctx.strokeStyle=this.color
		whiteboard.ctx.fillStyle=this.color
		whiteboard.ctx.globalCompositeOperation=this.composite
		whiteboard.ctx.lineWidth=whiteboard.maxDimension*this.lineScale
	}

	drawEnd(whiteboard){
		whiteboard.ctx.closePath()
	}
}

class PenStroke extends WhiteboardStroke {
	constructor(color){
		super()
		this.color=color
		this.mode="pen"
	}

	draw(whiteboard){
		this.drawStart(whiteboard)
		if(this.points.length){
			if(this.points.length==1){
				whiteboard.ctx.arc(this.points[0][0],this.points[0][1],whiteboard.ctx.lineWidth/2,0,2*Math.PI)
				whiteboard.ctx.fill()
			} else {
				whiteboard.ctx.moveTo(this.points[0][0],this.points[0][1])
				for(var i=1;i<this.points.length;i++){
					whiteboard.ctx.lineTo(this.points[i][0],this.points[i][1])
				}
				whiteboard.ctx.stroke()
			}
		}
		this.drawEnd(whiteboard)
	}
}

class EraserStroke extends PenStroke {
	constructor(color){
		super('#999')
		this.composite="destination-out"
		this.lineScale=0.03
		this.mode="eraser"
	}
}

class ClearStroke extends WhiteboardStroke {
	constructor(color){
		super()
		this.mode="clear"
		this.maxPoints=0
	}

	draw(whiteboard){
		this.drawStart(whiteboard)
		whiteboard.drawClear()
		this.drawEnd(whiteboard)
	}
}

class StampStroke extends WhiteboardStroke {
	constructor(image){
		super()
		this.mode="stamp"
		this.image=image
		this.maxPoints=1
	}

	draw(whiteboard){
		var width=this.image.naturalWidth,
		height=this.image.naturalHeight,
		imageMax=Math.max(width,height),
		scale=whiteboard.maxDimension/imageMax*0.025
		this.drawStart(whiteboard)
		whiteboard.ctx.drawImage(this.image,0,0,width,height,this.points[0][0],this.points[0][1],width*scale,height*scale)
		this.drawEnd(whiteboard)
	}
}
