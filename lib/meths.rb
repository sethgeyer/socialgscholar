def establish_current_user_and_create_session (username, password)
  current_user = @database_connection.sql("SELECT * FROM users WHERE username= '#{username}' AND password= '#{password}'").first
  flash[:notice] = "Welcome #{username}!"
  session[:user_id] = current_user['id']
end

def create_appropriate_error_message(username, password)
  if username == "" && password == ""
    "Password and Username is required"
  elsif username == ""
    "Username is required"
  elsif password == ""
    "Password is required"
  end
end

def add_user_to_database(username, password)
  @database_connection.sql("INSERT INTO users (username, password) VALUES ('#{username}', '#{password}')")
  establish_current_user_and_create_session(params[:username], params[:password])
  redirect "/"
rescue
  flash[:notice] = "Username is already taken"
  redirect '/users/new'
end