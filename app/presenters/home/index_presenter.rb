# frozen_string_literal: true

module Home
  class IndexPresenter < ApplicationPresenter
    attr_reader :current_user

    def initialize(current_user:)
      super()
      @current_user = current_user
    end

    def user_first_name
      current_user.first_name.presence || current_user.email.split('@').first
    end

    def user_initials
      current_user.initials
    end

    def admin?
      current_user.admin?
    end

    def stats
      @stats ||= {
        points: 0,
        challenges_active: 0,
        challenges_completed: 0,
        rewards_claimed: 0
      }
    end

    def active_challenges
      []
    end

    def recent_activity
      []
    end

    def leaderboard
      []
    end

    def app_name
      t_context('.app_name')
    end

    def welcome_text
      t_context('.welcome')
    end

    def sign_out_text
      t_context('.sign_out')
    end

    def view_all_text
      t_context('.view_all')
    end

    def stats_labels
      {
        points: t_context('.stats.points'),
        active: t_context('.stats.active_challenges'),
        completed: t_context('.stats.completed'),
        rewards: t_context('.stats.rewards_claimed')
      }
    end

    def section_titles
      {
        active_challenges: t_context('.sections.active_challenges'),
        recent_activity: t_context('.sections.recent_activity'),
        quick_actions: t_context('.sections.quick_actions'),
        leaderboard: t_context('.sections.leaderboard')
      }
    end

    def action_labels
      {
        find_challenges: t_context('.actions.find_challenges'),
        rewards_catalog: t_context('.actions.rewards_catalog'),
        my_profile: t_context('.actions.my_profile')
      }
    end

    def empty_state_messages
      {
        no_challenges: t_context('.empty.no_active_challenges'),
        browse_challenges: t_context('.empty.browse_challenges'),
        no_activity: t_context('.empty.no_activity'),
        no_leaderboard: t_context('.empty.no_leaderboard')
      }
    end
  end
end
