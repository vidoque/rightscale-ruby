# servers.rb

require 'pp' 
require 'yaml'
require 'getoptlong'
require 'right_api_client'
require 'tmpdir'

@client = RightApi::Client.new(YAML.load_file(File.expand_path('../login.yml', __FILE__)))

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--config-file', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--force', GetoptLong::NO_ARGUMENT ],
  [ '--save', GetoptLong::NO_ARGUMENT ],
  [ '--no-auto-start', GetoptLong::NO_ARGUMENT ]
)

force = false
save  = false
no_auto_start = false

opts.each do |opt, arg|
  case opt
  when '--help'
    puts 'ruby deployment.rb [create|delete] --config-file=<filename> [--force] [--save]
    --config-file   : Path to environment config file. Can be relative or 
                      absolute.
    --force         : On create action, script will delete an existing server 
                      with the same name and then re-create it.
    --save          : Save HREF of new resources in the YAML file specified in 
                      config file *_runtime_file.
    --no-auto-start : Specify to only create servers and not start them.'
    exit 0

  when '--config-file'
    @config = YAML.load_file(arg)

  when '--force'
    force = true

  when '--save'
    save = true

  when '--no-auto-start'
    no_auto_start = true

  end
end

unless ARGV.count > 0
  puts 'Provide an action to be executed create/delete'
  exit 1
end

action = ARGV[0]


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

case action
  when 'create'

    servers.each do | server |

      cloud = @client.clouds(:id => server['server_cloud_id']).show
      cloud_href = cloud.show.href
      instance_type_href    = cloud.instance_types.index(:filter => ["name==#{server['server_instance_type']}"]).first.href
      server_template_href  = @client.server_templates.index(:filter => ["name==#{server['server_template']}"]).first.href
      ssh_key_href          = cloud.ssh_keys.index(:filter => ["resource_uid==#{server['server_ssh_key_uid']}"]).first.href
      security_group_hrefs  = [cloud.security_groups.index(:filter => ["resource_uid==#{server['server_security_group_uid']}"]).first.href]
      #TODO: subnet_hrefs          = [cloud.subnets.index(:filter => ["name==#{server['server_subnet_uid']}"]).first.href]

      server_params = { :server => {
      :name => server['server_name'],
      :deployment_href => deployment_href,
      :instance => {
        :instance_type_href   => instance_type_href,
        :server_template_href => server_template_href,
        :cloud_href           => cloud_href,
        :security_group_hrefs => security_group_hrefs,
        :ssh_key_href         => ssh_key_href
      }}}
    new_server = @client.servers.create(server_params)

    #inputs = "inputs[][name]=MYINPUT&inputs[][value]=text:helloworld"
    #new_server.show.launch(inputs)

    end

end # end case

=begin

Reference:

name                                    required  type  values  regexp  blank?  description
server[name]                            yes String  * * no  The name of the server.
server[deployment_href]                 no  String  * * no  The href of the deployment to which the Server will be added.
server[description]                     no  String  * * no  The server description.
server[instance]                        yes Hash  * * no  
server[instance][cloud_href]            yes String  * * no  The href of the cloud that the Server should be added to.
server[instance][datacenter_href]       no  String  * * no  The href of the Datacenter / Zone.
server[instance][image_href]            no  String  * * no  The href of the Image to use.
server[instance][instance_type_href]    no  String  * * no  The href of the instance type.
server[instance][server_template_href]  yes String  * * no  The href of the Server Template.
server[instance][security_group_hrefs]  no  Array * * no  The hrefs of the security groups.
server[instance][ssh_key_href]          no  String  * * no  The href of the SSH key to use.
server[instance][subnet_hrefs]          no  Array * * no  The hrefs of the updated subnets.



server[instance][inputs]  no  Enumerable  * * no  
server[instance][inputs][*] no  String  * * no  The format used for passing 2.0-style Inputs. The key is the name of the input, and the value is the value to assign to the input. For more details on 2.0-style inputs, please see Inputs#multi_update.
server[instance][inputs][][name]  no  String  * * no  The input name. This format is used for passing legacy 1.0-style Inputs. Will eventually be deprecated.
server[instance][inputs][][value] no  String  * * no  The value of that input. Should be of the form 'text:my_value' or 'cred:MY_CRED' etc. This format is used for passing legacy 1.0-style Inputs. Will eventually be deprecated.
server[instance][ramdisk_image_href]  no  String  * * no  The href of the ramdisk image.
server[instance][user_data] no  String  * * no  User data that RightScale automatically passes to your instance at boot time.
server[optimized] no  String  true, false * no  A flag indicating whether Instances of this Server should be optimized for high-performance volumes (e.g. Volumes supporting a specified number of IOPS). Not supported in all Clouds.

=end
