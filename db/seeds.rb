# frozen_string_literal: true

if Rails.env.development?
  unless User.exists?(email: "admin@example.com")
    User.create!(
      email: "admin@example.com",
      password: "password123",
      password_confirmation: "password123",
      first_name: "Admin",
      last_name: "User",
      admin: true
    )
    puts "Created: admin@example.com / password123"
  end
end
