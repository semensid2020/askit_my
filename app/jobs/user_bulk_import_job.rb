# frozen_string_literal: true

class UserBulkImportJob < ApplicationJob
  queue_as :default

  def perform(archive_key, initiator)
    UserBulkImportService.call(archive_key)
  rescue StandardError => e
    # deliver_now, т.к. мы сейчас итак уже в бэкграунде, и говорить deliver_later смысле нет
    Admin::UserMailer.with(user: initiator, error: e).bulk_import_fail.deliver_now
  else
    #  в else попадаем если на стр. 7 ошибки наоборот НЕ БЫЛО
    Admin::UserMailer.with(user: initiator).bulk_import_done.deliver_now
  end
end
