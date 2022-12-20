"use strict"

$(document).ready(function(){
	loadEventSchedule(function(data){
		if (!data.length) return $('body').html("Match not found")
		for (var i=0; i<data.length; i++){
			var row = $($('template#matchRow').html())
			row.find('.R1').text(data[i]['R1'])
			row.find('.R2').text(data[i]['R2'])
			row.find('.R3').text(data[i]['R3'])
			row.find('.B1').text(data[i]['B1'])
			row.find('.B2').text(data[i]['B2'])
			row.find('.B3').text(data[i]['B3'])
			row.find('.match-id').text(getMatchName(data[i]['Match'])).attr('data-match-id',data[i]['Match'])
			row.click(showLinks)
			$('#matches').append(row)
		}
		var last = data[data.length-1]['Match'].replace(/[0-9]+/,""),
		addMatches = $('#addMatches'),
		edit = $('#edit')
		var next = {
			"qm": "playoffs",
			"qf": "semi-finals",
			"sf": "finals",
			"1p": "playoffs round 2",
			"2p": "playoffs round 3",
			"3p": "playoffs round 4",
			"4p": "playoffs round 5",
			"5p": "finals"
		}
		if (last == 'pm'){
			addMatches.html(addMatches.html().replace('playoffs', "event-table").replace('EVENT', eventId).replace('NEXT','qualifiers'))
			addMatches.show()
		} else if (next.hasOwnProperty(last)){
			addMatches.html(addMatches.html().replace('EVENT', eventId).replace('NEXT',next[last]))
			addMatches.show()
		} else {
			addMatches.hide()
		}
		edit.html(edit.html().replace('EVENT', eventId))
	})
	$('#lightBoxBG').click(function(){
		$('.lightBox').hide()
	})
	$('h1').text(eventName + " " + $('h1').text())
	$('title').text(eventName + " " + $('title').text())
})

function showLinks(e){
	var el = $(e.target),
	team,pos,
	row=el.closest('tr'),
	match=row.find('.match-id'),
	matchId=match.attr('data-match-id'),
	matchName=match.text(),
	r1=row.find('.R1').text(),
	r2=row.find('.R2').text(),
	r3=row.find('.R3').text(),
	b1=row.find('.B1').text(),
	b2=row.find('.B2').text(),
	b3=row.find('.B3').text()
	if (/^[0-9]+$/.test(el.text())){
		team=el.text()
		pos=el.attr('class').match(/\b[RB][1-3]\b/)[0]
	}

	var html = $('#lightBoxTemplate').html()
		.replace(/\$TEAM/g, team)
		.replace(/\$POS/g, pos)
		.replace(/\$MATCH_ID/g, matchId)
		.replace(/\$MATCH_NAME/g, matchName)
		.replace(/\$R1/g, r1)
		.replace(/\$R2/g, r2)
		.replace(/\$R3/g, r3)
		.replace(/\$B1/g, b1)
		.replace(/\$B2/g, b2)
		.replace(/\$B3/g, b3)
		.replace(/\$EVENT/g, eventId)
		.replace(/\$YEAR/g, eventYear)
	$('#lightBoxContent').html(html)
	$('#lightBoxContent').find('.dependTeam').toggle(!!team)
	$('.lightBox').show()
}
