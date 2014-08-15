-- for older versions of luvit and alternative package managers
return {
	name = "luvit-oauth",
	version = "0.1.5",
	description = "OAuth wrapper for luvit.io",
	repository = {
		url = "https://github.com/luvitrocks/luvit-oauth.git",
	},
	author = {
		name = "Dmitri Voronianski",
		email = "dmitri.voronianski@gmail.com"
	},
	licenses = {"MIT"},
	dependencies = {
		"luvit-querystring"
	},
	main = 'init.lua'
}
