# frozen_string_literal: true

module Admin
  class LocationsController < BaseController
    def index
      authorize_controller

      @presenter = build_index_presenter
    end

    def new
      location = Location.new(active: true)

      authorize([:admin, location])

      form = build_form(location)

      @presenter = FormPresenter.new(form: form)
    end

    def create
      location = Location.new(active: true)

      authorize([:admin, location])

      form = build_form(location)

      if form.update(location_params)
        redirect_to admin_locations_path,
          flash: { success: t_context('.success') }
      else
        @presenter = FormPresenter.new(form: form)

        render_action_with_errors(:new, object: form)
      end
    end

    def edit
      location = Location.find(params[:id])

      authorize([:admin, location])

      form = build_form(location)

      @presenter = FormPresenter.new(form: form)
    end

    def update
      location = Location.find(params[:id])

      authorize([:admin, location])

      form = build_form(location)

      if form.update(location_params)
        redirect_to admin_locations_path,
          flash: { success: t_context('.success') }
      else
        @presenter = FormPresenter.new(form: form)

        render_action_with_errors(:edit, object: form)
      end
    end

    private

    def build_form(location)
      Admin::Locations::Form.new(location)
    end

    def build_index_presenter
      search_form = ::Admin::Locations::SearchForm.new(
        search_form_params
      )

      filtered_locations = locations_for_index(
        search_form
      )

      ::Admin::Locations::IndexPresenter.new(
        locations: filtered_locations,
        search_form: search_form
      )
    end

    def locations_for_index(search_form)
      filtered_locations = Location.all

      if search_form.search_performed?
        filtered_locations =
          ::Admin::Locations::SearchService.new(
            filtered_locations,
            params: search_form_params
          ).call
      end

      filtered_locations
    end

    def search_form_params
      params.fetch(:admin_locations_search_form, {}).
        permit(:name)
    end

    def location_params
      params.
        require(:admin_locations_form).
        permit(:name, :latitude, :longitude, :radius_meters, :active)
    end
  end
end
