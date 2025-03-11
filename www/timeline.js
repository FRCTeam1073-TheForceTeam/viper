'use strict'

function drawTimeline(canvas, data){
	if (canvas.length) canvas = canvas[0]
	canvas.width = canvas.clientWidth
	canvas.height = canvas.clientHeight
	var tick_count = Math.max(3, Math.floor(canvas.width/100)),
	ctx = canvas.getContext('2d'),
	rowHeight = canvas.clientHeight / (data.timelines.length + .5),
	maxTime = Number.MIN_SAFE_INTEGER,
	minTime = Number.MAX_SAFE_INTEGER
	data.timelines.forEach(l=>{
		l.events.forEach(k=>{
			if (k.time<minTime) minTime = k.time
			if (k.time>maxTime) maxTime = k.time
		})
	})

	function clearCanvas(){
		ctx.clearRect(0, 0, canvas.width, canvas.height)
	}

	function getTicks(){
		var elapsed = maxTime-minTime,
		between = Math.floor(elapsed/(tick_count-1)),
		ticks=[]
		for (var i=0; i<tick_count; i++){
			ticks.push(minTime + i*between)
		}
		return ticks
	}

	function getX(time){
		return (canvas.width-rowHeight)*time/(maxTime-minTime)+rowHeight/2
	}

	function drawTimelineRow(row, i){
		var rowMid = rowHeight * (i+.5)

		// Horizontal line
		ctx.strokeStyle = ctx.fillStyle = 'gray'
		ctx.lineWidth = rowHeight/20
		ctx.beginPath()
		ctx.moveTo(rowHeight/2, rowMid)
		ctx.lineTo(canvas.width-rowHeight/2, rowMid)
		ctx.stroke()

		// Ticks on line
		getTicks().forEach(time=>{
			var x = getX(time)
			ctx.beginPath()
			ctx.moveTo(x, rowMid)
			ctx.lineTo(x, rowMid + rowHeight/6)
			ctx.stroke()
		})

		// Data points
		ctx.textBaseline = "middle"
		ctx.textAlign = "center"
		ctx.font = rowHeight/1.5 +"px sans-serif"
		ctx.lineWidth = rowHeight/12
		row.events.forEach(event=>{
			var conf = data.points[event.event]||{}
			ctx.strokeStyle = conf.outline||"gray"
			ctx.fillStyle = conf.fill||"gray"
			ctx.strokeText(conf.stamp||"?", getX(event.time), rowMid)
			ctx.fillText(conf.stamp||"?", getX(event.time), rowMid)
		})

		// Match name
		ctx.strokeStyle = ctx.fillStyle = 'gray'
		ctx.font = rowHeight/3 +"px sans-serif"
		ctx.textBaseline = "bottom"
		ctx.textAlign = "end"
		ctx.fillText(row.name, canvas.width-rowHeight/2, rowMid)
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

	function redraw(){
		clearCanvas()
		drawTimeAxis()
		data.timelines.forEach(drawTimelineRow)
	}

	function showTooltip(e){
		var r = e.target.getBoundingClientRect(),
		x = e.clientX - r.left,
		y = e.clientY - r.top,

		// Rearranging with algebra:
		// y =  rowHeight * (i+.5)
		// y/rowHeight = i+.5
		// y/rowHeight-.5 = i

		row = Math.round(y/rowHeight-.5),
		time = Math.round((x - rowHeight/2)*(maxTime-minTime) / (canvas.width-rowHeight))
		redraw()
		ctx.textBaseline = "top"
		ctx.textAlign = "center"
		ctx.fillStyle = "white"
		if (data.timelines[row]){
			data.timelines[row].events.forEach(event=>{
				if (event.time > time-3 && event.time < time+3){
					var text = displayTime(event.time) + " " + event.event,
					textW = ctx.measureText(text).width/2,
					textX = x-textW<0?textW:(x+textW>canvas.width?canvas.width-textW:x)
					ctx.fillText(text, textX, y+20)
					y+=rowHeight/2.5
				}
			})
			for (var i=time-3; i<time+3; i++){
				if (data.timelines[row].events[i]){
				}
			}
		}
	}

	redraw()
	canvas.addEventListener("click",showTooltip)
	canvas.addEventListener("mousemove",showTooltip)
}
