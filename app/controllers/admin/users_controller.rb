# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    before_action :require_authentication
    before_action :set_user, only: %i[edit update]

    def index
      respond_to do |format|
        format.html do
          @pagy, @users = pagy(User.order(created_at: :desc))
        end

        format.zip { respond_with_zipped_users }
      end
    end

    def create
      # Открываем Zip-архив, вытаскиваем из него файлы и обрабатываем их (создаем юзеров)
      if params[:archive].present?
        UserBulkService.call(params[:archive])
        flash.now[:success] = t('.success')
      end

      redirect_to admin_users_path
    end

    def edit
    end

    def update
      if @user.update(user_params)
        flash[:success] = t('.success')
        redirect_to admin_users_path
      else
        render :edit
      end
    end

    private

    # rubocop:disable Metrics/MethodLength
    def respond_with_zipped_users
      # Создаем объект OutputStream, это фактически архив, который мы будем пересылать юзеру на его запрос
      # при этом, архив этот у нас на диске нигде не хранится (т.е. он "временный")
      compressed_filestream = Zip::OutputStream.write_buffer do |zos|
        User.order(created_at: :desc).each do |user|
          zos.put_next_entry("user_#{user.id}.xlsx")
          # Делаем рендер строки "просто в память", записывая её в файл
          zos.print(render_to_string(
                      layout: false, handlers: [:axlsx], formats: [:xlsx],
                      template: 'admin/users/user',
                      locals: { user: user }
                    ))
        end
      end
      # rubocop:enable Metrics/MethodLength

      # Нужно "перемотать в начало файла (?)"
      compressed_filestream.rewind
      send_data(compressed_filestream.read, filename: 'users.zip')
    end

    def set_user!
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :name, :password, :password_confirmation)
    end

  end
end
