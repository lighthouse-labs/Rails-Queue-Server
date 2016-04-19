class Section < ActiveRecord::Base
  has_many :activities

  validates :slug, presence: true, uniqueness: true

  def to_param
    self.slug
  end

  def duration_in_hours
    activities.sum(:duration) / 60.0
  end
end
