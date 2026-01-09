# frozen_string_literal: true

require "rails_helper"

RSpec.feature "User logs in", type: :feature, js: true do
  let!(:general_user) { create(:user, :general_user, email: "user@example.com", password: "password123") }

  scenario "User fills the login form with correct login data" do
    visit new_user_session_path

    fill_in "Email", with: "user@example.com"
    fill_in "Password", with: "password123"
    click_on "Log in"

    expect(page).to have_content(general_user.full_name)
  end

  scenario "User fills the login form with incorrect password" do
    visit new_user_session_path

    fill_in "Email", with: "user@example.com"
    fill_in "Password", with: "wrongpassword"
    click_on "Log in"

    expect(page).to have_content("Invalid Email or password")
  end

  scenario "User fills the login form with non-existent email" do
    visit new_user_session_path

    fill_in "Email", with: "nonexistent@example.com"
    fill_in "Password", with: "password123"
    click_on "Log in"

    expect(page).to have_content("Invalid Email or password")
  end

  scenario "Blocked user cannot log in" do
    general_user.update!(blocked: true)

    visit new_user_session_path

    fill_in "Email", with: "user@example.com"
    fill_in "Password", with: "password123"
    click_on "Log in"

    expect(page).to have_content("blocked")
  end

  scenario "User visits protected page without logging in" do
    visit challenges_path

    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_content("You need to sign in")
  end
end
