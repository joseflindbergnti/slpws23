require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'

enable :sessions


def connect_to_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    return db
end

#db = connect_to_db('db/gym_tracker.db')

get('/')do
    slim(:index)
end

get('/login')do
    slim(:login)
end

get('/register')do
    #hitta en lösning så att "Password did not match" inte kommer upp hela tiden
    slim(:register)
end

post('/users/new') do
    db = connect_to_db('db/gym_tracker.db')
    session[:register_message] = ""
    username = params[:username]
    firstname = params[:firstname]
    password = params[:password]
    password_confirm = params[:password_confirm]
    if (password == password_confirm)

        username_compare = db.execute('SELECT username FROM users')
        i = 0
        while i < username_compare.length
            if username == username_compare[i]
                session[:register_message] = "Username is not unique"
                redirect('/register')
            end
            i += 1
        end

        password_digest =BCrypt::Password.create(password)
        db.execute("INSERT INTO users (username, firstname, pwdigest) VALUES (?, ?, ?)", username, firstname, password_digest)
        redirect('/')
    else
        session[:register_message] = "Passwords did not match"
        redirect('/register')
    end

end

