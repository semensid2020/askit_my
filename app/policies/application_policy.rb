# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    # Если пользователь в систему не вошел, то создаем Гостевого Юзера
    @user = user || GuestUser.new
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      # raise NotImplementedError, "You must define #resolve in #{self.class}"
      scope.all
    end

    private

    attr_reader :user, :scope
  end
end
