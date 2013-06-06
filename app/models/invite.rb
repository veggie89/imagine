class Invite
  include Mongoid::Document

  field :target
  field :provider
  field :course_id

  belongs_to :member
  validates :target, :uniqueness => {:scope => [:member_id,:course_id]},:presence => true

  scope :outside, -> { where(:provider.exists => true)}
  scope :inside, -> { where(:provider.exists => false)}

  after_create :push_notify
  
  # 站内邀请发送push
  # 通知 target,member想和你一起学习某课
  def push_notify
  	if provider.nil?
      cname = Course.find(course_id).title
      message = I18n.t("invite.common",:uname => member.name,:cname => cname)
  		WebsocketRails["notify_#{target}"].trigger "invite_course",message
  	end
  end

end
