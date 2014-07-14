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

def determine_whether_to_create_a_new_score_or_update_an_existing_score(activity_date, beverage_score, pong_score, network_score)
  if @database_connection.sql("SELECT * FROM scores WHERE user_id = #{session[:user_id].to_i} AND activity_date = '#{activity_date}'") != []
    @database_connection.sql("UPDATE scores SET beverage= #{beverage_score}, pong= #{pong_score}, network=#{network_score} WHERE user_id = #{session[:user_id].to_i} AND activity_date = '#{activity_date}'")
  else
    @database_connection.sql("INSERT INTO scores (user_id, activity_date, beverage, pong, network) VALUES (#{session[:user_id].to_i}, '#{activity_date}', #{beverage_score}, #{pong_score}, #{network_score} )")
  end
end