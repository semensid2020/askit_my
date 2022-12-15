module Api
  class TagsController < ApplicationController
    def index
      # AREL - это такая штука, котор. позволяет писать более сложные SQL-запросы на руби
      tags = Tag.arel_table
      # Находим заголовок(вки), в которых содержится передаваемое из формочки вводимое слово
      @tags = Tag.where(tags[:title].matches("%#{params[:term]}%"))

      # Метод index отвечает только в формате JSON!
      respond_to do |format|
        format.json
      end
    end
  end
end
