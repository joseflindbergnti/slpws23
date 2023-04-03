require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require_relative './model.rb'

enable :sessions


get('/')do
    session[:register_message] = ""
    session[:login_message] = ""
    slim(:index)
end

get('/error')do
    slim(:error)
end

def check_if_user_is_logged_in()
    if session[:user_id] == nil
        return false
    else 
        return true
    end
end

get('/workouts')do
    session[:workout_new_message] = ""
    if session[:user_id] == nil
        session[:login_message] = "You need to login to have access workouts"
        redirect('/login')
    else
        user_id = session[:user_id] ##fråga om detta är sättet som man ska spara användardatan
        @array_of_workouts = show_workouts(user_id)
        slim(:'workouts/index')
    end
end

get('/workouts/:id/edit')do
    if check_if_user_is_logged_in() == false
        session[:error_message] = "You do not have access to this functionality"
        redirect('/error')
    end
    workout_id = params[:id]
    if get_workout_user(workout_id)[0][0] != session[:user_id]
        session[:error_message] = "You do not have the ownership of this workout"
        redirect('/error')
    end

    @workout = show_specific_workout(workout_id)
    slim(:'workouts/edit')

end

get('/workouts/:id/update')do
    if check_if_user_is_logged_in() == false
        session[:error_message] = "You do not have access to this functionality"
        redirect('/error')
    end
    workout_id = params[:id]
    if get_workout_user(workout_id)[0][0] != session[:user_id]
        session[:error_message] = "You do not have the ownership of this workout"
        redirect('/error')
    end

    @musclegroup_names = get_all_musclegroup_names()
    @exercise_names = get_all_exercise_names()
    @workout = show_specific_workout(workout_id)
    slim(:'workouts/update')

end

get('/workouts/new')do
    @musclegroup_names = get_all_musclegroup_names()
    @exercise_names = get_all_exercise_names()
    slim(:'workouts/new')
end

def check_workout_inputs(exercise, reps, sets, number)
    exercise_names = get_all_exercise_names()
    i = 0
    k = 0
    while i < exercise_names.length
        if exercise_names[i][0] == exercise
            k += 1
        end
        i += 1
    end

    if k == 0
        session[:workout_new_message] = "Exercise #{number} does not exist"
        return false
    elsif reps == ""
        session[:workout_new_message] = "Add reps to exercise #{number}"
        return false
    elsif sets == ""
        session[:workout_new_message] = "Add sets to exercise #{number}"
        return false
    end
    return true
end

