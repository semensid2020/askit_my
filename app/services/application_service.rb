# frozen_string_literal: true

class ApplicationService
  # Метод self.call инстанцирует указанный класс, и потом вызывает то действие,
  # которое этот класс должен делать.
  def self.call(...)
    # Хз что это за новый синтаксис с многоточием
    new(...).call
  end
end
