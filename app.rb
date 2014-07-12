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
    all_scores = @database_connection.sql("SELECT scores.user_id, SUM(scores.beverage) from scores GROUP BY scores.user_id")
    erb :home, locals: {all_scores: all_scores}
  end

  get "/scores/new" do
    if session[:user_id]
      erb :new_score
    else
      redirect "/"
    end
  end

  post "/scores" do
    activity_date = params[:activity_date]
    beverage_score = params[:radio_beverage].to_i
    if @database_connection.sql("SELECT * FROM scores WHERE user_id = #{session[:user_id].to_i} AND activity_date = '#{activity_date}'") != []
      @database_connection.sql("UPDATE scores SET beverage= #{beverage_score} WHERE user_id = #{session[:user_id].to_i} AND activity_date = '#{activity_date}'")
    else
      @database_connection.sql("INSERT INTO scores (user_id, activity_date, beverage) VALUES (#{session[:user_id].to_i}, '#{activity_date}', #{beverage_score})")
    end
    redirect "/"
  end

  get '/logout' do
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
      add_user_to_database(params[:username], params[:password])
    end
  end
end
