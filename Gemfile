source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.7"

gem "rails", "~> 7.0.4", ">= 7.0.4.2"
gem "sprockets-rails"
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
gem "jsbundling-rails"
gem "cssbundling-rails"
gem "jbuilder"
gem "bootsnap", require: false

# All runtime config comes from the UNIX environment
# but we use dotenv to store that in files for
# development and testing
gem "dotenv-rails", groups: [:development, :test]

# Brakeman analyzes our code for security vulnerabilities
gem "brakeman"

# bundler-audit checks our dependencies for vulnerabilities
gem "bundler-audit"

# Sidekiq uses Redis, but since this app does not have
# Sidekiq installed yet, we bring this gem in so we can connect
# to Redis and validate the reader's setup.
gem "redis"

# FactoryBot replaces Rails fixtures with something
# more predictable and usable when the database
# is using foreign keys.
gem "factory_bot_rails"

# Faker is used to generate test data
gem "faker"

# This is used to run the dev environment
gem "foreman"

# sidekiq is used for running background jobs
gem "sidekiq"

# Prevents our workers from running too long if a request
# doesn't return in time.
gem "rack-timeout"

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  # Right at release time, webdrivers, rails and Selenium made
  # a breaking change and rather than stop the book release, I'm
  # hardcoding the version as instructed by the later versions of this gem.
  gem "webdrivers", "= 5.3.0"
  gem "pry"
end
