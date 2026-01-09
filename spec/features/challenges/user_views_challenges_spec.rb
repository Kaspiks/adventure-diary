# frozen_string_literal: true

require "rails_helper"

RSpec.feature "User views challenges", type: :feature, js: true do
  let!(:general_user) { create(:user, :general_user) }
  let!(:company_user) { create(:user, :company_user) }

  let!(:challenge_type) { create(:challenge_type, name: "Photo Challenge") }
  let!(:difficulty_level) { create(:difficulty_level, name: "Easy") }
  let!(:award_point_level) { create(:award_point_level, points: 100) }

  let!(:active_challenge) do
    create(:challenge,
      title: "Beautiful Sunset Photo",
      description: "Take a beautiful sunset photo",
      is_active: true,
      creator_user: company_user,
      challenge_type: challenge_type,
      difficulty_level: difficulty_level,
      award_point_level: award_point_level
    )
  end

  let!(:inactive_challenge) do
    create(:challenge,
      title: "Inactive Challenge",
      is_active: false,
      creator_user: company_user
    )
  end

  scenario "General user sees list of active challenges" do
    login general_user
    visit challenges_path

    expect(page).to have_content("Beautiful Sunset Photo")
    expect(page).not_to have_content("Inactive Challenge")
  end

  scenario "General user views challenge details" do
    login general_user
    visit challenges_path

    click_on "Beautiful Sunset Photo"

    expect(page).to have_content("Beautiful Sunset Photo")
    expect(page).to have_content("Take a beautiful sunset photo")
    expect(page).to have_content("Photo Challenge")
    expect(page).to have_content("Easy")
    expect(page).to have_content("100")
  end

  scenario "Company user can see their own challenges including inactive" do
    login company_user
    visit challenges_path

    expect(page).to have_content("Beautiful Sunset Photo")
  end
end
