class window.Veggie.BannerView extends Backbone.View
	id: "nav"	
	template: JST['banner_view']
	model: new Member()
	events: ->
		"click .avatar": "upload_avatar"
	initialize: ->
		@model.fetch
			success: =>
				$("nav").html(@render().el)
		window.current_member = @model
	render: ->	
		template = @template(@model.toJSON())
		@$el.html(template)
		this
	upload_avatar: (e) ->
		Utils.uploader($(e.currentTarget))
		