feature "New Score Page" do
  before(:each) do
    @date = Time.now.strftime("%m/%d/%Y")
  end

  scenario "visitor does not have access to this page unless logged in" do
    visit "scores/new"
    expect(page).to have_content("Scoreboard")
  end

  scenario "logged in user sees a Activity Form on the page" do
    register_and_log_in("Seth")
    visit "scores/new"
    section = page.find("#bev_button")
    section_content = ["Enjoyed a Beverage", "Nope", "Drank Too Much and Made a Jack-Ass of Myself"]
    expect(section).to have_content(section_content[0])
    expect(section).to have_content(section_content[1])
    expect(section).to have_content(section_content[2])

    section = page.find("#pong_button")
    section_content = ["Played Ping-Pong (or some other game", "Nope", "In gSchool with a:"]
    expect(section).to have_content(section_content[0])
    expect(section).to have_content(section_content[1])
    expect(section).to have_content(section_content[2])

    section = page.find("#network_button")
    section_content = ["Networked My Ass Off", "Nope", "Attended a Networking Meetup"]
    expect(section).to have_content(section_content[0])
    expect(section).to have_content(section_content[1])
    expect(section).to have_content(section_content[2])

    section = page.find("#learning_button")
    section_content = ["Contributed to the gSchool Learning Experience", "Nope", "Paired"]
    expect(section).to have_content(section_content[0])
    expect(section).to have_content(section_content[1])
    expect(section).to have_content(section_content[2])

    section = page.find("#badass_button")
    section_content = ["Wrote Some Totally Badass Code", "Nope", "Pushed Exercises to GitHub"]
    expect(section).to have_content(section_content[0])
    expect(section).to have_content(section_content[1])
    expect(section).to have_content(section_content[2])

  end

  scenario "user sees the current day in the form" do
    register_and_log_in("Seth")
    visit "scores/new"
    expect(page).to have_content(@date)
  end

  scenario "user fills in the form and is routed back to the home page" do
    register_and_log_in("Seth")
    make_a_choice_by_pressing_a_radio_button("#bev_button", "Drank Too Much and Made a Jack-Ass of Myself", @date)
    section = page.find("#leaderboard")
    expect(section).to have_content("Scoreboard")
  end

  scenario "user fills in the form and sees their updated score on the homepage" do
    register_and_log_in("Seth")
    make_a_choice_by_pressing_a_radio_button("#bev_button", "At Gather w/ a Stranger", @date)
    section = page.find("#leaderboard")
    expect(section).to have_content("Seth")
    section = page.find("#beer")
    expect(section).to have_content("4")
    #expect(page).to have_content(time)
  end


  scenario "user fills in the form for an already completed date and sees the updated information on the homepage" do
    register_and_log_in("Seth")
    make_a_choice_by_pressing_a_radio_button("#bev_button", "At Gather w/ a Stranger", @date) # +4
    make_a_choice_by_pressing_a_radio_button("#bev_button", "Drank Too Much and Made a Jack-Ass of Myself", @date) # -5
    section = page.find("#leaderboard")
    expect(section).to have_content("-5")
  end

  scenario "user fills in the form for the default date and second date" do
    register_and_log_in("Seth")
    make_a_choice_by_pressing_a_radio_button("#bev_button", "At Gather w/ a Stranger", @date) # +4
    second_date = (Time.now - 86400).strftime("%m/%d/%Y")
    make_a_choice_by_pressing_a_radio_button("#bev_button", "Drank Too Much and Made a Jack-Ass of Myself", second_date) # -5
    section = page.find("#leaderboard")
    expect(section).to have_content("-1")
  end

  scenario "user sees their scores and other's scores" do
    register_and_log_in("Stan")
    make_a_choice_by_pressing_a_radio_button("#bev_button", "At Gather w/ a Stranger", @date)
    click_on "Logout"
    register_and_log_in("Seth")
    make_a_choice_by_pressing_a_radio_button("#bev_button", "At Gather w/ a Stranger", @date)
    section = page.find("#leaderboard")
    expect(section).to have_content("Stan")
  end

  scenario "user selects a pong radio button and submits" do
    register_and_log_in("Seth")
    make_a_choice_by_pressing_a_radio_button("#pong_button", "gSchooler (student or instructor)", @date)
    section = page.find("#leaderboard")
    expect(section).to have_content("Seth")
    section = page.find("#pong")
    expect(section).to have_content("1")

  end

  scenario "user selects a network radio button and submits" do
    register_and_log_in("Seth")
    make_a_choice_by_pressing_a_radio_button("#network_button", "Attended a Networking Meetup or Hack-Nite Event", @date)
    section = page.find("#leaderboard")
    expect(section).to have_content("Seth")
    section = page.find("#network")
    expect(section).to have_content("5")
  end

  scenario "user selects a learning radio button and submits" do
    register_and_log_in("Seth")
    make_a_choice_by_pressing_a_radio_button("#learning_button", "Paired", @date)
    section = page.find("#leaderboard")
    expect(section).to have_content("Seth")
    section = page.find("#learning")
    expect(section).to have_content("1")
  end

  scenario "user selects a badass_code radio button and submits" do
    register_and_log_in("Seth")
    make_a_choice_by_pressing_a_radio_button("#badass_button", "Launched a NEW Personal Project on Heroku", @date)
    section = page.find("#leaderboard")
    expect(section).to have_content("Seth")
    section = page.find("#badass_code")
    expect(section).to have_content("15")
  end

  scenario "user logs two days of different activities" do
    register_and_log_in("Seth")
    make_a_choice_by_pressing_a_radio_button("#bev_button", "At Gather w/ a Stranger", @date) # +4
    second_date = (Time.now - 86400).strftime("%m/%d/%Y")
    make_a_choice_by_pressing_a_radio_button("#badass_button", "Launched a NEW Personal Project on Heroku", second_date) # +15
    section = page.find("#total_score")
    expect(section).to have_content("20")  # <- includes the default +1 value for push to GitHub
  end

  scenario "user logs an entry" do
    register_and_log_in("Seth")
    make_a_choice_by_pressing_a_radio_button("#bev_button", "At Gather w/ a Stranger", @date)
  end





  scenario "user decides not to input an activity" do
    register_and_log_in("Seth")
    visit "/scores/new"
    click_on "Cancel"
    expect(page).to have_content("Scoreboard")
  end



end