# frozen_string_literal: true

module Admin
  class AttemptStatusesController < BaseController
    def index
      authorize_controller

      @presenter = build_index_presenter
    end

    def new
      attempt_status = AttemptStatus.new

      authorize([:admin, attempt_status])

      form = build_form(attempt_status)

      @presenter = FormPresenter.new(form: form)
    end

    def create
      attempt_status = AttemptStatus.new

      authorize([:admin, attempt_status])

      form = build_form(attempt_status)

      if form.update(attempt_status_params)
        redirect_to admin_attempt_statuses_path,
          flash: { success: t_context(".success") }
      else
        @presenter = FormPresenter.new(form: form)

        render_action_with_errors(:new, object: form)
      end
    end

    def edit
      attempt_status = AttemptStatus.find(params[:id])

      authorize([:admin, attempt_status])

      form = build_form(attempt_status)

      @presenter = FormPresenter.new(form: form)
    end

    def update
      attempt_status = AttemptStatus.find(params[:id])

      authorize([:admin, attempt_status])

      form = build_form(attempt_status)

      if form.update(attempt_status_params)
        redirect_to admin_attempt_statuses_path,
          flash: { success: t_context(".success") }
      else
        @presenter = FormPresenter.new(form: form)

        render_action_with_errors(:edit, object: form)
      end
    end

    private

    def build_form(attempt_status)
      Admin::AttemptStatuses::Form.new(attempt_status)
    end

    def build_index_presenter
      search_form = Admin::AttemptStatuses::SearchForm.new(search_form_params)

      filtered_statuses = attempt_statuses_for_index(search_form)

      Admin::AttemptStatuses::IndexPresenter.new(
        attempt_statuses: filtered_statuses,
        search_form: search_form
      )
    end

    def attempt_statuses_for_index(search_form)
      filtered = AttemptStatus.all

      if search_form.search_performed?
        filtered = Admin::AttemptStatuses::SearchService.new(
          filtered,
          params: search_form_params
        ).call
      end

      filtered
    end

    def search_form_params
      params.fetch(:admin_attempt_statuses_search_form, {}).permit(:name)
    end

    def attempt_status_params
      params.require(:admin_attempt_statuses_form).permit(:code, :name, :is_final)
    end
  end
end

