# frozen_string_literal: true

require "rails_helper"

RSpec.feature "User attempts challenge", type: :feature, js: false do
  let!(:started_status) { create(:attempt_status, :started) }
  let!(:general_user) { create(:user, :general_user, reward_points: 0) }
  let!(:company_user) { create(:user, :company_user) }

  let!(:challenge) do
    create(:challenge,
      title: "Photo Challenge",
      description: "Take a beautiful photo",
      is_active: true,
      creator_user: company_user)
  end

  scenario "General user starts a challenge" do
    login general_user
    visit challenge_path(challenge)

    click_on "Start Challenge"

    expect(page).to have_content(I18n.t("challenges.start.success"))
    expect(general_user.challenge_attempts.count).to eq(1)
  end

  scenario "General user submits evidence for started challenge" do
    attempt = create(:challenge_attempt,
      user: general_user,
      challenge: challenge,
      attempt_status: started_status,
      started_at: Time.current)

    login general_user
    visit attempt_path(attempt)

    # Use Capybara's attach_file so Rack::Test records the multipart upload. Raw
    # find(...).set can leave params[:photos] empty; then validate_submission adds
    # :photo_required ("template_fields empty" branch) and the redirect carries an alert, not the success notice.
    within("form[enctype='multipart/form-data']") do
      # The evidence input has multiple: true. RackTest only builds a real upload
      # when #set receives an Array (see Capybara::RackTest::Node#set_input); a
      # single String leaves the field empty at submit time, so photos never
      # arrive and validate_submission fails with :photo_required.
      attach_file(
        "attempts_submit_actions_form[photos][evidence][]",
        [Rails.root.join("spec/fixtures/files/test.png").to_s],
        visible: :all
      )
      click_button "Submit for Review"
    end

    expect(page).to have_content(I18n.t("attempts.submit.success"))
    expect(attempt.reload.submitted?).to be true
  end

  scenario "General user cannot start same challenge twice" do
    create(:challenge_attempt,
      user: general_user,
      challenge: challenge,
      attempt_status: started_status)

    login general_user
    visit challenge_path(challenge)

    expect(page).not_to have_link("Start Challenge")
    expect(page).to have_content(I18n.t("challenges.show.already_started"))
  end
end
