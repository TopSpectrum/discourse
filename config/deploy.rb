RVM_LOAD="source $HOME/.rvm/scripts/rvm"

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

set :web, nil

set :unicorn_config, "#{current_path}/config/unicorn.conf.rb"
set :unicorn_use_bundler, true
set :unicorn_bundle_cmd, "#{RVM_LOAD} && cd #{current_path} && bundle exec"
set :unicorn_env, "development"

namespace :vlad do
  remote_task :bundle_install do
  	run "#{RVM_LOAD} && cd #{current_path} && bundle install"
  end

  remote_task :stop_sidekiq do
  	run "#{RVM_LOAD} && cd #{current_path} && bundle exec sidekiqctl stop /srv/topspectrum/dotforum/shared/pids/sidekiq.pid 5"
  end

  remote_task :start_sidekiq do
  	run "#{RVM_LOAD} && cd #{current_path} && bundle exec sidekiq -d -L #{current_path}/log/sidekiq.log -C #{current_path}/config/sidekiq.yml -e development"
  end

  remote_task :delete_sidekiq_pid do
  	run "rm /srv/topspectrum/dotforum/shared/pids/sidekiq.pid && exit 0"
  end

  remote_task :restart_sidekiq do
  	begin
	  	Rake::Task["vlad:stop_sidekiq"].invoke
	rescue
		# Invalid pid will cause failure, so lets delete and fail silently
		Rake::Task["vlad:delete_sidekiq_pid"].invoke
	end
  	sleep(5)
  	Rake::Task["vlad:start_sidekiq"].invoke
  end

  remote_task :update do
    Rake::Task["vlad:bundle_install"].invoke
  end

  remote_task :deploy_full do
  	Rake::Task["vlad:update"].invoke
    Rake::Task["vlad:reload_app"].invoke
    Rake::Task["vlad:restart_sidekiq"].invoke
  end
end

