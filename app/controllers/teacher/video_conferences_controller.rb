class Teacher::VideoConferencesController < Teacher::BaseController

  def show
    @video_conference = VideoConference.find params[:id]
    session[:cohort_id] = @video_conference.cohort.id if @video_conference.cohort?
    redirect_to @video_conference.activity_id? ? activity_path(@video_conference.activity) : :root
  end

  def update
    video_conference = VideoConference.find(params[:id])

    zoom_update = true
    old_status = video_conference.status
    if conference_params[:status] == 'finished' && video_conference.status != 'finished'
      end_zoom_meeting = ZoomMeeting::EndUserMeeting.call(
        video_conference: video_conference
      )

      zoom_update = end_zoom_meeting.success?

    end

    if zoom_update && video_conference.update(conference_params)
      if conference_params[:status]
        # action cable to update cohort on new conference
        VideoConferenceChannel.update_conference(video_conference, VideoConferenceChannel.channel_name_from_cohort(video_conference.cohort))
      end

      flash[:notice] = case conference_params[:status]
                       when 'finished'
                         "Video Conference Ended"
                       when 'waiting'
                         "Video Conference In Test Mode"
                       when 'started'
                         "Video Conference Started"
                       when 'broadcast'
                         "Video Conference Broadcasting"
                       else
                         "Video Conference Updated"
                       end

    else
      flash[:alert] = if end_zoom_meeting.error == "Sorry, you cannot delete this meeting since it's in progress."
                        "Please end the meeting in zoom first"
                      else
                        "Video Conference Could not be Updated"
                      end
    end

    redirect_back fallback_location: root_path
  end

  def create
    activity = Activity.find_by id: conference_params[:activity_id]
    cohort = Cohort.find_by id: conference_params[:cohort_id]
    if @current_user.hosting_active_video_conference?
      error = 'User already has an active video conference.'
    elsif activity&.active_conference_for_cohort(cohort)
      error = 'There is already a conference for that cohort and activity.'
    else
      create_zoom_meeting = ZoomMeeting::CreateUserMeeting.call(
        user:         @current_user,
        email:        conference_params[:email],
        duration:     conference_params[:duration].to_i,
        topic:        conference_params[:topic],
        use_password: conference_params[:use_password]
      )
      error = create_zoom_meeting.error if create_zoom_meeting.failure?
    end

    if error
      flash[:alert] = error
    else
      meeting = create_zoom_meeting.meeting
      VideoConference.create
      conference = VideoConference.new(
        name:            meeting['topic'],
        start_time:      meeting['start_time'],
        duration:        meeting['duration'],
        status:          'waiting',
        zoom_meeting_id: meeting['id'],
        zoom_host_id:    meeting['host_id'],
        zoom_host_email: conference_params[:email].empty? ? @current_user.email : conference_params[:email],
        start_url:       meeting['start_url'],
        join_url:        meeting['join_url'],
        password:        meeting['password'],
        cohort_id:       conference_params[:cohort_id] || cohort&.id,
        activity_id:     activity&.id
      )
      conference.user = current_user

      if conference.save!
        flash[:notice] = "Video Conference Created"
      else
        flash[:alert] = "conference could not be saved"
      end

    end
    redirect_back fallback_location: root_path
  end

  private

  def conference_params
    params.require(:video_conference).permit(
      :cohort_id, :activity_id, :topic, :duration, :start_time, :status, :use_password, :email, :cohort_id
    )
   end

end