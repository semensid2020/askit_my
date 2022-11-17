class UserBulkService < ApplicationService
  # Этот сервисный объект как раз и позволит нам заводить юзеров в системе на основе Excel
  # archive - тот архив, который юзер загрузил в систему
  attr_reader :archive

  def initialize(archive_param)
    # .tempfile - позволяет получить ссылку на этот загруженный файл
    @archive = archive_param.tempfile
  end

  # Тот самый метод call, который и будет выполнять всю основную работу
  def call
    Zip::File.open(@archive) do |zip_file|
      zip_file.each do |entry|
        # Сделаем с помощью метода из гема activerecord-import:
        # ignore true - записи не будут импортированы, если для них не проходят валидации
        User.import(users_from(entry), ignore: true)
      end
    end
  end

  private

  def users_from(entry)
    # Метод get_input_stream - берется из Zip::File
    sheet = RubyXL::Parser.parse_buffer(entry.get_input_stream.read)[0]
    sheet.map do |row|
      cells = row.cells
      # Пока просто создаем юзеров, не помещая их в БД
      User.new(name: cells[0].value.to_s,
               email: cells[1].value.to_s,
               password: cells[2].value.to_s,
               password_confirmation: cells[2].value.to_s )
    end
  end

end
