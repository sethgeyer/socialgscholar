class Scores
  def initialize(db_connection)
    @database_connection = db_connection
  end

  def create_initial_score(user_id)
    create_sql_string =
      <<-TEXT
        INSERT INTO scores (user_id, activity_date, beverage, pong, network, learning, badass_code, total_score)
        VALUES (#{user_id},
               '#{Time.now.strftime("%m/%d/%Y")}',
                0,
                0,
                0,
                0,
                0,
                0)
      TEXT
    @database_connection.sql(create_sql_string)
  end

  def get_the_last_two_weeks_of_scores(id, date_two_weeks_ago)
    @database_connection.sql("SELECT * FROM scores WHERE user_id = #{id} AND activity_date > '#{date_two_weeks_ago}' ORDER BY activity_date ")
  end

  def run_scores_totals(order_by_value, date)
    # date = (Time.new - (2 * 7 * 24 * 60 * 60)).strftime("%Y-%m-%d")
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

  def determine_whether_to_create_a_new_score_or_update_an_existing_score(id, activity_date, beverage_score, pong_score, network_score, learning_score, badass_code_score, total_score)
    if @database_connection.sql("SELECT * FROM scores WHERE user_id = #{id} AND activity_date = '#{activity_date}'") != []
      update_sql_string = <<-TEXT
                            UPDATE scores
                            SET beverage= #{beverage_score},
                                pong= #{pong_score},
                                network=#{network_score},
                                learning=#{learning_score},
                                badass_code=#{badass_code_score},
                                total_score=#{total_score}
                            WHERE user_id = #{id} AND activity_date = '#{activity_date}'
                          TEXT
      @database_connection.sql(update_sql_string)
    else
      create_sql_string = <<-TEXT
                            INSERT INTO scores (user_id, activity_date, beverage, pong, network, learning, badass_code, total_score)
                            VALUES (#{id},
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


end