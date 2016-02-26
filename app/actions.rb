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
  @matches_by_me = @matches.where("winner_id = ? or loser_id = ?", current_user[:id], current_user[:id])
  opponents_hash = {}
  opponents = @matches_by_me.map do |m|
    if (m.winner_id != 4)
      opponents_hash[m.winner_id.to_s] = {count: 0, matches: []} unless opponents_hash[m.winner_id.to_s]
      opponents_hash[m.winner_id.to_s][:count] += 1
      opponents_hash[m.winner_id.to_s][:user_obj] = User.find(m.winner_id)
      opponents_hash[m.winner_id.to_s][:matches] << m
    else
      opponents_hash[m.loser_id.to_s] = {count: 0, matches: []} unless opponents_hash[m.loser_id.to_s]
      opponents_hash[m.loser_id.to_s][:count] += 1
      opponents_hash[m.loser_id.to_s][:user_obj] = User.find(m.loser_id)
      opponents_hash[m.loser_id.to_s][:matches] << m
    end
  end
  @sorted_opponents = opponents_hash.sort_by { |key, value| value[:count]}.reverse

  @opponent_names = []
  @sorted_opponents.each do |opponent|
    @opponent_names << opponent[1][:user_obj].name
  end
  binding.pry
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


get '/users/' do
  erb :'/users/matches'
end

post '/matches/user/reset' do
end
