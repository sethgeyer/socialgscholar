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
    sql_string = <<-STRING
                  SELECT users.id, users.username,
                    SUM(scores.beverage) AS beer,
                    SUM(scores.pong) AS pong,
                    SUM(scores.network) AS network,
                    SUM(scores.learning) AS learning,
                    SUM(scores.badass_code) AS code,
                    SUM(scores.total_score) AS total_score
                  FROM scores
                  JOIN users
                  ON scores.user_id = users.id
                  GROUP BY users.id
                  ORDER BY SUM(scores.total_score) DESC
                  STRING
    all_scores = @database_connection.sql(sql_string)
    user = @database_connection.sql("SELECT * FROM users WHERE id = #{session[:user_id].to_i}").first if session[:user_id]

    erb :home, locals: {all_scores: all_scores, user: user}
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
    erb :new_user
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
