# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    def authorize(record, query = nil)
      # этот метод будет вызывать родительский метод, но также дописывать вот такую штуку :admin
      # :admin - это как раз то пространство имен, где лежит наша политика.
      super([:admin, record], query)
    end
  end
end
