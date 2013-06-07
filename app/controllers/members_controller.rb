class MembersController < ApplicationController
  before_filter :authenticate_member!,:except => :show
  
  # page
  def index
  	set_seo_meta(nil)
  end

  # api get
  def dashboard  
    data = {
      :quote => Eva::Quote.new(current_member).single,
      :courses => Eva::Course.new(current_member).list,
      :song => Eva::Song.new(current_member).single,
      :person => Eva::Person.new(current_member).single
    }

    unless current_member.is_member?
      guides = YAML.load_file(Rails.root.join("doc","guide.yml")).fetch("guide")
      data.merge!(:guides => guides)
    end
    render_json 0,'ok',data
  end

  # api get
  def account
    if current_member.is_member?
      @providers = Authorization::PROVIDERS.map do |p|
        {
          :provider => p,
          :has_bind => current_member.has_provider?(p) ? true : false,
          :omniauth_url => member_omniauth_authorize_path(p)
        }
      end
      data = current_member.as_json.merge(:providers => @providers)
      render_json 0,'ok',data
    else
      render_json -1,"u are not member"
    end
  end

  # get provider info
  def provider
    p = current_member.has_provider?(params[:provider])
    data = p.as_json
    case p.provider
    when "weibo"
      data.merge!(:friends => Wali::Friend.new(p).bilateral)
    when "tumblr"
      false
    end
    render_json 0,"ok",data
  end

  # get current member profile
  def profile
    render_json 0,"ok",current_member.as_profile
  end

  # To-Do
  # friendship status
  def invite_list
    if p = current_member.has_provider?("weibo")
      has_invites = current_member.invites.outside.collect(&:target)
      @friends = Wali::Friend.new(p).bilateral.select do |x|
        has_invites.exclude?(x["id"].to_s)
      end
    end
    data = {
      :friends => @friends
    }
    render_json 0,"ok",data
  end

  # api get
  def friend
    render_json 0,'ok'
  end

  # api get
  def teach
    if current_member.is_teacher?
      @courses = current_member.courses.collect(&:as_json)
      render_json 0,'ok',@courses
    else
      render_json -1,"u are not teacher"
    end
  end

  # page
  def show
  	role_ok = Member::ROLE.include?(params[:role])  
    if role_ok and @user = Member.send(params[:role]).where(:uid => params[:uid]).first
      set_seo_meta(@user.name)     
    else
      redirect_to "/not_found"
    end
  end

  # 充值
  # post
  def add_gem
    
  end

  # post
  def upload_avatar
    file = params[:image].tempfile.path 
    type = params[:image].content_type 
    if current_member.validate_upload_avatar(file,type)
      current_member.save_avatar(file)
      @avatar = current_member.avatar + "?#{Time.now.to_i}"
      render_json 0,t('flash.notice.avatar'),@avatar
    else
      render_json -1,t('flash.error.avatar')
    end
      
  end

  # post
  def upload_audio
    file = params[:file]
    @store_path = Member::AUDIO_PATH + current_member._id 
    @audio_path = current_member.audio_path(params[:_id])
    unless File.exist?(@store_path)
      `mkdir -p #{@store_path}`
    end
    # 压缩成 ogg
    `oggenc -q 4 #{file.tempfile.path} -o #{@audio_path}`
    render_json 0,"ok"
  end

  # set uid
  # post
  def update  
    if params[:uid].blank?
      render_json -1,t('flash.error.blank')
    else
      if @user = Member.u.where(:uid => params[:uid]).first
        render_json -1,t('flash.error.uid')
      else
        data = {
          :uid => params[:uid],
          :role => "u",
          :gem => 10,
          :email => params[:uid] + "@" + $config[:domain]
        }
        if current_member.update_attributes(data)
          render_json 0,"ok"
        else
          render_json -1,t('flash.error.uid_format')
        end
      end
    end
  end

  # invite
  # @target: uid
  # @msg
  # @provider 'weibo'
  # @course_id
  # @style common / teach
  def send_invite
    provider = params[:provider] || "weibo"
    
    # 检查被邀请者是否已经存在
    if p = Authorization.where(:provider => provider,:uid => params[:target]).first
      member = p.member
      # 相互添加好友并通知
      current_member.friend_ids << member._id
      current_member.save
      member.friend_ids << current_member._id
      member.save
      # 新建站内邀请
      current_member.invites.create(:target => member._id,:course_id => params[:course_id])
      render_json 1,"new friend"
    else
      args = params.slice(:target,:course_id).merge!(:provider => provider)
      message = params[:msg].gsub(/\s+/,' ') + " " + $config[:host]
      # 新建站外邀请
      invite = current_member.invites.new(args)
      if invite.save and p = current_member.has_provider?(provider)          
        HardWorker::SendInviteJob.perform_async(message,p._id)
        render_json 0,"send invite by #{provider}"
      else
        render_json -1,"error"
      end
    end
    
  end

  # 向已存在好友发起邀请
  # @_id
  # @course_id
  def invite_friend
    @friend = Member.find(params[:_id])
    if @friend.has_checkin?(params[:course_id])
      render_json -1,"already checkin"
    else
      current_member.invites.create(:target => @friend._id,:course_id => params[:course_id])
      render_json 0,"ok"
    end
  end

  # like
  # @obj [Song,Quote,Person]
  # @_id
  def like
    valiable_obj = %w{Song Quote Person}
    if valiable_obj.include? params[:obj]
      obj = eval(params[:obj]).find(params[:_id])
      obj.liked_by(current_member)
      render_json 0,"ok",obj.liked_count
    else
      render_json -1,"invalue"
    end
    
  end

end
