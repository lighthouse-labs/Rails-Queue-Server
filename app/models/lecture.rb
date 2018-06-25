class Lecture < ApplicationRecord

  include PgSearch

  default_scope { order(created_at: :desc) }

  belongs_to :presenter, class_name: User
  belongs_to :cohort
  belongs_to :activity

  pg_search_scope :by_keywords,
                  against:            [:subject, :body],
                  using:              {
                    tsearch: {
                      dictionary: "english",
                      any_word:   true,
                      prefix:     true
                    }
                  }

  scope :for_cohort, ->(cohort) { where(cohort_id: cohort.id) }
  scope :most_recent_first, -> { order("lectures.created_at ASC") }
  scope :for_teacher, ->(teacher) { where(presenter: teacher) }
  scope :filter_by_presenter_location, ->(location_id) {
    includes(presenter: :location)
      .where(locations: { id: location_id })
      .references(:teacher, :location)
  }

  validates :activity, presence: true
  validates :cohort, presence: true
  validates :subject, presence: true, length: { maximum: 100 }
  validates :day, presence: true, format: { with: DAY_REGEX, allow_blank: true }
  validates :body, presence: true

  def manageable_by?(user)
    user.admin? || (user == presenter)
  end

end
