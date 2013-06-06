class window.Veggie.TeachCourseView extends Backbone.View
	tagName: 'li'
	className: "form alert-success"
	template: JST['item/t_course']
	events:
		"click .edit": 'modify'
		"click .publish": 'publish'
		"click .save": "save"
		"click .next": "next"
		"click .delete": "delete"
		"click .back": "back"
		"mouseup .content": "handle_words"
	initialize: ->
		@listenTo(@model, 'change', @render)
		@listenTo(@model, 'destroy', @remove)
	back: ->
		@$el.siblings().show()
		@model.set editable: false
	save: ->
		self = this
		obj = $("form",@$el).serializeArray()
		serializedData = {}
		$.each obj, (index, field)->
			serializedData[field.name] = field.value
		if serializedData['content'] isnt '' and serializedData['title'] isnt ''
			Utils.loading @$el
			@model.save serializedData,success: (m,resp) ->
				data = _.extend resp.data, next: true
				self.model.set data			
				Utils.loaded self.$el
		else
			Utils.flash("请确认课程标题及内容已填写","error",@$el.parent())
	next: ->
		@model.set 
			editable: true
			next: true
	delete: ->
		self = this
		Utils.confirm "确认删除？", ->
			self.$el.siblings().show()
			self.model.destroy()
	modify: ->
		self = this
		@$el.siblings().hide()
		@model.set 
			editable: true
			next: false
		$form = $("form",@$el)
		Utils.tag_input($form)
		$('textarea',$form).css('overflow', 'hidden').autogrow()	
	publish: (e) ->
		content = $.trim @$el.find(".content").html()
		@model.ready content, =>
			@$el.siblings().show()
	handle_words: ->
		if window.getSelection
			sel = window.getSelection()
			wl = sel.getRangeAt(0).toString().length
			if wl is 0
				# 选中光标前面的单词
				sel.modify('move','left','word')
				sel.modify('extend','right','word')
			else
				Utils.getSelection()
	render: ->
		@$el.html @template(@model.toJSON())
		this