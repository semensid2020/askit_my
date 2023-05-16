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

        format.zip do
          UserBulkExportJob.perform_later(current_user)
          flash[:success] = t('.success')
          redirect_to admin_users_path
        end

      end
    end

    def create
      # Открываем Zip-архив, вытаскиваем из него файлы и обрабатываем их (создаем юзеров)
      if params[:archive].present?
        # Ставим задачу с этой джобой в очередь (perform_later):
        # Ниже current_user - тот, кто инициирует джобу. В дальнейшем будем получать email
        UserBulkImportJob.perform_later(create_blob, current_user)
        flash[:success] = t('.success')
        # flash.now[:success] = t('.success')  # Пришлось убрать здесь .now, иначе не вылетает попап
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
