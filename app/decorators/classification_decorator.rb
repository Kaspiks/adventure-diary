# frozen_string_literal: true

class ClassificationDecorator < ApplicationDecorator
  delegate :code, :system, :created_at, :updated_at, :classification_values, to: :object

  def title
    code.titleize.tr("_", " ")
  end

  def values_count
    classification_values.count
  end

  def active_values_count
    classification_values.active.count
  end

  def system_badge
    system ? "System" : "Custom"
  end

  def system?
    system
  end
end


