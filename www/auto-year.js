"use strict"

$(document).ready(function(){
	$('input[name="event_year"],input#event_year,input[name="year"],input#year').val(new Date().getFullYear())
	$('input[type="date"]').val(new Date().toISOString().substring(0,10))
})
