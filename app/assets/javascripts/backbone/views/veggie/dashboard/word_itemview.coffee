class window.Veggie.WordView extends Backbone.View
	tagName: 'div'
	className: 'step word'
	id: ->
		@model.get('title')
	attributes: ->
		"data-x": 0
		"data-y": -@model.get('num')*1000 
		"data-z": -@model.get('num')*1500	
		"data-scale": "1"
	template: JST['item/word']
	events: ->
		"enterStep": "enterStep"
		"webkitspeechchange .speech input": "speech"
		"focus .speech input": "focus_speech"
		"click .goFirst": "goFirst"
		"click .upload_img": "upload_img"
		"click .audio .record": "audio_record"
		"click .audio .play": "audio_play"
		"click .to_imagine": "to_imagine"
	initialize: ->
		@listenTo(@model, 'change', @render)
		@listenTo(@model, 'destroy', @remove)
		if t = @model.get("title")
			@my_audio = new Audio()			
			id = @model.cid
			@sound = soundManager.createSound
				id: id
				url: "http://tts.yeshj.com/uk/s/" + encodeURIComponent(t)
	render: ->
		@$el.html @template(@model.toJSON())	
		this
	to_imagine: ->
		$wv = $(".word_card:visible",@$el)
		$wh = $(".word_card:hidden",@$el)
		$wv.hide()
		$wh.show()						
		Veggie.GuideView.addOne Guide.imagine("word")
		@sound.play()
	goFirst: ->
		$("#imagine").jmpress "goTo",$("#ihome")
	focus_speech: (e) ->
		$(e.currentTarget).blur()
	speech: (e) ->
		$ele = $(e.currentTarget)
		key = $ele.data().key
		w = $ele.val()
		if w.toLowerCase() is key
			Utils.flash("发音很准哦！","success")
		else
			Utils.flash("#{w}? 还差一点，加油！","error")
		$ele.blur().val('')
		setTimeout(=>
			@sound.play()
		,500)
	enterStep: (e) ->
		max = $(".step").length - 1
		percent = @model.get('num')*100/max
		$("#progress .current_bar").css "width": "#{percent}%"
		$ele = $(e.currentTarget)
		if @sound
			@sound.play() 
		$("footer #uploader .uword input[name='_id']").val @model.get("_id")
		
		if @model.get('num') is 0
			Veggie.GuideView.addOne Guide.imagine("ihome")
		else if @model.get("num") is max
			Veggie.GuideView.addOne Guide.imagine("iend")
			
	upload_img: (e) ->
		Utils.uploader $(e.currentTarget),(img) =>
			@model.set 
				img_url: img
	audio_record: (e) ->
		self = this
		_id = @model.get("_id")
		$btn = $(e.currentTarget)
		if navigator.webkitGetUserMedia or navigator.getUserMedia
			window.recorder = window.recorder || new AudioRecorder()
			window.recorder.startRecording ->			
				$btn.addClass 'ing'
				setTimeout( ->
					window.recorder.stopRecording ->
						$btn.removeClass 'ing'
						window.recorder.createDownloadLink(self.my_audio,_id)
				,3000)
		else
			Utils.flash "您的浏览器不支持语音输入，请尝试chrome","error"
	audio_play: (e) ->
		if @my_audio.src isnt ''			
			@my_audio.play() 
		else if src = @model.get("my_audio")
			@my_audio.src = src
			@my_audio.play() 
		else
			Utils.flash("你还没有录音呢，请点击我左边那家伙先录个音吧！","error")
		