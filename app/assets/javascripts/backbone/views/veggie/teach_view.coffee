class window.Veggie.TeachView extends Veggie.View
	id: "teach"
	className: "common"
	template: JST['teach_view']
	collection: new Veggie.Teach()
	events:
		"click .new": 'newCourse'
	render: ->
		template = @template(is_teacher: window.current_member.get("is_teacher"))
		@$el.html(template)
		this
	newCourse: ->
		course = new Course()
		@addOne course
	addOne: (course) ->
		view = new Veggie.TeachCourseView
			model: course
		$("#t_courses",@$el).append(view.render().el)
	extra: ->
		if window.current_member.get("is_teacher")
			if @collection.models.length is 0
				guide = Guide.generate "你已经成为 17up 学会的教师了，赶快创建你的第一课吧"
				Veggie.GuideView.addOne(guide,$("#t_assets"))
			else
				for c in @collection.models
					@addOne(c)
		else
			guide = Guide.generate "目前，“教案” 功能正在实验室阶段，你想成为一名 17up 教师吗？请通过任何方式联系我吧，感谢您的支持！"
			Veggie.GuideView.addOne(guide,$("#t_assets"))
		super()