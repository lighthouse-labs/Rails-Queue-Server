class Admin::OutcomesController < Admin::BaseController

  before_action :load_outcome, except: [:index, :new, :create]

  def index
    @outcomes = Outcome
    @outcomes = @outcomes.search params[:outcome_text] if params[:outcome_text].present?
    @outcomes = @outcomes.search params[:term] if params[:term].present?
    respond_to do |format|
      format.html
      format.js { render json: @outcomes, root: false }
    end
  end

  def update
    @outcome.update(outcome_params)
    redirect_to :back
  end

  private

  def load_outcome
    @outcome = Outcome.find(params[:id])
  end

  def outcome_params
    params.require(:outcome).permit(
      :text,
      item_outcomes_attributes: [
        :id, :item_type, :item_id, :_destroy
      ]
    )
  end

  def build_error_messages(outcome)
    errors = []
    errors << 'Outcome text is already taken' unless outcome.errors[:text].empty?
    skill_errors = outcome.skills.reject(&:valid?)
    unless skill_errors.empty?
      skill_errors.each do |skill|
        errors << "Skill '#{skill.text}' is already assigned to another outcome"
      end
    end
    errors
  end

end
