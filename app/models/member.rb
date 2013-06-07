class Member
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:weibo,:twitter,:github,:tumblr,:instagram,:youtube]

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""
  
  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Token authenticatable
  # field :authentication_token, :type => String

  field :role 
  field :uid
  field :gem, :type => Integer, :default => 0
  field :friend_ids, :type => Array

  has_many :authorizations,:dependent => :destroy
  has_many :courses
  has_many :u_words,:dependent => :destroy
  has_many :invites,:dependent => :destroy

  embeds_many :course_grades
  accepts_nested_attributes_for :course_grades

  validates :uid, :uniqueness => true,
                  :allow_blank => true,
                  :length => {:in => 2..20 },
                  :format => {:with => /^[A-Za-z0-9_]+$/ }

  after_destroy :clear_data

  AVATAR_URL = "/system/images/member/"
  AVATAR_PATH = "#{Rails.root}/public" + AVATAR_URL

  AUDIO_URL = "/system/audios/member/"
  AUDIO_PATH = "#{Rails.root}/public" + AUDIO_URL

  AVATAR_SIZE_LIMIT = 3000*1000 #3m
  THUMB_SIZE = 120
  ## role 用户组别 
  ROLE = %w{a u t}
  # nil 三无用户，被清理对象
  scope :x, -> {where(:role => nil)}
  ROLE.each do |r|
    scope r.to_sym, -> {where(:role => r)}
  end
  
  def admin?
    self.role == "a"
  end

  def is_teacher?
    self.role == "t" || admin?
  end
  
  def is_member?
    !role.blank?
  end

  def checked_courses
    cids = course_grades.collect(&:course_id)
    Course.where(:_id.in => cids)
  end

  def invited_courses 
    cids = Invite.inside.where(:target => self._id).collect(&:course_id).uniq
    Course.where(:_id.in => cids)
  end

  def has_checkin?(course_id)
    course_grades.where(:course_id => course_id).any?
  end

  def member_path
    "#{role}/#{uid}"
  end

  def avatar
    File.exist?(AVATAR_PATH + avatar_name) ? (AVATAR_URL + avatar_name) : "icon/avatar.jpg"
  end

  def avatar_name
    "#{_id}/#{c_at.to_i}.jpg"
  end

  def validate_upload_avatar(file,type)
    type.scan(/(jpeg|png|gif)/).any? and File.size(file) < AVATAR_SIZE_LIMIT
  end

  def audio_path(ts)
    AUDIO_PATH + "#{_id}/#{ts}.ogg"
  end

  def audio_url(ts)
    AUDIO_URL + "#{_id}/#{ts}.ogg"
  end

  def has_u_word(wid)
    UWord.where(:member_id => self.id,:word_id => wid).first
  end
  
  def name
    p = self.authorizations.first
    p ? p.user_name : $config[:author]
  end
  
  def has_provider?(p)
    self.authorizations.where(:provider => p).first
  end

  def save_avatar(file_path)
    `mkdir -p #{AVATAR_PATH + _id}`
    Image::Convert.square_thumb(file_path,THUMB_SIZE).write(AVATAR_PATH + avatar_name)
  end

  def bind_service(omniauth, expires_time)
    self.authorizations.create!(
      provider:     omniauth.provider,
      uid:          omniauth.uid,
      token: omniauth.credentials.token,
      secret: omniauth.credentials.secret,
      info: omniauth.info,
      expired_at: expires_time,
      refresh_token: omniauth.credentials.refresh_token
    )
  end

  def self.generate(prefix = Utils.rand_passwd(7,:number => true))
    email = prefix + "@" + $config[:domain]
    passwd = Utils.rand_passwd(8)
    user = Member.new(
      :email => email,
      :password => passwd,
      :password_confirmation => passwd)
    if user.save!
      user
    else
      self.generate(prefix + "v")
    end
  end

  def clear_data
    `rm -rf #{AVATAR_PATH + _id}`
  end 

  def as_json
    ext = {
      :member_path => member_path,
      :grades => course_grades.length,
      :words => u_words.length
    }
    super(:only => [:c_at,:role,:uid]).merge(ext)
  end

  def as_profile
    {
      :_id => _id,
      :avatar => avatar,
      :name => name,
      :member_path => member_path,
      :gem => gem,
      :is_member => is_member?,
      :is_teacher => is_teacher?
    }
  end

  rails_admin do
    field :email do
      pretty_value do
        bindings[:view].image_tag(bindings[:object].avatar)
      end
      column_width 55
    end
    field :uid
    field :role
    field :gem
    field :c_at
    field :last_sign_in_ip
    field :authorizations
  end

  #mongo index
  index({role: 1,uid: 1},{ unique: true })
end
