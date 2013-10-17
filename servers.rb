

=begin
config_file = "tsm-env-config.yml"

config = YAML.load_file(config_file)
=end

#deployment_href = YAML.load_file(config['deployment'][0]['deployment_runtime_file'])
deployment_href = YAML.load_file('_deployment.yml')
pp deployment_href

