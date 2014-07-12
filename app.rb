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
    erb :home
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
