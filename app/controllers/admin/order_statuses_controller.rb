# frozen_string_literal: true

module Admin
  class OrderStatusesController < BaseController
    def index
      authorize_controller

      @presenter = build_index_presenter
    end

    def new
      order_status = OrderStatus.new

      authorize([:admin, order_status])

      form = build_form(order_status)

      @presenter = FormPresenter.new(form: form)
    end

    def create
      order_status = OrderStatus.new

      authorize([:admin, order_status])

      form = build_form(order_status)

      if form.update(order_status_params)
        redirect_to admin_order_statuses_path,
          flash: { success: t_context(".success") }
      else
        @presenter = FormPresenter.new(form: form)

        render_action_with_errors(:new, object: form)
      end
    end

    def edit
      order_status = OrderStatus.find(params[:id])

      authorize([:admin, order_status])

      form = build_form(order_status)

      @presenter = FormPresenter.new(form: form)
    end

    def update
      order_status = OrderStatus.find(params[:id])

      authorize([:admin, order_status])

      form = build_form(order_status)

      if form.update(order_status_params)
        redirect_to admin_order_statuses_path,
          flash: { success: t_context(".success") }
      else
        @presenter = FormPresenter.new(form: form)

        render_action_with_errors(:edit, object: form)
      end
    end

    private

    def build_form(order_status)
      Admin::OrderStatuses::Form.new(order_status)
    end

    def build_index_presenter
      search_form = Admin::OrderStatuses::SearchForm.new(search_form_params)

      filtered_statuses = order_statuses_for_index(search_form)

      Admin::OrderStatuses::IndexPresenter.new(
        order_statuses: filtered_statuses,
        search_form: search_form
      )
    end

    def order_statuses_for_index(search_form)
      filtered = OrderStatus.all

      if search_form.search_performed?
        filtered = Admin::OrderStatuses::SearchService.new(
          filtered,
          params: search_form_params
        ).call
      end

      filtered
    end

    def search_form_params
      params.fetch(:admin_order_statuses_search_form, {}).permit(:name)
    end

    def order_status_params
      params.require(:admin_order_statuses_form).permit(:code, :name, :is_final)
    end
  end
end

