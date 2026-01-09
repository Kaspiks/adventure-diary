# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Company user manages orders", type: :feature, js: true do
  let!(:pending_status) { create(:order_status, :pending) }
  let!(:approved_status) { create(:order_status, :approved) }
  let!(:delivered_status) { create(:order_status, :delivered) }
  let!(:cancelled_status) { create(:order_status, :cancelled) }

  let!(:company_user) { create(:user, :company_user) }
  let!(:other_company_user) { create(:user, :company_user) }
  let!(:general_user) { create(:user, :general_user) }

  let!(:reward) do
    create(:reward,
      title: "Coffee Mug",
      cost_points: 100,
      owner_user: company_user
    )
  end

  let!(:pending_order) do
    create(:order,
      user: general_user,
      reward: reward,
      order_status: pending_status,
      total_points: 100
    )
  end

  scenario "Company user views orders for their rewards" do
    login company_user
    visit admin_orders_path

    expect(page).to have_content("Coffee Mug")
    expect(page).to have_content(general_user.full_name)
    expect(page).to have_content("Pending")
  end

  scenario "Company user approves an order" do
    login company_user
    visit admin_order_path(pending_order)

    click_on "Approve"

    expect(page).to have_content("approved")
    expect(pending_order.reload.order_status).to eq(approved_status)
  end

  scenario "Company user marks order as delivered" do
    pending_order.update!(order_status: approved_status)

    login company_user
    visit admin_order_path(pending_order)

    click_on "Mark Delivered"

    expect(page).to have_content("delivered")
    expect(pending_order.reload.order_status).to eq(delivered_status)
  end

  scenario "Company user cancels an order" do
    initial_points = general_user.reward_points

    login company_user
    visit admin_order_path(pending_order)

    accept_confirm do
      click_on "Cancel"
    end

    expect(page).to have_content("cancelled")
    expect(pending_order.reload.order_status).to eq(cancelled_status)
    expect(general_user.reload.reward_points).to eq(initial_points + 100)
  end

  scenario "Company user cannot manage orders for other company's rewards" do
    login other_company_user
    visit admin_order_path(pending_order)

    expect(page).to have_content("not authorized")
  end
end
