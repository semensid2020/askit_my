# frozen_string_literal: true

class UserBulkExportService < ApplicationService

  # rubocop:disable Metrics/MethodLength
  def call
    renderer = ActionController::Base.new

    # Создаем объект OutputStream, это фактически архив, который мы будем пересылать юзеру на его запрос
    # при этом, архив этот у нас на диске нигде не хранится (т.е. он "временный")
    compressed_filestream = Zip::OutputStream.write_buffer do |zos|
      User.order(created_at: :desc).each do |user|
        zos.put_next_entry("user_#{user.id}.xlsx")
        # Делаем рендер строки "просто в память", записывая её в файл
        zos.print(renderer.render_to_string(
                    layout: false, handlers: [:axlsx], formats: [:xlsx],
                    template: 'admin/users/user',
                    locals: { user: user }
                  ))
      end
    end
    # rubocop:enable Metrics/MethodLength

    # Нужно "перемотать в начало файла (?)"
    compressed_filestream.rewind
    ActiveStorage::Blob.create_and_upload!(io: compressed_filestream,
                                           filename: 'users.zip')
  end

end
