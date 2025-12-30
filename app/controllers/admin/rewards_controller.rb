# frozen_string_literal: true

module Admin
  class RewardsController < BaseController
    before_action :set_reward, only: [:show, :edit, :update, :destroy, :orders]

    def index
      @presenter = build_index_presenter
    end

    def show
      authorize @reward
      @presenter = Admin::Rewards::ShowPresenter.new(reward: @reward)
    end

    def new
      reward = Reward.new
      form = build_form(reward)
      @presenter = FormPresenter.new(form: form)
    end

    def create
      reward = Reward.new(owner_user: current_user)
      form = build_form(reward)

      if form.create(create_params)
        redirect_to admin_reward_path(reward), notice: t(".success")
      else
        @presenter = FormPresenter.new(form: form)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @reward
      form = build_form(@reward)
      @presenter = FormPresenter.new(form: form)
    end

    def update
      authorize @reward
      form = build_form(@reward)

      if form.update(update_params)
        redirect_to admin_reward_path(@reward), notice: t(".success")
      else
        @presenter = FormPresenter.new(form: form)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @reward
      @reward.destroy
      redirect_to admin_rewards_path, notice: t(".success")
    end

    def orders
      authorize @reward, :manage_orders?
      @presenter = Admin::Rewards::OrdersPresenter.new(
        reward: @reward,
        orders: @reward.orders.includes(:user, :order_status).ordered
      )
    end

    private

    def set_reward
      @reward = Reward.find(params[:id])
    end

    def build_index_presenter
      search_form = Admin::Rewards::SearchForm.new(search_form_params)
      rewards = Admin::Rewards::SearchService.new(
        search_form: search_form,
        current_user: current_user,
        sortable_params: sortable_params
      ).call

      Admin::Rewards::IndexPresenter.new(
        search_form: search_form,
        rewards: rewards,
        sortable_params: sortable_params
      )
    end

    def build_form(reward)
      Admin::Rewards::Form.new(reward)
    end

    def create_params
      params.require(:admin_rewards_form).
        permit(
          :title, 
          :description, 
          :cost_points, 
          :is_active, 
          :stock_quantity, 
          :image
        )
    end

    def update_params
      create_params
    end

    def search_form_params
      params.fetch(:admin_rewards_search_form, {}).permit(:title, :is_active)
    end
  end
end

