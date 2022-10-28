$(document).ready(function(){
    if (!eventYear || !eventVenue){
        $('h1').text("Event Not Found")
        return
    }
    var title = $('title')
    title.text(eventName + " " + title.text())
    $('h1').text(eventName)
    $('a').each(function(){
        $(this).attr('href',$(this).attr('href').replace('YEAR', eventYear).replace('EVENT', eventId))
    })
    $('#links li').hide()
    loadEventFiles(function(fileList){
        for (var i=0; i<fileList.length; i++){
            var extension = fileList[i].replace(/[^\.]+\./,"")
            switch (extension){
                case "schedule.csv":
                    $('.dependSchedule').show()
                    break;
                case "txt":
                    $('.dependScouting').show()
                    break;
                case "alliances.csv":
                    $('.dependAlliances').show()
                    break;
            }
        }
        for (var i=0; i<fileList.length; i++){
            var extension = fileList[i].replace(/[^\.]+\./,"")
            switch (extension){
                case "alliances.csv":
                    $('.notAlliances').hide()
                    break;
            }
        }
        $('#links').show()
    })
})