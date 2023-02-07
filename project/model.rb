require 'sqlite3'
require 'bcrypt'

def connect_to_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    return db
end

def get_all_for_username(username)
    db = connect_to_db('db/gym_tracker.db')
    result = db.execute('SELECT * FROM users WHERE username = ?',username).first
    return result
end

def register_user(username, firstname, password_digest)
    db = connect_to_db('db/gym_tracker.db')
    db.execute("INSERT INTO users (username, firstname, pwdigest) VALUES (?, ?, ?)", username, firstname, password_digest)
end

def get_all_usernames()
    db = connect_to_db('db/gym_tracker.db')
    result = db.execute('SELECT username FROM users')
    return result
end