require_relative "./../app"
require "capybara/rspec"
ENV["RACK_ENV"] = "test"

Capybara.app = App


RSpec.configure do |config|
  config.before do
    database_connection = GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])

    database_connection.sql("BEGIN")
  end

  config.after do
    database_connection = GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])

    database_connection.sql("ROLLBACK")
  end
end


def  register_and_log_in(name)
  visit "/users/new"
  fill_in "Username:", with: "#{name}"
  fill_in "Password:", with: "#{name.downcase}"
  fill_in "Image URL", with: "http://photos1.meetupstatic.com/photos/member/1/2/e/highres_145320302.jpeg"
  click_on "Submit"
end

def user_logs_in(name)
  fill_in "Username:", with: "#{name}"
  fill_in "Password:", with: "#{name.downcase}"
  click_on "Login"
end

def make_a_choice_by_pressing_a_radio_button(form_section, radio_button, date)
  visit "scores/new"
  select date, from: "Date of Activity"
  within(page.find(form_section)) { choose radio_button }
  click_on("Submit")
end
