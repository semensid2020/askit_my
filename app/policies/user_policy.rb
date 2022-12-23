# frozen_string_literal: true

class UserPolicy < ApplicationPolicy

  def create?
    # Создать пользователя = зарегистрироваться. Это могут только гости.
    user.guest?
  end

  def update?
    # Менять данные о юзере может сам юзер
    record == user
  end

  def index?
    # В данном случае - никто, т.к. здесь мы говорим о только о users_controller,
    # а не об админском users_controller'е
    false
  end

  def show?
    # Конкретного юзера пусть кто угодно может просматривать, почему нет.
    true
  end

  def destroy?
    # На данном этапе из НЕадминского контроллера пусть никто не может свою учетку удалить.
    false
  end
end
