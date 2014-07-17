def establish_current_user_and_create_session (username, password)
  current_user = @database_connection.sql("SELECT * FROM users WHERE username= '#{username}' AND password= '#{password}'").first
  if current_user != nil
  flash[:notice] = "Welcome #{username}!"
  session[:user_id] = current_user['id']
  else
  flash[:notice] = "The username and password combination you entered is not valid.  Try again."
  end
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

def add_user_to_database(username, password, image_url=nil)
  @database_connection.sql("INSERT INTO users (username, password, image_url) VALUES ('#{username}', '#{password}', '#{image_url}')")
  establish_current_user_and_create_session(params[:username], params[:password])
  create_sql_string = <<-TEXT
                            INSERT INTO scores (user_id, activity_date, beverage, pong, network, learning, badass_code, total_score)
                            VALUES (#{session[:user_id].to_i},
                                   '#{Time.now.strftime("%m/%d/%Y")}',
                                    0,
                                    0,
                                    0,
                                    0,
                                    0,
                                    0)
  TEXT
  @database_connection.sql(create_sql_string)
  redirect "/"
rescue
  flash[:notice] = "Username is already taken"
  redirect '/users/new'
end

def determine_whether_to_create_a_new_score_or_update_an_existing_score(activity_date, beverage_score, pong_score, network_score, learning_score, badass_code_score, total_score)
  if @database_connection.sql("SELECT * FROM scores WHERE user_id = #{session[:user_id].to_i} AND activity_date = '#{activity_date}'") != []
    update_sql_string = <<-TEXT
                            UPDATE scores
                            SET beverage= #{beverage_score},
                                pong= #{pong_score},
                                network=#{network_score},
                                learning=#{learning_score},
                                badass_code=#{badass_code_score},
                                total_score=#{total_score}
                            WHERE user_id = #{session[:user_id].to_i} AND activity_date = '#{activity_date}'
                          TEXT
    @database_connection.sql(update_sql_string)
  else
    create_sql_string = <<-TEXT
                            INSERT INTO scores (user_id, activity_date, beverage, pong, network, learning, badass_code, total_score)
                            VALUES (#{session[:user_id].to_i},
                                   '#{activity_date}',
                                    #{beverage_score},
                                    #{pong_score},
                                    #{network_score},
                                    #{learning_score},
                                    #{badass_code_score},
                                    #{total_score})
    TEXT
    @database_connection.sql(create_sql_string)
  end
end

def run_scores_totals(order_by_value)
  date = (Time.new - (2 * 7 * 24 * 60 * 60)).strftime("%Y-%m-%d")
  sql_string = <<-STRING
                  SELECT users.id, users.image_url, users.username,
                    SUM(scores.beverage) AS beer,
                    SUM(scores.pong) AS pong,
                    SUM(scores.network) AS network,
                    SUM(scores.learning) AS learning,
                    SUM(scores.badass_code) AS code,
                    SUM(scores.total_score) AS total_score
                  FROM scores
                  JOIN users
                  ON scores.user_id = users.id
                  WHERE activity_date > '#{date}'
                  GROUP BY users.id
                  ORDER BY SUM(scores.#{order_by_value}) DESC

  STRING
  @database_connection.sql(sql_string)
end
