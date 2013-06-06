class window.Veggie.GuideView extends Backbone.View
	tagName: 'div'
	className: ->
		if @model.get("num") and @model.get("num") isnt 1
			'asset alert hide'
		else
			'asset alert'
	template: JST['item/guide']
	events:
		"click .next": 'next'
		"click .start": 'start'
	@addOne: (guide,$wrap = $("#assets")) ->
		if guide
			view = new Veggie.GuideView
				model: guide
			$wrap.show().html(view.render().el)
	next: ->
		$next = @$el.next()
		$next.fadeIn()		
		@remove()
	start: ->
		$("#courses,#widgets").fadeIn()
		@remove()
	render: ->
		@$el.html @template(@model.toJSON())
		$form = $("#set_uid form",@$el)
		$form.bind 'ajax:before',(d) ->
			Utils.loading $("nav .brand")
		$form.bind 'ajax:success', (d,data) =>
			if data.status is 0	
				@next()
				$("#side_nav li:first-child").siblings().show()
				$("nav .gem").text("10")
				mixpanel.track("new member")
			else
				Utils.flash(data.msg,"error")
			Utils.loaded $("nav .brand")
		this