$(document).ready(function(){
    $('#teleop').hide()
    $('#to-teleop').click(function(){
        $('#auto').hide()
        $('#teleop').show()
        return false
    })
    $('#to-auto').click(function(){
        $('#teleop').hide()
        $('#auto').show()
        return false
    })

    var cycles = []
    var cycle
    cycleInterrupt()

    $('.placement').click(function(){
        cycleStage("placement")
    })

    $('.collectLoadingZone').click(function(){
        cycleStage("collect")
    })

    function cycleStage(place){
        if (cycle.stage==0 || cycle.lastPlace==place){
            cycle.stage = 1
            cycle.startTime = Date.now()
        } else if (cycle.stage==1){
            cycle.stage = 2
        } else {
            var cycleTime = Math.round((Date.now() - cycle.startTime)/1000)
            if (cycleTime >= 7){ // Faster than seven seconds is not possible, scouter error.
                cycles.push(cycleTime)
                $('input[name="full_cycle_fastest_seconds"]').val(Math.min(...cycles))               
                $('input[name="full_cycle_average_seconds"]').val(Math.round(cycles.reduce((a,b) => a + b, 0) / cycles.length))
                $('input[name="full_cycle_count"]').val(cycles.length)
            }
            cycle.stage = 1
            cycle.startTime = Date.now()
        }
        cycle.lastPlace = place
    }

    function cycleInterrupt(){
        cycle = {
            startTime: 0,
            lastPlace: "",
            stage: 0
        }
    }

    $('.count,button,label').click(function(){
        if (!$(this).is('.placement,.collectLoadingZone')) cycleInterrupt()
    })
})