# test1.rb

require 'pp' 
require 'yaml'
require 'right_api_client'

#cred_file = 'C:\Users\jim.davies\Documents\Keys\Rightscale\login.yml'
cred_file = ''

if (defined? cred_file) and cred_file != ''
  @client = RightApi::Client.new(YAML.load_file(cred_file))

else (defined? ENV['RS_EMAIL']) and (defined? ENV['RS_PASSWORD']) and (defined? ENV['RS_ACCOUNTID'])
  begin
    @client = RightApi::Client.new(:email => ENV['RS_EMAIL'], :password => ENV['RS_PASSWORD'], :account_id => ENV['RS_ACCOUNTID'])
  rescue
    raise "No Rightscale login details found. Use a cred file or set username/password as environment variables."
  end
end

cloud = @client.clouds(:id => '2').show

#server = {'server_ssh_key_uid' => 'tsmkey01' }
#pp server['server_ssh_key_uid']

server = { 'server_ssh_key_uid' => 'tsmkey01' }

#server_security_group_uidputs cloud.ssh_keys.index(:filter => ["resource_uid==#{server['server_ssh_key_uid']}"]).first.href
puts cloud.ssh_keys.index(:filter => ["resource_uid==#{server['server_ssh_key_uid']}"]).first.href
#puts cloud.security_groups.index(:filter => ["resource_uid==#{server['server_security_group_uid']}"]).first.href

#puts cloud.subnets.index(:filter => ["resource_uid==#{server['server_subnet_uid']}"]).first.href
