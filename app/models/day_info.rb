class DayInfo < ApplicationRecord

  validates :day, uniqueness: true, format: {with: DAY_REGEX}

end
