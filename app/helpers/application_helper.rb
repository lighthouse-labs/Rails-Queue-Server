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

  # Display an integer time as a string
  # Ex: integer_time_to_s(930) # => "9:30"
  def integer_time_to_s(int_time)
    return nil if int_time.blank?
    hours = int_time / 100
    minutes = int_time % 100
    minutes = "00" if minutes == 0
    return "#{hours}:#{minutes}"
  end

  def avatar_for(user)
    if user.custom_avatar.url
      user.custom_avatar.url(:thumb)
    else
      user.avatar_url
    end
  end

  def format_date_time(time)
    time ? time.strftime("%b %e, %l:%M %p") : ''
  end

  def it_is_6pm_already?
    Time.current.seconds_since_midnight >= DAY_FEEDBACK_AFTER
  end

  def link_to_add_fields(name, f, association, css_classes)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields btn btn-primary btn-sm #{css_classes}", data: {id: id, fields: fields.gsub("\n", "")})
  end

end
