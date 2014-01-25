load 'deploy/assets'
require 'bundler/capistrano'

set :stages, %w(pennsic gulfwars)
set :default_stage, "pennsic"
require 'capistrano/ext/multistage'

set :application, 'thing'
set :repository,  "git://github.com/skandragon/#{application}.git"
set :deploy_to, "/www/#{application}"
set :use_sudo, false
set :scm, :git
set :branch, 'master'
set :deploy_via, :remote_cache

set :rails_env, 'production'

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

  task :build_configs, roles: :app, except: {no_release: true} do
    ['config/unicorn_init.sh', 'config/unicorn.rb', 'config/nginx.conf'].each do |filename|
      run "ls -l #{release_path}/#{filename}"
      puts "Building #{filename}"...
      data = File.read("#{release_path}/#{filename}.in")
      data.gsub!('@app@', server_socket)
      data.gsub!('@servername@', server_hostname)
      File.open("#{release_path}/#{filename}", "w") do |file|
        file.puts data
      end
    end
    exit
  end
  after 'deploy:git_log', 'deploy:build_configs'

  task :setup_configs, roles: :app do
    run "rm -f /etc/nginx/sites-enabled/#{application}"
    run "rm -f /etc/unicorn/unicorn_#{application}"
    run "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    run "ln -nfs #{current_path}/config/unicorn_init.sh /etc/unicorn/unicorn_#{application}"
#    run "mkdir -p #{shared_path}/config"
#    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
#    puts "Now edit the config files in #{shared_path}."
  end
  after 'deploy:setup', 'deploy:setup_configs'

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