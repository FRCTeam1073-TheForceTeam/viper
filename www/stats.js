$(document).ready(function(){
    loadEventStats(buildTable)
    $('h1').text(eventName + " " + $('h1').text())
    $('#lightBoxBG').click(function(){
        $('#lightBoxBG').hide()
        $('#lightBoxContent').hide()
    })
})

var teamList = []
var sortStat = 'score'
var teamsPicked = {}

function buildTable(){
    teamList = Object.keys(eventStatsByTeam)
    for (var i=0; i<teamList.length; i++){
        var team = teamList[i]
        teamsPicked[team] = teamsPicked[team]||false
    }
    teamList.sort((a,b)=>{
        if (teamsPicked[a] != teamsPicked[b]) return teamsPicked[b]?-1:1
        return getTeamValue(sortStat,b)-getTeamValue(sortStat,a)
    })
    var table = $('#statsTable').html('')
    var tableWidth = teamList.length + 1
    var sections = Object.keys(statSections)
    for (var i=0; i<sections.length; i++){
        var section = sections[i]
        table.append($(`<tr><th colspan=${tableWidth}><h4>${section}</h4></th></tr>`))
        var hr = $('<tr>')
        hr.append($('<th>'))
        for (var j=0; j<teamList.length; j++){
            var team = teamList[j],
            picked = teamsPicked[team]
            hr.append($('<th>').text(team).click(setTeamPicked).toggleClass('picked',picked))
        }
        table.append(hr)
        for (var j=0; j<statSections[section].length; j++){
            var field = statSections[section][j],
            highGood = (statInfo[field]['good']||"high")=='high',
            statName = (statInfo[field]['type']=='avg'?"Average ":"") + statInfo[field]['name'],
            doSort = $('<span class=dosort>').text("▶").toggleClass('active',field==sortStat),
            tr = $('<tr class=statRow>').append($('<th>').text(statName + " ").append(doSort).attr('data-stat',field).click(reSortTable)),
            best = (highGood?-1:1)*99999999   
            for (var k=0; k<teamList.length; k++){
                var team = teamList[k],
                picked = teamsPicked[team],
                value = getTeamValue(field, team)
                if (!picked && ((highGood && value > best) || (!highGood && value < best))) best = value
            }
            for (var k=0; k<teamList.length; k++){
                var team = teamList[k]
                picked = teamsPicked[team],
                value = getTeamValue(field, team)
                tr.append($('<td>').toggleClass('picked',picked).toggleClass('best',!picked && value==best).attr('data-team',team).click(showTeamStats).text(statInfo[field]['type']=='%'?Math.round(value*100)+"%":Math.round(value)))
            }
            table.append(tr)
        }
        var chart = $('<canvas>'),
        bgColors=['#9767EB','#5C73F2','#5EB2DB','#62F5D7','#6CEB8C'],
        data=[]
        table.append($('<tr>').append($(`<td colspan=${tableWidth}>`).append($('<div class=chart>').append(chart))))
        for (var j=0; j<statSections[section].length; j++){
            var field = statSections[section][j]
            if (statInfo[field]['type'] == 'avg'){
                var values = []
                for (var k=0; k<teamList.length; k++){
                    values.push(getTeamValue(field, teamList[k]))
                }
                data.push({
                    label: statInfo[field]['name'],
                    data: values,
                    backgroundColor: bgArr(bgColors[j])
                })
            }
        }
        new Chart(chart,{
            type: 'bar',
            data: {
                labels: teamList,
                datasets: data
            },
            options: {
                scales: {
                    y: {beginAtZero: true,stacked: true},
                    x: {stacked: true}
                }
            }
        })
    }
}

function showTeamStats(){
    var ignore={'event':1,'team':1}
    var team = parseInt($(this).attr('data-team')),
    fields = Object.keys(eventStats[0]),
    table = $('<table border=1>')
    $('#lightBoxContent').html('').append($('<h2>').text("Team " + team)).append(table)
    for (var i=0; i<fields.length; i++){
        var tr = $('<tr>'),
        field = fields[i]
        if (!ignore[field]){
            table.append(tr)
            tr.append($('<th>').text(statInfo[field]?statInfo[field]['name']:field))
            for (var j=0; j<eventStats.length; j++){
                if (eventStats[j]['team'] == team){
                    tr.append($('<td>').text(eventStats[j][field]))
                }
            }
        }
    }
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
        arr.push(i<teamList.length-picked?color:"darkgray")
    }
    return arr
}
function setTeamPicked(){
    var team = parseInt($(this).text())
    teamsPicked[team] = !teamsPicked[team]
    buildTable()
}

function reSortTable(){
    sortStat = $(this).attr('data-stat')
    buildTable()
}

function getTeamValue(field, team){
    if (! team in eventStatsByTeam) return 0
    var stats = eventStatsByTeam[team]
    if (! field in stats ||! 'count' in stats || !stats['count']) return 0
    var divisor = (statInfo[field]['type']=='count')?1:stats['count']
    return (stats[field]||0) / divisor
}