# frozen_string_literal: true

puts "Seeding permissions..."
permissions_file = Rails.root.join("db/seeds/permissions.yml")
if File.exist?(permissions_file)
  permissions_data = YAML.load_file(permissions_file)
  permissions_data.each do |perm|
    Permission.find_or_create_by!(code: perm["code"]) do |p|
      p.description = perm["description"]
    end
  end
  puts "  Created #{Permission.count} permissions"
end

puts "Seeding settings..."
settings_file = Rails.root.join("db/seeds/settings.yml")
if File.exist?(settings_file)
  settings_data = YAML.load_file(settings_file)
  settings_data.each do |setting_data|
    Setting.find_or_create_by!(key: setting_data["key"]) do |s|
      s.value = setting_data["value"]
      s.value_type = setting_data["value_type"] || "string"
      s.group = setting_data["group"] || "general"
      s.description = setting_data["description"]
    end
  end
  puts "  Created #{Setting.count} settings"
end

puts "Seeding challenge types..."
challenge_types_file = Rails.root.join("db/seeds/challenge_types.yml")
if File.exist?(challenge_types_file)
  challenge_types_data = YAML.load_file(challenge_types_file)
  challenge_types_data.each do |ct|
    ChallengeType.find_or_create_by!(code: ct["code"]) do |c|
      c.name = ct["name"]
      c.description = ct["description"]
    end
  end
  puts "  Created #{ChallengeType.count} challenge types"
end

puts "Seeding difficulty levels..."
difficulty_levels_file = Rails.root.join("db/seeds/difficulty_levels.yml")
if File.exist?(difficulty_levels_file)
  difficulty_levels_data = YAML.load_file(difficulty_levels_file)
  difficulty_levels_data.each do |dl|
    DifficultyLevel.find_or_create_by!(code: dl["code"]) do |d|
      d.name = dl["name"]
      d.description = dl["description"]
      d.sort_order = dl["sort_order"]
    end
  end
  puts "  Created #{DifficultyLevel.count} difficulty levels"
end

puts "Seeding award point levels..."
award_point_levels_file = Rails.root.join("db/seeds/award_point_levels.yml")
if File.exist?(award_point_levels_file)
  award_point_levels_data = YAML.load_file(award_point_levels_file)
  award_point_levels_data.each do |apl|
    AwardPointLevel.find_or_create_by!(code: apl["code"]) do |a|
      a.name = apl["name"]
      a.points = apl["points"]
      a.description = apl["description"]
    end
  end
  puts "  Created #{AwardPointLevel.count} award point levels"
end

puts "Seeding attempt statuses..."
attempt_statuses_file = Rails.root.join("db/seeds/attempt_statuses.yml")
if File.exist?(attempt_statuses_file)
  attempt_statuses_data = YAML.load_file(attempt_statuses_file)
  attempt_statuses_data.each do |as|
    AttemptStatus.find_or_create_by!(code: as["code"]) do |a|
      a.name = as["name"]
      a.is_final = as["is_final"]
    end
  end
  puts "  Created #{AttemptStatus.count} attempt statuses"
end

puts "Seeding order statuses..."
order_statuses_file = Rails.root.join("db/seeds/order_statuses.yml")
if File.exist?(order_statuses_file)
  order_statuses_data = YAML.load_file(order_statuses_file)
  order_statuses_data.each do |os|
    OrderStatus.find_or_create_by!(code: os["code"]) do |o|
      o.name = os["name"]
      o.is_final = os["is_final"]
    end
  end
  puts "  Created #{OrderStatus.count} order statuses"
end

puts "Seeding locations..."
locations_file = Rails.root.join("db/seeds/locations.yml")
if File.exist?(locations_file)
  locations_data = YAML.load_file(locations_file)
  locations_data.each do |loc|
    Location.find_or_create_by!(name: loc["name"]) do |l|
      l.latitude = loc["latitude"]
      l.longitude = loc["longitude"]
      l.radius_meters = loc["radius_meters"]
    end
  end
  puts "  Created #{Location.count} locations"
end

puts "Seeding roles..."
roles_file = Rails.root.join("db/seeds/roles.yml")
if File.exist?(roles_file)
  roles_data = YAML.load_file(roles_file)
  roles_data.each do |role_data|
    role = Role.find_or_create_by!(name: role_data["name"]) do |r|
      r.description = role_data["description"]
    end

    permission_codes = role_data["permissions"] || []
    permissions = Permission.where(code: permission_codes)
    role.permissions = permissions
    puts "  Role '#{role.name}' has #{role.permissions.count} permissions"
  end
  puts "  Created #{Role.count} roles"
