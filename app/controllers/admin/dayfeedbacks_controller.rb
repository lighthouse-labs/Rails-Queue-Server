class Admin::DayfeedbacksController < Admin::BaseController

  FILTER_BY_OPTIONS = [:mood, :day, :location_id, :archived?, :start_date, :end_date].freeze
  DEFAULT_PER = 20

  before_action :load_dayfeedback, only: [:archive, :unarchive]

  def index
    @dayfeedbacks = DayFeedback.filter_by(filter_by_params)

    # => A location wasn't provided, use the current_user's location as the default
    if params[:location_id].nil?
      @dayfeedbacks = @dayfeedbacks.filter_by_location(current_user.location.id)
    end
    
    @paginated_dayfeedbacks = @dayfeedbacks.reverse_chronological_order
      .page(params[:page])
      .per(DEFAULT_PER)
  end

  def archive
    @dayfeedback.archive(current_user)
    if @dayfeedback.save
      render nothing: true
    end
  end

  def unarchive
    @dayfeedback.unarchive
    if @dayfeedback.save
      render nothing: true
    end      
  end

  private

  def filter_by_params
    params.slice(*FILTER_BY_OPTIONS).select { |k,v| v.present? }
  end

  def load_dayfeedback
    @dayfeedback = DayFeedback.find(params[:id])
  end

end