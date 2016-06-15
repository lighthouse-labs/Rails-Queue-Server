class Section < ActiveRecord::Base

  has_many :activities

  has_many :activity_submissions, through: :activities

  default_scope { order(order: :asc) }

  validates :slug, presence: true, uniqueness: true

  def to_param
    self.slug
  end

  def duration_in_hours
    # add 10% for buffer
    (activities.sum(:duration) / 60.0) * 1.1
  end
end
