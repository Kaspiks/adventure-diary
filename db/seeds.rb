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
      s.rich_text = setting_data["rich_text"] || false
    end
  end
  puts "  Created #{Setting.count} settings"
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
  puts "Seeding admin user..."
  admin_role = Role.find_by(name: "Admin")

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
end

puts "Seeding complete!"
