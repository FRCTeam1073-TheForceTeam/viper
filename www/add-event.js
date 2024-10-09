"use strict"

function setComp(){
	var comp = $('#comp').val(),
	season = new Date().getFullYear();
	if (comp == 'ftc'){
		if (new Date().getMonth <= 8) season--
		season += "-" + (season+1+"").slice(-2)
	}
	location.hash=comp
	$('a').each(function(){
		$(this).attr('href',$(this).attr('href').replace(/COMP|ftc|frc/g, comp))
		$(this).attr('href',$(this).attr('href').replace(/SEASON|20[0-9]{2}(-[0-9]{2})?/g, season))
		$(this).text($(this).text().replace(/COMP|ftc|frc/gi, comp.toUpperCase()))
	})
}

$(document).ready(function(){
	var hash = location.hash.replace(/^#/,"")
	$(`#comp option[value="${hash}"]`).attr('selected', 'selected')
	$('#comp').change(setComp)
	setComp()
})
