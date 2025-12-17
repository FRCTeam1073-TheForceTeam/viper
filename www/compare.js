"use strict"

addI18n({
	manage_teams:{
		en:'Manage Teams',
		tr:'Takımları Yönet',
		pt:'Gerenciar Equipes',
		he:'נהל קבוצות',
		zh_tw:'管理團隊',
		fr:'Gérer les équipes',
	},
	compare_page_title:{
		en:'Compare Teams: _TEAMS_ at _EVENT_',
		tr:'Takımları Karşılaştır: _TEAMS_ _EVENT_ adresinde',
		pt:'Comparar Equipes: _TEAMS_ em _EVENT_',
		he:'השווה קבוצות: _TEAMS_ ב-_EVENT_',
		zh_tw:'比較團隊：_TEAMS_ 參加 _EVENT_',
		fr:'Comparer les équipes : _TEAMS_ à _EVENT_',
	},
})

$(function() {
	// Resize iframes to match content height
	function resizeIframes() {
		$('iframe').each(function() {
			const iframe = $(this)
			const iframeDoc = this.contentDocument || this.contentWindow.document
			if (iframeDoc && iframeDoc.body) {
				const height = Math.max(
					iframeDoc.body.scrollHeight,
					iframeDoc.documentElement.scrollHeight
				)
				iframe.height(height + 20)
			}
		})
	}

	if (!eventYear) {
		showError('no_event_title','no_event_message')
		return
	}

	function getTeamInfo(teamNum){
		var info=eventTeamsInfo[teamNum]
		if (!info)return""
		var name=info.nameShort||""
		if (info.city)name+=`, ${info.city}`
		if (info.stateProv)name+=`, ${info.stateProv}`
		if (info.country)name+=`, ${info.country}`
		return name
	}

	function showTeamButtons() {
		$('#teamButtons').html("").addClass('lightBoxCenterContent').show()
		var teamList = Object.keys(eventStatsByTeam)
		teamList.sort((a,b) => a-b)
		var currentTeams = ((location.hash.match(/^\#(?:.*\&)?(?:teams\=)([0-9,]+)(?:\&.*)?$/)||["",""])[1] || "").split(',').filter(t => t)
		teamList.forEach(function(team){
			var button = $(`<button id=team-${team} class=team>${team}</button>`)
			var teamInfo = getTeamInfo(team)
			if (teamInfo) {
				button.attr('data-tooltip', teamInfo)
			}
			if (currentTeams.includes(team)) {
				button.addClass('picked')
			}
			button.click(function(){
				teamButtonClicked.call(this)
			})
			$('#teamButtons').append(button)
		})
	}

	function teamButtonClicked(){
		var team = $(this).text()
		var currentTeams = ((location.hash.match(/^\#(?:.*\&)?(?:teams\=)([0-9,]+)(?:\&.*)?$/)||["",""])[1] || "").split(',').filter(t => t)
		var teamIndex = currentTeams.indexOf(team)

		if (teamIndex >= 0) {
			// Team is already picked, remove it
			currentTeams.splice(teamIndex, 1)
		} else {
			// Team not picked, add it
			currentTeams.push(team)
		}

		if (currentTeams.length > 0) {
			location.hash = `#event=${eventId}&teams=${currentTeams.join(',')}`
		} else {
			location.hash = `#event=${eventId}`
		}
	}

	function showComparison() {
		const teams = ((location.hash.match(/^\#(?:.*\&)?(?:teams\=)([0-9,]+)(?:\&.*)?$/)||["",""])[1] || "").split(',').filter(t => t)
		const lightboxWasOpen = $('#teamButtons').hasClass('lightBoxCenterContent')

		// Always show management bar and set up manage teams button
		$('#managementBar').show()
		$('#manageTeamsBtn').off('click').click(function(){
			showTeamButtons()
			showLightBox($('#teamButtons'))
		})

		if (teams.length >= 1) {
			// Show comparison with iframes
			$('#compareContainer').html("").show()

			function buildTeamUrl(teamNum) {
				let url = 'team.html#'
				const parts = []
				if (eventId) parts.push('event=' + eventId)
				if (teamNum) parts.push('team=' + teamNum)
				return url + parts.join('&')
			}

			function onIframeLoad() {
				setTimeout(resizeIframes, 500)
				setTimeout(resizeIframes, 1500)
			}

			// Create iframes dynamically for each team
			teams.forEach(function(team) {
				$('#compareContainer').append(
					$('<div class="teamFrame">').append(
						$('<iframe scrolling="no">').attr('src', buildTeamUrl(team)).on('load', onIframeLoad)
					)
				)
			})

			// Update page title when iframes load
			function updateTitle() {
				if (teams.length > 0) {
					addTranslationContext({teams: teams.join(', '), event: eventName})
					applyTranslations()
				}
			}

			$('#compareContainer iframe').on('load', updateTitle)
			updateTitle()

			// Manage lightbox state
			if (lightboxWasOpen) {
				// Lightbox was open, refresh it and keep it open
				showTeamButtons()
				showLightBox($('#teamButtons'))
			} else if (teams.length < 2) {
				// Less than 2 teams and lightbox wasn't open, open it
				showTeamButtons()
				showLightBox($('#teamButtons'))
			}
		} else {
			// No teams, hide comparison and show lightbox with team buttons
			$('#compareContainer').hide()
			showTeamButtons()
			showLightBox($('#teamButtons'))
		}
	}

	Promise.all([
		promiseEventStats(),
		promiseTeamsInfo()
	]).then(values => {
		;[[window.eventStats, window.eventStatsByTeam], window.eventTeamsInfo] = values
		showComparison()
	})

	$(window).on('hashchange', showComparison)
})
