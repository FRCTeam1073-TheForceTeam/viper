$(document).ready(function(){
    loadEventStats(function(){
        var markPicked = $('#markPicked'),
        viewTeam = $('#viewTeam'),
        sortBy = $('#sortBy'),
        allStats = Object.keys(statInfo)
        markPicked.change(setTeamPicked).children().not(':first').remove()
        viewTeam.change(function(){
            team = $(this).val()
            $(this).val("")
            setHash()
            showTeamStats()
        }).children().not(':first').remove()
        sortBy.html('').change(reSort)
        teamList = Object.keys(eventStatsByTeam)
        for (var i=0; i<teamList.length; i++){
            var t = teamList[i]
            markPicked.append($('<option>').attr('value',t).text(t))
            viewTeam.append($('<option>').attr('value',t).text(t))
        }
        allStats.sort((a,b)=>{return getStatInfoName(a).localeCompare(getStatInfoName(b))})
        for (var i=0; i<allStats.length; i++){
            var field = allStats[i],
            info = statInfo[field]||{},
            name = getStatInfoName(field)
            if(info['type']!='text') sortBy.append($('<option>').attr('value',field).text(name))
        }
        $('#sortBy').val(sortStat)
        showStats()
    })
    $('h1').text($('h1').text().replace("EVENT", eventName))
    $('title').text($('title').text().replace("EVENT", eventName))
    $('#lightBoxContent iframe').attr('src',`/team.html#event=${eventId}`)
    $('#lightBoxBG').click(function(){
        $('#lightBoxBG').hide()
        $('#lightBoxContent').hide()
        team=""
        $('#lightBoxContent iframe').attr('src',`/team.html#event=${eventId}`)
        setHash()
    })
})

function getStatInfoName(field){
    var info = statInfo[field]||{}
    return info['name']||field
}

var team = ""
var teamList = []
var sortStat = 'score'
var teamsPicked = {}
parseHash()

function parseHash(){
    team = (location.hash.match(/^\#(?:.*\&)?(?:team\=)([0-9]+)(?:\&.*)?$/)||["",""])[1]
    sortStat = (location.hash.match(/^\#(?:.*\&)?(?:sort\=)([a-zA-Z_\-0-9]+)(?:\&.*)?$/)||["","score"])[1]
    teamsPicked={}
    ;(location.hash.match(/^\#(?:.*\&)?(?:picked\=)(([0-9]+,)*[0-9]+)(?:\&.*)?$/)||["",""])[1].split(/,/).forEach((t)=>{if(t)teamsPicked[parseInt(t)]=1})
}

function setHash(){
    hash=`#event=${eventId}`
    if(team)hash+=`&team=${team}`
    if(sortStat!='score')hash+=`&sort=${sortStat}`
    var l = Object.keys(teamsPicked).filter(t=>teamsPicked[t])
    l.sort((a,b)=>{parseInt(a)<parseInt(b)})
    if (l.length)hash+='&picked='+l.join(',')
    location.hash = hash
}

$(window).on('hashchange', function(){
    parseHash()
    showStats()
})

function showStats(){
    for (var i=0; i<teamList.length; i++){
        var t = teamList[i]
        teamsPicked[t] = teamsPicked[t]||false
    }
    teamList.sort((a,b)=>{
        if (teamsPicked[a] != teamsPicked[b]) return teamsPicked[b]?-1:1
        return getTeamValue(sortStat,b)-getTeamValue(sortStat,a)
    })
    var graphs = $('#statGraphs').html('')
    var sections = Object.keys(aggregateGraphs)
    
    for (var i=0; i<sections.length; i++){
        var section = sections[i],
        chart = $('<canvas>'),
        data=[],
        percent=false
        graphs.append($('<h2>').text(section))
        graphs.append($('<div class=chart>').append(chart))
        for (var j=0; j<aggregateGraphs[section]['data'].length; j++){
            var field = aggregateGraphs[section]['data'][j],
            info = statInfo[field]||{}
            var values = []
            for (var k=0; k<teamList.length; k++){
                values.push(getTeamValue(field, teamList[k]))
            }
            data.push({
                label: (info['type']=='avg'?'Average ':'') + (info['name']||field) + (info['type']=='%'?' %':''),
                data: values,
                backgroundColor: bgArr(graphColors[j])
            })
            if (info['type']=='%') percent=true
        }
        var stacked = aggregateGraphs[section]['graph']=="stacked"
        var yScale = {beginAtZero:true,stacked:stacked,bounds:percent?'data':'ticks'}
        if (percent)yScale['suggestedMax'] = 100
        new Chart(chart,{
            type: 'bar',
            data: {
                labels: teamList,
                datasets: data
            },
            options: {
                scales: {
                    y: yScale,
                    x: {stacked: stacked}
                }
            }
        })
    }
    if(team) showTeamStats()
}

function showTeamStats(){
    var ignore={'event':1,'team':1},
    t = $(this).attr('data-team')
    if (t) team = parseInt(t)
    if (!team) return
    $('#lightBoxContent iframe').attr('src',`/team.html#event=${eventId}&team=${team}`)
    window.scrollTo(0,0)
    $('#lightBoxBG').show()
    $('#lightBoxContent').show()
}

function bgArr(color){
    var arr = [],
    picked = 0
    for (var i=0; i<teamList.length; i++){
        if (teamsPicked[teamList[i]]) picked++
    }
    for (var i=0; i<teamList.length; i++){
        arr.push(i<teamList.length-picked?color:darkenColor(color))
    }
    return arr
}
function setTeamPicked(){
    var markPicked = $('#markPicked'),
    t = parseInt(markPicked.val())
    markPicked.val("")
    if (!t) return
    teamsPicked[t] = !teamsPicked[t]
    setHash()
    showStats()
}

function reSort(){
    sortStat=$('#sortBy').val()
    setHash()
    showStats()
}

function darkenColor(color){
    var m = color.match(/^\#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})$/)
    if(m){
        return "#" + 
        (Math.round(parseInt(m[1],16)/2)).toString(16).padStart(2,'0') +
        (Math.round(parseInt(m[2],16)/2)).toString(16).padStart(2,'0') +
        (Math.round(parseInt(m[3],16)/2)).toString(16).padStart(2,'0')
    }
    return "darkGray"

}

function getTeamValue(field, team){
    if (! team in eventStatsByTeam) return 0
    var stats = eventStatsByTeam[team],
    info = statInfo[field]||{}
    if (! field in stats ||! 'count' in stats || !stats['count']) return 0
    var divisor = /count|minmax/.test(info['type'])?1:stats['count']
    return (stats[field]||0) / divisor * (info['type']=='%'?100:1)
}
