helpers do
  def current_user
    @current_user = User.find(session[:user_id]) if session[:user_id]
  end

  def check_flash
    @flash = session[:flash] if session[:flash]
    session[:flash] = nil
  end

  def get_wins(user_id, friend_id, game_id)
    Match.where(winner_id: user_id, loser_id: friend_id, game_id: game_id).count(:winner_id)
  end

  def get_loses(user_id, friend_id, game_id)
    Match.where(winner_id: friend_id, loser_id: user_id, game_id: game_id).count(:loser_id)
  end

  def get_recent_matches(user_id, friend_id, game_id)
    Match.where("(player1_id = ? and player2_id = ?) or (player1_id = ? and player2_id = ?)", user_id, friend_id, friend_id, user_id).where(game_id: game_id).order(created_at: :desc).limit(10)
  end

  def get_all_matches_a_friend(user_id, friend_id)
    Match.where("(player1_id = ? and player2_id = ?) or (player1_id = ? and player2_id = ?)", @me.id, @friend.id, @friend.id, @me.id).order(created_at: :desc)
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


get '/matches/user/:id' do
  @friend = User.find(params[:id])

  # WIP, test with User.find(1)
  @me = current_user
  #@friend = User.find(3)
  @matches = Match.all

  # Query to get overall record
  @me_overall_win = @matches.where(winner_id: @me.id, loser_id: @friend.id).count(:winner_id)
  @me_overall_lose = @matches.where(winner_id: @friend.id, loser_id: @me.id).count(:loser_id)


  @game_stats = {}
  Game.all.each do |game|
    @game_stats[game.title] = {
      wins: get_wins(@me.id, @friend.id, game.id),
      losses: get_loses(@me.id, @friend.id, game.id),
      matches: get_recent_matches(@me.id, @friend.id, game.id)
    }
  end

  erb :'/users/matches'
end

get '/matches/user/:id/all' do
  @me = current_user
  @friend = User.find(params[:id])
  #@friend = User.find(2)

  @me_and_friend_all_matches = get_all_matches_a_friend(@me.id, @friend.id)

  erb :'/users/all_matches'
end

post '/matches/user/reset' do
end
