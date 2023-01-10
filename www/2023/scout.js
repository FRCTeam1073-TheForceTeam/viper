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
})