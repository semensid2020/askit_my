class ApplicationService
  # Метод self.call инстанцирует указанный класс, и потом вызывает то действие,
  # которое этот класс должен делать.
  def self.call(*args, &block)
    new(*args, &block).call
  end
end
