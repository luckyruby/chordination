require 'bundler/capistrano'

set :application, "chordination"
set :deploy_to, "/var/www/#{application}"
set :scm, :git
set :scm_verbose, true
set :repository,  "https://github.com/luckyruby/chordination.git"
set :branch, "master"
set :rails_env, "production"
set :normalize_asset_timestamps, false
set :user, 'deployer'
set :use_sudo, false
ssh_options[:forward_agent] = true

role :web, "chordination.com"                          # Your HTTP server, Apache/etc
role :app, "chordination.com"                          # This may be the same as your `Web` server
role :db,  "chordination.com", :primary => true # This is where Rails migrations will run

namespace :deploy do
  
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      our_revision = 
        begin
          current_revision
        rescue Exception => e
          nil
        end

      if our_revision
        from = source.next_revision(current_revision)
        if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
          run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
        else
          logger.info "Skipping asset pre-compilation because there were no asset changes"
        end
      else
          logger.info "Could not determine current revision. Precompiling Assets..."
          run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      end
    end
  end
  
  desc "Zero-downtime restart of Unicorn"
  task :restart, :except => { :no_release => true } do
    run "sudo god restart #{application}"
  end

  desc "Start unicorn"
  task :start, :except => { :no_release => true } do
    run "sudo god start #{application}"
  end

  desc "Stop unicorn"
  task :stop, :except => { :no_release => true } do
    run "sudo god stop #{application}"
  end
  
  task :add_symlinks, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
    run "ln -nfs #{shared_path}/config/unicorn.rb #{latest_release}/config/unicorn.rb"
    run "ln -nfs #{shared_path}/config/mailer.yml #{latest_release}/config/mailer.yml"
    run "ln -nfs #{shared_path}/system #{latest_release}/system"
    run "ln -nfs #{shared_path}/db/seeds.rb #{latest_release}/db/seeds.rb"
  end
  
  desc "Write the current version to public_html/revision.txt"
  task :write_revision, :except => { :no_release => true } do
    run "cd #{latest_release}; git rev-parse HEAD > #{latest_release}/public/revision.txt"
  end
end
before "deploy:assets:precompile", "deploy:add_symlinks"
after "deploy:update_code", "deploy:write_revision"