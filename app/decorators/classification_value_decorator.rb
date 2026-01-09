# frozen_string_literal: true

class ClassificationValueDecorator < ApplicationDecorator
  delegate :value, :active, :classification, :classification_id, :created_at, :updated_at, to: :object

  def title
    value
  end

  def title_with_state
    TitlePresenter.new(self, attribute: :title).title_with_state
  end

  def classification_title
    classification.code.titleize.tr("_", " ")
  end

  def active?
    active
  end

  def status_badge
    active? ? "Active" : "Inactive"
  end

  def status_color
    active? ? "emerald" : "slate"
  end
end

