set :application, 'thing'
set :repo_url, 'git://github.com/skandragon/thing.git'

set :deploy_to, '/www/thing'
set :scm, :git
set :branch, 'master'
set :deploy_via, :remote_cache

set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.4.0'

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

set :linked_files, %w{config/secrets.yml}

set :puma_conf, "#{shared_path}/config/puma.rb"

namespace :deploy do
  before 'check:linked_files', 'puma:config'
  before 'check:linked_files', 'puma:nginx_config'
  after 'puma:smart_restart', 'nginx:restart'

  task :git_log do
    on roles(:app), in: :sequence, except: {no_release: true} do
      execute "cd #{release_path} && rm -rf tmp/pids"
      execute "cd #{release_path} && ln -s #{shared_path}/pids tmp/pids"
      execute "cd #{repo_path} && git show --format='%H %ai' | head -1 > #{release_path}/hash.txt"
    end
  end
  after 'deploy:updated', 'deploy:git_log'

  desc 'Make sure local git is in sync with remote.'
  task :check_revision do
    on roles(:app), in: :sequence do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts 'WARNING: HEAD is not the same as origin/master'
        puts 'Run `git push` to sync changes.'
        exit
      end
    end
  end
  before 'deploy', 'deploy:check_revision'
end
