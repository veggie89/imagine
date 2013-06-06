class window.Veggie.CourseView extends Backbone.View
	tagName: 'li'
	template: JST['item/course']
	collection: new Veggie.Words()
	events: ->
		"click b": "toggleSelect"
		"click .checkin": "checkin"
		"click .study": "study"
		"click .imagine_words": "imagine_words"
		"click .back-to-list": "back_to_list"
		"click .back-to-content": "back_to_content"
	initialize: ->
		@listenTo(@model, 'change', @render)
		@listenTo(@model, 'study', @study)
	checkin: ->
		@model.checkin =>
			Veggie.GuideView.addOne Guide.courses("content")
	select_words_from_collection: ->
		@model.set 
			open: true
			imagine: false
		words = @collection.where
			imagine: false
		titles = _.map words, (w) ->
			w.get("title")
		for w in titles
			$('b:contains("' + w + '")').addClass 'selected'	
	study: ->
		Utils.loading @$el		
		@collection.fetch
			url: "/words/index?_id=" + @model.get("_id")
			success: (data) =>
				Utils.loaded @$el
				Veggie.hide_nav()
				@$el.parent().siblings().hide()
				@$el.siblings().hide()									
				@select_words_from_collection()	
				window.route.active_view.current_course = @model
				unless @model.get("has_checkin")
					Veggie.GuideView.addOne Guide.courses("checkin")
				window.chatroom.enter_channel(@model.get("_id"))
	back_to_list: ->
		@model.set 
			open: false
		@$el.siblings().show()
		@$el.parent().siblings().show()
		$("#assets").empty()		
		@collection.reset()
		$("#imagine").empty()
		window.chatroom.leave_channel()
	save_step: (id) ->
		cid = @model.get("_id")
		$.jStorage.set "course_#{cid}",id
	back_to_content: ->
		$word = $(".step.active")
		@save_step $word.attr("id")
		window.route.active_view.deinit_imagine()
		@$el.removeClass 'opacity'
		Veggie.GuideView.addOne Guide.courses("back_content")
		@select_words_from_collection()
		$("#imagine").empty()
		# w = $.trim($(".title",$word).text())
		# Utils.highlight $('b:contains("' + w + '")')		
	toggleSelect: (e) ->
		$target = $(e.currentTarget)
		word = @collection.where
			title: $.trim($target.text())
		if $target.hasClass 'selected'
			$target.removeClass 'selected'
			word[0].set 
				imagine: true
		else			
			$target.addClass 'selected'
			word[0].set 
				imagine: false
	addOneWord: (word,opts = {}) ->
		options = _.extend
			model: word
			opts
		view = new Veggie.WordView options			 
		new_step = view.render().el
		$("#imagine").append(new_step)
		# $("#imagine").jmpress("canvas").append(new_step)
		# $("#imagine").jmpress("init",new_step)
	addEnd: ->
		word = new Word
			tip: "Imagine Never End"
			num: @collection.length + 1
			end: "end"
		@addOneWord(word,id: "iend")
	addHome: ->
		word = new Word
			tip: "Start Imagine"
			num: 0
			sum: @collection.length
		@addOneWord(word,id: "ihome")
	imagine_words: ->		
		@addHome()
		for word in @collection.models
			@addOneWord word
		@addEnd()
		# render
		@model.set
			open: true
			imagine: true		
		# init imagine
		window.route.active_view.init_imagine()
		@$el.addClass 'opacity'
		if document.createElement('input').webkitSpeech is undefined
			Utils.flash("请使用最新版本的chrome浏览器达到最佳学习效果","error")
	render: ->
		@$el.html @template(@model.toJSON())
		this