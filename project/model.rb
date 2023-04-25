# Module that contains functions
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
    # @param [String] username Searchterm
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
    # @param [String] username Searchterm
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
    # @param [String] username Searchterm
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
    # @param [String] username Username of the user
    # @param [String] firstname Firstname of the user
    # @param [String] password_digest Encrypted password of the user
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
    # @param [String] muscle_name Name of the muscle
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
    # @param [String] exercise_name Name of the exercise
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
    # @param [String] musclegroup_name Name of the exercise
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
    # @param [Interger] user_id ID of the user
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
    # @param [Interger] id ID of the workout
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
    # @param [String] exercise_name Name of the exercise
    # @param [String] muscle_1 Muscle used in the exercise
    # @param [String] muscle_2 Muscle used in the exercise
    # @param [String] muscle_3 Muscle used in the exercise
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

    # Finds all information for all exercises in the tables exercise and exercise_muscle_rel
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

    # Finds all information for an exercise in the tables exercise and exercise_muscle_rel
    #
    # @return [Hash]
    #   * :exercise_name [String] The name of the exercise
    #   * :muscle_name [String] The name of the muscles used
    #   * :id [Integer] The ID of the exercise
    # @return [nil] if not found 
    #
    # @see #connect_to_db
    def show_specific_exercise(exercise_id)
        db = connect_to_db()

        result = db.execute('SELECT exercises.exercise_name, muscles.muscle_name, exercises.id
                            FROM ((exercise_muscle_rel
                                INNER JOIN exercises ON exercise_muscle_rel.exercise_id = exercises.id)
                                INNER JOIN muscles ON exercise_muscle_rel.muscle_id = muscles.id)
                            WHERE exercise_id = ?', exercise_id)

        return result

    end

    # Deletes an exercise
    #
    # @param [Integer] id ID of the exercise
    #
    # @see #connect_to_db
    def delete_exercise(id)
        db = connect_to_db()

        db.execute('DELETE FROM exercises WHERE id = ?', id)
        db.execute('DELETE FROM exercise_muscle_rel WHERE exercise_id = ?', id)

    end

    # Updates the information of an exercise
    #
    # @param [Integer] exercise_id ID of the exercise
    # @param [String] exercise_name Name of the exercise
    # @param [Array] muscles_array Array containing the muscles used
    #
    # @see #connect_to_db
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

    # Creates a new workout in the workout, workout_exercise_rel and workout_musclegroup_rel tables
    #
    # @param [Integer] user_id ID of the user connected to the workout
    # @param [Integer] date Date of the workout 
    # @param [String] musclegroup_1 Musclegroup used in the exercise
    # @param [String] musclegroup_2 Musclegroup used in the exercise
    # @param [Array] exercise_array Array containing the exercises information
    #
    # @see #connect_to_db
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

    # Finds all information for all workouts connected to a user
    #
    # @param [Integer] user_id The users ID
    #
    # @return [Array]
    #   * :id [Integer] ID of the workout
    #   * :date [Integer] Date of the workout
    #   * :musclegroups [Hash] The musclegroups used in the workout
    #   * :musclegroups [Array] Array containing exercise_name, reps, sets and weight of an exercise
    # @return [nil] if not found 
    #
    # @see #connect_to_db
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

    # Finds all information for a specific workout
    #
    # @param [Integer] workout_id The workouts ID
    #
    # @return [Hash]
    #   * :id [Integer] ID of the workout
    #   * :date [Integer] Date of the workout
    #   * :musclegroups [Hash] The musclegroups used in the workout
    #   * :musclegroups [Array] Array containing exercise_name, reps, sets and weight of an exercise
    # @return [nil] if not found 
    #
    # @see #connect_to_db
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

    # Deletes an workout
    #
    # @param [Integer] id ID of the workout
    #
    # @see #connect_to_db
    def delete_workout(id)
        db = connect_to_db()

        db.execute('DELETE FROM workouts WHERE id = ?', id)
        db.execute('DELETE FROM workout_musclegroup_rel WHERE workout_id = ?', id)
        db.execute('DELETE FROM workout_exercise_rel WHERE workout_id = ?', id)

    end

    # Updates the information of an workout
    #
    # @param [Integer] workout_id ID of the workout
    # @param [Integer] date The date of the workout
    # @param [String] musclegroup_1 Musclegroup used
    # @param [String] musclegroup_2 Musclegroup used
    # @param [Array] exercise_array Array containing the exercises
    #
    # @see #connect_to_db
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