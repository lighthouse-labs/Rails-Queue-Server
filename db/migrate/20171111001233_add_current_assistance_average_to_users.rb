class AddCurrentAssistanceAverageToUsers < ActiveRecord::Migration[5.0]
  def up
    Student.find_each(batch_size: 100) do |s|
      s.cohort_assistance_average = s.assistances.completed.where(cohort_id: cohort_id).where.not(rating: nil).average(:rating).to_f.round(2)
      s.save!
    end
  end
  def down
    Student.update_all({cohort_assistance_average: nil})
  end
end
