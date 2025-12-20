# frozen_string_literal: true

if Rails.env.development?
  Rake::Task["db:migrate"].enhance do
    Rake::Task["annotaterb:models"].invoke
  end

  Rake::Task["db:rollback"].enhance do
    Rake::Task["annotaterb:models"].invoke
  end
end
