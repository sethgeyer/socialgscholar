require_relative "./../app"
require "capybara/rspec"
ENV["RACK_ENV"] = "test"

Capybara.app = App


RSpec.configure do |config|
  config.before do
    database_connection = DatabaseConnection.establish(ENV["RACK_ENV"])

    database_connection.sql("BEGIN")
  end

  config.after do
    database_connection = DatabaseConnection.establish(ENV["RACK_ENV"])

    database_connection.sql("ROLLBACK")
  end
end


def  register_and_log_in(name)
  visit "/users/new"
  fill_in "Username", with: "#{name}"
  fill_in "Password", with: "#{name.downcase}"
  click_on "Submit"
end

def user_logs_in(name)
  fill_in "Username", with: "#{name}"
  fill_in "Password", with: "#{name.downcase}"
  click_on "Login"
end
