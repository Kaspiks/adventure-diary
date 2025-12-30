# frozen_string_literal: true

module Admin
  class NavigationPresenter < ApplicationPresenter
    NavigationSection = Struct.new(:title, :items)
    NavigationItem = Struct.new(:title, :icon, :url, :active?)

    def initialize(view_context:, controller_name:, user:)
      super()
      @view_context = view_context
      @controller_name = controller_name
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
        :configuration => configuration_nav_items
      }
    end

    def general_nav_items
      [
        dashboard_nav_item,
        users_nav_item,
        roles_nav_item,
        challenges_nav_item,
        rewards_nav_item,
        orders_nav_item
      ]
    end

    def configuration_nav_items
      [
        classification_items_nav_item,
        settings_nav_item
      ]
    end

    def dashboard_nav_item
      NavigationItem.new(
        t_context(".items.dashboard"),
        "home",
        @view_context.admin_root_path,
        @controller_name == "dashboard"
      )
    end

    def users_nav_item
      NavigationItem.new(
        t_context(".items.users"),
        "users",
        @view_context.admin_users_path,
        @controller_name == "users"
      )
    end

    def roles_nav_item
      NavigationItem.new(
        t_context(".items.roles"),
        "lock",
        @view_context.admin_roles_path,
        @controller_name == "roles"
      )
    end

    def challenges_nav_item
      NavigationItem.new(
        t_context(".items.challenges"),
        "target",
        @view_context.admin_challenges_path,
        @controller_name == "challenges"
      )
    end

    def rewards_nav_item
      NavigationItem.new(
        t_context(".items.rewards"),
        "gift",
        @view_context.admin_rewards_path,
        @controller_name == "rewards"
      )
    end

    def orders_nav_item
      NavigationItem.new(
        t_context(".items.orders"),
        "shopping-cart",
        @view_context.admin_orders_path,
        @controller_name == "orders"
      )
    end

    def classification_items_nav_item
      return unless Admin::ClassificationItemPolicy.new(@user, nil).index?

      NavigationItem.new(
          t_context(".items.classification_items"),
          "category",
          @view_context.admin_classification_items_path,
          @controller_name == "classification_items"
      )
    end

    def settings_nav_item
      NavigationItem.new(
        t_context(".items.settings"),
        "settings",
        @view_context.admin_settings_path,
        @controller_name == "settings"
      )
    end
  end
end

