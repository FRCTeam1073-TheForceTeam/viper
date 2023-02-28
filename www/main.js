"use strict"

$.getScript("/local.js")

window.addEventListener("load", () => {
	if ("serviceWorker" in navigator){
		navigator.serviceWorker.register("/offline-service-worker.cgi").then(function(reg) {
			//console.log('Registration succeeded. Scope is ' + reg.scope)
		})
	}
})

var recentEventName = ""
var recentEventId = ""
var recentEventYear = ""

function getDate(s){
	if (!s) return ""
	var m = /[0-9]{4}-[0-9]{2}-[0-9]{2}/.exec(s)
	if (m) return m[0]
	return ""
}

function dateCompare(a,b){
	return getDate(b).localeCompare(getDate(a))
}

$(document).ready(function(){
	if (!inIframe()){
		var hamburger = $('<div id=hamburger>☰</div>'),
		mainMenu = $('<div id=mainMenu class=lightBoxCenterContent>')
		$('body').append(hamburger).append(mainMenu)
		hamburger.click(function(){showLightBox(mainMenu)})

		if (!window.eventId){
			$.get("/event-list.cgi",function(data){
				var events = data.split(/[\r\n]/)
				if (events.length){
					events = events.sort(dateCompare)
					var recent = events[0].split(",")
					if (recent.length>=4){
						recentEventId = recent[0]
						recentEventYear = recentEventId.replace(/([0-9]{4}).*/,'$1')
						var venue = recentEventId.replace(/[0-9]{4}(.*)/,'$1')
						recentEventName = `${recentEventYear} ` + (recent[1]||venue)
					}
				}
			}).always(populateMainMenu)
		} else {
			populateMainMenu()
		}

		function populateMainMenu(){
			$.get("/main-menu.html",function(data){
				mainMenu.html(
					data
						.replace(/EVENT_NAME/g, (window.eventName)||recentEventName)
						.replace(/EVENT_ID/g, (window.eventId)||recentEventId)
						.replace(/YEAR/g, (window.eventYear)||recentEventYear)
				)
				mainMenu.find('.dependEvent').toggle(!!(window.eventName||recentEventName))
				showMainMenuUploads()
			})
		}
		$('body').append($('<div id=fullscreen>⛶</div>').click(toggleFullScreen))
		function showMainMenuUploads(){
			hamburger.toggleClass("hasUploads", hasUploads())
			mainMenu.find('.dependUpload').toggle(hasUploads())
		}
		$(window).on('hashchange',showMainMenuUploads)
		$('body').append($('<div id=lightBoxBG>').click(closeLightBox))
	}
})
function closeLightBox(){
	$('#lightBoxBG,.lightBoxCenterContent,.lightBoxFullContent').hide()
}
function showLightBox(content){
	$('#lightBoxBG').show()
	content.show()
}

function toggleFullScreen() {
	if (!document.fullscreenElement) document.documentElement.requestFullscreen()
	else if (document.exitFullscreen) document.exitFullscreen()
	closeLightBox()
	return false
}

function hasUploads(){
	for (var i in localStorage){
		if (/^20[0-9]{2}[A-Za-z0-9\-]+_(([0-9]+)|(.*_.*))$/.test(i)) return true
	}
	return false
}

function inIframe(){
	try {
		return window.self !== window.top;
	} catch (e) {
		return true;
	}
}
