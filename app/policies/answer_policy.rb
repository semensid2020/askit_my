# frozen_string_literal: true

class AnswerPolicy < ApplicationPolicy

  def create?
    !user.guest?
  end

  def update?
    user.admin_role? || user.moderator_role? || user.author?(record)
  end

  def destroy?
    user.admin_role? || user.author?(record)
  end

  def index?
    true
  end

  # По идее на данном этапе не имеет смысла писать для show, т.к. открыть ответ для просмотра нельзя.
  # но на всякий случай лучше оставить - на будущее.
  def show?
    true
  end
end
