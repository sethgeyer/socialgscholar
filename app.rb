require "sinatra"
require "active_record"
require "./lib/database_connection"
require "rack-flash"
require "./lib/meths"

class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    @database_connection = DatabaseConnection.establish(ENV["RACK_ENV"])
  end

  get "/" do

    all_scores = run_scores_totals("total_score")
    beverage_score = run_scores_totals("beverage")
    pong_score = run_scores_totals("pong")
    network_score = run_scores_totals("network")
    learning_score = run_scores_totals("learning")
    badass_code_score = run_scores_totals("badass_code")

    user = @database_connection.sql("SELECT * FROM users WHERE id = #{session[:user_id].to_i}").first if session[:user_id]

    erb :home, locals: {all_scores: all_scores,
                        beverage_score: beverage_score,
                        pong_score: pong_score,
                        network_score: network_score,
                        learning_score: learning_score,
                        badass_code_score: badass_code_score,
                        user: user}
  end

  get "/scores/new" do
    if session[:user_id]
      last_three_days = [Time.now.strftime("%m/%d/%Y"), (Time.now - 86400).strftime("%m/%d/%Y"), (Time.now - 86400 - 86400).strftime("%m/%d/%Y")]
      erb :new_score, :locals => {dates: last_three_days}
    else
      redirect "/"
    end
  end

  post "/scores" do
    activity_date = params[:activity_date]
    beverage_score = params[:radio_beverage].to_i
    pong_score = params[:radio_pong].to_i
    network_score = params[:radio_network].to_i
    learning_score = params[:radio_learning].to_i
    badass_code_score = params[:radio_badass].to_i
    total_score = beverage_score + pong_score + network_score + learning_score + badass_code_score
    determine_whether_to_create_a_new_score_or_update_an_existing_score(activity_date, beverage_score, pong_score, network_score, learning_score, badass_code_score, total_score)
    redirect "/"
  end

  get "/logout" do
    session.delete(:user_id)
    redirect "/"
  end

  get "/users/new" do
    erb :new_user, :layout => false
  end

  get "/users/edit" do
    if session[:user_id]
      user = @database_connection.sql("SELECT * FROM users WHERE id=#{session[:user_id].to_i}").first
      erb :edit_user, locals: {:current_user => user}
    else
      redirect "/"
    end
  end

  put "/users/put" do
    new_password = params[:password]
    new_image_url = params[:image_url]
    if new_password != ""
      @database_connection.sql("UPDATE users SET password='#{new_password}', image_url='#{new_image_url}' WHERE id=#{session[:user_id].to_i}").first
      flash[:notice] = "Your changes have been saved"
      redirect "/"
    else
      flash[:notice] = "You Must Input a Valid Password"
      user = @database_connection.sql("SELECT * FROM users WHERE id=#{session[:user_id].to_i}").first
      erb :edit_user, locals: {:current_user => user}
    end
  end


  post "/login" do
    establish_current_user_and_create_session(params[:username], params[:password])
    redirect "/"
  end

  post "/users" do
    if params[:username] == "" || params[:password] == ""
      flash[:notice] = create_appropriate_error_message(params[:username], params[:password])
      redirect '/users/new'
    else
      add_user_to_database(params[:username], params[:password], params[:image_url])
    end
  end
end
