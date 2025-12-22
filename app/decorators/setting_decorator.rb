# frozen_string_literal: true

class SettingDecorator < ApplicationDecorator
  delegate :id, :key, :value, :value_type, :group, :description, :rich_text?, :boolean?, :multiline?, :created_at, :updated_at, to: :object

  def display_key
    key.titleize.gsub("_", " ")
  end

  def display_value
    return "Yes" if boolean? && object.typed_value == true
    return "No" if boolean? && object.typed_value == false
    return "(not set)" if value.blank?

    if rich_text?
      stripped = ActionController::Base.helpers.strip_tags(value)
      cleaned = stripped.gsub(/&nbsp;/i, " ")
      decoded = CGI.unescapeHTML(cleaned)
      normalized = decoded.gsub(/[\u00A0\s]+/, " ").strip
      normalized.truncate(100)
    elsif multiline?
      value.truncate(100)
    else
      value
    end
  end

  def group_badge_class
    case group
    when "general" then "bg-blue-500/20 text-blue-200 border-blue-500/30"
    when "appearance" then "bg-purple-500/20 text-purple-200 border-purple-500/30"
    when "content" then "bg-emerald-500/20 text-emerald-200 border-emerald-500/30"
    when "notifications" then "bg-amber-500/20 text-amber-200 border-amber-500/30"
    else "bg-slate-500/20 text-slate-200 border-slate-500/30"
    end
  end

  def type_label
    value_type.titleize
  end
end
