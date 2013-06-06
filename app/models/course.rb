class Course
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  field :title
  field :lang
  field :status, type: Integer, default: 3
  field :tags, type: Array
  field :content
  field :raw_content, default: ""
  field :script, type: Array
  
  # author
  belongs_to :member

  validates :title, :presence => true, :uniqueness => {:scope => :member}

  scope :en,where(:lang => nil)

  STATUS = {
    "1" => "open",
    "2" => "ready",
    "3" => "draft"
  }
  # 1 : 发布状态 不能被修改，否则变为 3
  # 2 : 审核状态 不能修改，－>1 ->3
  # 3 : 草稿状态 默认
  STATUS.each do |k,v|
    scope v.to_sym,where(:status => k.to_i)
  end

  def words_in_content
    raw_content.scan(/<b>([^<\/]*)<\/b>/).flatten.uniq
  end

  def words
    Word.where(:title.in => words_in_content)
  end

  def prepare_words
    words_in_content.each do |w|
      Onion::Word.new(w).insert(:skip_exist => 1)
    end
  end

  def make_raw_content
    self.raw_content = content.split("\r\n").map do |s|
      "<div>#{s}</div>"
    end.join()
  end

  def make_open
    self.update_attribute(:status,1)
    self.member.course_grades << CourseGrade.new(:course_id => self.id)
  end

  def as_json
    ext = {
      "author" => {
        "name" => member.name,
        "url" => member.member_path
      },
      "tags" => tags.join(","),
      "wl" => words_in_content.length
    }
    super(:only => [:_id,:title,:content,:raw_content,:u_at,:status]).merge(ext)
  end

  rails_admin do
    list do 
      field :status, :integer do
        pretty_value do
          STATUS[value.to_s]
        end
      end
      field :title
      field :member
    end
    edit do 
      field :status, :integer
      field :title
      field :content , :text
      field :raw_content, :text
    end
    show do 
      configure :raw_content do 
        pretty_value do 
          bindings[:view].raw value
        end
      end
    end
  end

  index({ title: 1})
  index({ tags: 1})

end
