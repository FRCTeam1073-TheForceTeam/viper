"use strict"

// Enter your team number here
// to enable team specific features
// and highlighting
// To get it from the subdomain, for multiple site hosting, use:
// var ourTeam=parseInt((location.hostname.match(/[0-9]+/g)||["0"])[0]); // team number from sub-domain
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
