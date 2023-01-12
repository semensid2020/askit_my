# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    before_action :require_authentication
    before_action :set_user!, only: %i[edit update destroy]
    before_action :authorize_user!
    after_action :verify_authorized

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
        # Ставим задачу с этой джобой в очередь (perform_later):
        # Ниже current_user - тот, кто инициирует джобу. В дальнейшем будем получать email
        UserBulkImportJob.perform_later(create_blob, current_user)
        flash.now[:success] = t('.success')
      end

      redirect_to admin_users_path
    end

    def edit; end

    def update
      if @user.update(user_params)
        flash[:success] = t('.success')
        redirect_to admin_users_path
      else
        render :edit
      end
    end

    def destroy
      @user.destroy
      flash[:success] = t('.success')
      redirect_to admin_users_path
    end

    private

    def create_blob
      file = File.open(params[:archive])
      result = ActiveStorage::Blob.create_and_upload!(io: file,
                                                      filename: params[:archive].original_filename)
      file.close
      # key - уникальный id загруженного в ActiveStorage файла, хранится в одной из таблиц
      result.key
    end

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
      params.require(:user).permit(
        :email, :name, :password, :password_confirmation, :role
      ).merge(admin_edit: true)
    end

    def authorize_user!
      authorize(@user || User)
    end
  end
end
