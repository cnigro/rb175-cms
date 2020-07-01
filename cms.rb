require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'redcarpet'

root = File.expand_path('..', __FILE__)

configure do
  enable :sessions
  set :session_secret, "it's a secret to everybody"
end

get '/' do
  # @files = Dir.entries('data').select { |file| !File.directory? file }
  @files = Dir.glob(root + "/data/*").map { |path| File.basename(path) }
  erb :index
end

get '/:filename' do |filename|
  file_path = root + "/data/" + filename

  if File.file?(file_path)
    headers["Content-Type"] = "text/plain"
    File.read(file_path)
  else
    session[:message] = "#{filename} does not exist."
    redirect '/'
  end

  # @text = File.readlines('data/' + filename)
  # erb :contents
end