post('/workouts/new')do

    if check_if_user_is_logged_in() == false
        session[:error_message] = "You do not have access to this functionality"
        redirect('/error')
    end

    date = params[:date]
    

    if date == ""
        session[:workout_new_message] = "Choose a date"
        redirect('/workouts/new')
    end

    date_compare = get_dates_for_workouts(session[:user_id])
    i = 0
    while i < date_compare.length
        if date == date_compare[i][0]
            session[:workout_new_message] = "You already have a workout on this day"
            redirect('/workouts/new')
        end
        i += 1
    end


    musclegroup_1 = params[:musclegroup_1]
    musclegroup_2 = params[:musclegroup_2]

    if musclegroup_1 == ""
        session[:workout_new_message] = "Choose at least one musclegroup"
        redirect('/workouts/new')
    end

    workout_exercise_array = []

    exercise_1 = params[:exercise_1]
    if exercise_1 != ""
        weight_1 = params[:weight_1]
        reps_1 = params[:reps_1]
        sets_1 = params[:sets_1]

        if check_workout_inputs(exercise_1, reps_1, sets_1, 1) == true
            workout_exercise_array.append({
                exercise_name: exercise_1,
                weight: weight_1,
                reps: reps_1,
                sets: sets_1
            })
        else
            redirect('/workouts/new')
        end
    end

    exercise_2 = params[:exercise_2]
    if exercise_2 != ""
        weight_2 = params[:weight_2]
        reps_2 = params[:reps_2]
        sets_2 = params[:sets_2]

        if check_workout_inputs(exercise_2, reps_2, sets_2, 2) == true
            workout_exercise_array.append({
                exercise_name: exercise_2,
                weight: weight_2,
                reps: reps_2,
                sets: sets_2
            })
        else
            redirect('/workouts/new')
        end
    end

    exercise_3 = params[:exercise_3]
    if exercise_3 != ""
        weight_3 = params[:weight_3]
        reps_3 = params[:reps_3]
        sets_3 = params[:sets_3]

        if check_workout_inputs(exercise_3, reps_3, sets_3, 3) == true
            workout_exercise_array.append({
                exercise_name: exercise_3,
                weight: weight_3,
                reps: reps_3,
                sets: sets_3
            })
        else
            redirect('/workouts/new')
        end
    end

    exercise_4 = params[:exercise_4]
    if exercise_4 != ""
        weight_4 = params[:weight_4]
        reps_4 = params[:reps_4]
        sets_4 = params[:sets_4]

        if check_workout_inputs(exercise_4, reps_4, sets_4, 4) == true
            workout_exercise_array.append({
                exercise_name: exercise_4,
                weight: weight_4,
                reps: reps_4,
                sets: sets_4
            })
        else
            redirect('/workouts/new')
        end
    end

    exercise_5 = params[:exercise_5]
    if exercise_5 != ""
        weight_5 = params[:weight_5]
        reps_5 = params[:reps_5]
        sets_5 = params[:sets_5]

        if check_workout_inputs(exercise_5, reps_5, sets_5, 5) == true
            workout_exercise_array.append({
                exercise_name: exercise_5,
                weight: weight_5,
                reps: reps_5,
                sets: sets_5
            })
        else
            redirect('/workouts/new')
        end
    end

    if workout_exercise_array == []
        session[:workout_new_message] = "Fill in atleast 1 exercise"
    end

    user_id = session[:user_id]
    workout_new(user_id, date, musclegroup_1, musclegroup_2, workout_exercise_array)

    redirect('/workouts/new')
end

get('/exercises')do
    session[:exercise_new_message] = ""

    @array_of_exercises = show_all_exercises()

    slim(:'exercises/index')
end

get('/exercises/:id/edit')do
    if session[:user_id] != 1
        session[:error_message] = "You do not have access to this functionality"
        redirect('/error')
    else
        @exercise_id = params[:id]
        @exercise_information = show_specific_exercise(@exercise_id)
        slim(:'exercises/edit')
    end
end

post('/exercises/:id/delete')do
    id = params[:id]
    delete_exercise(id)
    redirect('/exercises')
end

get('/exercises/:id/update')do
    @id = params[:id]
    @exercise_update = show_specific_exercise(@id)
    @muscle_names = get_all_muscle_names()
    slim(:'exercises/update')
end

def check_muscle_name(muscle_name)
    if muscle_name == ""
        return true
    end
    muscle_compare = get_all_muscle_names()
    i = 0
    while i < muscle_compare.length
        if muscle_compare[i][0] == muscle_name
            return true
        end

        i += 1
    end
    return false
end

post('/exercises/:id/update') do
    id = params[:id]
    exercise_name = params[:exercise_name]
    muscle_1 = params[:muscle_1]
    muscle_2 = params[:muscle_2]
    muscle_3 = params[:muscle_3]

    
    if (exercise_name == "" || muscle_1 == "")
        session[:exercise_update_message] = "Fill in a name and at least 1 muscle"
        redirect("/exercises/#{id}/update")
    end

    exercise_name_compare = get_all_exercise_names()

    i = 0
    while i < exercise_name_compare.length
        if exercise_name == exercise_name_compare[i][0]

            id_compare = get_exercise_id(exercise_name_compare[i][0])
            
            if id_compare[0][0] != id.to_i
                session[:exercise_update_message] = "This exercise already excists"
                redirect("/exercises/#{id}/update")
            end
        end
        i += 1
    end

    if check_muscle_name(muscle_1) == false
        session[:exercise_update_message] = "Muscle 1 does not exist"
        redirect("/exercises/#{id}/update")
    elsif check_muscle_name(muscle_2) == false
        session[:exercise_update_message] = "Muscle 2 does not exist"
        redirect("/exercises/#{id}/update")
    elsif check_muscle_name(muscle_3) == false
        session[:exercise_update_message] = "Muscle 3 does not exist"
        redirect("/exercises/#{id}/update")
    end

    if muscle_2 == ""
        muscles_array = [muscle_1]
    elsif muscle_3 == ""
        muscles_array = [muscle_1, muscle_2]
    else
        muscles_array = [muscle_1, muscle_2, muscle_3]
    end

    edit_exercise(id, exercise_name, muscles_array)

    redirect('/exercises')

