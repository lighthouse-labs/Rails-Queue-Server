module AssessmentTestsHelper

  def url_for_proctologist(test, cohort)
    student_usernames = cohort.students.active.map { |s| s.enrollment_id(cohort) }
    student_usernames = student_usernames.join(',')
    "#{ENV['PROCTOLOGIST_URL']}admin/exams/#{test}/?studentIds=#{student_usernames}"
  end

  def programming_tests
    ProgrammingTest.active.map do |pt|
      { name: pt.test_activities.first.name, exam_code: pt.exam_code }
    end
  end

end
