$(document).ready(function(){
    if (!eventYear || !eventVenue){
        $('h1').text("Event Not Found")
        return
    }
    var title = $('title')
    var uploadCount = getUploads().length
    title.text(eventName + " " + title.text())
    $('h1').text(eventName)
    $('a').each(function(){
        $(this).attr(
            'href',$(this).attr('href')
            .replace('YEAR', eventYear)
            .replace('EVENT', eventId)
            .replace('UPLOAD_COUNT', uploadCount)
        )
        $(this).text(
            $(this).text()
            .replace('YEAR', eventYear)
            .replace('EVENT', eventId)
            .replace('UPLOAD_COUNT', uploadCount)
        )
    })
    $('.initHid').hide()
    loadEventFiles(function(fileList){
        for (var i=0; i<fileList.length; i++){
            var extension = fileList[i].replace(/[^\.]+\./,"")
            switch (extension){
                case "schedule.csv":
                    $('.dependSchedule').show().parents().show()
                    break;
                case "scouting.csv":
                    $('.dependScouting').show().parents().show()
                    break;
                case "alliances.csv":
                    $('.dependAlliances').show().parents().show()
                    break;
            }
        }
        if (uploadCount) $('.dependUploads').show().parents().show()
    })
})