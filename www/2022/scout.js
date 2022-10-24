var pos; // = "B3"
var team; // = "44"
var match; // = "qm1"
var matchName = ""
$(document).ready(function(){
    if (!eventYear || !eventVenue){
        $('h1').text("Event Not Found")
        return
    }

    function getScoutKey(){
        return `${eventId}_${match}_${team}`
    }

    function showPosList(){
        $('.screen').hide()
        window.scrollTo(0,0)
        $('h1').text(eventName)
        $('#select-bot button').click(function(){
            pos = $(this).text()
            showMatchList()
        })
        $('#select-bot').show()
    }

    function showMatchList(){
        $('.screen').hide()
        window.scrollTo(0,0)
        $('h1').text(`${eventName} ${pos}`)
        for (var i=0; i<eventData.length; i++){
            var qualTeam = eventData[i][pos]
            var qual = i+1
            $('#match-list').append(
                $('<li>').text("Qualifier " + qual + " ")
                .append($(`<button data-team=${qualTeam} data-qualifier=${qual}>`).text(pos + " : " + qualTeam).click(function(){
                    team = $(this).attr('data-team')
                    match = "qm" + $(this).attr('data-qualifier')
                    showScouting()
                }))
            )
        }
        $('#select-match').show()
    }

    function getMatchName(){
        return match.replace(/^qm/, "Qualifier ")
    }

    var scouting = $('#scouting')
    function showScouting(){
        $('.screen').hide()
        window.scrollTo(0,0)
        scouting[0].reset()
        matchName = getMatchName()
        $('h1').text(`${eventName}, ${matchName}, Team ${team}`)
        $('.team').text(team)
        $('input[name="event"]').val(eventId)
        $('input[name="match"]').val(match)
        $('input[name="team"]').val(team)
        $('.match').text(matchName)
        $('.teamColorBG').toggleClass('redTeamBG', pos.startsWith('R')).toggleClass('blueTeamBG', pos.startsWith('B'))
        scouting.show()
    }

    var title = $('title')
    title.text(eventName + " " + title.text())
    loadEventData()
    showPosList()
    //showScouting()

    function toggleChecked(o){
        o.each(function(){
            $(this).prop('checked', !$(this).prop('checked'))
        })
    }

	$("label").click(function(e){
		e.preventDefault()
		check=$(this).find(':checkbox,:radio')
		if (check.attr('disabled') && !check.prop('checked')) return
		toggleChecked(check)
	})

	$("img.count").click(function(e){
		var toAdd = /up/.test($(this).attr('src'))?1:-1
        var input = $(this).closest('td').find('input')
        var val = input.val()
        val = /^[0-9]+$/.test(val)?parseInt(val):0
        val = val+toAdd
        val = val<0?0:val
        input.val(val)
	})

    function safeCSV(s){
        return s.replace(/[\r\n\t,]+ */g, " ")
    }

    function toCSV(){
        keys = []
        values = {}
        $('#scouting input,#scouting textarea').each(function(){
            var el=$(this),name=el.attr('name'),val=el.val(),type=el.attr('type')
            off=(type=='checkbox'||type=='radio')&&!el.prop('checked')
            if (!values.hasOwnProperty(name)){
                keys.push(name)
                values[name] = "0"
            }
            if (!off) values[name] = val
        })
        return [
            keys.map(safeCSV).join(",") + "\n",
            keys.map(function(v){return values[v]}).map(safeCSV).join(",") + "\n"
        ] 
    }

    function formHasChanges(f){
        var changes = false
        f.find('input,textarea').each(function(){
            var el=$(this),name=el.attr('name'),val=el.val(),type=el.attr('type'),init=el.attr('value')||''
            if (type=='hidden') return
            if (type=='checkbox'||type=='radio'){
                val=el.prop('checked')
                init=el.attr('checked')!==undefined
            }
            if (val!==init)changes=true            
        })
        return changes
    }

    function store(){
        if (formHasChanges(scouting)){
            localStorage.setItem(getScoutKey(), toCSV()[1])
        }
    }

	$("#nextBtn").click(function(e){
        store()
        var i = parseInt(match.replace(/[^0-9]/g,""))
        if (i >= eventData.length){
            alert("Data saved and done. That was the last match!")
        } else {
            team = eventData[i][pos]
            match = "qm" + (i+1)
            showScouting()
        }
        return false;
	})
    $("#matchBtn").click(function(e){
        store()
        showMatchList()
        return false;
	})
    $("#robotBtn").click(function(e){
        store()
        showPosList()
        return false;
	})
    $("#uploadBtn").click(function(e){
        store()
        var csv = ""
        var year = eventId.substring(0,4)
        for (i in localStorage){
            if (new RegExp(`${year}.*_.*_`).test(i)) {
                csv += localStorage.getItem(i)
            }
        }
        if (!csv){
            alert ("No data to upload")
        } else {
            csv = toCSV()[0] + csv
            $('#csv').val(csv)
            $('#upload').submit()
        }
        return false;
	})
    $("#backMatchBtn").click(function(e){
        if (!formHasChanges(scouting) || confirm("Discard data and go back?")) showMatchList()
        return false;
	})
    $("#backRobotBtn").click(function(e){        
        if (!formHasChanges(scouting) || confirm("Discard data and go back?")) showPosList()
        return false;
	})
})
