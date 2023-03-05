"use strict"

// Enter your team number here
// to enable team specific features
// and highlighting
var ourTeam=0

// A list of options that will drop down from the host name
// box on export.html
var transferHosts = [
	"localhost",
	//"webscout2.example.com",
	//"localhost:1234",
	//"http://insecure-webscout.example.com",
]

// Any code here gets run on every page.

// Inject a site wide message
//$('h1').after($("<div>Hello World</div>"))

// Inject a message just on the home page
//if (location.pathname=="/") $('h1').after($(`<div>Welcome to ${ourTeam}'s scouting app!</div>`))

// Change the default page title
//$('title,h1').each(function(){
//	$(this).text($(this).text().replace(/FRC Scouting App/g,`${ourTeam}'s Scouting`))
//})

// Use a custom CSS file
//$('head').append("<link rel=stylesheet type=text/css href=/local.css>")
