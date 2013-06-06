#= require_self
#= require ./routers/mobile_router

class window.Mobile
	constructor: ->
		$("body").addClass 'mobile'
		window.route = new Mobile.Router()
		Backbone.history.start()