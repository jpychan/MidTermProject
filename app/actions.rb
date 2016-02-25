# Homepage (Root path)
get '/' do
  erb :index
end

get '/matches' do
  erb :'matches/index'
end

get '/matches/new' do
  erb :'matches/new'
end

get '/users/:id' do
  erb :'/users/matches'
end