end

get('/exercises/new')do

    @muscle_names = get_all_muscle_names()
    slim(:'exercises/new')
end

post('/exercises/new')do
    exercise_name = params[:exercise_name]
    muscle_1 = params[:muscle_1]
    muscle_2 = params[:muscle_2]
    muscle_3 = params[:muscle_3]

    if (exercise_name == "" || muscle_1 == "")
        session[:exercise_new_message] = "Fill in a name and at least 1 muscle"
        redirect('/exercises/new')
    end

    exercise_name_compare = get_all_exercise_names()
    
    i = 0
    while i < exercise_name_compare.length
        if exercise_name == exercise_name_compare[i][0]
            session[:exercise_new_message] = "This exercise already excists"
            redirect('/exercises/new')
        end
        i += 1
    end

    if check_muscle_name(muscle_1) == false
        session[:exercise_new_message] = "Muscle 1 does not exist"
        redirect('/exercises/new')
    elsif check_muscle_name(muscle_2) == false
        session[:exercise_new_message] = "Muscle 2 does not exist"
        redirect('/exercises/new')
    elsif check_muscle_name(muscle_3) == false
        session[:exercise_new_message] = "Muscle 3 does not exist"
        redirect('/exercises/new')
    end

    exercise_new(exercise_name, muscle_1, muscle_2, muscle_3)
    session[:exercise_new_message] = "You successfully added a new exercise"

    redirect('/exercises/new')

end

get('/login')do
    slim(:login)
end

post('/users/login') do
    username = params[:username]
    password = params[:password]

    if (username == "" || password == "")
        session[:login_message] = "Fill in a Username/Password"
        redirect('/login')

    else
        result = get_all_for_username(username)
        if result == nil
            session[:login_message] = "No matching Username"
            redirect('/login')
        else
            pwdigest = result['pwdigest']
            id = result['id']
            firstname = result['firstname']
            if BCrypt::Password.new(pwdigest) == password  
                session[:user_id] = id
                session[:firstname] = firstname
                redirect('/')
            else
                session[:login_message] = "Wrong Password"
                redirect('/login')
            end
        end

    end

end

get('/register')do
    slim(:register)
end

post('/users/new') do
    username = params[:username]
    firstname = params[:firstname]
    password = params[:password]
    password_confirm = params[:password_confirm]

    if (username == "" || firstname == "" || password == "")
        session[:register_message] = "Fill in a Username/Firstname/Password"
        redirect('/register')

    elsif (password == password_confirm)

        username_compare = get_all_usernames()
        i = 0
        while i < username_compare.length
            if username == username_compare[i]
                session[:register_message] = "Username is not unique"
                redirect('/register')
            end
            i += 1
        end

        password_digest =BCrypt::Password.create(password)
        register_user(username, firstname, password_digest)
        
        
        session[:user_id] = get_user_id(username)[0][0]
        session[:firstname] = get_user_firstname(username)[0][0]
        redirect('/')
    else
        session[:register_message] = "Passwords did not match"
        redirect('/register')
    end

end

post('/users/logout')do
    session[:login_message] = "You have logged out"
    session[:user_id] = nil
    session[:firstname] = nil
    redirect('/login')
end

