class window.Veggie.MemberView extends Backbone.View
	tagName: 'div'
	className: 'member'
	template: JST['item/member']
	initialize: ->
		@listenTo(@model, 'change', @render)
	render: ->
		template = @template(@model.toJSON())
		@$el.html(template)
		this


			
