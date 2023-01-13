# frozen_string_literal: true

class UserBulkImportService < ApplicationService
  # Этот сервисный объект как раз и позволит нам заводить юзеров в системе на основе Excel
  # archive - тот архив, который юзер загрузил в систему
  attr_reader :archive_key, :service

  # rubocop:disable Lint/MissingSuper
  def initialize(archive_key)
    @archive_key = archive_key
    @service = ActiveStorage::Blob.service
  end
  # rubocop:enable Lint/MissingSuper

  # Тот самый метод call, который и будет выполнять всю основную работу
  def call
    read_zip_entries do |entry|
      entry.get_input_stream do |f|
        # Сделаем с помощью метода из гема activerecord-import:
        # ignore true - записи не будут импортированы, если для них не проходят валидации
        User.import(users_from(f.read), ignore: true)
        f.close
      end
    end
  # Убеждаемся, что мы удаляем архив с которым работали, после того, как мы с ним закончили
  # т.е. удаляется файл из ActiveStore, имеющий уникальный ключ archive_key
  ensure
    service.delete(archive_key)
  end

  private

  def read_zip_entries
    return unless block_given?

    # Речь о "потоке" данных из файла:
    stream = zip_stream
    #  Делаем "бесконечный" цикл, который берет каждый следующий файл из архива
    # потому что мы не знаем сколько там файлов, т.к. делаем стриминг.
    loop do
      # Вообще, можно было бы сделать так, чтобы число итераций было не бесконечным, а все-таки как-то ограничивалось
      entry = stream.get_next_entry

      #  Выходим из бесконечного цикла, если записей (файлов) больше нету
      break unless entry
      # Также мы переходим к следующей итерации (видимо следующему файлу), если имя некорректное
      next unless entry.name.end_with?('.xlsx')

      # Передаем entry в метод def call (на строчку 17)
      yield entry
    end
  # Обязательно закрываем поток:
  ensure
    stream.close
  end

  # Метод, который будет выполнять стриминг загруженного zip-файла
  def zip_stream
    # Получаем путь для загруженного файла по его ID
    f = File.open(service.path_for(archive_key))
    stream = Zip::InputStream.new(f)
    f.close
    stream
  end

  def users_from(data)
    # Метод get_input_stream - берется из Zip::File
    sheet = RubyXL::Parser.parse_buffer(data)[0]
    sheet.map do |row|
      cells = row.cells[0..2].map { |c| c&.value.to_s }
      # Пока просто создаем юзеров, не помещая их в БД
      User.new(name: cells[0],
               email: cells[1],
               password: cells[2],
               password_confirmation: cells[2])
    end
  end
end
