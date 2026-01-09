# frozen_string_literal: true

require "rails_helper"

RSpec.feature "User attempts challenge", type: :feature, js: true do
  let!(:started_status) { create(:attempt_status, :started) }
  let!(:submitted_status) { create(:attempt_status, :submitted) }

  let!(:general_user) { create(:user, :general_user, reward_points: 0) }
  let!(:company_user) { create(:user, :company_user) }

  let!(:challenge) do
    create(:challenge,
      title: "Photo Challenge",
      description: "Take a beautiful photo",
      is_active: true,
      creator_user: company_user
    )
  end

  scenario "General user starts a challenge" do
    login general_user
    visit challenge_path(challenge)

    click_on "Start Challenge"

    expect(page).to have_content("Challenge started")
    expect(general_user.challenge_attempts.count).to eq(1)
  end

  scenario "General user submits evidence for started challenge" do
    attempt = create(:challenge_attempt,
      user: general_user,
      challenge: challenge,
      attempt_status: started_status,
      started_at: Time.current
    )

    login general_user
    visit challenge_attempt_path(attempt)

    fill_in "Evidence URL", with: "https://example.com/photo.jpg"
    click_on "Submit"

    expect(page).to have_content("submitted")
    expect(attempt.reload.attempt_status).to eq(submitted_status)
  end

  scenario "General user cannot start same challenge twice" do
    create(:challenge_attempt,
      user: general_user,
      challenge: challenge,
      attempt_status: started_status
    )

    login general_user
    visit challenge_path(challenge)

    expect(page).not_to have_link("Start Challenge")
    expect(page).to have_content("already started")
  end
end
