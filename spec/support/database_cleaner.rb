# frozen_string_literal: true

# require File.join(File.dirname(__FILE__))

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :deletion, { except: %w[student_submissions] }
    DatabaseCleaner.clean
    DegreeType.seed
    CommitteeRole.seed
  end

  config.after(:suite) do
    DatabaseCleaner.clean
  end

  config.before(:each, js: true) do
    Capybara.current_driver = :selenium
    DatabaseCleaner.strategy = :truncation
  end

  config.before do
    DatabaseCleaner.start
    DegreeType.seed
    CommitteeRole.seed
  end
  config.after do
    DatabaseCleaner.clean
  end
end
