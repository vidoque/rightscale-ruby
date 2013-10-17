# deployments.rb

require 'pp' 
require 'yaml'
require 'getoptlong'
require 'right_api_client'

configfile = 'tsm-env-config.yml'

@client = RightApi::Client.new(YAML.load_file(File.expand_path('../login.yml', __FILE__)))
config = YAML.load_file(configfile)
puts "Building #{config['deployment_name']}"

cloud = @client.clouds(:id => config['cloud_id']).show

# DESTROY any deployment with same name
# TODO: only do if '--force' parameter is specified
existing_deployment = @client.deployments.index(:filter => ["name==#{config['deployment_name']}"]).first
unless existing_deployment.nil? 
  puts "Destroying #{existing_deployment.show.href}"
  existing_deployment.destroy
end

deployment_params = { :deployment => {
    :name => config['deployment_name'],
    :description => config['deployment_desc']
    }}
new_deployment = @client.deployments.create(deployment_params)

puts "Created #{new_deployment.show.href}"