class ProjectsController < ApplicationController
  before_action :find_project, only: [:show, :edit, :update]
  def index
    @projects = Project.all
  end
  def show
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to action: :index, notice: "#{@project.name} created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project
    else
      render :new
    end
  end

  private

  def find_project
    @project = Project.find_by(slug: params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end
end
