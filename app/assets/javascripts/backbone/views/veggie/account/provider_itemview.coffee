class window.Veggie.ProviderView extends Backbone.View
	tagName: 'div'
	className: 'step provider'
	id: ->
		@model.get('provider')
	attributes: ->
		"data-x": @model.get('num')*1500
		"data-y": 0
		"data-z": 0	
		"data-scale": "1"
	template: JST['item/provider']
	events: ->
		"enterStep": "enterStep"
	initialize: ->
		@listenTo(@model, 'change', @render)
	render: ->
		@$el.html @template(@model.toJSON())	
		this
	enterStep: ->
		@model.fetch =>
			$(".container",@$el).fadeIn()
		this