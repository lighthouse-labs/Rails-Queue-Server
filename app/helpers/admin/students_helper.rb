module Admin::StudentsHelper

  def completed_registration?(student)
    student.completed_registration ? "YES" : "NO"
  end

  def prep_time_spent(minutes)
    if minutes <= 60
      "#{minutes} mins"
    else
      "#{(minutes / 60.0).round(1)} hours"
    end
  end

  def day_placeholder(user)
    user.use_double_digit_week? ? "wxxdx or wxxe" : "wxdx or wxe"
  end

end
