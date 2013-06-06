class window.Song extends Backbone.Model
	defaults:
		"_id": ""
		"title": 'love of my life'
		"url": 'http://17up.org/audios/friends.m4a'
		"artist": "Queen"
	url: "/songs/create"
	liked: (success) ->
		self = this
		$.post "/members/like",obj: "Song",_id: self.get("_id"),(data) =>
			if data.status is 0
				self.set
					liked: true
				success(data.data) if success
