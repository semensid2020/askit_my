# frozen_string_literal: true

class CommentDecorator < ApplicationDecorator
  delegate_all
  decorates_association :user

  def for?(commentable)
    # Если штука была задекорирована, то нужно вытащить из неё конкретный объект,
    # т.е. конкретный образец класса
    commentable = commentable.object if commentable.decorated?
    # Какая-то хитрая строка ^^^ . Разобраться...
    commentable == self.commentable
    # self в данном случае указывает на конкретный комментарий, и по связи commentable мы смотрим,
    #  для чего конкретно комментарий был оставлен
  end
end
