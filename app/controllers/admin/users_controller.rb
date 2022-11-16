# frozen_string_literal: true

class Admin::UsersController < ApplicationController
  before_action :require_authentication

  def index
    @pagy, @users = pagy(User.order(created_at: :desc))
  end

end
