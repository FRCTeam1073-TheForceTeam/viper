"use strict"

// Enter your team number here
// to enable team specific features
// and highlighting
var ourTeam=0

// Whether or not to collect comments during scouting
var showScoutingComments=false

// Whether or not to allow scouters to request data review
var showReviewRequest=true

// A list of options that will drop down from the host name
// box on export.html
var transferHosts = [
	"localhost",
	//"webscout2.example.com",
	//"localhost:1234",
	//"http://insecure-webscout.example.com",
]

// stats.viperscout.com tracks your server's host name, your team number,
// events, count of things scouted, and count of scouters. It does NOT
// collect your scouting data, scouters' names, or other personally
// identifiable information. To opt out of this analytics collection
// from your server, set the following variable to true.
var analyticsOptOut=false

// Any code here gets run on every page.

// Inject a site wide message
//$(document).ready(function(){
//  $('h1').after($("<div>Hello World</div>"))
//})

// Inject a message just on the home page
//$(document).ready(function(){
//  if (location.pathname=="/") $('h1').after($(`<div>Welcome to ${ourTeam}'s scouting app!</div>`))
//})

// Change the default page title
//$(document).ready(function(){
//  $('title,h1').each(function(){
//	  $(this).text($(this).text().replace(/Viper/g,`${ourTeam}'s Scouting`))
//  })
//})
