require 'sinatra'

set :erb, layout: :layout, format: :html5

get '/' do
  erb :index
end
