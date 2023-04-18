module Model
    require 'sqlite3'
    require 'bcrypt'
    require 'sinatra/reloader'


    # Before-block that connects the other functions to the database and makes the result a hash
    def connect_to_db()
        db = SQLite3::Database.new('db/gym_tracker.db')
        db.results_as_hash = true
        return db
    end

    # Finds all information that is connected to a username
    #
    # @option params [String] username Searchterm
    #
    # @return [Hash]
    #   * :id [Integer] The ID of the user
    #   * :firstname [String] The firstname of the user
    #   * :pwdigest [String] The encrypted password of the user
    # @return [nil] if not found
    #
    # @see #connect_to_db
    def get_all_for_username(username)
        db = connect_to_db()
        result = db.execute('SELECT * FROM users WHERE username = ?',username).first
        return result
    end

    # Finds ID that is connected to a username
    #
    # @option params [String] username Searchterm
    #
    # @return [Hash]
    #   * :id [Integer] The ID of the user
    # @return [nil] if not found
    #
    # @see #connect_to_db
    def get_user_id(username)
        db = connect_to_db()
        result = db.execute('SELECT id FROM users WHERE username = ?', username)
        return result
    end

    # Finds firstname that is connected to a username
    #
    # @option params [String] username Searchterm
    #
    # @return [Hash]
    #   * :firstname [String] The firstname of the user
    # @return [nil] if not found
    #
    # @see #connect_to_db
    def get_user_firstname(username)
        db = connect_to_db()
        result = db.execute('SELECT firstname FROM users WHERE username = ?', username)
        return result
    end

    # Creates a new user in the users table 
    #
    # @option params [String] username Username of the user
    # @option params [String] firstname Firstname of the user
    # @option params [String] password_digest Encrypted password of the user
    #
    # @see #connect_to_db
    def register_user(username, firstname, password_digest)
        db = connect_to_db()
        db.execute("INSERT INTO users (username, firstname, pwdigest) VALUES (?, ?, ?)", username, firstname, password_digest)
    end

    # Finds all usernames in the table users
    #
    # @return [Hash]
    #   * :username [String] The username of the user
    # @return [nil] if not found
    #
    # @see #connect_to_db
    def get_all_usernames()
        db = connect_to_db()
        result = db.execute('SELECT username FROM users')
        return result
    end

    # Finds all exercise names in the table exercises
    #
    # @return [Hash]
    #   * :exercise_name [String] The exercise name
    # @return [nil] if not found
    #
    # @see #connect_to_db
    def get_all_exercise_names()
        db = connect_to_db()
        result = db.execute('SELECT exercise_name FROM exercises')
        return result
    end

    # Finds all muscle names in the table muscles
    #
    # @return [Hash]
    #   * :muscle_name [String] The muscle name
    # @return [nil] if not found
    #
    # @see #connect_to_db
    def get_all_muscle_names()
        db = connect_to_db()
        result = db.execute('SELECT muscle_name FROM muscles')
        return result
    end

    # Finds all musclegroup names in the table musclegroups
    #
    # @return [Hash]
    #   * :musclegroup_name [String] The musclegroup name
    # @return [nil] if not found
    #
    # @see #connect_to_db
    def get_all_musclegroup_names()
        db = connect_to_db()
        result = db.execute('SELECT musclegroup_name FROM musclegroups')
        return result
    end

    # Finds ID for the muscle name
    #
    # @option params [String] muscle_name Name of the muscle
    #
    # @return [Hash]
    #   * :id [Integer] The ID of the muscle
    # @return [nil] if not found 
    #
    # @see #connect_to_db
    def get_muscle_id(muscle_name)
        db = connect_to_db()
        result = db.execute('SELECT id FROM muscles WHERE muscle_name = ?', muscle_name)
        return result
    end

    # Finds ID for the exercise name
    #
    # @option params [String] exercise_name Name of the exercise
    #
    # @return [Hash]
    #   * :id [Integer] The ID of the exercise
    # @return [nil] if not found 
    #
    # @see #connect_to_db
    def get_exercise_id(exercise_name)
        db = connect_to_db()
        result = db.execute('SELECT id FROM exercises WHERE exercise_name = ?', exercise_name)
        return result
    end

    # Finds ID for the musclegroup name
    #
    # @option params [String] musclegroup_name Name of the exercise
    #
    # @return [Hash]
    #   * :id [Integer] The ID of the musclegroup
    # @return [nil] if not found 
    #
    # @see #connect_to_db
    def get_musclegroup_id(musclegroup_name)
        db = connect_to_db()
        result = db.execute('SELECT id FROM musclegroups WHERE musclegroup_name = ?', musclegroup_name)
        return result
    end

    # Finds all dates of the workouts connected to a user
    #
    # @option params [Interger] user_id ID of the user
    #
    # @return [Hash]
    #   * :date [Integer] The date of the workout
    # @return [nil] if not found 
    #
    # @see #connect_to_db
    def get_dates_for_workouts(user_id)
        db = connect_to_db()
        result = db.execute('SELECT date FROM workouts WHERE user_id = ?', user_id)
        return result
    end

    # Finds user ID for a workout
    #
    # @option params [Interger] id ID of the workout
    #
    # @return [Hash]
    #   * :user_id [Integer] The ID of the user
    # @return [nil] if not found 
    #
    # @see #connect_to_db
    def get_workout_user(id)
        db = connect_to_db()
        result = db.execute('SELECT user_id FROM workouts WHERE id = ?', id)
        return result
    end

    # Creates a new exercise in the exercises table and exercise_muscle_rel table
    #
    # @option params [String] exercise_name Name of the exercise
    # @option params [String] muscle_1 Muscle used in the exercise
    # @option params [String] muscle_2 Muscle used in the exercise
    # @option params [String] muscle_3 Muscle used in the exercise
    #
    # @see #connect_to_db
    def exercise_new(exercise_name, muscle_1, muscle_2, muscle_3)
        db = connect_to_db()

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

    # Finds all information for an exercise in the tables exercise and exercise_muscle_rel
    #
    # @return [Array]
    #   * :exercise_name [String] The name of the exercise
    #   * :muscle_name [String] The name of the muscles used
    #   * :id [Integer] The ID of the exercise
    # @return [nil] if not found 
    #
    # @see #connect_to_db
    def show_all_exercises()
        db = connect_to_db()

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
        db = connect_to_db()

        result = db.execute('SELECT exercises.exercise_name, muscles.muscle_name, exercises.id
                            FROM ((exercise_muscle_rel
                                INNER JOIN exercises ON exercise_muscle_rel.exercise_id = exercises.id)
                                INNER JOIN muscles ON exercise_muscle_rel.muscle_id = muscles.id)
                            WHERE exercise_id = ?', exercise_id)

        return result

    end

    def delete_exercise(id)
        db = connect_to_db()

        db.execute('DELETE FROM exercises WHERE id = ?', id)
        db.execute('DELETE FROM exercise_muscle_rel WHERE exercise_id = ?', id)

    end

    def edit_exercise(exercise_id, exercise_name, muscles_array)
        db = connect_to_db()

        db.execute('DELETE FROM exercise_muscle_rel WHERE exercise_id = ?', exercise_id)

        db.execute('UPDATE exercises SET exercise_name = ? WHERE id = ?', exercise_name, exercise_id)

        i = 0

        while i < muscles_array.length
            muscle_id = get_muscle_id(muscles_array[i])

            db.execute('INSERT INTO exercise_muscle_rel (exercise_id, muscle_id) VALUES (?, ?)', exercise_id, muscle_id[0][0])

            i += 1
        end
    end

    def workout_new(user_id, date, musclegroup_1, musclegroup_2, exercise_array)
        db = connect_to_db()
        db.results_as_hash = false

        db.execute('INSERT INTO workouts (user_id, date) VALUES (?, ?)', user_id, date)  
        workout_id = db.execute('SELECT id FROM workouts WHERE user_id = ? AND date = ?', user_id, date)
        workout_id = workout_id[0][0]
        
        musclegroup_1_id = get_musclegroup_id(musclegroup_1)
        musclegroup_1_id = musclegroup_1_id[0][0]

        db.execute('INSERT INTO workout_musclegroup_rel (workout_id, musclegroup_id) VALUES (?, ?)', workout_id, musclegroup_1_id)

        if musclegroup_2 != ""
            musclegroup_2_id = get_musclegroup_id(musclegroup_2)
            db.execute('INSERT INTO workout_musclegroup_rel (workout_id, musclegroup_id) VALUES (?, ?)', workout_id, musclegroup_2_id[0][0])
        end

        i = 0
        while i < exercise_array.length
            exercise_id = get_exercise_id(exercise_array[i][:exercise_name])
            db.execute('INSERT INTO workout_exercise_rel (workout_id, exercise_id, weight, reps, sets) VALUES (?, ?, ?, ?, ?)', workout_id, exercise_id[0][0], exercise_array[i][:weight], exercise_array[i][:reps], exercise_array[i][:sets])
            i += 1
        end

    end

    def show_workouts(user_id)
        db = connect_to_db()

        array_of_workouts = []

        workout_id = db.execute('SELECT id FROM workouts WHERE user_id = ?', user_id)

        i = 0
        while i < workout_id.length
            exercise_names = db.execute('SELECT exercises.exercise_name 
                                    FROM(workout_exercise_rel
                                        INNER JOIN exercises ON workout_exercise_rel.exercise_id = exercises.id)
                                    WHERE workout_id = ?', workout_id[i][0])
            k = 0
            exercise_array = []
            while k < exercise_names.length
                exercise_id = get_exercise_id(exercise_names[k][0])

                weight = db.execute('SELECT weight FROM workout_exercise_rel WHERE workout_id = ? AND exercise_id = ?', workout_id[i][0], exercise_id[0][0] )
                reps = db.execute('SELECT reps FROM workout_exercise_rel WHERE workout_id = ? AND exercise_id = ?', workout_id[i][0], exercise_id[0][0] )
                sets = db.execute('SELECT sets FROM workout_exercise_rel WHERE workout_id = ? AND exercise_id = ?', workout_id[i][0], exercise_id[0][0] )
                
                exercise_array.append({
                    exercise_name: exercise_names[k][0],
                    weight: weight[0][0],
                    reps: reps[0][0],
                    sets: sets[0][0]
                })
                k += 1
            end
            
            musclegroup_names = db.execute('SELECT musclegroups.musclegroup_name
                                            FROM (workout_musclegroup_rel
                                                INNER JOIN musclegroups ON workout_musclegroup_rel.musclegroup_id = musclegroups.id)
                                            WHERE workout_id = ?', workout_id[i][0])
            date = db.execute('SELECT date FROM workouts WHERE id= ?', workout_id[i][0])
            
            array_of_workouts.append({
                id: workout_id[i][0],
                date: date[0][0],
                musclegroups: musclegroup_names,
                exercises: exercise_array
            })

            i += 1  
        end

        return array_of_workouts
    end


    def show_specific_workout(workout_id)
        db = connect_to_db()
        
        exercise_names = db.execute('SELECT exercises.exercise_name 
                                    FROM(workout_exercise_rel
                                        INNER JOIN exercises ON workout_exercise_rel.exercise_id = exercises.id)
                                    WHERE workout_id = ?', workout_id)
        k = 0
        exercise_array = []
        while k < exercise_names.length
            exercise_id = get_exercise_id(exercise_names[k][0])

            weight = db.execute('SELECT weight FROM workout_exercise_rel WHERE workout_id = ? AND exercise_id = ?', workout_id, exercise_id[0][0] )
            reps = db.execute('SELECT reps FROM workout_exercise_rel WHERE workout_id = ? AND exercise_id = ?', workout_id, exercise_id[0][0] )
            sets = db.execute('SELECT sets FROM workout_exercise_rel WHERE workout_id = ? AND exercise_id = ?', workout_id, exercise_id[0][0] )
            
            exercise_array.append({
                exercise_name: exercise_names[k][0],
                weight: weight[0][0],
                reps: reps[0][0],
                sets: sets[0][0]
            })
            k += 1
        end
            
        musclegroup_names = db.execute('SELECT musclegroups.musclegroup_name
                                        FROM (workout_musclegroup_rel
                                            INNER JOIN musclegroups ON workout_musclegroup_rel.musclegroup_id = musclegroups.id)
                                        WHERE workout_id = ?', workout_id)
        date = db.execute('SELECT date FROM workouts WHERE id= ?', workout_id)
            
        return {
            id: workout_id,
            date: date[0][0],
            musclegroups: musclegroup_names,
            exercises: exercise_array
        }
    end

    def delete_workout(id)
        db = connect_to_db()

        db.execute('DELETE FROM workouts WHERE id = ?', id)
        db.execute('DELETE FROM workout_musclegroup_rel WHERE workout_id = ?', id)
        db.execute('DELETE FROM workout_exercise_rel WHERE workout_id = ?', id)

    end

    def workout_update(workout_id, date, musclegroup_1, musclegroup_2, exercise_array)
        db = connect_to_db()

        db.execute('DELETE FROM workout_musclegroup_rel WHERE workout_id = ?', workout_id)
        db.execute('DELETE FROM workout_exercise_rel WHERE workout_id = ?', workout_id)

        db.execute('UPDATE workouts SET date = ? WHERE id = ?', date, workout_id)

        musclegroup_1_id = get_musclegroup_id(musclegroup_1)
        musclegroup_1_id = musclegroup_1_id[0][0]

        db.execute('INSERT INTO workout_musclegroup_rel (workout_id, musclegroup_id) VALUES (?, ?)', workout_id, musclegroup_1_id)

        if musclegroup_2 != ""
            musclegroup_2_id = get_musclegroup_id(musclegroup_2)
            db.execute('INSERT INTO workout_musclegroup_rel (workout_id, musclegroup_id) VALUES (?, ?)', workout_id, musclegroup_2_id[0][0])
        end

        i = 0
        while i < exercise_array.length
            exercise_id = get_exercise_id(exercise_array[i][:exercise_name])
            db.execute('INSERT INTO workout_exercise_rel (workout_id, exercise_id, weight, reps, sets) VALUES (?, ?, ?, ?, ?)', workout_id, exercise_id[0][0], exercise_array[i][:weight], exercise_array[i][:reps], exercise_array[i][:sets])
            i += 1
        end

    end


end