class window.Olive.CourseView extends Backbone.View
	tagName: 'li'
	className: "form alert-success"
	template: JST['item/o_course']
	events:
		"click .check": 'check'
		"click .open": 'open'
		"click .back": "back"
	initialize: ->
		@listenTo(@model, 'change', @render)
		@listenTo(@model, 'destroy', @remove)
	back: ->
		@$el.siblings().show()
		@model.set check: false
	check: ->
		@$el.siblings().hide()
		@model.set 
			check: true
	open: (e) ->
		@model.open =>
			@$el.siblings().show()
	render: ->
		@$el.html @template(@model.toJSON())
		this