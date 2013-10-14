# test1.rb

require 'pp' 
require 'yaml'
require 'right_api_client'

@client = RightApi::Client.new(YAML.load_file(File.expand_path('../login.yml', __FILE__)))
puts "Available methods: #{pp @client.api_methods}"

