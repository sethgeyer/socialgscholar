feature "New Score Page" do


  scenario "visitor does not have access to this page unless logged in" do
    visit "scores/new"
    expect(page).to have_content("Leaderboard")
  end

  scenario "logged in user sees a Activity Form on the page" do
    register_and_log_in("Seth")
    visit "scores/new"
    bev_section = page.find("#bev_button")
    expect(bev_section).to have_content("Enjoyed a Beverage")
    expect(bev_section).to have_content("Nope")
    expect(bev_section).to have_content("In gSchool Classroom")

  end

  scenario "user sees the current day in the form" do
    skip
    register_and_log_in("Seth")
    visit "scores/new"
    time = Time.now.strftime("%m/%d/%Y")
    expect(page).to have_content(time)
  end

  scenario "user fills in the form and is routed back to the home page" do
    register_and_log_in("Seth")
    visit "scores/new"
    bev_section = page.find("#bev_button")
    within(bev_section) { choose "In gSchool Classroom"}
    click_on("Submit")
    expect(page).to have_content("Leaderboard")
  end

  scenario "user fills in the form and sees there updated score on the homepage" do
    register_and_log_in("Seth")
    visit "scores/new"
    bev_section = page.find("#bev_button")
    within(bev_section) { choose "At Gather w/ a Stranger"}
    click_on("Submit")
    time = Time.now.strftime("%m/%d/%Y")
    expect(page).to have_content("4")
    #expect(page).to have_content(time)
  end


  scenario "user fills in the form for an already completed date and sees the updated information on the homepage" do
    register_and_log_in("Seth")
    visit "scores/new"
    bev_section = page.find("#bev_button")
    within(bev_section) { choose "At Gather w/ a Stranger"} # + 4
    click_on("Submit")
    time = Time.now.strftime("%m/%d/%Y")
    visit "scores/new"
    bev_section = page.find("#bev_button")
    within(bev_section) { choose "In gSchool Classroom"} # + 1
    click_on("Submit")
    time = Time.now.strftime("%m/%d/%Y")
    expect(page).to have_content("1")
    #expect(page).to have_content(time)
  end




end