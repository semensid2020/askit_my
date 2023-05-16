# frozen_string_literal: true

class UserBulkExportJob < ApplicationJob
  queue_as :default

  def perform(initiator)
    # Эта строка (вызов сервиса) возвращает объект ActiveStorage (наш архив с юзерами)
    zipped_blob = UserBulkExportService.call

    # Теперь, когда архив сгенерирован, хотим его отправить пользователю
    Admin::UserMailer.with(user: initiator, zipped_blob: zipped_blob).bulk_export_done.deliver_now
  ensure
    # Удаляем архив
    zipped_blob.purge
  end
end
