# frozen_string_literal: true

require "rails_helper"

RSpec.feature "User creates challenge", type: :feature, js: true do
  let!(:company_user) { create(:user, :company_user) }
  let!(:general_user) { create(:user, :general_user) }

  let!(:challenge_type) { create(:challenge_type, name: "Photo Challenge") }
  let!(:difficulty_level) { create(:difficulty_level, name: "Easy") }
  let!(:award_point_level) { create(:award_point_level, points: 100, name: "Standard") }
  let!(:location) { create(:location, name: "Central Park") }

  scenario "Company user creates a new challenge" do
    login company_user
    visit new_challenge_path

    fill_in "Title", with: "Beautiful Nature Photo"
    fill_in "Description", with: "Take a photo of nature in the park"
    select "Photo Challenge", from: "Challenge type"
    select "Easy", from: "Difficulty level"
    select "Standard", from: "Award point level"
    select "Central Park", from: "Location"
    check "Active"

    click_on "Create Challenge"

    expect(page).to have_content("Challenge was successfully created")
    expect(page).to have_content("Beautiful Nature Photo")
  end

  scenario "Company user sees validation errors" do
    login company_user
    visit new_challenge_path

    click_on "Create Challenge"

    expect(page).to have_content("can't be blank")
  end

  scenario "General user cannot access challenge creation" do
    login general_user
    visit new_challenge_path

    expect(page).to have_content("not authorized")
  end
end
