begin
  class HerokuSan::Stage
    def contributors
      (@options['contributors'] ||= []).flatten
    end

    def sh_heroku_local(*command)
      preflight_check_for_cli
      cmd = (['heroku'] + command + ['--app', app]).compact
      show_command = cmd.join(' ')
      $stderr.puts show_command if @debug
      ok = system clean_env, show_command
      status = $?
      ok or fail "Command failed with status (#{status.exitstatus}): [#{show_command}]"
    end
  private
    def auth_token
      @auth_token ||= (ENV['HEROKU_API_KEY'] ||
        # have to clear munged ENV
        `GEM_HOME='' BUNDLE_GEMFILE='' GEM_PATH='' RUBYOPT='' heroku auth:token`.chomp unless MOCK)
    end

    def sh_heroku(*command)
      preflight_check_for_cli
      cmd = (command + ['--app', app]).compact
      show_command = cmd.join(' ')
      ok = system clean_env, "heroku", *cmd
      status = $?
      ok or fail "Command failed with status (#{status.exitstatus}): [heroku #{show_command}]"
    end

    def clean_env
      env = ENV.to_hash
      env['GEM_HOME']       = ''
      env['BUNDLE_GEMFILE'] = ''
      env['GEM_PATH']       = ''
      env['RUBYOPT']        = ''
      env
    end
  end

  class MyStrategy < HerokuSan::Deploy::Base
    def deploy
      check_assets

      tag = @commit || (@stage.tag ? "tag #{@stage.tag}": nil) || 'current branch'
      puts %Q(pushing "#{tag}" to #{@stage.name})

      super

      puts '--- Maintenance On'
      @stage.maintenance do
        # clear memcache
        @stage.run 'rails runner -e production Rails.cache.clear'
        # database backup
        @stage.sh_heroku_local 'pgbackups:capture --expire'
        @stage.migrate
      end
      puts '--- Maintenance Off'

      # rebuild index if needed
      if @stage.addons.include? 'flying_sphinx:wooden'
        @stage.run('rake search:index')
      end
    end

    def check_assets
      return if $assets_set

      puts 'Did you remember to run `rake assets:precompile` and checkin the changes?'
      puts '  Note: if you see a change make sure you bump the asset version number'
      print "yes or no: "
      response = $stdin.gets.strip.downcase

      unless response == 'yes'
        puts 'please make sure that assets are up to date before continuing.'
        exit 1
      end

      $assets_set = true
    end
  end

  HerokuSan.project = HerokuSan::Project.new(Rails.root.join("config","heroku.yml"), :deploy => MyStrategy)
rescue NameError
  # if HerokuSan isn't loaded don't care
end
