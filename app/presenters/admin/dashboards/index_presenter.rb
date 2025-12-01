# frozen_string_literal: true

module Admin
  module Dashboards
    class IndexPresenter < ApplicationPresenter
      attr_reader :current_user

      def initialize(current_user:)
        super()
        @current_user = current_user
      end

      def user_full_name
        current_user.full_name
      end

      def user_initials
        current_user.initials
      end

      def stats
        @stats ||= {
          total_users: User.count,
          active_users: User.active.count,
          blocked_users: User.blocked.count,
          admins: User.admins.count
        }
      end

      def recent_users
        @recent_users ||= User.order(created_at: :desc).limit(5)
      end

      def title
        t_context('.title')
      end

      def subtitle
        t_context('.subtitle')
      end

      def view_all_text
        t_context('.view_all')
      end

      def stats_labels
        {
          total_users: t_context('.stats.total_users'),
          active_users: t_context('.stats.active_users'),
          blocked_users: t_context('.stats.blocked_users'),
          admins: t_context('.stats.admins')
        }
      end

      def recent_users_labels
        {
          title: t_context('.recent_users.title'),
          name: t_context('.recent_users.name'),
          email: t_context('.recent_users.email'),
          status: t_context('.recent_users.status'),
          joined: t_context('.recent_users.joined'),
          active: t_context('.recent_users.active'),
          blocked: t_context('.recent_users.blocked'),
          admin: t_context('.recent_users.admin'),
          empty: t_context('.recent_users.empty')
        }
      end

      def quick_actions_labels
        {
          title: t_context('.quick_actions.title'),
          manage_users: t_context('.quick_actions.manage_users'),
          create_challenge: t_context('.quick_actions.create_challenge'),
          add_reward: t_context('.quick_actions.add_reward'),
          app_settings: t_context('.quick_actions.app_settings')
        }
      end
    end
  end
end
