#= require_self
#= require_tree ../collections
#= require_tree ../views

class Mobile.Router extends Backbone.Router  
	initialize: ->
		this
	routes:
		'':'images'
	images: ->
		view = new Mobile.MediaView()