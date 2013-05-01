class window.Member extends Backbone.Model
	defaults:
		"_id": ''
		"name": ''
		"avatar": ''
		"gem": ''
	url: "/members/profile"
	parse: (resp)->
		if resp.status is 0
			resp.data