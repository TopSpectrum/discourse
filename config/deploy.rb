
set :application, "dotforum"

key_location = ENV["EC2_KEY"]
unless key_location
	p "You must have environment variable EC2_KEY set to location of ec2 key"
	exit 1
end
set :ssh_flags, ["-i", "#{key_location}"]

set :domain, "ubuntu@dotforum"
set :deploy_to, "/srv/topspectrum/dotforum"

set :repository, 'https://github.com/TopSpectrum/discourse.git'
set :revision, "origin/master"

namespace :vlad do
  def stop
    run "foreman stop"
  end

  def start
    run "foreman start"
  end

  remote_task :start, roles: :app do
    stop
    start
  end

  remote_task :stop, roles: :app do
    stop
  end

  remote_task :update do
  	p "Monkey"
#    Rake::Task["vlad:start"].invoke
  end
end