end

if Rails.env.development?
  puts "Seeding development users..."

  admin_role = Role.find_by(name: "administrator")
  company_role = Role.find_by(name: "company_user")
  general_role = Role.find_by(name: "general_user")

  unless User.exists?(email: "admin@example.com")
    User.create!(
      email: "admin@example.com",
      password: "password123",
      password_confirmation: "password123",
      first_name: "Admin",
      last_name: "User",
      admin: true,
      role: admin_role
    )
    puts "  Created: admin@example.com / password123"
  else
    user = User.find_by(email: "admin@example.com")
    user.update!(role: admin_role) if user.role.nil?
    puts "  Admin user already exists, ensured role assignment"
  end

  unless User.exists?(email: "company@example.com")
    User.create!(
      email: "company@example.com",
      password: "password123",
      password_confirmation: "password123",
      first_name: "Company",
      last_name: "Manager",
      admin: false,
      role: company_role
    )
    puts "  Created: company@example.com / password123"
  end

  unless User.exists?(email: "user@example.com")
    User.create!(
      email: "user@example.com",
      password: "password123",
      password_confirmation: "password123",
      first_name: "Regular",
      last_name: "User",
      admin: false,
      role: general_role
    )
    puts "  Created: user@example.com / password123"
  end

  company_user = User.find_by(email: "company@example.com")
  if company_user && Challenge.count == 0
    puts "Seeding sample challenges..."
    photo_type = ChallengeType.find_by(code: "photo")
    checkin_type = ChallengeType.find_by(code: "checkin")
    easy = DifficultyLevel.find_by(code: "easy")
    medium = DifficultyLevel.find_by(code: "medium")
    bronze = AwardPointLevel.find_by(code: "bronze")
    silver = AwardPointLevel.find_by(code: "silver")
    gold = AwardPointLevel.find_by(code: "gold")
    central_park = Location.find_by(name: "Central Park")
    golden_gate = Location.find_by(name: "Golden Gate Bridge")

    Challenge.create!(
      creator_user: company_user,
      location: central_park,
      challenge_type: photo_type,
      difficulty_level: easy,
      award_point_level: bronze,
      title: "Central Park Photo Walk",
      description: "Take a beautiful photo anywhere in Central Park and share your adventure!",
      is_active: true
    )

    Challenge.create!(
      creator_user: company_user,
      location: golden_gate,
      challenge_type: checkin_type,
      difficulty_level: medium,
      award_point_level: silver,
      title: "Golden Gate Explorer",
      description: "Visit the iconic Golden Gate Bridge and check in at this landmark.",
      is_active: true
    )

    Challenge.create!(
      creator_user: company_user,
      location: nil,
      challenge_type: photo_type,
      difficulty_level: easy,
      award_point_level: gold,
      title: "Sunset Chaser",
      description: "Capture the most beautiful sunset you can find on your travels.",
      is_active: true
    )

    puts "  Created #{Challenge.count} sample challenges"
  end

  # Seed sample rewards
  if company_user && Reward.count == 0
    puts "Seeding sample rewards..."

    Reward.create!(
      owner_user: company_user,
      title: "Coffee Voucher",
      description: "Enjoy a free coffee at any participating location. Valid for any size drink.",
      cost_points: 50,
      is_active: true,
      stock_quantity: 100
    )

    Reward.create!(
      owner_user: company_user,
      title: "Movie Ticket",
      description: "One free movie ticket valid at any cinema. Excludes 3D and IMAX screenings.",
      cost_points: 200,
      is_active: true,
      stock_quantity: 50
    )

    Reward.create!(
      owner_user: company_user,
      title: "Adventure T-Shirt",
      description: "Exclusive Adventure Diary branded t-shirt. Available in various sizes.",
      cost_points: 500,
      is_active: true,
      stock_quantity: 20
    )

    Reward.create!(
      owner_user: company_user,
      title: "Premium Membership",
      description: "One month of premium membership with exclusive challenges and double points.",
      cost_points: 1000,
      is_active: true,
      stock_quantity: nil
    )

    puts "  Created #{Reward.count} sample rewards"
  end

  load Rails.root.join("db/seeds/demo_riga_motor_museum.rb")
end

puts "Seeding complete!"
