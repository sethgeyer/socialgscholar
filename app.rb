require "sinatra"
require "active_record"
require_relative "lib/users"
require_relative "lib/scores"
require "rack-flash"
require "gschool_database_connection"

class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    @users = Users.new(GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"]))
    @scores = Scores.new(GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"]))

    @database_connection = GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])
  end

  get "/" do
    date_two_weeks_ago = (Time.new - (2 * 7 * 24 * 60 * 60)).strftime("%Y-%m-%d")
    all_scores = @scores.run_scores_totals("total_score", date_two_weeks_ago)
    beverage_score = @scores.run_scores_totals("beverage", date_two_weeks_ago)
    pong_score = @scores.run_scores_totals("pong", date_two_weeks_ago)
    network_score = @scores.run_scores_totals("network", date_two_weeks_ago)
    learning_score = @scores.run_scores_totals("learning", date_two_weeks_ago)
    badass_code_score = @scores.run_scores_totals("badass_code", date_two_weeks_ago)
    user = @users.find_by_id(session[:user_id]) if session[:user_id]
    erb :home, locals: {all_scores: all_scores,
                        beverage_score: beverage_score,
                        pong_score: pong_score,
                        network_score: network_score,
                        learning_score: learning_score,
                        badass_code_score: badass_code_score,
                        user: user,
                        date_two_weeks_ago: date_two_weeks_ago}
  end

  get "/activity/:id" do
    date_two_weeks_ago = (Time.new - (2 * 7 * 24 * 60 * 60)).strftime("%Y-%m-%d")
    id = params[:id].to_i
    activity = @scores.get_the_last_two_weeks_of_scores(id, date_two_weeks_ago)
    erb :user_activity, locals: {activity: activity}
  end

  get "/scores/new" do
    if session[:user_id]
      today = Time.now
      last_three_days = [today.strftime("%m/%d/%Y"), (today - 86400).strftime("%m/%d/%Y"), (today - 86400 - 86400).strftime("%m/%d/%Y")]
      erb :new_score, :locals => {dates: last_three_days}
    else
      redirect "/"
    end
  end

  post "/scores" do
    id = session[:user_id].to_i
    activity_date = params[:activity_date]
    beverage_score = params[:radio_beverage].to_i
    pong_score = params[:radio_pong].to_i
    network_score = params[:radio_network].to_i
    learning_score = params[:radio_learning].to_i
    badass_code_score = params[:radio_badass].to_i
    total_score = beverage_score + pong_score + network_score + learning_score + badass_code_score
    @scores.determine_whether_to_create_a_new_score_or_update_an_existing_score(id, activity_date, beverage_score, pong_score, network_score, learning_score, badass_code_score, total_score)
    redirect "/"
  end

  get "/logout" do
    session.delete(:user_id)
    redirect "/"
  end

  get "/users/new" do
    erb :new_user, :layout => false
  end

  post "/users" do
    if params[:username] == "" || params[:password] == ""
      flash[:notice] = create_appropriate_error_message(params[:username], params[:password])
      redirect '/users/new'
    else
      begin
        @users.add_to_dbase(params[:username], params[:password], params[:image_url])
        current_user = @users.find_in_dbase(params[:username], params[:password])
        create_session_and_flash_message(current_user)
        @scores.create_initial_score(current_user['id'].to_i)
        redirect "/"
      rescue
        flash[:notice] = "Username is already taken"
        redirect '/users/new'
      end
    end
  end

  get "/users/edit" do
    if session[:user_id]
      user = @users.find_by_id(session[:user_id])
      erb :edit_user, locals: {:current_user => user}
    else
      redirect "/"
    end
  end

  put "/users/put" do
    new_password = params[:password]
    new_image_url = params[:image_url]
    if new_password != ""
      @users.update_profile_info(new_password, new_image_url, session[:user_id].to_i)
      flash[:notice] = "Your changes have been saved"
      redirect "/"
    else
      flash[:notice] = "You Must Input a Valid Password"
      user = @users.find_by_id(session[:user_id])
      erb :edit_user, locals: {:current_user => user}
    end
  end

  post "/login" do
    current_user = @users.find_in_dbase(params[:username], params[:password])
    create_session_and_flash_message(current_user)
    redirect "/"
  end

  def create_session_and_flash_message(current_user)
    if current_user != nil
      flash[:notice] = "Welcome #{params[:username]}!"
      session[:user_id] = current_user['id']
    else
      flash[:notice] = "The username and password combination you entered is not valid.  Try again."
    end
  end

  def create_appropriate_error_message(username, password) #1
    if username == "" && password == ""
      "Password and Username is required"
    elsif username == ""
      "Username is required"
    elsif password == ""
      "Password is required"
    end
  end


end
