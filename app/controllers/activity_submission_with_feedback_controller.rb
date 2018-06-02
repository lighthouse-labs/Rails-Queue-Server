class ActivitySubmissionWithFeedbackController < ApplicationController

  # AJAX only
  # from activities#show
  def create
    @activity = Activity.find params[:activity_id]
    result = SubmitActivityWithFeedback.call(
      user:                                       current_user,
      activity:                                   @activity,
      activity_submission_with_optional_feedback: ActivitySubmissionWithOptionalFeedback.new(submission_params)
    )

    @success = result.success?

    if @success
      flash[:notice] = "Congrats on completing activity '#{@activity.name}'!"
      render nothing: true, status: :ok
    else
      @errors = result.errors
      render layout: false, status: :bad_request # bad request
    end
  end

  private

  def submission_params
    params.require(:activity_submission_with_optional_feedback).permit(
      :time_spent,
      :note,
      :github_url,
      :detail,    # feedback
      :rating     # feedback
    )
  end

end
