class SmartQueueRouter::TeacherLocationScore

  include Interactor

  before do
    @teachers = context.teachers
    @same_location_bonus = context.same_location_bonus
    @assistee = context.assistance_request.requestor
  end

  def call
    @teachers.each do |_id, teacher|
      teacher[:routing_score] ||= 0
      teacher[:routing_score] += @same_location_bonus if teacher[:object].location == @assistee.location
    end
  end

end
