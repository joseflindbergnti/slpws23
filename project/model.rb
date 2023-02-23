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

def get_all_exercise_names()
    db = connect_to_db('db/gym_tracker.db')
    result = db.execute('SELECT exercise_name FROM exercises')
    return result
end

def exercise_new(exercise_name, muscle_1, muscle_2, muscle_3)
    db = connect_to_db('db/gym_tracker.db')

    db.execute("INSERT INTO exercises (exercise_name) VALUES (?)", exercise_name)
    exercise_id = db.execute("SELECT id FROM exercises WHERE exercise_name = ?", exercise_name)

    if muscle_2 == ""
        muscle_ids = db.execute("SELECT id FROM muscles WHERE muscle_name = (?)", muscle_1)
    elsif muscle_3 == ""
        muscle_ids = db.execute("SELECT id FROM muscles WHERE muscle_name IN (?, ?)", muscle_1, muscle_2)     
    else
        muscle_ids = db.execute("SELECT id FROM muscles WHERE muscle_name IN (?, ?, ?)", muscle_1, muscle_2, muscle_3)
    end

    i = 0

    while i < muscle_ids.length

        db.execute("INSERT INTO exercise_muscle_rel (exercise_id, muscle_id) VALUES (?, ?)", exercise_id[0][0], muscle_ids[i][0])
        
        i += 1
    end
end