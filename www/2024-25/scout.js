"use strict"

$(document).ready(function(){
	$('.auto .count').click(function(){
		setTimeout(function(){
			$('#to-tele-button').addClass('pulse-bg')
		},30000)
	})
})
