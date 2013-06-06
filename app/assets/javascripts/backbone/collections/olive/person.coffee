class window.Olive.Person extends Backbone.Model
	url: "/olive/persons"
	parse: (resp)->
		if resp.status is 0
			resp.data

	