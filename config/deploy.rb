set :application, 'thing'
set :repo_url, 'git://github.com/skandragon/thing.git'

set :deploy_to, '/www/thing'
set :scm, :git
set :branch, "master"
set :deploy_via, :remote_cache

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# set :deploy_to, '/var/www/my_app'
# set :scm, :git

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :keep_releases, 5

namespace :deploy do
  desc 'Restart application'
  task :restart do
    desc "restart unicorn server"
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute "/etc/unicorn/unicorn_#{fetch :application} restart"
    end
  end

#  after :restart, :clear_cache do
#    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
#    end
#  end

  after :finishing, 'deploy:cleanup'

  task :git_log do
    on roles(:app), in: :sequence, except: {no_release: true} do
      execute "cd #{release_path} && rm -rf tmp/pids"
      execute "cd #{release_path} && ln -s #{shared_path}/pids tmp/pids"
      execute "cd #{repo_path} && git show --format='%H %ai' | head -1 > #{release_path}/hash.txt"
    end
  end
  after "deploy:updated", "deploy:git_log"

#  task :setup_config do
#    on roles(:app), in: sequence do
#      execute "rm -f /etc/nginx/sites-enabled/#{application}"
#      execute "rm -f /etc/unicorn/unicorn_#{application}"
#      execute "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
#      execute "ln -nfs #{current_path}/config/unicorn_init.sh /etc/unicorn/unicorn_#{application}"
#    end
#  end
#  after "deploy:setup", "deploy:setup_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app), in: :sequence do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end
  before "deploy", "deploy:check_revision"

  task :copy_secrets do
    on roles(:app) do
      run "cp #{deploy_to}/private/secrets.yml #{release_path}/config/secrets.yml"
    end
  end
  after 'deploy:migrate', 'deploy:copy_secrets'

  task :copy_system_files do
    on roles(:app) do
      %w{shared}.each do |share|
        execute "cp #{release_path}/#{share}/* #{shared_path}/system/"
        execute "chmod a+rX #{shared_path}/system/*.exe"
      end
    end
  end
  after 'deploy:updated', 'deploy:copy_system_files'
end
