# frozen_string_literal: true

require "rails_helper"

RSpec.feature "User purchases reward", type: :feature, js: true do
  let!(:pending_status) { create(:order_status, :pending) }

  let!(:general_user) { create(:user, :general_user, reward_points: 500) }
  let!(:company_user) { create(:user, :company_user) }

  let!(:affordable_reward) do
    create(:reward,
      title: "Coffee Mug",
      cost_points: 100,
      is_active: true,
      stock_quantity: 10,
      owner_user: company_user
    )
  end

  let!(:expensive_reward) do
    create(:reward,
      title: "Laptop Bag",
      cost_points: 1000,
      is_active: true,
      stock_quantity: 5,
      owner_user: company_user
    )
  end

  let!(:out_of_stock_reward) do
    create(:reward,
      title: "Sold Out Item",
      cost_points: 50,
      is_active: true,
      stock_quantity: 0,
      owner_user: company_user
    )
  end

  scenario "General user purchases an affordable reward" do
    login general_user
    visit reward_path(affordable_reward)

    accept_confirm do
      click_on "Purchase"
    end

    expect(page).to have_content("Order placed successfully")
    expect(general_user.reload.reward_points).to eq(400)
    expect(affordable_reward.reload.stock_quantity).to eq(9)
  end

  scenario "General user cannot purchase reward with insufficient points" do
    login general_user
    visit reward_path(expensive_reward)

    expect(page).to have_content("Not enough points")
    expect(page).not_to have_button("Purchase")
  end

  scenario "General user cannot purchase out of stock reward" do
    login general_user
    visit reward_path(out_of_stock_reward)

    expect(page).to have_content("Out of Stock")
    expect(page).not_to have_button("Purchase")
  end

  scenario "General user sees order confirmation after purchase" do
    login general_user
    visit reward_path(affordable_reward)

    accept_confirm do
      click_on "Purchase"
    end

    visit orders_path

    expect(page).to have_content("Coffee Mug")
    expect(page).to have_content("Pending")
    expect(page).to have_content("100")
  end
end
