# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    def index
      @presenter = build_index_presenter
    end

    def show
      user = User.find(params[:id])
      @presenter = Admin::Users::ShowPresenter.new(user: user, current_user: current_user)
    end

    def new
      user = User.new
      form = build_form(user)
      @presenter = FormPresenter.new(form: form)
    end

    def create
      user = User.new
      form = build_form(user)

      if form.create(create_params)
        redirect_to admin_user_path(user), notice: t(".success")
      else
        @presenter = FormPresenter.new(form: form)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      user = User.find(params[:id])
      form = build_form(user)
      @presenter = FormPresenter.new(form: form)
    end

    def update
      user = User.find(params[:id])
      form = build_form(user)

      if form.update(update_params)
        redirect_to admin_user_path(user), notice: t(".success")
      else
        @presenter = FormPresenter.new(form: form)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      user = User.find(params[:id])
      user.destroy
      redirect_to admin_users_path, notice: t(".success")
    end

    private

    def build_index_presenter
      search_form = Admin::Users::SearchForm.new(search_form_params)
      users = Admin::Users::SearchService.new(search_form: search_form).call

      Admin::Users::IndexPresenter.new(search_form: search_form, users: users)
    end

    def build_form(user)
      Admin::Users::Form.new(user)
    end

    def create_params
      params.require(:admin_users_form).permit(
        :first_name,
        :last_name,
        :email,
        :password,
        :password_confirmation,
        :admin,
        :blocked,
        :role_id
      )
    end

    def update_params
      params.require(:admin_users_form).permit(
        :first_name,
        :last_name,
        :email,
        :admin,
        :blocked,
        :role_id
      )
    end

    def search_form_params
      params.fetch(:admin_users_search_form, {}).permit(
        :email,
        :first_name,
        :last_name
      )
    end
  end
end
