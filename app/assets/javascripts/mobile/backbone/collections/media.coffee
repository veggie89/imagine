class window.Mobile.Media extends Backbone.Model
	url: "/mobile/fetch"
	parse: (resp)->
		if resp.status is 0
			resp.data