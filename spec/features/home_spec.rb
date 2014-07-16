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
    expect(page).to have_content("Logged in as Seth")

    expect(page).to have_link("Edit Profile")
  end


  scenario "visitor fills in login credentials incorrectly and logs in" do
    register_and_log_in("Seth")
    click_on "Logout"
    fill_in "Username", with: "Sethy"
    fill_in "Password", with: "123"
    click_on "Login"
    expect(page).to have_content("The username and password combination you entered is not valid.  Try again.")
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


  scenario "user logs in and sees a link to view detailed scores by individual" do
    register_and_log_in("Stan")
    click_on "Log Activity"
    click_on "Submit"
    click_on "Logout"
    register_and_log_in("Seth")
    click_on "Stan"
    expect(page).to have_content("Past Activity")
    expect(page).to have_link("Back to Home")
    expect(page).to have_content("1")
  end

  scenario "logged in user presses 'Log Activity' link and routes to input form" do
    register_and_log_in("Seth")
    click_on "Log Activity"
    expect(page).to have_button("Submit")
  end

  scenario "logged in user wants to see the points leaders" do
    register_and_log_in("Stan")
    make_a_choice_by_pressing_a_radio_button("#badass_button", "Launched a NEW Personal Project on Heroku", Time.now.strftime("%m/%d/%Y"))
    click_on "Logout"
    register_and_log_in("Seth")
    make_a_choice_by_pressing_a_radio_button("#network_button", "Co-Organized a Networking Event", Time.now.strftime("%m/%d/%Y"))
    expect(page.find("#points_leaders")).to have_content("Seth")
    expect(page.find("#points_leaders")).to have_content("Stan")
  end
end