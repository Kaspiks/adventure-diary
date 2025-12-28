# frozen_string_literal: true

module Admin
  class ClassificationValuesController < BaseController
    def new
      classification = Classification.find(params[:classification_id])
      value = ClassificationValue.new(classification: classification, active: true)

      authorize([:admin, classification])

      form = build_form(value)

      @presenter = FormPresenter.new(form: form)
    end

    def create
      classification = Classification.find(params[:classification_id])
      value = ClassificationValue.new(classification: classification)

      authorize([:admin, classification])

      form = build_form(value)

      if form.update(classification_value_params)
        redirect_back_to admin_classification_path(classification),
          flash: { success: t_context('.success') }
      else
        @presenter = FormPresenter.new(form: form)

        render_action_with_errors(:new, object: form)
      end
    end

    def edit
      value = ClassificationValue.find(params[:id])

      authorize([:admin, value.classification])

      form = build_form(value)

      @presenter = FormPresenter.new(form: form)
    end

    def update
      value = ClassificationValue.find(params[:id])

      authorize([:admin, value.classification])

      form = build_form(value)

      if form.update(classification_value_params)
        redirect_back_to admin_classification_path(value.classification_id),
          flash: { success: t_context('.success') }
      else
        @presenter = FormPresenter.new(form: form)

        render_action_with_errors(:edit, object: form)
      end
    end

    private

    def build_form(value)
      Admin::ClassificationValues::Form.new(value)
    end

    def classification_value_params
      params.
        require(:admin_classification_values_form).
        permit(:classification_id, :value, :active)
    end
  end
end
