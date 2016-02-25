# Homepage (Root path)
get '/' do
  erb :index
end

get '/matches/new' do
  erb :'matches/new'
end