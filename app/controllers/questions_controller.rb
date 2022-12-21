# frozen_string_literal: true

class QuestionsController < ApplicationController
  include QuestionsAnswers
  before_action :require_authentication, except: %i[show index]
  before_action :set_question!, only: %i[show destroy edit update]
  before_action :authorize_question!
  after_action :verify_authorized

  def index
    # Загружаем не только все вопросы, но и для каждого вопроса сразу подгрузить юзеров. Иначе n+1
    @tags = Tag.where(id: params[:tag_ids]) if params[:tag_ids]
    @pagy, @questions = pagy(Question.all_by_tags(@tags))

    @questions = @questions.decorate
    @tags = Tag.all
  end

  def show
    load_question_answers
  end

  def new
    @question = Question.new
  end

  def edit; end

  def create
    @question = current_user.questions.build(question_params)
    if @question.save
      # Уведомление, отображаемое один раз (до перезагрузки страницы):
      flash[:success] = t('.success')
      redirect_to questions_path
    else
      render :new
    end
  end

  def update
    if @question.update(question_params)
      flash[:success] = t('.success')
      redirect_to questions_path
    else
      render :edit
    end
  end

  def destroy
    @question.destroy
    flash[:success] = t('.success')
    redirect_to questions_path
  end

  private

  def question_params
    params.require(:question).permit(:title, :body, tag_ids: [])
  end

  def set_question!
    @question = Question.find(params[:id])
  end

  def authorize_question!
    # На случай если вопроса нет вовсе передаем тупо модель:
    authorize(@question || Question)
    # Сам же метод authorize - доступен из Pundit
  end
end
