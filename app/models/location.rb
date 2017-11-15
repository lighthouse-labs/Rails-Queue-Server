class Location < ApplicationRecord

  has_many :users
  has_many :cohorts
  has_many :programs

  belongs_to :supported_by_location, class_name: 'Location' # nullable

  def em_location
    Location.find_by_id(self.supported_by_location_id) || self
  end

end
