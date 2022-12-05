$(document).ready(function(){
    if (/^\#[0-9]+(,[0-9]+)*$/.test(location.hash)){
        var teams = location.hash.replace(/^\#/,"").split(/,/)
        for (var i=0; i<teams.length; i++){
            addTeam(teams[i]);
        }
    }
    $('#add').click(function(e){
        e.preventDefault()
        addTeam($('#team').val())
        return false
    })
    if (eventId){
        loadEventSchedule(function(){
            for(var i=0; i<eventTeams.length; i++){
               addTeam(eventTeams[i]) 
            }
        })
    }
})

function addTeam(team){
    if (!/^[0-9]+$/.test(team)) return
    var year = ($('#yearInp').val())
    $('#teams')
        .append(`<h2>Team ${team}</h2>`)
        .append(`<img src=/data/${year}/${team}.jpg>`)
        .append(`<input type=file name=${team} accept="image/*">`)
        .append(`<hr>`)
}
