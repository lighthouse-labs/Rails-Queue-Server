class Assistance < ActiveRecord::Base
  has_one :assistance_request
  belongs_to :assistor, :class => User
  belongs_to :assistee, :class => User

  before_create :set_start_at

  scope :currently_active, -> { where(:end_at => nil) }
  scope :order_by_start, -> { order(:start_at) }
  scope :assisted_by, -> (user) { where(:assistor => user) }
  scope :assisting, -> (user) { where(:assistee => user) }

  def end(notes)
    self.notes = notes
    self.end_at = Time.now
    self.save
  end

  private

  def set_start_at
    self.start_at = Time.now
  end

end