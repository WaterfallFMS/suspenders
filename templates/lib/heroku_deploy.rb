begin
  class HerokuSan::API
    def post_addon(*args)
      heroku_api.post_addon(*args)
    rescue => e
      puts "Could not install #{args[1]}: #{e.to_s}"
    end

    def sh_heroku_local(app, *command)
      preflight_check_for_cli

      cmd = (['heroku'] + command + ['--app', app]).compact

      show_command = cmd.join(' ')
      $stderr.puts show_command if @debug

      ok = Bundler.with_clean_env { system show_command }

      status = $?
      ok or fail "Command failed with status (#{status.exitstatus}): [heroku #{show_command}]"
    end
  end

  class MyStrategy < HerokuSan::Deploy::Base
    def deploy
      tag = @commit || (@stage.tag ? "tag #{@stage.tag}": nil) || 'current branch'
      puts %Q(pushing "#{tag}" to #{@stage.name})

      super

      puts '--- Maintenance On'
      @stage.maintenance do
        # clear memcache
        @stage.run 'rails runner -e production Rails.cache.clear'
        # database backup
        @stage.heroku.sh_heroku_local @stage.app, 'pgbackups:capture --expire'
        @stage.migrate
      end
      puts '--- Maintenance Off'

      # rebuild index if needed
      if @stage.addons.include? 'flying_sphinx:wooden'
        @stage.run('rake search:index')
      end
    end
  end

  HerokuSan.project = HerokuSan::Project.new(Rails.root.join("config","heroku.yml"), :deploy => MyStrategy)
rescue NameError
  # if HerokuSan isn't loaded don't care
end
