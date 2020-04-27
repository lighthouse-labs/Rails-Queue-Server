class TechInterviewsController < ApplicationController

  before_action :not_for_students

  before_action :require_template, only: [:new, :create]
  before_action :require_interviewee, only: [:new, :create]

  before_action :require_interview, only: [:edit, :update, :confirm, :complete, :show, :start, :stop]
  before_action :only_incomplete, only: [:edit, :update, :confirm, :complete]
  before_action :only_queued, only: [:start]
  before_action :only_in_progress, only: [:stop, :edit, :update]

  def show; end

  def new
    @tech_interview = TechInterview.new(interviewee: @interviewee)
  end

  def create
    result = NationalQueue::CreateTechInterview.call(
      interviewer: current_user,
      interviewee: @interviewee,
      tech_interview_template: @interview_template
    )

    # should not fail, throw 500 / unexpected error if so
    if result.success?
      redirect_to edit_tech_interview_path(result.tech_interview)
    else
      raise result.error
    end
  end

  def start
    result = NationalQueue::CreateTechInterview.call(
      interviewer: current_user,
      tech_interview: @tech_interview
    )

    if result.success?
      redirect_to edit_tech_interview_path(@tech_interview), notice: "Interview Started. Grab #{@tech_interview.interviewee.first_name}, find a quiet spot and go through the questions. Remember to keep it to 45 to 60 minutes."
    else
      redirect_to :back, alert: result.error
    end
  end

  # interviewer decided to undo the start (return to queue)
  def stop
    result = NationalQueue::UpdateTechInterview.call(
      interviewer: current_user,
      options:  {
        type:              'cancel_interview',
        tech_interview_id: @tech_interview.id
      }
    )

    if result.success?
      redirect_to :back, notice: 'Interview stopped and pushed back into the queue'
    else
      redirect_to :back, alert: result.error
    end
  end

  def edit; end

  def update
    if @tech_interview.update(interview_params)
      redirect_to confirm_tech_interview_path(@tech_interview)
    else
      render :edit
    end
  end

  # GET (final step form)
  def confirm; end

  # PUT (final step submission)
  def complete
    result = CompleteTechInterview.call(
      params:         params,
      tech_interview: @tech_interview,
      interviewer:    current_user
    )

    if @tech_interview.save
      redirect_to @tech_interview, notice: "Interview completed. Student e-mailed with feedback."
    else
      render :edit
    end
  end

  private

  def require_template
    @interview_template = TechInterviewTemplate.find params[:tech_interview_template_id]
  end

  def require_interviewee
    @interviewee = User.find params[:interviewee_id]
  end

  def require_interview
    @tech_interview = TechInterview.find params[:id]
    @interview_template ||= @tech_interview.tech_interview_template
    @questions = @interview_template.questions.active.sequential
  end

  def only_incomplete
    redirect_to @tech_interview, alert: 'Already Completed!' if @tech_interview.completed?
  end

  def only_queued
    redirect_to :back, alert: 'No longer in the queue!' unless @tech_interview.queued?
  end

  def only_in_progress
    redirect_to @tech_interview unless @tech_interview.in_progress?
  end

  def not_for_students
    redirect_to(:tech_interview_templates) unless teacher? || admin?
  end

  def interview_params
    params.require(:tech_interview).permit(
      :feedback,
      :internal_notes,
      :articulation_score,
      :knowledge_score,
      results_attributes: [:notes, :score, :id]
    )
  end

end
