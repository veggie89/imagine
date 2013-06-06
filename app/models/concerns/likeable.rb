module Concerns
  module Likeable
    extend ActiveSupport::Concern

    included do
      field :liked_member_ids, :type => Array, :default => []
    end

    def liked_by?(member)
      return false if member.blank?
      self.liked_member_ids.include?(member._id)
    end

    def liked_by(member)
      self.liked_member_ids << member._id
      self.save
    end

    def liked_count
      self.liked_member_ids.length
    end
  end
end