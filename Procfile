web: bundle exec unicorn -p 3000 --config-file "config/unicorn.conf.rb"
worker: bundle exec sidekiq -e $RAILS_ENV
