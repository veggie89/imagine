class CoursesController < ApplicationController
	before_filter :authenticate_member!

	# 登記课程
	def checkin
		if @course = Course.find(params[:_id])
			gems = current_member.gem
			if gems - 7 > 0
				current_member.course_grades << CourseGrade.new(:course_id => @course.id)
			 	current_member.gem = gems - 7
			 	current_member.save
			 	render_json 0,"ok",gems - 7
			 else
			 	render_json -2,"not enough gems"
			 end		
		else
			render_json -1,"no course"
		end
	end

  	def update
		unless params[:_id].present? and find_member_course
			@course = current_member.courses.new
		end
		@course.title = params[:title]
		@course.tags = params[:tags].split(",")
		@course.content = params[:content].strip
		@course.status = 3
		@course.make_raw_content
		if @course.save		
			render_json 0,"save success",@course.as_json
		else
			render_json -1,"fail"
		end
	end

	def ready
		if find_member_course
			@course.raw_content = params[:raw_content]
			# 标记课程状态为审核中
			@course.status = 2
			@course.save				
			render_json 0,"wait for open"
		else
			render_json -1,"no course"
		end
	end

	def open
		if find_member_course
			HardWorker::PrepareWordJob.perform_async(@course._id)
			@course.make_open					
			render_json 0,"open"
		else
			render_json -1,"no course"
		end
	end

	def destroy
		if find_member_course
			@course.destroy
			render_json 0,"destroy"
		else
			render_json -1,"no course"
		end
	end

	private
	def find_member_course
		if current_member.admin?
			@course = Course.find(params[:_id])
		else
			@course = current_member.courses.find(params[:_id])
		end
	end
end
