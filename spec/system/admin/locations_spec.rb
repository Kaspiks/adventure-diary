# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin Locations", type: :system do
  let(:admin_user) { create(:user, :admin) }

  before do
    sign_in admin_user
  end

  describe "new location form" do
    it "displays the map container with proper data attributes", js: true do
      visit new_admin_location_path

      expect(page).to have_css('[data-controller="location-map"]')
      expect(page).to have_css('[data-location-map-target="container"]')
      expect(page).to have_css('[data-location-map-target="name"]')
      expect(page).to have_css('[data-location-map-target="latitude"]')
      expect(page).to have_css('[data-location-map-target="longitude"]')
      expect(page).to have_css('[data-location-map-target="radius"]')
      expect(page).to have_css('[data-location-map-target="modeToggle"]')
      
      # Wait for Leaflet to initialize
      expect(page).to have_css('.leaflet-container', wait: 5)
    end

    it "allows toggling pick mode", js: true do
      visit new_admin_location_path
      
      # Wait for map to load
      expect(page).to have_css('.leaflet-container', wait: 5)
      
      toggle_button = find('[data-location-map-target="modeToggle"]')
      expect(toggle_button).to have_text("Pick on Map")
      
      toggle_button.click
      expect(toggle_button).to have_text("Exit Pick Mode")
    end
  end

  describe "edit location form" do
    let!(:location) { create(:location, :central_park) }

    it "displays existing location on map", js: true do
      visit edit_admin_location_path(location)

      expect(page).to have_css('.leaflet-container', wait: 5)
      
      # Verify form is populated with existing values
      expect(find('[data-location-map-target="name"]').value).to eq(location.name)
      expect(find('[data-location-map-target="latitude"]').value).to include("40.7829")
      expect(find('[data-location-map-target="longitude"]').value).to include("-73.9654")
      
      # Verify radius circle should be present (marker exists)
      expect(page).to have_css('.leaflet-marker-icon', wait: 5)
    end
  end

  describe "form submission" do
    it "creates a new location successfully", js: true do
      visit new_admin_location_path

      fill_in "admin_locations_form[name]", with: "Test Location"
      fill_in "admin_locations_form[latitude]", with: "51.5074"
      fill_in "admin_locations_form[longitude]", with: "-0.1278"
      fill_in "admin_locations_form[radius_meters]", with: "200"

      click_button "Create Location"

      expect(page).to have_content("Location created successfully")
      expect(Location.last.name).to eq("Test Location")
    end
  end
end
