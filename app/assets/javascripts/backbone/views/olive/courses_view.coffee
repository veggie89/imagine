class window.Olive.CoursesView extends Olive.View
	id: 'courses'
	className: "block"
	template: JST['courses_view']
	collection: new Olive.Courses()
	addOne: (course) ->
		view = new Olive.CourseView
			model: course
		@$el.append(view.render().el)
	render: ->
		template = @template()
		@$el.html(template)			
		this
	extra: ->
		for c in @collection.models
			@addOne(c)
		super()