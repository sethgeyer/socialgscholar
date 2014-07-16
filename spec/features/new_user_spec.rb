
feature "registration page" do

  scenario "visitor sees a registration form" do
    visit '/users/new'
    expect(page).to have_button("Submit")
    expect(page).to have_content("Username")
    expect(page).to have_content("Password")
    expect(page).to have_content("Image URL")
  end

  scenario "visitor fills in form to create an account" do
    register_and_log_in("Seth")
    #save_and_open_page
    #   # expect(page).to have_content("Thank you for registering")
    expect(page).to have_content("Welcome Seth!")
  end

  scenario "visitor fills in username but no password" do
    visit '/users/new'
    fill_in "Username", with: "Seth"
    # fill_in "password", with: ""
    click_on "Submit"
    expect(page).to have_content("Password is required")
    expect(page).to have_content("Register Here")
  end

  scenario "visitor fills in password but no username" do
    visit '/users/new'
    fill_in "Password", with: "seth"
    click_on "Submit"
    expect(page).to have_content("Username is required")
    expect(page).to have_content("Register Here")
  end

  scenario "visitor fills in neither password nor username" do
    visit '/users/new'
    click_on "Submit"
    expect(page).to have_content("Password and Username is required")
    expect(page).to have_content("Register Here")
  end

  scenario "a registering visitor selects a username that has already been taken" do
    register_and_log_in("Seth")
    click_on "Logout"
    register_and_log_in("Seth")
    expect(page).to have_content("Username is already taken")
  end

  scenario "visitor decides not to register" do
    visit "/users/new"
    click_on "Cancel"
    expect(page).to have_content("Scoreboard")
  end


end