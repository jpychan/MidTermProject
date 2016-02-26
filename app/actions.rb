helpers do
  def current_user
    @current_user = User.find(session[:user_id]) if session[:user_id]
  end

  def check_flash
    @flash = session[:flash] if session[:flash]
    session[:flash] = nil
  end

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
  @match = Match.new
  erb :'matches/new'
end

# post '/matches/record' do
#   @match = Match.new
#   if @match.save
#     redirect '/matches'
#   else
#     session[:flash] = "There was an error."
#     redirect 'matches/new'
#   end
# end

get '/matches/edit' do
  @match = Match.find(:id)
  erb :'matches/edit'
end

post '/matches/edit' do
  #insert code from new match form when I have it
end


get '/matches/users/:id' do
  #@friend = User.find(params[:friend_id])

  # WIP, test with User.find(1)
  @me = User.find(1)
  @friend = User.find(2)
  @me_overall_win = Match.where(winner_id: @me.id, loser_id: @friend.id).count(:winner_id)
  @me_overall_lose = Match.where(winner_id: @friend.id, loser_id: @me.id).count(:loser_id)

  #SB checker win and lose counter
  @me_sb_win = Match.where(winner_id: @me.id, loser_id: @friend.id, game_id: 1).count(:winner_id)
  @me_sb_lose = Match.where(winner_id: @friend.id, loser_id: @me.id, game_id: 1).count(:loser_id)
  #SB history details, last 10 games
  @me_and_myfriend_matches_sb = Match.where("(player1_id = ? and player2_id = ?) or (player1_id = ? and player2_id = ?)", @me.id, @friend.id, @friend.id, @me.id).where(game_id: 1).order(created_at: :desc).limit(10)


  #FIFA checker
  @me_fifa_win = Match.where(winner_id: @me.id, loser_id: @friend.id, game_id: 2).count(:winner_id)
  @me_fifa_lose = Match.where(winner_id: @friend.id, loser_id: @me.id, game_id: 2).count(:loser_id)
  #FIFA history details, last 10 games
  @me_and_myfriend_matches_fifa = Match.where("(player1_id = ? and player2_id = ?) or (player1_id = ? and player2_id = ?)", @me.id, @friend.id, @friend.id, @me.id).where(game_id: 2).order(created_at: :desc).limit(10)

  #NHL checker
  @me_nhl_win = Match.where(winner_id: @me.id, loser_id: @friend.id, game_id: 3).count(:winner_id)
  @me_nhl_lose = Match.where(winner_id: @friend.id, loser_id: @me.id, game_id: 3).count(:loser_id)
  #NHL history details, last 10 games
  @me_and_myfriend_matches_nhl = Match.where("(player1_id = ? and player2_id = ?) or (player1_id = ? and player2_id = ?)", @me.id, @friend.id, @friend.id, @me.id).where(game_id: 3).order(created_at: :desc).limit(10)

  erb :'/users/matches'
end

post '/matches/user/reset' do
end
