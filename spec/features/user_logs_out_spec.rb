# frozen_string_literal: true

require "rails_helper"

RSpec.feature "User logs out", type: :feature, js: true do
  let!(:general_user) { create(:user, :general_user) }

  scenario "User clicks logout button" do
    login general_user

    find("a", text: /log out|sign out|logout/i).click

    expect(page).to have_current_path(new_user_session_path)
  end

  scenario "User session is cleared after logout" do
    login general_user

    find("a", text: /log out|sign out|logout/i).click

    visit challenges_path

    expect(page).to have_current_path(new_user_session_path)
  end
end
