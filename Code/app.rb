require 'sinatra'
require 'slim'
require 'SQLite3'
require 'BCrypt'

get('/') do
    slim(:index)
end

get('/user/new') do
    slim(:'user/new')
end

get('/user/index') do
    slim(:'user/index')
end

post('/create') do 
    db = SQLite3::Database.new("db/todo.db")
    db.results_as_hash = true
    username = params["username"]
    password = params["password"]
    confirm_password = params["confirm_password"]
    result = db.execute("SELECT * FROM user WHERE username=?", username)

    if result.empty?
        if password == confirm_password
            password_digest = BCrypt::Password.create(password)
            db.execute("INSERT INTO user(username, password) VALUES (?,?)", [username, password_digest])
            session[:user_id] = db.execute("SELECT user_id FROM user WHERE username=?", [username])
            session[:username] = username
            redirect('/registration_con')
        else
            redirect('/error')
            
        end
    else
        redirect('/error')
    end

    redirect('/user/index')
end

get('/error') do
    slim(:'error')
end

get('/registration_con') do 
    slim(:'registration_con')
end

post('/login') do
    db = SQLite3::Database.new("db/todo.db")
    username = params["username"]
    password = params["password"]
    db.results_as_hash = true
    result = db.execute("SELECT user_id, password FROM user WHERE username=?", [username])
    if result.empty?
        redirect('/error')
    end
    user_id = result.first["user_id"]
    password_digest = result.first["password"]
    if BCrypt::Password.new(password_digest) == password
        session[:username] = username
        session[:user_id] = user_id
        redirect("../shop/index")
    else
        redirect("../error")
    end
    
end 

get('/shop/index') do 
   db = SQLite3::Database.new("db/todo.db")
   db.results_as_hash = true
   todo = db.execute('SELECT * FROM varor')
   slim(:'shop/index', locals:{todo:todo})
end

post('/shop/create_item') do
    db = SQLite3::Database.new("db/todo.db")
    title = params["title"]
    pris = params["pris"]
    lager = params["lager"] 
    if title == ""
        redirect('/shop/index')
    end
    db.execute("INSERT INTO varor(title, pris, lager) VALUES (?,?,?)", [title, pris, lager])
    redirect('/shop/index')
end