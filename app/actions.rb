# Homepage (Root path)
get '/' do
  erb :index
end

get '/users/:id' do
  erb :'/users/matches'
end