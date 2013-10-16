# test1.rb

require 'pp' 
require 'yaml'
require 'right_api_client'

deployment_name = 'Test Deployment 3'
server_name = 'My New Server 1'
template_name = 'Linux 1'
cloud_id = '2'

@client = RightApi::Client.new(YAML.load_file(File.expand_path('../login.yml', __FILE__)))

#@client.log(STDOUT)

server_template_href = @client.server_templates.index(:filter => ["name==#{template_name}"]).first.href
cloud = @client.clouds(:id => cloud_id).show

# delete if exists
existing_deployment = @client.deployments.index(:filter => ["name==#{deployment_name}"]).first
unless existing_deployment.nil? 
  existing_deployment.destroy
end

deployment_params = { :deployment => {
    :name => deployment_name,
    :description => 'A description'
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
new_server.api_methods

inputs = "inputs[][name]=MYINPUT&inputs[][value]=text:helloworld"
new_server.show.launch(inputs)


