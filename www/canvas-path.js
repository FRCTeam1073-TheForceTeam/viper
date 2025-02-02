
function getPixelCoordinates(mapImage, isReversedX, coordinates, floatingImage, isReversedY){
	var m = coordinates.match(/^([0-9]{1,2})x([0-9]{1,2})$/)
	if (!m || !m.length) return
	var px = parseInt(m[1]),
	py = parseInt(m[2])
	if (isReversedX) px = 100 - px
	if (isReversedY) py = 100 - py
	var d = mapImage.getBoundingClientRect(),
	s = floatingImage?floatingImage.getBoundingClientRect():{width:0,height:0},
	x = Math.round(px * d.width / 100 - s.width/2),
	y = Math.round(py * d.height / 100 - s.height/2)
	return {x:x,y:y}
}

// https://stackoverflow.com/a/36805543
function drawArrow(ctx, from, to, size){
	ctx.beginPath()
	ctx.moveTo(from.x,from.y)
	ctx.lineTo(to.x,to.y)
	ctx.stroke()
	ctx.beginPath()
	var angle=Math.atan2(to.y-from.y,to.x-from.x),
	x=size*Math.cos(angle)+to.x,
	y=size*Math.sin(angle)+to.y
	ctx.moveTo(x,y)
	angle+=2*Math.PI/3
	x=size*Math.cos(angle)+to.x
	y=size*Math.sin(angle)+to.y
	ctx.lineTo(x,y)
	angle+=2*Math.PI/3
	x=size*Math.cos(angle)+to.x
	y=size*Math.sin(angle)+to.y
	ctx.lineTo(x,y)
	ctx.closePath()
	ctx.fill()
}

function drawDot(ctx, at, radius){
	let dot = new Path2D()
	dot.arc(at.x, at.y, radius, 0, 2*Math.PI, false)
	ctx.fill(dot)
}

function sizeAndClearCanvas(canvas){
	ctx = canvas.getContext('2d')
	canvas.width = canvas.clientWidth
	canvas.height = canvas.clientHeight
	ctx.clearRect(0, 0, canvas.width, canvas.height)
}

function drawPath(canvas, color, path, isReversedX, isReversedY){
	if (canvas.length) canvas = canvas[0]
	var last, ctx = canvas.getContext('2d')
	ctx.lineWidth = canvas.width*.005
	path.split(/ /).forEach((point)=>{
		ctx.fillStyle = ctx.strokeStyle = color
		var c = getPixelCoordinates(canvas,isReversedX,point,null,isReversedY)
		if (c){
			if (last) drawArrow(ctx,last,c,canvas.width*.015)
			else drawDot(ctx,c,canvas.width*.01)
			last = c
		}
	})
}
