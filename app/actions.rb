helpers do
  def current_user
    @current_user = User.find(session[:user_id]) if session[:user_id]
  end

  def check_flash
    @flash = session[:flash] if session[:flash]
    session[:flash] = nil
  end

  def opponent(match, user_id)
    match.winner_id == user_id ? match.loser : match.winner
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

  def pending_requests_count
    @received_pending_requests_count = ResetRequest.where(requested_id: @current_user.id, confirmed: false, rejected: false).count
  end

end

before do
  current_user
  check_flash
  if @current_user
    pending_requests_count
  end
end

# Homepage (Root path)
get '/' do
  erb :index
end

#User Sign Up

get '/users/signup' do
  if current_user
    redirect '/matches'
  else
    @user = User.new
    erb :'users/signup_form'
  end
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

#User Login / Logout
get '/users/login' do
  if current_user
    redirect '/matches'
  else
    erb :'users/login'
  end
end

post '/users/login' do
  @user = User.find_by(:username => params[:username])
  if @user && @user.authenticate(params[:password])
    session[:user_id] = @user.id
    redirect '/'
  else
    session[:flash] = "Invalid login."
    redirect '/users/login'  
  end
end

get '/logout' do
  session.clear
  redirect '/'
end

#Matches Views
get '/matches' do
  if @current_user
    @matches = Match.all
    @matches_by_me = @matches.where("winner_id = ? or loser_id = ?", current_user[:id], current_user[:id])

    @matches_by_me = @matches_by_me.group_by { |match| opponent(match, current_user.id) }
    @matches_by_me = @matches_by_me.values.sort { |a, b| b.length <=> a.length}

    erb :'matches/index'
  else
    session[:flash] = "Please login first!"
    redirect '/users/login'
  end
end

get '/matches/new' do
  if current_user
    @games = Game.all
    @match = Match.new
    erb :'matches/new'
  else
    session[:flash] = "Please login first!"
    redirect '/users/login'
  end
end

post '/matches/record' do
  @game_id = params[:game]
  @entered_username = params[:player2_username]
  @player2 = User.find_by(:username => params[:player2_username])
  if @player2 == nil
    session[:flash] = "The username you entered does not exist."
    redirect '/matches/new'
  elsif @current_user == @player2
    session[:flash] = "You can't be the opponent too!"
    redirect '/matches/new'  
  else
    if params[:win] == "true"
      winner_id = @current_user.id
      loser_id = @player2.id
    else
      winner_id = @player2.id
      loser_id = @current_user.id
    end
    @match = Match.new(
      game_id: @game_id,
      player1_id: @current_user.id,
      player2_id: @player2.id,
      winner_id: winner_id,
      loser_id: loser_id)

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

  if @match.participant?(@current_user.id)
    erb :'matches/edit'
  elsif current_user
    session[:flash] = "You didn't participate in that match!"
    redirect '/matches'
  else
    session[:flash] = "Please login first!"
    redirect '/users/login'
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
      redirect '/matches'
    else
      session[:flash] = "Edit failed"
      redirect '/match/edit/:id'
    end
  end
end

get '/users/' do
  erb :'/users/matches'
end

get '/user/reset_requests' do
  if @current_user
    @all_requests = ResetRequest.where("(requester_id = ?) or (requested_id = ?)", @current_user.id, @current_user.id)  
    @received_pending_requests = ResetRequest.where(requested_id: @current_user.id, confirmed: false, rejected: false).order(created_at: :desc)
    @sent_pending_requests = ResetRequest.where(requester_id: @current_user.id, confirmed: false, rejected: false).order(created_at: :desc)
    @completed_requests = @all_requests.where("(confirmed = ?) or (rejected = ?)", true, true).order(updated_at: :desc)
    erb :'/users/reset_requests'
  else
    session[:flash] = "Please login first!"
    redirect '/users/login'
  end
end

post '/matches/user/reset' do
  reset_request = ResetRequest.new(requester_id: @current_user.id, requested_id: params[:friend_id], game_id: params[:game_id])
    if reset_request.unique_pending_request?(@current_user.id, params[:friend_id], params[:game_id])

    reset_request.save
    redirect "/user/reset_requests"
  else
    session[:flash] = "There's already a pending request between you."
    redirect "/matches/user/#{params[:friend_id]}"
  end
end

post '/user/reset_requests/confirm' do
  @the_request = ResetRequest.find(params[:request_id])
  @the_request.confirmed = true
  @the_request.save
  @me = @current_user
  @friend = @the_request.requester
  @matches = get_all_matches_a_friend(@me.id, @friend.id)
  @matches.destroy_all
  redirect '/user/reset_requests'
end

post '/user/reset_requests/reject' do
  @the_request = ResetRequest.find(params[:request_id])
  @the_request.rejected = true
  @the_request.save
  redirect '/'
end

get '/matches/user/:id' do
  if @current_user
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
      matches: get_recent_matches(@me.id, @friend.id, game.id),
      game: game.id,
      picture: game.picture_url
    }
    end
    erb :'/users/matches'
  else
    session[:flash] = "Please login first!"
    redirect '/users/login'
  end
end

get '/matches/user/:id/all' do
  if @current_user
    @me = current_user
    @friend = User.find(params[:id])
    #@friend = User.find(2)

    @me_and_friend_all_matches = get_all_matches_a_friend(@me.id, @friend.id)

    erb :'/users/all_matches'
  else
    session[:flash] = "Please login first!"
    redirect '/users/login'
  end
end


