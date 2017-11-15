class AddCurrentAssistanceAverageToUsers < ActiveRecord::Migration[5.0]
  def change
    Student.find_each(batch_size: 20) do |s|
      # Student.where(id: s.id).update()
      s.assistance_average = StudentStats.new(s).bootcamp_assistance_stats[:average_score]
      s.save!
    end
  end
end
