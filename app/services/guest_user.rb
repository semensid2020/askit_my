# frozen_string_literal: true

class GuestUser
  def guest?
    true
  end

  def author?(_)
    # Гость не является автором ни одного вопроса, ответа...
    false
  end

  # Метод, который вызывается автоматически если относительно образца класса был
  # вызван несуществующий метод (см. плейлист Метапрограммирование на YT-канале)
  def method_missing(name, *args, &block)
    # Пытаемся считать роль этого пользователя. Для гостя вернётся false, т.к. нет никакой роли
    return false if name.to_s.end_with?('_role?')

    super(name, *args, &block)
  end

  # Похоже, что это метод, обратный def method_missing
  def respond_to_missing?(name, include_private)
    return true if name.to_s.end_with?('_role?')

    super(name, include_private)
  end
end
