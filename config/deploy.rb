load 'deploy/assets'
require 'bundler/capistrano'
require 'capistrano/'
require 'capistrano/ext/multistage'

set :stages, %w(pennsic gulfwars)
set :default_stage, "pennsic"

set :application, 'thing'
set :repository,  "git://github.com/skandragon/#{application}.git"
set :deploy_to, "/www/#{application}"
set :use_sudo, false
set :scm, :git
set :branch, 'master'
set :deploy_via, :remote_cache

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

namespace :deploy do
  #noinspection RubyUnnecessarySemicolon
  task :start do ; end
  #noinspection RubyUnnecessarySemicolon
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

after 'deploy', 'deploy:cleanup' # keep only the last 5 releases

namespace :deploy do
  %w[start stop restart upgrade].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/unicorn/unicorn_#{application} #{command}"
    end
  end

  task :copy_secrets, roles: :app, except: { no_release: true } do
    run "cp #{deploy_to}/private/secrets.yml #{release_path}/config/secrets.yml"
  end
  after 'deploy:finalize_update', 'deploy:copy_secrets'

  task :backup_symlinks, roles: :app, except: { no_release: true } do
    run "ln -s #{shared_path}/system/backup #{release_path}/tmp/backup"
  end
  after 'deploy:finalize_update', 'deploy:backup_symlinks'

  namespace :resque do
    desc 'start or restart resque workers'
    task :start_or_restart, roles: :app, except: {no_release: true} do
      #run "/usr/local/bin/god signal resque QUIT"
    end
  end
  after 'deploy:restart', 'deploy:resque:start_or_restart'
  after 'deploy:start', 'deploy:resque:start_or_restart'

#  desc "Compile C code"
#  task :compile_c do
#    run "cd #{release_path}/util-src && make build install"
#  end
#  after "deploy:update_code", "deploy:compile_c"

  task :git_log, roles: :app, except: {no_release: true} do
    run "cd #{release_path} && git show --format='%H %ai' | head -1 > #{release_path}/hash.txt"
  end
  after 'deploy:update_code', 'deploy:git_log'

  task :setup_config, roles: :app do
    run "rm -f /etc/nginx/sites-enabled/#{application}"
    run "rm -f /etc/unicorn/unicorn_#{application}"
    run "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    run "ln -nfs #{current_path}/config/unicorn_init.sh /etc/unicorn/unicorn_#{application}"
#    run "mkdir -p #{shared_path}/config"
#    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
#    puts "Now edit the config files in #{shared_path}."
  end
  after 'deploy:setup', 'deploy:setup_config'

#  task :symlink_config, roles: :app do
#    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
#  end
#  after "deploy:finalize_update", "deploy:symlink_config"

  desc 'Make sure local git is in sync with remote.'
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts 'WARNING: HEAD is not the same as origin/master'
      puts 'Run `git push` to sync changes.'
      exit
    end
  end
  before 'deploy', 'deploy:check_revision'
end