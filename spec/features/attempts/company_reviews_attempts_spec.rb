# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Company user reviews attempts", type: :feature, js: true do
  let!(:submitted_status) { create(:attempt_status, :submitted) }
  let!(:approved_status) { create(:attempt_status, :approved) }
  let!(:rejected_status) { create(:attempt_status, :rejected) }

  let!(:company_user) { create(:user, :company_user) }
  let!(:other_company_user) { create(:user, :company_user) }
  let!(:general_user) { create(:user, :general_user, reward_points: 0) }

  let!(:challenge) do
    create(:challenge,
      title: "Photo Challenge",
      creator_user: company_user
    )
  end

  let!(:submitted_attempt) do
    create(:challenge_attempt,
      user: general_user,
      challenge: challenge,
      attempt_status: submitted_status,
      submitted_at: Time.current,
      evidence_url: "https://example.com/photo.jpg"
    )
  end

  scenario "Company user views pending attempts for their challenges" do
    login company_user
    visit admin_attempts_path

    expect(page).to have_content("Photo Challenge")
    expect(page).to have_content(general_user.full_name)
    expect(page).to have_content("Submitted")
  end

  scenario "Company user approves an attempt" do
    login company_user
    visit admin_attempt_path(submitted_attempt)

    expect(page).to have_content("Photo Challenge")
    expect(page).to have_content(general_user.full_name)

    accept_confirm do
      click_on "Approve"
    end

    expect(page).to have_content("approved")
    expect(submitted_attempt.reload.attempt_status).to eq(approved_status)
    expect(general_user.reload.reward_points).to be > 0
  end

  scenario "Company user rejects an attempt" do
    login company_user
    visit admin_attempt_path(submitted_attempt)

    accept_confirm do
      click_on "Reject"
    end

    expect(page).to have_content("rejected")
    expect(submitted_attempt.reload.attempt_status).to eq(rejected_status)
    expect(general_user.reload.reward_points).to eq(0)
  end

  scenario "Company user cannot review attempts for other company's challenges" do
    login other_company_user
    visit admin_attempt_path(submitted_attempt)

    expect(page).to have_content("not authorized")
  end
end
