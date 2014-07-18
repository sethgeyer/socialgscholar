class Users
  def initialize(db_connection)
    @database_connection = db_connection
  end

  def add_to_dbase(username, password, image_url)
    image = "http://www.digitaltonto.com/wp-content/uploads/2013/03/Young-Bill-Gates-e1365202494393.png" if image_url == ""
    @database_connection.sql("INSERT INTO users (username, password, image_url) VALUES ('#{username}', '#{password}', '#{image}')")
  end

  def find_in_dbase(username, password)
    @database_connection.sql("SELECT * FROM users WHERE username= '#{username}' AND password= '#{password}'").first
  end

  def find_by_id(user_id)
    @database_connection.sql("SELECT * FROM users WHERE id=#{user_id.to_i}").first
  end

  def update_profile_info(new_password, new_image_url, user_id)
    @database_connection.sql("UPDATE users SET password='#{new_password}', image_url='#{new_image_url}' WHERE id=#{user_id}").first
  end







end


