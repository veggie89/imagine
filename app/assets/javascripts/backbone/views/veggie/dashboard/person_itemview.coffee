class window.Veggie.PersonView extends Backbone.View
	id: "person"
	className: "left"
	template: JST['item/person']
	events:
		"click .enter": "enter"
		"click .back": "back"
		"click .pause": "pause"
	render: ->
		@$el.html @template(@model.toJSON())
		this
	enter: (e) ->
		@$el.addClass "enter_in"
		if @open
			console.log "resume"
		else
			@open = true
			$("body").css "overflow":"hidden"	
			@$el.css "margin-left": "0"		
			$action = $(e.currentTarget).parent()
			Veggie.hide_nav =>
				width = $(window).width() - 48
				@$el.removeClass("left").animate
					"width": width + "px"
					800
					-> 
						$(@).css "width": "auto"
						$action.css 
							"-webkit-transform": "translateX(0)"
			@$el.parent().siblings().hide()
			@$el.siblings().hide()
	back: (e) ->
		$action = $(e.currentTarget).parent()
		@open = false
		@$el.css "margin-left": "10px"
		@$el.siblings().show()
		@$el.parent().siblings().show()
		@$el.removeClass("enter_in").addClass("left").css "width":"50%"	
		$action.css 
			"-webkit-transform": "translateX(120px)"
		$("body").css "overflow":"auto"
	pause: ->
		@$el.removeClass("enter_in")