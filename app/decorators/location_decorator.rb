# frozen_string_literal: true

class LocationDecorator < ApplicationDecorator
  def collection_title
    title.to_s
  end

  def title
    name
  end

  def title_with_state
    TitlePresenter.new(self, attribute: :title).title_with_state
  end
end
