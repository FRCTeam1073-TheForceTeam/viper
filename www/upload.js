$(document).ready(showUploads)

var csv = {}

function showUploads(){
    var up = $('#uploads').html("")
    var count = 0
    for (i in localStorage){
        if (/^20[0-9]{2}.*_.*_/.test(i)){
            var year = i.replace(/^(20[0-9]{2}).*/,"$1"),
            header = localStorage.getItem(`${year}_headers`)
            if (!csv[year]){
                csv[year] = header
            }
            csv[year] += localStorage.getItem(i)
            up.append($('<hr>'))
            up.append($('<h4>').text(i))
            up.append($('<pre>').text(header + localStorage.getItem(i)))
            up.append($('<button>Delete</button>').attr("data-match",i).click(deleteMatch))
            count++
        }
    }
    if (!count){
        up.text('There is no data to upload.')
        $('button').hide()
    }
    var years = Object.keys(csv);
    var text = ""
    for (var i=0; i<years.length; i++){
        text += csv[years[i]]
    }
    $('#csv').val(text)
}

function deleteMatch(){
    var match = $(this).attr("data-match")
    if (confirm(`Are you sure you want to delete ${match}?`)){
        localStorage.removeItem(match)
        showUploads()
    }
}
