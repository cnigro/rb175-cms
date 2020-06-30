require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

root = File.expand_path('..', __FILE__)

get '/' do
  # @files = Dir.entries('data').select { |file| !File.directory? file }
  @files = Dir.glob(root + "/data/*").map { |path| File.basename(path) }
  erb :index
end

get '/:filename' do |filename|
  file_path = root + "/data/" + filename
  headers["Content-Type"] = "text/plain"
  File.read(file_path)
  # @text = File.readlines('data/' + filename)
  # erb :contents
end