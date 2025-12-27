# frozen_string_literal: true

module Admin
  class RolesController < BaseController
    def index
      @presenter = build_index_presenter
    end

    def show
      role = Role.find(params[:id])
      @presenter = Admin::Roles::ShowPresenter.new(role: role)
    end

    def new
      role = Role.new
      form = build_form(role)
      @presenter = FormPresenter.new(form: form)
    end

    def create
      role = Role.new
      form = build_form(role)

      if form.create(create_params)
        redirect_to admin_role_path(role), notice: t(".success")
      else
        @presenter = FormPresenter.new(form: form)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      role = Role.find(params[:id])
      form = build_form(role)
      @presenter = FormPresenter.new(form: form)
    end

    def update
      role = Role.find(params[:id])
      form = build_form(role)

      if form.update(update_params)
        redirect_to admin_role_path(role), notice: t(".success")
      else
        @presenter = FormPresenter.new(form: form)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      role = Role.find(params[:id])

      if role.users.exists?
        redirect_to admin_roles_path, alert: t(".has_users")
      else
        role.destroy
        redirect_to admin_roles_path, notice: t(".success")
      end
    end

    private

    def build_index_presenter
      roles = Role.ordered.includes(:permissions)
      Admin::Roles::IndexPresenter.new(roles: roles)
    end

    def build_form(role)
      Admin::Roles::Form.new(role)
    end

    def create_params
      params.require(:admin_roles_form).permit(
        :name,
        :description,
        permission_ids: []
      )
    end

    def update_params
      params.require(:admin_roles_form).permit(
        :name,
        :description,
        permission_ids: []
      )
    end
  end
end








