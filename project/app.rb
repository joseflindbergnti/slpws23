require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require_relative './model.rb'

enable :sessions

#db = connect_to_db('db/gym_tracker.db')

get('/')do
    session[:register_message] = ""
    session[:login_message] = ""
    slim(:index)
end

get('/workouts')do
    slim(:'workouts/index')
end

get('/workouts/new')do
    slim(:'workouts/new')
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
                session[:id] = id
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
        redirect('/')
    else
        session[:register_message] = "Passwords did not match"
        redirect('/register')
    end

end

