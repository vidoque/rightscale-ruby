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
  [ '--save', GetoptLong::NO_ARGUMENT ]
)

force = false
save  = false

opts.each do |opt, arg|
  case opt
  when '--help'
    puts 'ruby deployment.rb [create|delete] --config-file=<filename> [--force] [--save]
    --config-file : Path to environment config file. Can be relative or 
                    absolute.
    --force       : On create action, script will delete an existing deployment 
                    with the same name and then re-create it.
    --save        : Save HREF of new resource in the YAML file specified in 
                    config file *_runtime_file.'
    puts ''
    exit 0

  when '--config-file'
    config = YAML.load_file(arg)
    @deployment_name = config['deployments'][0]['deployment_name']
    @deployment_runtime_file = config['deployments'][0]['deployment_runtime_file']
    runtime_file = File.join(Dir.tmpdir, config['deployment'][0]['deployment_runtime_file'])
    @deployment_href = YAML.load_file(runtime_file)

  when '--force'
    force = true

  when '--save'
    save = true

  end
end

pp @deployment_href






###################


# add --no-auto-start param

# read config-file

# lookup deployment_href
# look for file
# if file not present
#   set deployment_href as 'default'

# foreach deployment in deployments
#   get servers
#   foreach server in servers
#     build-up deploy parameters
#     create server
#     if no-auto-start = false
#        start up with input parameters