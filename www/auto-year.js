"use strict"

$(document).ready(function(){
	$('input[name="event_year"],input#event_year,input[name="year"],input#year').val(new Date().getFullYear())
	$('input[type="date"]').val(new Date().toISOString().substring(0,10))
	$('a').each(function(){
		var href=$(this).attr('href')
		if (href&&/YEAR/.test(href))$(this).attr('href',href.replace(/YEAR/g,new Date().getFullYear()))
	})
})
