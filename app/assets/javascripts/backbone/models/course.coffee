class window.Course extends Backbone.Model
	defaults:
		"_id": ''
		"title": ''
		"content": ''
		"tags": ''
		"status": 0
		"open": false
	url: "/courses/update"
	ready: (content,callback) ->
		params = 
			_id: @.get("_id")
			raw_content: content
		$.post "/courses/ready",params,(data) =>
			if data.status is 0	
				@.set 
					status: 2
					editable: false
					raw_content: content
				callback() if callback
	open: (callback) ->
		$.post "/courses/open",_id:@.get("_id"),(data) =>
			if data.status is 0	
				@.set 
					status: 1
					check: false
				callback() if callback
	destroy: ->
		super()
		$.post '/courses/destroy',_id:@.get("_id")
	checkin: (callback)->
		$.post "/courses/checkin",_id:@.get("_id"),(data) =>
			if data.status is 0	
				@.set 
					has_checkin: true
				$("nav .gem").text(data.data)
				callback()
			else if data.status is -2
				Utils.flash("你的绿叶不足，还不能学这节课程","error")


	