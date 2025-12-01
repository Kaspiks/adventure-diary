# frozen_string_literal: true

if Rails.env.development?
  ANNOTATE_OPTIONS = '--position=bottom'

  task "db:migrate": :environment do
    Rake::Task["db:migrate"].enhance do
      system("bundle exec annotaterb models #{ANNOTATE_OPTIONS}")
    end
  end

  task "db:rollback": :environment do
    Rake::Task["db:rollback"].enhance do
      system("bundle exec annotaterb models #{ANNOTATE_OPTIONS}")
    end
  end
end
