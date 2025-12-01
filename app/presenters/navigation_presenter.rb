# frozen_string_literal: true

class NavigationPresenter < ApplicationPresenter
  NavigationSection = Struct.new(:title, :items)
  NavigationItem = Struct.new(:title, :icon, :url, :active?)

  def initialize(view_context:, controller_path:, user:)
    super()
    @view_context = view_context
    @controller_path = controller_path
    @user = user
  end

  def navigation_sections
    sections.map do |section, section_items|
      section_name = section ? t_context(".sections.#{section}.title") : nil
      NavigationSection.new(section_name, section_items)
    end
  end

  private

  def sections
    data_for_sections.reduce({}) do |result, (section, items)|
      visible_items = items.compact
      visible_items.present? ? result.merge(section => visible_items) : result
    end
  end

  def data_for_sections
    {
      nil => general_nav_items,
      :administration => administration_nav_items,
      :configuration => configuration_nav_items
    }
  end

  def general_nav_items
    [
      home_nav_item,
      trips_nav_item
    ]
  end

  def administration_nav_items
    [
      users_nav_item
    ]
  end

  def configuration_nav_items
    [
      settings_nav_item
    ]
  end

  def home_nav_item
    build_nav_item(
      icon: "home",
      path: @view_context.root_path,
      section: "home",
      matcher: /\Ahome/
    )
  end

  def trips_nav_item
    return unless @view_context.respond_to?(:trips_path)

    build_nav_item(
      icon: "map",
      path: @view_context.trips_path,
      section: "trips",
      matcher: /\Atrips/
    )
  end

  def users_nav_item
    return unless @view_context.respond_to?(:administration_users_path)

    build_nav_item(
      icon: "users",
      path: @view_context.administration_users_path,
      section: "administration/users",
      matcher: %r{\Aadministration/users}
    )
  end

  def settings_nav_item
    return unless @view_context.respond_to?(:configuration_settings_path)

    build_nav_item(
      icon: "settings",
      path: @view_context.configuration_settings_path,
      section: "configuration/settings",
      matcher: %r{\Aconfigurations/settings}
    )
  end

  def build_nav_item(icon:, path:, section:, matcher:)
    title = t_context(".sections.#{section}.title")
    NavigationItem.new(title, icon, path, @controller_path.match?(matcher))
  end
end
