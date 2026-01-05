# frozen_string_literal: true

module Home
  class IndexPresenter < ApplicationPresenter
    attr_reader :current_user, :view_context

    def initialize(current_user:, view_context:)
      super()
      @current_user = current_user
      @view_context = view_context
    end

    def quick_actions
      navigation_presenter.quick_actions
    end

    def admin_quick_actions
      navigation_presenter.admin_quick_actions
    end

    private def navigation_presenter
      @navigation_presenter ||= NavigationPresenter.new(
        view_context: view_context,
        current_user: current_user
      )
    end

    def user_first_name
      current_user.first_name.presence || current_user.email.split("@").first
    end

    def user_initials
      current_user.initials
    end

    def admin?
      current_user.admin? || current_user.administrator? || current_user.company_user?
    end

    def stats
      @stats ||= {
        points: current_user.reward_points,
        challenges_active: user_active_attempts.count,
        challenges_completed: user_completed_attempts.count,
        rewards_claimed: rewards_claimed
      }
    end

    def active_challenges
      @active_challenges ||= begin
        challenge_ids = Challenge
          .active
          .joins(:challenge_attempts)
          .merge(ChallengeAttempt.for_user(current_user).non_final)
          .select("challenges.id")
          .distinct
          .limit(5)

        Challenge
          .where(id: challenge_ids)
          .includes(:challenge_type, :difficulty_level, :award_point_level, :location)
          .ordered
      end
    end

    def recent_activity
      @recent_activity ||= current_user.challenge_attempts
                                        .includes(:challenge, :attempt_status)
                                        .ordered
                                        .limit(5)
    end

    def leaderboard
      @leaderboard ||= User.where("reward_points > 0")
                           .order(reward_points: :desc)
                           .limit(5)
    end

    def app_name
      t_context(".app_name")
    end

    def welcome_text
      t_context(".welcome")
    end

    def sign_out_text
      t_context(".sign_out")
    end

    def view_all_text
      t_context(".view_all")
    end

    def stats_labels
      {
        points: t_context(".stats.points"),
        active: t_context(".stats.active_challenges"),
        completed: t_context(".stats.completed"),
        rewards: t_context(".stats.rewards_claimed")
      }
    end

    def section_titles
      {
        active_challenges: t_context(".sections.active_challenges"),
        recent_activity: t_context(".sections.recent_activity"),
        quick_actions: t_context(".sections.quick_actions"),
        leaderboard: t_context(".sections.leaderboard")
      }
    end

    def empty_state_messages
      {
        no_challenges: t_context(".empty.no_active_challenges"),
        browse_challenges: t_context(".empty.browse_challenges"),
        no_activity: t_context(".empty.no_activity"),
        no_leaderboard: t_context(".empty.no_leaderboard")
      }
    end

    private

    def user_active_attempts
      current_user.challenge_attempts.non_final
    end

    def user_completed_attempts
      current_user.challenge_attempts.joins(:attempt_status).where(attempt_statuses: { code: "approved" })
    end

    def rewards_claimed
      current_user.orders.joins(:order_status).where(order_status: { code: "delivered" }).count
    end
  end
end
