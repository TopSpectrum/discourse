
set :application, "dotforum"

key_location = ENV["EC2_KEY"]
unless key_location
	p "You must have environment variable EC2_KEY set to location of ec2 key"
	exit 1
end
set :ssh_flags, ["-i", "#{key_location}","-A"]

set :domain, "ubuntu@dotforum"
set :deploy_to, "/srv/topspectrum/dotforum"

set :repository, 'https://github.com/TopSpectrum/discourse.git'
set :revision, "origin/master"

set :web, nil

set :unicorn_config, "#{current_path}/config/unicorn.conf.rb"
set :unicorn_use_bundler, true
set :unicorn_bundle_cmd, "cd #{current_path} && rvm all do bundle exec"
set :unicorn_env, "development"

namespace :vlad do
  remote_task :bundle_install do
  	run "cd #{current_path} && rvm all do bundle install"
  end

  remote_task :update do
    Rake::Task["vlad:bundle_install"].invoke
  end

  remote_task :deploy_full do
  	Rake::Task["vlad:update"].invoke
    Rake::Task["vlad:reload_app"].invoke
  end
end

