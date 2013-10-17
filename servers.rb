# servers.rb

require 'pp' 
require 'yaml'
require 'getoptlong'
require 'right_api_client'
require 'tmpdir'

config_file = "tsm-env-config.yml"
config = YAML.load_file(config_file)

runtime_file = File.join(Dir.tmpdir, config['deployment'][0]['deployment_runtime_file'])
@deployment_href = YAML.load_file(runtime_file)
pp @deployment_href
