class Song
  	include Mongoid::Document
  	include Concerns::Likeable

  	field :lyrics
	field :artist
	field :album
	field :title
	field :format

	validates :title, :uniqueness => true,:presence => true
	validates :lyrics, :presence => true

	after_destroy :clear_data

	AUDIO_URL = "/system/audios/song/"
	AUDIO_PATH = "#{Rails.root}/public" + AUDIO_URL

	def audio_path
		AUDIO_PATH + "#{_id}/#{$config[:name]}." + format if format
	end

	def audio_url
		AUDIO_URL + "#{_id}/#{$config[:name]}." + format if format
	end

	def as_json
		ext = {
			:url => audio_url,
			:liked_count => liked_count
		}
		super(:only => [:_id,:lyrics,:artist,:title]).merge(ext)
	end

	def clear_data
    	`rm -rf #{AUDIO_PATH + _id}`
  	end 

	rails_admin do 
	  	field :title
	  	field :artist
	  	field :album
	  	field :format
	  	field :lyrics, :text
	end
end
