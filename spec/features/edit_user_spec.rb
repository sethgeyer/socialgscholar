feature "edit user page" do

  scenario "visitor tries to access the edit user page" do
    visit "/users/edit"
    expect(page).to have_content("Leaderboard")
  end

  scenario "user wishes to edit their profile" do
    visit "/"
    register_and_log_in("Seth")
    click_link("Edit Profile")
    expect(page).to have_content("Edit Your Profile")
    #expect(page.find("#username")).to have_content("Seth")
    expect(page).to have_button("Submit")
    expect(page).to have_link("Cancel")
  end

  scenario "user wishes to cancel their profile updates" do
    register_and_log_in("Seth")
    visit "/users/edit"
    click_on "Cancel"
    expect(page).to have_content("Leaderboard")
  end

  scenario "user changes their password" do
    register_and_log_in("Seth")
    visit "/users/edit"
    fill_in "Password", with: "sethy"
    click_on "Submit"
    expect(page).to have_content("Your changes have been saved")
    click_on "Logout"

    fill_in "Username", with: "Seth"
    fill_in "Password", with: "sethy"
    click_on "Login"
    expect(page).to have_content("Welcome Seth")
    expect(page).to have_content("Edit Profile")

  end

  scenario "user edits profile and saves password as '' " do
    register_and_log_in("Seth")
    visit "/users/edit"
    fill_in "Password", with: ""
    click_on "Submit"
    expect(page).to have_content("You Must Input a Valid Password")


  end


end