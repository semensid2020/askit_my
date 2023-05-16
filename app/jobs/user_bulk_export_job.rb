# frozen_string_literal: true

class UserBulkExportJob < ApplicationJob
  queue_as :default

  def perform(initiator)
    # Эта строка (вызов сервиса) возвращает объект ActiveStorage (наш архив с юзерами)
    stream = UserBulkExportService.call

    # Теперь, когда архив сгенерирован, хотим его отправить пользователю
    Admin::UserMailer.with(user: initiator, stream: stream).bulk_export_done.deliver_now
  end
end
