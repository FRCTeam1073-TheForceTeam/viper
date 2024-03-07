'use strict'

function drawTimeline(canvas, data){
	if (canvas.length) canvas = canvas[0]
	canvas.width = canvas.clientWidth
	canvas.height = canvas.clientHeight
	var ctx = canvas.getContext('2d'),
	rowHeight = canvas.clientHeight / (data.timelines.length + 2),
	maxTime = Number.MIN_SAFE_INTEGER,
	minTime = Number.MAX_SAFE_INTEGER,
	eventColors = {},
	eventFirstTimes = {},
	eventOrder
	data.timelines.forEach(l=>{
		Object.keys(l.data).forEach(k=>{
			k = parseInt(k)
			if (k<minTime) minTime = k
			if (k>maxTime) maxTime = k
			var v = l.data[k]
			if (!eventFirstTimes.hasOwnProperty(v))	eventFirstTimes[v] = k
			else eventFirstTimes[v] = Math.min(k,eventFirstTimes[v])
		})
	})
	eventOrder = Object.keys(eventFirstTimes)
	eventOrder.sort((a,b)=>eventFirstTimes[a]-eventFirstTimes[b])
	eventOrder.forEach((v,i) => eventColors[v]=data.colors[i%data.colors.length])

	function clearCanvas(){
		ctx.clearRect(0, 0, canvas.width, canvas.height)
	}

	function makeTransparent(color){
		if (/^#[0-9A-Fa-f]{3}$/.test(color)) return color+"9"
		if (/^#[0-9A-Fa-f]{6}$/.test(color)) return color+"99"
		return color
	}

	function drawDot(at, radius){
		let dot = new Path2D()
		dot.arc(at.x, at.y, radius, 0, 2*Math.PI, false)
		ctx.strokeWidth
		ctx.stroke(dot)
		ctx.fill(dot)
	}

	function getTicks(){
		var elapsed = maxTime-minTime,
		between = Math.floor(elapsed/5),
		ticks=[]
		for (var i=0; i<6; i++){
			ticks.push(minTime + i*between)
		}
		return ticks
	}

	function getX(time){
		return (canvas.width-rowHeight)*time/(maxTime-minTime)+rowHeight/2
	}

	function drawTimelineRow(row, i){
		var rowMid = rowHeight * (i+1.5) + rowHeight/2
		ctx.strokeStyle = ctx.fillStyle = 'gray'
		ctx.lineWidth = rowHeight/20
		ctx.beginPath()
		ctx.moveTo(rowHeight/2, rowMid)
		ctx.lineTo(canvas.width-rowHeight/2, rowMid)
		ctx.stroke()
		ctx.font = rowHeight/3 +"px sans-serif"
		ctx.textBaseline = "bottom"
		ctx.textAlign = "start"
		ctx.fillText(row.name, rowHeight, rowMid)
		getTicks().forEach(time=>{
			var x = getX(time)
			ctx.beginPath()
			ctx.moveTo(x, rowMid)
			ctx.lineTo(x, rowMid + rowHeight/6)
			ctx.stroke()
		})
		Object.keys(row.data).forEach(time=>{
			var event = row.data[time]
			ctx.strokeStyle = eventColors[event]
			ctx.fillStyle = makeTransparent(eventColors[event])
			drawDot({x:getX(time),y:rowMid},rowHeight/4)
		})
		ctx.strokeStyle = ctx.fillStyle = 'gray'
		ctx.font = rowHeight/3 +"px sans-serif"
		ctx.textBaseline = "bottom"
		ctx.textAlign = "start"
		ctx.fillText(row.name, rowHeight, rowMid)
	}

	function displayTime(time){
		var sec = Math.floor(time%60)
		return Math.floor(time/60) + ":" + (sec<10?"0"+sec:sec)
	}

	function drawTimeAxis(){
		var rowBottom = canvas.height - rowHeight/8
		getTicks().forEach(time=>{
			var x = getX(time),
			text = displayTime(time)
			ctx.strokeStyle = ctx.fillStyle = 'gray'
			ctx.lineWidth = rowHeight/20
			ctx.font = rowHeight/3 +"px sans-serif"
			ctx.textBaseline = "bottom"
			ctx.textAlign = "center"
			ctx.fillText(text, x, rowBottom)
		})
	}

	function drawLegend(){
		var padding = rowHeight/8,
		x=padding,
		rowTop=padding
		eventOrder.forEach(event=>{
			ctx.strokeStyle = ctx.fillStyle = eventColors[event]
			ctx.font = rowHeight/3 +"px sans-serif"
			ctx.textBaseline = "top"
			ctx.textAlign = "start"
			var width = ctx.measureText(event).width
			if (x>padding && x+width>canvas.width-padding){
				x = padding
				rowTop += rowHeight/2.5
			}
			ctx.fillText(event, x, rowTop)
			x += width + rowHeight/4
		})
	}

	function redraw(){
		clearCanvas()
		drawTimeAxis()
		drawLegend()
		data.timelines.forEach(drawTimelineRow)
	}

	function showTooltip(e){
		var r = e.target.getBoundingClientRect(),
		x = e.clientX - r.left,
		y = e.clientY - r.top,
		row = Math.round((y - rowHeight*1.75)/rowHeight),
		time = Math.round((x - rowHeight/2)*(maxTime-minTime) / (canvas.width-rowHeight))
		redraw()
		ctx.textBaseline = "top"
		ctx.textAlign = "center"
		ctx.fillStyle = "white"
		if (data.timelines[row]){
			for (var i=time-3; i<time+3; i++){
				if (data.timelines[row].data[i]){
					var text = displayTime(i) + " " + data.timelines[row].data[i],
					textW = ctx.measureText(text).width/2,
					textX = x-textW<0?textW:(x+textW>canvas.width?canvas.width-textW:x)
					console.log(`x: ${x}    textW: ${textW}    textX:${textX}`)
					ctx.fillText(text, textX, y+20)
					y+=rowHeight/2.5
				}
			}
		}
	}


	redraw()
	canvas.addEventListener("click",showTooltip)
	canvas.addEventListener("mousemove",showTooltip)


}
