puts "Vlad loading..."
set :application, "dotforum"
set :ssh_flags, %w[ -i /Users/jason/workspace/topspectrum/keys/default.pem]

set :domain, "ubuntu@ec2-54-218-52-233.us-west-2.compute.amazonaws.com"
set :deploy_to, "/srv/topspectrum/dotforum"

set :repository, 'https://github.com/TopSpectrum/discourse.git'
set :revision, "origin/master"
#task :staging do
#end

#task :prod do
#  set :domain,    "example.com"
#  set :deploy_to, "/path/to/install"
#end
