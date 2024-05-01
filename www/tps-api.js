'use strict'

function tpsRedirectToLogin(site, redirect, scopes){
	if (!site) site = location.hostname
	var hash = location.hash?location.hash+'&':'#'
	if (!redirect) redirect = location.origin + location.pathname + hash + "tps_auth=<DATA>"
	if (!scopes) scopes = [
		'tpw.teamNumber',
		'tpw.scouting.username',
		'tpw.scouting.impersonate',
		'tps.entry.add',
		'tps.entry.get',
		'tps.entry.edit',
		'tps.entry.delete'
	]
	location.href="https://thepurplewarehouse.com/scouting/auth/generate/"+btoa(JSON.stringify({
		site: site,
		redirect: redirect,
		scopes: scopes
	}))
	return false
}

function tpsGetAuth(){
	var auth=(location.hash.match(/^\#(?:.*\&)?tps_auth\=([A-Za-z0-9\+\/\=]+)(?:\&.*)?$/)||["",""])[1]
	if (auth) {
		localStorage.setItem("tps_auth", atob(auth))
		history.replaceState(null, "", location.href.replace(/[\#\&]tps_auth=.*/,""))
	}
	var auth = localStorage.getItem("tps_auth")
	if (!auth) return false
	return JSON.parse(auth).body.details
}

function tpsRemoveAuth(){
	localStorage.removeItem("tps_auth")
}

function tpsApi(path, requestBodyJson){
	var auth = tpsGetAuth()
	if (!auth) return Promise.reject(new Error('Missing auth'))
	var url = `https://api.thepurplestandard.com/v1${path}?key=${auth.key}`
	var options = !requestBodyJson?{}:{
		method: "POST",
		headers: {"Content-Type": "application/json"},
		body: JSON.stringify(requestBodyJson)
	}
	return fetch(
		url,
		options
	).then(response => {
		if (!response.ok) throw new Error(`${response.status} ${response.statusText} for ${url}`)
		return response.json()
	}).then(data => {
		if (!data.success){
			tpsRemoveAuth()
			throw new Error('TPS authentication expired, TPS key cleared')
		}
		return data.body
	})
}

function tpsEntryAdd(entry, privacy, threshold){
	var requestBody = {entry:entry}
	if (privacy) requestBody.privacy = privacy
	if (threshold) requestBody.threshold = threshold
	return tpsApi('/entry/add', requestBody).then(body=>body.hash)
}

function tpsEntryVerify(hash){
	return tpsApi(`/entry/verify/${hash}`).then(body=>body.verified)
}

function tpsEntryGet(hash){
	return tpsApi(`/entry/get/${hash}`).then(body=>body.entry)
}

function tpsLatest(eventId){
	return tpsApi(`/entry/latest/${eventId}`).then(body=>body.latest)
}

function tpsListEvent(eventId){
	return tpsApi(`/entry/list/event/${eventId}`).then(body=>body.entries)
}
