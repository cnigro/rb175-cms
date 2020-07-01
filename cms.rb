require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'redcarpet'

root = File.expand_path('..', __FILE__)

configure do
  enable :sessions
  set :session_secret, "it's a secret to everybody"
end

def error_for_document_name(name)
  if !(1..100).cover? name.size
    'List name must be between 1 and 100 characters.'
  elsif session[:lists].any? { |list| list[:name] == name }
    'List name must be unique.'
  end
end

def data_path
  if ENV["RACK_ENV"] == 'test'
    File.expand_path('../test/data', __FILE__)
  else
    File.expand_path('../data', __FILE__)
  end
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
    erb render_markdown(content)
  end
end

get '/' do
  pattern = File.join(data_path, '*')
  @files = Dir.glob(pattern).map { |path| File.basename(path) }
  erb :index, layout: :layout
end

get '/new' do
  erb :new, layout: :layout
end

post '/create' do
  filename = params[:filename].to_s

  if filename.size == 0
    session[:message] = "A name is required."
    status 422
    erb :new
  else
    file_path = File.join(data_path, filename)
    
    File.open(file_path, 'w') { |f| f.write('') }
    session[:message] = "#{params[:filename]} was created."
    
    redirect '/'
  end
end

post '/:filename' do |filename|
  file_path = File.join(data_path, filename)
  File.write(file_path, params[:content])
  session[:message] = "Changes to #{filename} have been saved."
  redirect '/'
end

get '/:filename' do |filename|
  file_path = File.join(data_path, filename)

  if File.file?(file_path)
    load_file_content(file_path)
  else
    session[:message] = "#{filename} does not exist."
    redirect '/'
  end
end

get '/:filename/edit' do |filename|
  file_path = File.join(data_path, filename)
  @filename = filename
  @content = File.read(file_path)
  erb :edit, layout: :layout
end


