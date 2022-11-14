# frozen_string_literal: true

# Заметка:
# Всякие rescue_from лучше убирать в отдельные модули, которые в RoR называются concerns

module ErrorHandling
  extend ActiveSupport::Concern

  # Добавляет весь функционал ниже в класс, куда подключен этот модуль (консёрн)
  included do
    rescue_from ActiveRecord::RecordNotFound, with: :notfound

    private

    def notfound(exception)
      # Заметка:
      # Записывает возникшую ошибку в журнал ошибок Rails:
      logger.warn(exception)

      render file: 'public/404.html', status: :not_found, layout: false
    end
  end
end
