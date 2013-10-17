# deployments.rb

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
    puts 'ruby deployment.rb [create|delete] --config-file=<filename> [--force]
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
    @deployment_name = config['deployment'][0]['deployment_name']
    @deployment_runtime_file = config['deployment'][0]['deployment_runtime_file']

  when '--force'
    force = true

  when '--save'
    save = true

  end
end

unless ARGV.count > 0
  puts 'Provide an action to be executed create/delete'
  exit 1
end

action = ARGV[0]

case action
when 'create'
  if force == true
    existing_deployment = @client.deployments.index(:filter => ["name==#{@deployment_name}"]).first
    unless existing_deployment.nil? 
      print "Forcing deletion of #{@deployment_name} (#{existing_deployment.show.href})..."
      begin
        existing_deployment.destroy
      rescue
        puts "Failed to #{action}"
        puts $!, $@
        exit 1
      else
        puts "OK"
      end
    end
  end 
  deployment_params = { :deployment => {
    :name => @deployment_name,
    :description => 'Deployment created by Ruby/Jenkins'
    }}
  begin
    new_deployment = @client.deployments.create(deployment_params)
  rescue
    puts "Failed to #{action}"
    puts $!, $@
    exit 1
  else
    print "Created #{@deployment_name} (#{new_deployment.show.href})..."
    puts "OK"
    if save == true
      runtime_file = File.join(Dir.tmpdir, @deployment_runtime_file)
      puts "Saved to #{runtime_file}"
      File.open(runtime_file, 'w') {|f| f.write new_deployment.show.href.to_yaml }
    end
  end
  exit 0

when 'delete'
  existing_deployment = @client.deployments.index(:filter => ["name==#{@deployment_name}"]).first
  unless existing_deployment.nil? 
    print "Deleting #{@deployment_name} (#{existing_deployment.show.href})..."
    begin
        existing_deployment.destroy
    rescue
        puts "Failed to #{action}"
        puts $!, $@
        exit 1
    else
        puts "OK"
    end
  end
  exit 0
end
