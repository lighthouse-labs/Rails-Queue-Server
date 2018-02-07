module ApplicationHelper

  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end

  def fools?
    Date.current.month == 4 && Date.current.day == 1
  end

  # teachers always have cable ON
  # people in prep should have cable OFF
  # active students (bootcamp) have cable ON
  # people in limited cohorts have cable OFF (limited = no assistance stuff)
  def disable_cable?
    current_user.nil? || !current_user.active? || current_user.prospect? ||
      (!current_user.is_a?(Teacher) && current_user.cohort && current_user.cohort.limited?) || impersonating? ||
      (current_user.is_a?(Student) && !current_user.cohort.program.has_queue?)
  end

  # folks in limited (previous alumni) cohort dont need to take up action cable connections
  def disable_cable_for_some
    ' disable-cable' if disable_cable?
  end

  # Display an integer time as a string
  # Ex: integer_time_to_s(930) # => "9:30"
  def integer_time_to_s(int_time)
    return nil if int_time.blank?
    hours = int_time / 100
    minutes = int_time % 100
    minutes = "00" if minutes == 0
    "#{hours}:#{minutes}"
  end

  def avatar_for(user)
    if user.custom_avatar?
      user.custom_avatar.url(:thumb)
    elsif user.avatar_url
      user.avatar_url
    else
      image_path('duck-on.png')
    end
  end

  def format_date_time(time)
    time ? time.strftime("%b %e, %l:%M %p") : ''
  end

  def it_is_6pm_already?
    Time.current.seconds_since_midnight >= DAY_FEEDBACK_AFTER
  end

  def title(page_title)
    content_for :title, page_title
  end

  def link_to_add_fields(name, f, association, css_classes)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields btn btn-primary btn-sm #{css_classes}", data: { id: id, fields: fields.delete("\n") })
  end

  def shortened_github_url(url)
    url.to_s.strip.gsub(/https?\:\/\/.*github\.com\//, '')
  end

  def progress_bar_class(percent)
    if percent >= 96
      'progress-bar-success'
    elsif percent > 70
      'progress-bar-info'
    elsif percent > 50
      'progress-bar-warning'
    else
      'progress-bar-danger'
    end
  end

  def l_score_label_class(val)
    return 'badge-default' if val.nil?
    val = val.to_f

    if val < 2.1
      'badge-danger'
    elsif val < 2.4
      'badge-warning'
    elsif val < 2.8
      'badge-info'
    elsif val <= 4.0
      'badge-success'
    else
      'badge-default'
    end
  end

  def integer_l_score_label_class(val)
    return 'badge-default' if val.nil?

    if val < 2
      'badge-danger'
    elsif val < 3
      'badge-warning'
    elsif val < 4
      'badge-info'
    elsif val == 4
      'badge-success'
    end
  end

  def project_eval_status_label_class(eval)
    if eval.in_state?(:pending)
      'badge-warning'
    elsif eval.in_state?(:in_progress)
      'badge-info'
    elsif eval.in_state?(:rejected)
      'badge-danger'
    elsif eval.in_state?(:accepted) || eval.in_state?(:auto_accepted)
      'badge-success'
    else
      'badge-default'
    end
  end

end
