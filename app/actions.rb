helpers do
  def current_user
    @current_user = User.find(session[:user_id]) if session[:user_id]
  end

  def check_flash
    @flash = session[:flash] if session[:flash]
    session[:flash] = nil
  end

  def no_user_error!
    rescue 
      redirect '/matches/new'
  end
end

class UserDoesNotExist < StandardError
end

before do
  current_user
  check_flash
end

# Homepage (Root path)
get '/' do
  erb :index
end

#User Login / Logout
get '/users/login' do
  erb :'users/login'
end

post '/users/login' do
  @user = User.find_by(:username => params[:username])
  if @user && @user.authenticate(params[:password])
    session[:user_id] = @user.id
    redirect '/'
  else
    session[:flash] = "Invalid login."
    redirect '/users/login'  end
end

get '/logout' do
  session.clear
  redirect '/'
end

#User Sign Up

get '/users/signup' do
  @user = User.new
  erb :'users/signup_form'
end

post '/users/signup' do
  username = params[:username]
  name = params[:name]
  password = params[:password]

  @user = User.new username: username, name: name, password: password

  if @user.save
    session[:user_id] = @user.id
    redirect '/'
  else
    session[:flash] = "We could not create your user. You suck."
    redirect '/users/signup'
  end
end


#Matches Views
get '/matches' do
  @matches = Match.all
  erb :'matches/index'
end

get '/matches/new' do
  @games = Game.all
  @match = Match.new
  erb :'matches/new'
end

post '/matches/record' do
  @game_id = params[:game]
  @entered_username = params[:player2_username]
  @player2 = User.find_by(:username => params[:player2_username])
  if @player2 == nil
    session[:flash] = "The username you entered does not exist."
    redirect '/matches/new'
  else
    if params[:win] == "true"
      winner_id = @current_user.id
      loser_id = @player2.id
    else
      winner_id = @player2.id
      loser_id = @current_user.id
    end
    @match = Match.new game_id: game_id, player1_id: @current_user.id, player2_id: @player2.id, winner_id: winner_id, loser_id: loser_id

    if @match.save
      redirect '/matches'
    else
      session[:flash] = "There was an error."
      redirect '/matches/new'
    end
  end
end

get '/match/edit/:id' do
  @games = Game.all
  @match = Match.find(params[:id])
  @player2 = @match.player2
  if @current_user.id == @match.player1_id || @match.player2_id
    erb :'matches/edit'
  else
    redirect '/matches'
  end
end


post '/match/edit' do
  @match = Match.find(params[:match_id])
  @match.game_id = params[:game]
  @match.player2 = User.find_by(:username => params[:player2_username])
  if @match.player2 == nil
    session[:flash] = "The username you entered does not exist."
    redirect '/matches/new'
  else
    if params[:win] == "true"
      @match.winner_id = @current_user.id
      @match.loser_id = @match.player2.id
    else
      @match.winner_id = @match.player2.id
      @match.loser_id = @current_user.id
    end
    
    if @match.save
      redirect '/'
    else
      session[:flash] = "Edit failed"
      redirect '/match/edit/:id'
    end
  end
end

get '/users/' do
  erb :'/users/matches'
end

post '/matches/user/reset' do
end
