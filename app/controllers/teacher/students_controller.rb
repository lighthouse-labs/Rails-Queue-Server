class Teacher::StudentsController < Teacher::BaseController

  before_action :load_student, only: [:show]

  DEFAULT_PER = 10

  def index; end

  def show
    @projects = Project.all
    @evaluations = @student.evaluations
    @assistances = @student.assistances.order(created_at: :desc).page(params[:page]).per(DEFAULT_PER)
  end

  private

  def load_student
    @student = Student.find(params[:id])
  end

end
