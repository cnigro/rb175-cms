require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'redcarpet'

root = File.expand_path('..', __FILE__)

configure do
  enable :sessions
  set :session_secret, "it's a secret to everybody"
end

def render_markdown(md)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(md)
end

def load_file_content(path)
  content = File.read(path)
  p content
  case File.extname(path)
  when '.txt'
    headers["Content-Type"] = "text/plain"
    content
  when '.md'
    render_markdown(content)
  end
end

get '/' do
  @files = Dir.glob(root + "/data/*").map { |path| File.basename(path) }
  erb :index
end

get '/:filename' do |filename|
  file_path = root + "/data/" + filename

  if File.file?(file_path)
    load_file_content(file_path)
  else
    session[:message] = "#{filename} does not exist."
    redirect '/'
  end
end

get '/:filename/edit' do |filename|
  file_path = root + "/data/" + filename
  @filename = filename
  @content = File.read(file_path)
  erb :edit
end

post '/:filename' do |filename|
  file_path = root + "/data/" + filename
  File.write(file_path, params[:content])
  session[:message] = "Changes to #{filename} have been saved."
  redirect '/'
end