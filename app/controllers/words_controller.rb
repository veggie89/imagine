class WordsController < ApplicationController
	before_filter :authenticate_member!

	# @course_id
	def index
		@course = Course.find(params[:_id])
		data = @course.words.each_with_index.map do |w,i|
			ext = {
				:imagine => current_member.has_u_word(w).present?,
				:num => i + 1,
				:synsets => w.synset,
				:sentences => w.sentence
			}
			w.as_json.merge!(ext)
		end
		render_json 0,"ok",data	
	end

	def fetch
		title = params[:title]
		word = Onion::Word.new(title).insert(:skip_exist => 1)
		
		# 联想好友们的发音，图片
		#Onion::Word.wordnet(params[:title],:synset)
		#Onion::Word.from_tweet(title)
		render_json 0,"ok",data	
	end

	# @id
	# @synset array
	# 联想同义词，提供wordnet参考，由老师编辑添加
	def insert_synset
		
	end

	def insert_sentence
		
	end

	# U Word
	# 用户上传图片
  	# upload &image &id
  	# response with js.haml
	def upload_img_u
	    @uw = find_or_create_uw(params[:_id])
		file = params[:image].tempfile.path
	    type = params[:image].content_type
		if @uw&&@uw.validate_upload_image(file,type)
    		@uw = @uw.make_image(file)
    		@uw.img_info = params[:info]
    		@uw.save
			img = @uw.image_url + "?#{Time.now.to_i}"
			render_json 0,t("flash.success.upload.uword"),img
		else
			render_json -1,"error"
		end	
	end

	# U word
	# 个人发音,自动上传
    def upload_audio_u
	    @uw = find_or_create_uw(params[:_id])
	    file = params[:file]
	    @store_path = UWord::AUDIO_PATH + "#{@uw._id}"
	    unless File.exist?(@store_path)
	      `mkdir -p #{@store_path}`
	    end
	    # 压缩成 ogg
	    `oggenc -q 4 #{file.tempfile.path} -o #{@uw.audio_path}`
	    render_json 0,"ok"
	end

	private
	  def find_or_create_uw(id)
	    @word = Word.find(id)
	    unless @uw = current_member.has_u_word(@word)
	      @uw = current_member.u_words.new(:word_id => @word._id)
	    end
	    @uw
	  end

end