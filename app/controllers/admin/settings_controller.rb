# frozen_string_literal: true

module Admin
  class SettingsController < BaseController
    def index
      settings = Setting.ordered
      @presenter = Admin::Settings::IndexPresenter.new(settings: settings, current_group: params[:group])
    end

    def edit
      setting = Setting.find(params[:id])
      authorize setting
      form = build_form(setting)
      @presenter = FormPresenter.new(form: form)
    end

    def update
      setting = Setting.find(params[:id])
      authorize setting
      form = build_form(setting)

      if form.update(update_params)
        redirect_to admin_settings_path(group: setting.group), notice: t(".success")
      else
        @presenter = FormPresenter.new(form: form)
        render :edit, status: :unprocessable_entity
      end
    end

    def bulk_update
      authorize Setting, :update?

      settings_params.each do |id, attrs|
        setting = Setting.find_by(id: id)
        setting&.update(value: attrs[:value])
      end

      redirect_to admin_settings_path(group: params[:group]), notice: t(".success")
    end

    private

    def build_form(setting)
      Admin::Settings::Form.new(setting)
    end

    def update_params
      params.require(:admin_settings_form).permit(:value)
    end

    def settings_params
      params.require(:settings).permit!
    end
  end
end
