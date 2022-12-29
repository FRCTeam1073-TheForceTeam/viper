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
    var teamCount = 0,
    tbody = $('#statsTable tbody').html("")
    $('#statsTable input').each(function(){
      val = $(this).val()
      if (val){
        $(`#team-${val}`).addClass("picked")
        teamCount++
      }
    })
    $('#teamButtons').toggle(teamCount!=6)
    if(teamCount==6){
      if (typeof matchPredictorSections === 'undefined') return
      var r1 = parseInt($('#R1').val())
      var r2 = parseInt($('#R2').val())
      var r3 = parseInt($('#R3').val())
      var b1 = parseInt($('#B1').val())
      var b2 = parseInt($('#B2').val())
      var b3 = parseInt($('#B3').val())
      var sections = Object.keys(matchPredictorSections),
      row = $("<tr>")
      row.append($('<td class="redTeamBG viewTeam">').attr('data-team',r1).click(showTeamStats).text(r1?'👁':''))
      row.append($('<td class="redTeamBG viewTeam">').attr('data-team',r2).click(showTeamStats).text(r2?'👁':''))
      row.append($('<td class="redTeamBG viewTeam">').attr('data-team',r3).click(showTeamStats).text(r3?'👁':''))
      row.append($('<td class="blueTeamBG viewTeam">').attr('data-team',b1).click(showTeamStats).text(b1?'👁':''))
      row.append($('<td class="blueTeamBG viewTeam">').attr('data-team',b2).click(showTeamStats).text(b2?'👁':''))
      row.append($('<td class="blueTeamBG viewTeam">').attr('data-team',b3).click(showTeamStats).text(b3?'👁':''))
      row.append($('<th>'))
      tbody.append(row)
      row = $("<tr>")
      row.append($('<td class="redTeamBG">').attr('data-team',r1).click(showImg).html(`<img src=/data/${eventYear}/${r1}.jpg>`))
      row.append($('<td class="redTeamBG">').attr('data-team',r2).click(showImg).html(`<img src=/data/${eventYear}/${r2}.jpg>`))
      row.append($('<td class="redTeamBG">').attr('data-team',r3).click(showImg).html(`<img src=/data/${eventYear}/${r3}.jpg>`))
      row.append($('<td class="blueTeamBG">').attr('data-team',b1).click(showImg).html(`<img src=/data/${eventYear}/${b1}.jpg>`))
      row.append($('<td class="blueTeamBG">').attr('data-team',b2).click(showImg).html(`<img src=/data/${eventYear}/${b2}.jpg>`))
      row.append($('<td class="blueTeamBG">').attr('data-team',b3).click(showImg).html(`<img src=/data/${eventYear}/${b3}.jpg>`))
      row.append($('<th>'))
      tbody.append(row)
      for (var i=0; i<sections.length; i++){
        var section = sections[i]
        for (var j=0; j<matchPredictorSections[section].length; j++){
          var field = matchPredictorSections[section][j]
          statInfo[field] = statInfo[field]||{}
          var statName = statInfo[field]['name']||field
          var row = $("<tr>")
          row.append($('<td class=redTeamBG>').text(getTeamValue(field,r1)))
          row.append($('<td class=redTeamBG>').text(getTeamValue(field,r2)))
          row.append($('<td class=redTeamBG>').text(getTeamValue(field,r3)))
          row.append($('<td class=blueTeamBG>').text(getTeamValue(field,b1)))
          row.append($('<td class=blueTeamBG>').text(getTeamValue(field,b2)))
          row.append($('<td class=blueTeamBG>').text(getTeamValue(field,b3)))
          row.append($('<th>').text(statName))
          tbody.append(row)
        }
      }
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
    if (! stats || ! field in stats ||! 'count' in stats || !stats['count']) return ""
    return Math.round((stats[field]||0) / stats['count'])
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