class TechInterviewCreator

  def run
    # no tech interviews on weekends
    puts "Running..."
    return false unless weekday?
    Cohort.is_active.each do |cohort|
      tz = cohort.location.timezone
      Time.use_zone(tz) do
        if within_mentor_hours?
          handle_cohort(cohort)
        end
      end
    end
  end

  private

  def handle_cohort(cohort)
    puts "Handling cohort #{cohort.name}"

    # if there are any active interviews in this location, then no go
    if interview = TechInterview.for_locations([cohort.location.name]).active.first
      return handle_existing_interview(cohort, interview)
    end

    interview_templates.each do |template|
      if template.week <= cohort.week
        if interview = create_interview(cohort, template)
          return interview
        end
      end
    end
  end

  def handle_existing_interview(cohort, interview)
    puts "Existing W#{interview.week } interview found for #{cohort.location.name}: #{interview.id}"

    mins = (Time.current - interview.created_at).to_i / 60
    if mins >= 20 && interview.queued?
      slack_alert interview, "There's a stale tech interview in #{cohort.location.name} Queue: #{interview.interviewee.full_name} [#{mins}min]."
    end
  end

  def slack_alert(interview, msg)
    return unless ENV['SLACK_WEBHOOK_QUEUE_ALERTS'].present?
    return if interview.last_alerted_at? && (Time.current - interview.last_alerted_at) < (20*60)

    cohort     = interview.cohort
    receiver   = cohort.location.slack_username
    channel    = cohort.location.slack_channel

    options    = {
      username: 'Compass',
      icon_url: 'https://cdn3.iconfinder.com/data/icons/browsers-1/512/Browser_JJ-512.png',
      channel: channel
    }
    poster = Slack::Poster.new(ENV['SLACK_WEBHOOK_QUEUE_ALERTS'], options)
    poster.send_message("#{receiver}, #{msg}")
    interview.touch(:last_alerted_at)
  rescue Exception => e
    ignore
  end

  def create_interview(cohort, template)
    puts "Creating W#{template.week} interview for #{cohort.name}"

    if student = fetch_student(cohort, template)
      result = CreateTechInterview.call(
        interviewee: student,
        interview_template: template
      )
    end
  end

  def fetch_student(cohort, template)
    interviewed_student_ids = template.tech_interviews.for_cohort(cohort).select(:interviewee_id)
    cohort.students.active.where.not(id: interviewed_student_ids).order('random()').first
  end

  def within_mentor_hours?
    hour = Time.current.hour
    hour >= 11 && hour < 21
  end

  def weekday?
    Date.current.on_weekday?
  end

  def interview_templates
    @interview_templates ||= TechInterviewTemplate.all
  end

end