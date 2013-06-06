class window.Mobile.MediaView extends Backbone.View
	id: "images"
	template: JST['mobile/templates/media_view']
	collection: new Mobile.Media()
	events:
		"click .reload": "reload"
	initialize: ->
		@collection.fetch
			success: (data) =>
				$("article").append(@render().el)
	reload: ->
		@collection.fetch
			url: "/mobile/fetch?reload=1"
			success: (data) =>
				@render()
	render: ->
		template = @template(@collection.toJSON())
		@$el.html(template)
		this