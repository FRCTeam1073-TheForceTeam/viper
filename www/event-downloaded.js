$(document).ready(function(){
	$('h1').each(function(){
		$(this).text($(this).text().replace(/EVENT/,eventName))
	})
	$('a').each(function(){
		$(this).attr('href',$(this).attr('href').replace(/EVENT/,eventId))
	})
})
