require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'

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

def get_all_muscle_names()
    db = connect_to_db('db/gym_tracker.db')
    result = db.execute('SELECT muscle_name FROM muscles')
    return result
end

def get_all_musclegroup_names()
    db = connect_to_db('db/gym_tracker.db')
    result = db.execute('SELECT musclegroup_name FROM musclegroups')
    return result
end

def get_muscle_id(muscle_name)
    db = connect_to_db('db/gym_tracker.db')
    result = db.execute('SELECT id FROM muscles WHERE muscle_name = ?', muscle_name)
    return result
end

def get_exercise_id(exercise_name)
    db = connect_to_db('db/gym_tracker.db')
    result = db.execute('SELECT id FROM exercises WHERE exercise_name = ?', exercise_name)
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

def show_all_exercises()
    db = connect_to_db('db/gym_tracker.db')

    exercise_ids = db.execute('SELECT id FROM exercises')

    array_of_exercises = []
    i = 0

    while i < exercise_ids.length

        result = db.execute('SELECT exercises.exercise_name, muscles.muscle_name, exercises.id
                            FROM ((exercise_muscle_rel
                                INNER JOIN exercises ON exercise_muscle_rel.exercise_id = exercises.id)
                                INNER JOIN muscles ON exercise_muscle_rel.muscle_id = muscles.id)
                            WHERE exercise_id = ?', exercise_ids[i][0])

        array_of_exercises.append(result)

        i += 1
    end

    return array_of_exercises
end

def show_specific_exercise(exercise_id)
    db = connect_to_db('db/gym_tracker.db')

    result = db.execute('SELECT exercises.exercise_name, muscles.muscle_name, exercises.id
                        FROM ((exercise_muscle_rel
                            INNER JOIN exercises ON exercise_muscle_rel.exercise_id = exercises.id)
                            INNER JOIN muscles ON exercise_muscle_rel.muscle_id = muscles.id)
                        WHERE exercise_id = ?', exercise_id)

    return result

end

def delete_exercise(id)
    db = connect_to_db('db/gym_tracker.db')

    db.execute('DELETE FROM exercises WHERE id = ?', id)
    db.execute('DELETE FROM exercise_muscle_rel WHERE exercise_id = ?', id)

end

def edit_exercise(exercise_id, exercise_name, muscles_array)
    db = connect_to_db('db/gym_tracker.db')

    db.execute('DELETE FROM exercise_muscle_rel WHERE exercise_id = ?', exercise_id)

    db.execute('UPDATE exercises SET exercise_name = ? WHERE id = ?', exercise_name, exercise_id)

    i = 0

    while i < muscles_array.length
        muscle_id = get_muscle_id(muscles_array[i])
        p muscle_id
        p exercise_id
        db.execute('INSERT INTO exercise_muscle_rel (exercise_id, muscle_id) VALUES (?, ?)', exercise_id, muscle_id[0][0])

        i += 1
    end


end