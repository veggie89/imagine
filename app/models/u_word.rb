class UWord
  include Mongoid::Document

  field :img_size, type: Hash
  field :img_info

  belongs_to :member
  belongs_to :word

  validates :member_id, :presence => true, :uniqueness => {:scope => :word_id }
  
  IMAGE_URL = "/system/images/u_word/"
  IMAGE_PATH = "#{Rails.root}/public" + IMAGE_URL
  IMAGE_SIZE_LIMIT = 2*1000*1000 #2m
  IMAGE_WIDTH = 280

  AUDIO_URL = "/system/audios/u_word/"
  AUDIO_PATH = "#{Rails.root}/public" + AUDIO_URL

  scope :has_image, -> {where(:img_size.exists => true)}

  def title
    word.title
  end

  def make_image(file)
  	dir = IMAGE_PATH + "#{_id}"
  	unless File.exist?(dir)
    	`mkdir -p #{dir}`
  	end
  	h = Image::Convert.new(file,:outfile => image_path).draw(word.image_path)
  	self.img_size = {:width => IMAGE_WIDTH,:height => h}
  	self
  end
  
  def image_path
    IMAGE_PATH + "#{_id}/#{$config[:name]}.jpg"
  end
  
  def image_url
    IMAGE_URL + "#{_id}/#{$config[:name]}.jpg"
  end

  def audio_path
    AUDIO_PATH + "#{_id}/#{$config[:name]}.ogg"
  end

  def audio_url
    AUDIO_URL + "#{_id}/#{$config[:name]}.ogg"
  end

  def has_audio
    return File.exist?(audio_path)
  end

  def validate_upload_image(file,type)
    type.scan(/(jpeg|png|gif)/).any? and File.size(file) < IMAGE_SIZE_LIMIT
  end

	# for show
  def as_json
    data = word.as_json
	if img_size
		data.merge!({
			:img_size => img_size,
			:img_info => img_info,
			:img_url => image_url
		})
	end
	if has_audio
		data.merge!({
			:my_audio => audio_url
		})
	end
	data
  end

end
