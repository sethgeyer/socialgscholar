feature "homepage" do

  before(:each) do
    visit "/"
  end


  scenario "visitor sees a registration button" do
    expect(page).to have_link("Signup")
  end

  scenario "visitor sees the login form" do
    expect(page).to have_button("Login")
    expect(page).not_to have_link("Logout")

  end

  scenario "visitor sees 'All Stats' summary" do
    expect(page).to have_content("Leaderboard")
    expect(page).not_to have_content("Your Stats")
  end

  scenario "visitor clicks signup link and routes to Signup Page" do
    click_on "Signup"
    expect(page).to have_content("Register Here")
  end

  scenario "visitor fills in login credentials and logs in" do
    register_and_log_in("Seth")
    # user_logs_in("Seth")
    expect(page).to have_content("Welcome Seth!")
    expect(page).to have_content("Your Stats")


  end

  scenario "user logs out" do
    register_and_log_in("Seth")
    # save_and_open_page
    #user_logs_in("Seth")
    click_on "Logout"
    expect(page).to have_link("Signup")
  end

  scenario "user logs in and can see the Log Activity link" do
    expect(page).not_to have_link("Log Activity")
    register_and_log_in("Seth")
    expect(page).to have_link("Log Activity")
  end

  scenario "logged in user presses 'Log Activity' link and routes to input form" do
    register_and_log_in("Seth")
    click_on "Log Activity"
    expect(page).to have_button("Submit")
  end

end