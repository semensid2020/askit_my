# frozen_string_literal: true

module QuestionsAnswers
  extend ActiveSupport::Concern

  included do
    # do_render - по умолчанию false!
    def load_question_answers(do_render: false)
      @question = @question.decorate
      @answer ||= @question.answers.build
      @pagy, @answers = pagy(@question.answers.order(created_at: :desc))
      @answers = @answers.decorate
      render('questions/show') if do_render
    end
  end
end
