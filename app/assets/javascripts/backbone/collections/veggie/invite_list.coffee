class window.Veggie.InviteList extends Backbone.Model
	url: "/members/invite_list"
	parse: (resp)->
		if resp.status is 0
			resp.data