$(document).ready(function(){
    var events = []
    $.ajax({
        url:"/event-list.cgi",
        dataType:"text",
        success:function(data){
            events = data.split(/[\r\n]/)
            var years = {}
            for (var i=0; i<events.length; i++){
                var m = events[i].match(/^[0-9]{4}/)
                if(m) years[m[0]] = 1
            }
            years = Object.keys(years)
            years.sort((a,b) => {return a-b})
            for (var i=0; i<years.length; i++){
                var year = years[i]
                $('#years').append($(`<option value=${year}>${year}</option>`))
            }
            if (!years.length) $('#years').hide()
            showEvents()
        }
    })
    function showEvents(){
        var list = $('#events-list')
        list.html('');
        var filter = location.hash.replace(/^\#/,"")
        if (!filter) filter = $('#years option:last').attr('value')
        for (var i=0; i<events.length; i++){
            if (events[i] && events[i].startsWith(filter)){
                var event = events[i]
                var year = event.substring(0,4)
                var venue = event.substring(4)
                list.append($(`<li><a href=/event.html#${event}>${year} ${venue}</a></li>`))
            }
        }
    }
    $(window).on('hashchange', showEvents)
    $('#years').change(function(){
        year = $('#years').val()
        if (/^[0-9]{4}$/.test(year)){
            location.hash = `#${year}`
        }
        $('#years').val('-')
    })
})
