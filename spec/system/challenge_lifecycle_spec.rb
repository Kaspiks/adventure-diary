# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Challenge Lifecycle", type: :system do
  let!(:started_status) { create(:attempt_status, :started) }
  let!(:submitted_status) { create(:attempt_status, :submitted) }
  let!(:approved_status) { create(:attempt_status, :approved) }
  let!(:rejected_status) { create(:attempt_status, :rejected) }

  let(:company_user) { create(:user, :company_user) }
  let(:general_user) { create(:user, :general_user, reward_points: 0) }
  let(:admin_user) { create(:user, :admin) }

  let!(:challenge) do
    create(:challenge,
      title: "Test Photo Challenge",
      description: "Take a beautiful photo",
      creator_user: company_user,
      is_active: true
    )
  end

  describe "full lifecycle: start -> submit -> approve -> points awarded" do
    it "allows general_user to start and submit, company_user to approve", js: true do
      # Step 1: General user starts challenge
      sign_in general_user
      visit challenges_path

      expect(page).to have_content("Test Photo Challenge")
      click_link "View Details"

      expect(page).to have_content("Test Photo Challenge")
      click_link "Start Challenge"

      expect(page).to have_content("Challenge started")

      # Step 2: Submit evidence
      visit my_attempts_path
      click_link "View Details"

      fill_in "evidence_url", with: "https://example.com/my-photo.jpg"
      click_button "Submit for Review"

      expect(page).to have_content("Evidence submitted")

      # Step 3: Company user reviews and approves
      sign_out general_user
      sign_in company_user

      visit admin_attempts_path
      expect(page).to have_content("All Attempts")

      click_link "View"
      expect(page).to have_content("Attempt Details")

      accept_confirm do
        click_link "Approve"
      end

      expect(page).to have_content("Attempt approved")

      # Step 4: Verify points were awarded
      general_user.reload
      expect(general_user.reward_points).to eq(challenge.award_points)
    end
  end

  describe "company_user can only review own challenges" do
    let(:other_company) { create(:user, :company_user) }
    let!(:other_challenge) { create(:challenge, creator_user: other_company) }
    let!(:attempt) do
      create(:challenge_attempt,
        user: general_user,
        challenge: other_challenge,
        attempt_status: submitted_status,
        submitted_at: Time.current
      )
    end

    it "company_user cannot approve others' challenge attempts", js: true do
      sign_in company_user
      visit admin_attempt_path(attempt)

      expect(page).to have_content("You don't have permission")
    end
  end

  describe "administrator has full access" do
    let!(:attempt) do
      create(:challenge_attempt,
        user: general_user,
        challenge: challenge,
        attempt_status: submitted_status,
        submitted_at: Time.current
      )
    end

    it "admin can approve any attempt", js: true do
      sign_in admin_user
      visit admin_attempt_path(attempt)

      expect(page).to have_content("Attempt Details")
      expect(page).to have_link("Approve")
    end
  end
end

