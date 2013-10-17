# test1.rb

require 'pp' 
require 'yaml'
require 'right_api_client'

#deployment_name = 'Test Deployment 1'
#server_name = 'My New Server 1'
#template_name = 'Linux MCI v1'
#cloud_id = '2'
configfile = 'tsm-env-config.yml'

@client = RightApi::Client.new(YAML.load_file(File.expand_path('../login.yml', __FILE__)))
config = YAML.load_file(configfile)
puts config
config.each { |key, value| instance_variable_set("@#{key}", value) }
#puts @deployment_name
#puts @cloud_id
#puts @servers[0]['server_name']

@servers.each { | server | 
    puts server['server_name']
    puts server['server_size']
    puts server['server_template']
}

=begin
server_template_href = @client.server_templates.index(:filter => ["name==#{template_name}"]).first.href
cloud = @client.clouds(:id => cloud_id).show

existing_deployment = @client.deployments.index(:filter => ["name==#{deployment_name}"]).first
unless existing_deployment.nil? 
  existing_deployment.destroy
end

deployment_params = { :deployment => {
    :name => deployment_name,
    :description => 'New deployment'
    }}
new_deployment = @client.deployments.create(deployment_params)

server_params = { :server => {
    :name => server_name,
    :deployment_href => new_deployment.show.href,
    :instance => {
        :server_template_href => server_template_href,
        :cloud_href           => cloud.href,
        :security_group_hrefs => [cloud.security_groups.index(:filter => ['name==default']).first.href],
        :ssh_key_href         => cloud.ssh_keys.index.first.href,
        :datacenter_href      => cloud.datacenters.index.first.href
    }}}
new_server = @client.servers.create(server_params)

inputs = "inputs[][name]=MYINPUT&inputs[][value]=text:helloworld"
new_server.show.launch(inputs)
=end



