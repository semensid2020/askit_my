module Admin
  class UserMailer < ApplicationMailer
    def bulk_import_done
      @user = params[:user]

      mail to: @user.email, subject: I18n.t('admin.user_mailer.bulk_import_done.subject')
    end

    def bulk_import_fail
      @error = params[:error]
      @user = params[:user]

      mail to: @user.email, subject: I18n.t('admin.user_mailer.bulk_import_fail.subject')
    end

    def bulk_export_done
      # Считываем юзера и архив из парамс
      @user = params[:user]
      zipped_blob = params[:zipped_blob]

      # Считываем содержание архива и прикрепляем к письму
      attachments[zipped_blob.attachable_filename] = zipped_blob.download
      # отправляем письмо с архивом юзеру-инициатору экспорта
      mail to: @user.email, subject: I18n.t('admin.user_mailer.bulk_export_done.subject')
    end

  end
end
