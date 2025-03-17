"use strict"

addI18n({
	event_downloaded_title:{
		en:'_EVENT_ API Data',
	},
	event_download_instruction:{
		en:'How would you like to use the data?',
	},
	update_schedule_link:{
		en:'Update schedule',
	},
	compare_scouting_link:{
		en:'Compare scouting data',
	},
	scouter_rankings_link:{
		en:'See scouter rankings',
	},
	view_event_link:{
		en:'View the event page',
	},
})

$(document).ready(function(){
	$('h1,title').attr('data-event',eventName)
	$('a').each(function(){
		$(this).attr('href',$(this).attr('href').replace(/EVENT/,eventId))
	})
	applyTranslations()
})
