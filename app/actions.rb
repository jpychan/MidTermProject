# Homepage (Root path)
get '/' do
  erb :index
end

get '/matches' do
  erb :'matches/index'
end
