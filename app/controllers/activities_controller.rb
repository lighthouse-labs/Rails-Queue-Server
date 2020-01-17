class ActivitiesController < ApplicationController

  # must be before the course calendar inclusion now
  before_action :load_workbook, only: [:show]
  before_action :require_activity, only: [:show, :edit, :update]

  include CourseCalendar # concern
  include GithubEducationPack # concern

  before_action :teacher_required, only: [:new, :create, :edit, :update]
  before_action :check_if_day_unlocked, only: [:show]
  before_action :check_if_teacher_only, only: [:show]
  before_action :load_section, only: [:new, :edit, :update]
  before_action :load_form_url, only: [:new, :edit]

  def index
    @activities = Activity.active.order(average_rating: :desc)
    apply_filters
    @activities = @activities.page(params[:page])
  end

  def show
    # => If it evaluates code, we take multiple submissions (always a new submission)
    if @activity.evaluates_code?
      @activity_submission = ActivitySubmission.new
      @last_submission = current_user.activity_submissions.where(activity: @activity)
      @last_submission = @last_submission.where(cohort_id: current_user.cohort_id) if current_user.cohort_id? && @activity.bootcamp?
      @last_submission = @last_submission.last
    else
      @activity_submission = current_user.activity_submissions.where(activity: @activity).first || ActivitySubmission.new
    end

    @activity_feedback = @activity.activity_feedbacks.where(user: current_user).reverse_chronological_order.first

    @lectures = @activity.lectures if @activity.has_lectures?

    @number_of_active_students = cohort.students&.active.size

    ## Stolen from days#show (need to DRY) - KV
    load_day_schedule
  end

  def autocomplete
    @outcomes = (Outcome.search(params[:term]) - @activity.outcomes)
    render json: ActivityAutocompleteSerializer.new(outcomes: @outcomes).outcomes.as_json, root: false
  end

  def edit
    load_day_schedule
  end

  private

  def load_workbook
    @workbook ||= Workbook.available_to(current_user).find_by!(slug: params[:workbook_id]) if params[:workbook_id].present?
  end

  def apply_filters
    filter_by_permissions
    filter_by_stretch
    filter_by_notes
    filter_by_lectures
    filter_by_keywords
  end

  def filter_by_permissions
    @activities = @activities.until_day(current_user.curriculum_day) if active_student?
  end

  def filter_by_stretch
    params[:stretch] ||= 'Include'
    @activities = case params[:stretch]
                  when 'Exclude'
                    @activities.core
                  when 'Only'
                    @activities.stretch
                  else
                    @activities
    end
  end

  def filter_by_notes
    params[:notes] ||= 'Exclude'
    @activities = case params[:notes]
                  when 'Only'
                    @activities.where(type: 'PinnedNote')
                  when 'Exclude'
                    @activities.where.not(type: 'PinnedNote')
                  else
                    @activities
    end
  end

  def filter_by_lectures
    params[:lectures] ||= 'Exclude'
    @activities = case params[:lectures]
                  when 'Only'
                    @activities.where(type: %w[LecturePlan Breakout])
                  when 'Exclude'
                    @activities.where.not(type: %w[LecturePlan Breakout])
                  else
                    @activities
    end
  end

  def filter_by_keywords
    @activities = @activities.by_keywords(params[:keywords]) if params[:keywords].present?
  end

  def new
    @activity = Activity.new(day: params[:day_number])
    if @section
      @activity.section = @section
      @form_url = [@section, :activities]
    else
      @form_url = day_activities_path(params[:day_number])
    end
  end

  def teacher_required
    redirect_to(day_activity_path(@activity.day, @activity), alert: 'Not allowed') unless teacher?
  end

  def require_activity
    @activity = if params[:uuid].present?
                  Activity.find_by!(uuid: params[:uuid])
                else
                  Activity.find(params[:id])
                end

    # If a workbook is provided, the activity should be in there, otherwise problem.
    raise ActiveRecord::RecordNotFound if @workbook && !@workbook.item_for_activity(@activity)

    # for workbooks use their unlock_on_day b/c the activity itself may have another future date
    params[:day_number]          ||= @workbook.unlock_on_day if @workbook
    params[:day_number]          ||= @activity.day
    params[:teacher_resource_id] ||= @activity.section_id if @activity.teachers_only?
    params[:prep_id]             ||= @activity.section_id if @activity.prep?
    params[:project_id]          ||= @activity.section_id if @activity.project?
  end

  def check_if_day_unlocked
    # when viewing workbook, we don't consider the activity.day for access
    if student? && !@workbook
      redirect_to day_path('today'), alert: 'Not allowed' unless @activity.day == params[:day_number]
    end
  end

  def check_if_teacher_only
    if student? && @activity.teachers_only?
      redirect_to day_path('today'), alert: 'Students are not allowed to view teacher resoures'
    end
  end

  def load_section
    if slug = params[:prep_id]
      @section = Prep.find_by(slug: slug)
    elsif slug = params[:project_id]
      @section = Project.find_by(slug: slug)
    elsif slug = params[:teacher_resource_id] && (teacher? || admin?)
      @section = TeacherSection.find_by(slug: slug)
    end
  end

  def load_form_url
    if @activity
      load_edit_url
    else
      load_new_url
    end
  end

  def load_new_url
    @form_url = if params[:day_number]
                  day_activities_path(params[:day_number])
                else
                  [@section, :activities]
    end
  end

  def load_edit_url
    @form_url = if params[:day_number]
                  day_activity_path(params[:day_number], @activity)
                elsif @section&.is_a?(Prep)
                  prep_activity_path(@section, @activity)
      # elsif @section && @section.is_a?(Project)
      # project_activity_path <= Not yet supported - KV
    end
  end

end
