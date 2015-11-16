puts "Vlad loading..."
set :application, "dotforum"

key_location = ENV["EC2_KEY"]
unless key_location
	p "You must have environment variable EC2_KEY set to location of ec2 key"
	exit 1
end
set :ssh_flags, [ "-i", "#{key_location}"]

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

#/Users/jason/workspace/topspectrum/keys/default.pem