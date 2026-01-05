# frozen_string_literal: true

class NavigationPresenter < ApplicationPresenter
  QuickAction = Struct.new(:title, :icon, :url, :color, :description, keyword_init: true) do
    def icon_color_class
      case color
      when "emerald" then "text-emerald-400"
      when "blue" then "text-blue-400"
      when "amber" then "text-amber-400"
      when "cyan" then "text-cyan-400"
      when "purple" then "text-purple-400"
      when "rose" then "text-rose-400"
      when "orange" then "text-orange-400"
      when "yellow" then "text-yellow-400"
      else "text-slate-400"
      end
    end

    def bg_color_class
      case color
      when "emerald" then "bg-emerald-500/20"
      when "blue" then "bg-blue-500/20"
      when "amber" then "bg-amber-500/20"
      when "cyan" then "bg-cyan-500/20"
      when "purple" then "bg-purple-500/20"
      when "rose" then "bg-rose-500/20"
      when "orange" then "bg-orange-500/20"
      when "yellow" then "bg-yellow-500/20"
      else "bg-slate-500/20"
      end
    end
  end

  def initialize(view_context:, current_user:)
    super()
    @view_context = view_context
    @current_user = current_user
  end

  def quick_actions
    actions = []
    actions << find_challenges_action
    actions << my_attempts_action if @current_user.challenge_attempts.any?
    actions << rewards_catalog_action
    actions << my_profile_action
    actions << my_orders_action if @current_user.orders.any?
    actions.compact
  end

  def admin_quick_actions
    return [] unless admin_user?

    [
      admin_dashboard_action,
      manage_challenges_action,
      review_attempts_action
    ].compact
  end

  private

  def admin_user?
    @current_user.admin? || @current_user.administrator? || @current_user.company_user?
  end

  def find_challenges_action
    QuickAction.new(
      title: I18n.t("navigation.quick_actions.find_challenges", default: "Find Challenges"),
      icon: "map-pin",
      url: @view_context.challenges_path,
      color: "emerald",
      description: I18n.t("navigation.quick_actions.find_challenges_desc", default: "Discover new adventures")
    )
  end

  def my_attempts_action
    QuickAction.new(
      title: I18n.t("navigation.quick_actions.my_attempts", default: "My Attempts"),
      icon: "activity",
      url: @view_context.my_attempts_path,
      color: "blue",
      description: I18n.t("navigation.quick_actions.my_attempts_desc", default: "View your progress")
    )
  end

  def rewards_catalog_action
    QuickAction.new(
      title: I18n.t("navigation.quick_actions.rewards_catalog", default: "Rewards Catalog"),
      icon: "gift",
      url: @view_context.rewards_path,
      color: "amber",
      description: I18n.t("navigation.quick_actions.rewards_catalog_desc", default: "Spend your points")
    )
  end

  def my_profile_action
    QuickAction.new(
      title: I18n.t("navigation.quick_actions.my_profile", default: "My Profile"),
      icon: "user",
      url: @view_context.profile_path,
      color: "cyan",
      description: I18n.t("navigation.quick_actions.my_profile_desc", default: "View your stats")
    )
  end

  def my_orders_action
    QuickAction.new(
      title: I18n.t("navigation.quick_actions.my_orders", default: "My Orders"),
      icon: "package",
      url: @view_context.orders_path,
      color: "purple",
      description: I18n.t("navigation.quick_actions.my_orders_desc", default: "Track your rewards")
    )
  end

  def admin_dashboard_action
    QuickAction.new(
      title: I18n.t("navigation.quick_actions.admin_dashboard", default: "Admin Dashboard"),
      icon: "category",
      url: @view_context.admin_root_path,
      color: "rose",
      description: I18n.t("navigation.quick_actions.admin_dashboard_desc", default: "Manage the app")
    )
  end

  def manage_challenges_action
    QuickAction.new(
      title: I18n.t("navigation.quick_actions.manage_challenges", default: "Manage Challenges"),
      icon: "settings",
      url: @view_context.admin_challenges_path,
      color: "orange",
      description: I18n.t("navigation.quick_actions.manage_challenges_desc", default: "Create and edit challenges")
    )
  end

  def review_attempts_action
    pending_count = ChallengeAttempt.pending_review.count
    return nil if pending_count.zero?

    QuickAction.new(
      title: I18n.t("navigation.quick_actions.review_attempts", default: "Review Attempts"),
      icon: "check",
      url: @view_context.admin_attempts_path,
      color: "yellow",
      description: I18n.t("navigation.quick_actions.review_attempts_desc", count: pending_count, default: "%{count} pending review")
    )
  end
end
