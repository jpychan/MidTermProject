# Homepage (Root path)
get '/' do
  erb :index
end

# maybe put it under matches folder, and call 
# this erb file: show.erb?

# because naming a 'matches' is 
# overlapping with matches folder


get '/users/:id' do
  erb :'/users/matches'
end