# frozen_string_literal: true

class UserBulkExportService < ApplicationService

  def call
    # Создаем объект OutputStream, это фактически архив, который мы будем пересылать юзеру на его запрос
    # при этом, архив этот у нас на диске нигде не хранится (т.е. он "временный")
    compressed_filestream = output_stream

    # Нужно "перемотать в начало файла (?)"
    compressed_filestream.rewind
    compressed_filestream
  end

  private

  def output_stream
    renderer = ActionController::Base.new

    Zip::OutputStream.write_buffer do |zos|
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
  end
end
