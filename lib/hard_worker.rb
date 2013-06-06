module HardWorker
  class Base
    include Sidekiq::Worker
    sidekiq_options retry: false 
    
    def logger(msg)
      Logger.new(File.join(Rails.root,"log","sidekiq-job.log")).info("[#{self.class}] #{msg}")
    end
  end
    
  class SendGreetJob < Base          
    def perform(id, opts={})
      provider = Authorization.find(id)
      self.logger(provider.user_name)
      Wali::Greet.new(provider,opts).deliver
      invites = Invite.where(:provider => provider.provider,:target => provider.uid)
      if invites.any?
        member = provider.member
        invites.each do |invite|
          # 每个当前用户相关邀请的发起人的好友名单中加入当前用户
          # 并获赠 2 gem
          # 通知 owner 有新朋友接受了邀请，并获得了奖励
          owner = invite.member
          owner.friend_ids << member._id
          owner.gem += 2
          owner.save
          # 当前被邀请用户免费登记受邀课程,并加好友
          # 通知受邀者成功接受了多少个邀请，并新增了多少好友
          member.friend_ids << owner._id
          member.course_grades << CourseGrade.new(:course_id => invite.course_id)
          member.save

        end
      end
    end
  end

  class PrepareWordJob < Base
    def perform(cid)
      words_count = Course.find(cid).prepare_words.length
      self.logger("#{words_count} words prepared")
    end
  end

  class SendInviteJob < Base
    def perform(message,id)
      provider = Authorization.find(id)
      Wali::Base.new(provider).client.statuses_update(message)
    end
  end
  
  class UploadOlive < Base

    def perform(content,pic)
      begin
        p = Authorization.official("weibo")
        data = Wali::Base.new(p).client.statuses_upload(content,pic)
				msg = data["error_code"] ? data.to_s : "#{data["id"]} published"
				self.logger msg
      rescue => ex
        self.logger("#{content} [#{pic}] fail msg: #{ex.to_s}")
      end
      #twitter
      veggie = Authorization.official("twitter")
      Wali::Base.new(veggie).client.update_with_media(content,File.open(pic))
    end
  end
  
end
