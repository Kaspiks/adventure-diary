# frozen_string_literal: true

require "rails_helper"

RSpec.feature "User views rewards", type: :feature, js: true do
  let!(:general_user) { create(:user, :general_user, reward_points: 500) }
  let!(:company_user) { create(:user, :company_user) }

  let!(:affordable_reward) do
    create(:reward,
      title: "Coffee Mug",
      description: "A nice coffee mug",
      cost_points: 100,
      is_active: true,
      stock_quantity: 10,
      owner_user: company_user
    )
  end

  let!(:expensive_reward) do
    create(:reward,
      title: "Laptop Bag",
      description: "A premium laptop bag",
      cost_points: 1000,
      is_active: true,
      stock_quantity: 5,
      owner_user: company_user
    )
  end

  let!(:inactive_reward) do
    create(:reward,
      title: "Hidden Reward",
      is_active: false,
      owner_user: company_user
    )
  end

  scenario "General user sees list of available rewards" do
    login general_user
    visit rewards_path

    expect(page).to have_content("Coffee Mug")
    expect(page).to have_content("100")
    expect(page).to have_content("Laptop Bag")
    expect(page).to have_content("1000")
    expect(page).not_to have_content("Hidden Reward")
  end

  scenario "General user views reward details" do
    login general_user
    visit reward_path(affordable_reward)

    expect(page).to have_content("Coffee Mug")
    expect(page).to have_content("A nice coffee mug")
    expect(page).to have_content("100")
    expect(page).to have_content("10") # stock
  end

  scenario "General user sees their current points" do
    login general_user
    visit rewards_path

    expect(page).to have_content("500")
  end
end
