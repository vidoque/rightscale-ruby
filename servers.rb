# servers.rb

# Reference: http://reference.rightscale.com/api1.5/resources/ResourceServers.html

require 'pp' 
require 'yaml'
require 'getoptlong'
require 'right_api_client'
require 'tmpdir'

#@client = RightApi::Client.new(YAML.load_file(File.expand_path('../login.yml', __FILE__)))

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--config-file', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--cred-file', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--force', GetoptLong::NO_ARGUMENT ],
  [ '--save', GetoptLong::NO_ARGUMENT ],
  [ '--no-auto-start', GetoptLong::NO_ARGUMENT ]
)

cred_file = ''
force = false
no_save  = false
no_auto_start = false

opts.each do |opt, arg|
  case opt
  when '--help'
    puts 'ruby servers.rb [create|delete] --config-file <filepath> [--cred-file <filepath>] [--force] [--save]
    --config-file   : Path to environment config file. 
    --cred-file     : Path to Rightscale credential file.
    --force         : On create action, script will delete an existing server 
                      with the same name and then re-create it.
    --no-save          : Save HREF of new resources in the YAML file specified in 
                      config file *_runtime_file.
    --no-auto-start : Specify to only create servers and not start them.'
    exit 0

  when '--config-file'
    @config = YAML.load_file(arg)

  when '--cred-file'
    cred_file = arg

  when '--force'
    force = true

  when '--save'
    save = true

  when '--no-auto-start'
    no_auto_start = true

  end
end

unless ARGV.count > 0
  puts 'Provide an action to be executed'
  exit 1
end

action = ARGV[0]

# Login
if (defined? cred_file) and cred_file != ''
  @client = RightApi::Client.new(YAML.load_file(cred_file))
else (defined? ENV['RS_EMAIL']) and (defined? ENV['RS_PASSWORD']) and (defined? ENV['RS_ACCOUNTID'])
  begin
    @client = RightApi::Client.new(:email => ENV['RS_EMAIL'], :password => ENV['RS_PASSWORD'], :account_id => ENV['RS_ACCOUNTID'])
  rescue
    raise "No Rightscale login details found. Use a cred file or set username/password as environment variables."
  end
end

# Currently only supports a single deployment (the first) per config file
deployment_name = @config['deployments'][0]['deployment_name']
deployment_runtime_file = @config['deployments'][0]['deployment_runtime_file']
deployment_href = @config['deployments'][0]['deployment_href']
servers = @config['deployments'][0]['servers']

# Get deployment_href from (firstly) config_file or (secondly) runtime_file
if deployment_href == "runtime" || deployment_href.nil? || deployment_href.empty?
  runtime_file = File.join(Dir.tmpdir, deployment_runtime_file)
  if File.exist?(runtime_file)
    puts "Using runtime_file: #{runtime_file}"
    deployment_href = YAML.load_file(runtime_file)
  else
    raise "Cannot find #{runtime_file}."
  end
end

# 
case action
  when 'create'

    servers.each do | server |

      cloud = @client.clouds(:id => server['server_cloud_id']).show
      cloud_href = cloud.show.href
      instance_type_href    = cloud.instance_types.index(:filter => ["name==#{server['server_instance_type']}"]).first.href
      server_template_href  = @client.server_templates.index(:filter => ["name==#{server['server_template']}"]).first.href
      ssh_key_href          = cloud.ssh_keys.index(:filter => ["resource_uid==#{server['server_ssh_key_uid']}"]).first.href
      security_group_hrefs  = [cloud.security_groups.index(:filter => ["resource_uid==#{server['server_security_group_uid']}"]).first.href]
      #TODO: subnet_hrefs   = [cloud.subnets.index(:filter => ["name==#{server['server_subnet_uid']}"]).first.href]
      subnet_hrefs          = [server['server_subnet_href']]

      server_params = { :server => {
      :name => server['server_name'],
      :deployment_href => deployment_href,
      :instance => {
        :instance_type_href   => instance_type_href,
        :server_template_href => server_template_href,
        :cloud_href           => cloud_href,
        :security_group_hrefs => security_group_hrefs,
        :ssh_key_href         => ssh_key_href,
        :subnet_hrefs         => subnet_hrefs
      }}}
      
      new_server = @client.servers.create(server_params)
      puts "Created #{server['server_name']}"

      #TODO: Add tag to new_server

      # Launch server
      unless no_auto_start == true
        @inputs = []
        server['server_inputs'].each do | input_hash |
          input_hash.each do | input_name, input_value |
            @inputs << "inputs[][name]=#{input_name}&inputs[][value]=#{input_value}" # 1.0 notation (deprecated)
            #@inputs << %Q(inputs[#{input_name}]=#{input_value}) # 2.0 notation but not working
            @inputs.inspect
          end
        end

        inputs_join = @inputs.join('&')

        new_server.show.launch(inputs_join)
        puts "Launched #{server['server_name']}"
        puts "With inputs:"
        puts inputs_join

      end # end unless

    end # end do

  when 'delete'

    puts "Delete functionality not yet implemented"
    exit 0

end # end case

exit 0
