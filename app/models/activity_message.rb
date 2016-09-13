class ActivityMessage < ApplicationRecord

  KINDS = ['Lecture Notes']

  belongs_to :activity
  belongs_to :user # message creator
  belongs_to :cohort # message creator

  default_scope { order(created_at: :desc) }

  scope :for_cohort, -> (cohort) { where(cohort_id: cohort.id) }

  validates :activity, presence: true
  validates :user, presence: true
  validates :cohort, presence: true

  validates :subject, presence: true, length: { maximum: 100 }
  validates :day, presence: true, format: { with: DAY_REGEX, allow_blank: true }

  validates :kind, presence: true
  validates :body, presence: true

  after_create :notify_cohort_students
  after_create :create_empty_feedbacks

  private

  def notify_cohort_students
    UserMailer.new_activity_message(self).deliver
  end

  def create_empty_feedbacks
    cohort.students.each do |student|
      activity.feedbacks.create(student: student, teacher: user)
    end
  end
end
