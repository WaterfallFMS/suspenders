module Suspenders
  class AppBuilder < Rails::AppBuilder
    include Suspenders::Actions

    def readme
      template 'README.md.erb', 'README.md'
    end

    def remove_public_index
      remove_file 'public/index.html'
    end

    def remove_rails_logo_image
      remove_file 'app/assets/images/rails.png'
    end

    def copy_config
      remove_file 'config/locales/en.yml'
      directory 'suspender_config', 'config', :exclude_pattern => /\.erb/
      invoke :setup_secret_token
    end

    def copy_controllers
      remove_file 'app/controllers/application_controller.rb'
      directory 'controllers', 'app/controllers'
    end

    def copy_migrations
      copy_file 'db/create_user_migration.rb', 'db/migrate/20131209215557_create_users.rb'
      copy_file 'db/create_tenant_migration.rb', 'db/migrate/20131210131921_create_tenants.rb'
    end

    def copy_helpers
      remove_file 'app/helpers/application_helper.rb'
      directory 'helpers', 'app/helpers'
    end

    def copy_policies
      directory 'policies', 'app/policies'
    end

    def copy_lib
      directory 'lib/templates', 'lib/templates'
    end

    def copy_javascripts
      remove_file 'app/assets/javascripts/application.js'
      directory 'javascripts', 'app/assets/javascripts'
    end

    def copy_models
      directory 'models', 'app/models'
    end

    def copy_spec
      remove_file 'spec/spec_helper.rb'
      directory 'spec', 'spec'
    end

    def copy_views
      directory 'views', 'app/views'
    end

    def raise_on_delivery_errors
      replace_in_file 'config/environments/development.rb',
        'raise_delivery_errors = false', 'raise_delivery_errors = true'
    end

    def raise_on_unpermitted_parameters
      action_on_unpermitted_parameters = <<-RUBY

  # Raise an ActionController::UnpermittedParameters exception when
  # a parameter is not explcitly permitted but is passed anyway.
  config.action_controller.action_on_unpermitted_parameters = :raise
      RUBY
      inject_into_file(
        "config/environments/development.rb",
        action_on_unpermitted_parameters,
        before: "\nend"
      )
    end

    def provide_setup_script
      copy_file 'bin_setup', 'bin/setup'
      run 'chmod a+x bin/setup'
    end

    def configure_generators
      config = <<-RUBY
    config.generators do |generate|
      generate.helper false
      generate.javascript_engine false
      generate.request_specs false
      generate.routing_specs false
      generate.stylesheets false
      generate.test_framework :rspec
      generate.view_specs false
    end

      RUBY

      inject_into_class 'config/application.rb', 'Application', config
    end

    def copy_tddium
      copy_file 'suspender_config/tddium.yml', 'config/tddium.yml'
    end

    def test_factories_first
      append_file 'Rakefile', factories_spec_rake_task
    end

    def configure_smtp
      prepend_file 'config/environments/production.rb',
        "require Rails.root.join('config/initializers/smtp')\n"

      config = <<-RUBY

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = SMTP_SETTINGS
      RUBY

      inject_into_file 'config/environments/production.rb', config,
        :after => 'config.action_mailer.raise_delivery_errors = false'
    end

    def enable_rack_deflater
      config = <<-RUBY

  # Enable deflate / gzip compression of controller-generated responses
  config.middleware.use Rack::Deflater
      RUBY

      inject_into_file 'config/environments/production.rb', config,
        :after => "config.serve_static_assets = false\n"
    end

    def setup_staging_environment
      run 'cp config/environments/production.rb config/environments/staging.rb'

      prepend_file 'config/environments/staging.rb',
        "Mail.register_interceptor RecipientInterceptor.new(ENV['EMAIL_RECIPIENTS'])\n"
    end

    def create_slug_ignore
      copy_file 'slug_ignore', '.slugignore'
    end

    def copy_heroku_config
      template 'suspender_config/heroku_san.yml.erb', 'config/heroku.yml'
    end

    def correct_heroku_deploy
      config = <<-RUBY
require Rails.root.join('lib','heroku_deploy') rescue nil
      RUBY

      copy_file 'lib/heroku_deploy.rb', 'lib/heroku_deploy.rb'
      inject_into_file 'Rakefile', config,
        :after => "require File.expand_path('../config/application', __FILE__)\n"
    end

    def setup_secret_token
      template 'suspender_config/initializers/secret_token.rb.erb',
        'config/initializers/secret_token.rb',
        :force => true
    end

    def create_partials_directory
      empty_directory 'app/views/application'
    end

    def create_shared_flashes
      copy_file 'views/application/_flashes.html.erb', 'app/views/application/_flashes.html.erb'
    end

    def create_shared_javascripts
      copy_file 'views/application/_javascript.html.erb', 'app/views/application/_javascript.html.erb'
    end

    def create_application_layout
      remove_file 'app/views/layouts/application.html.erb'
      #template 'views/layouts/application.html.erb.erb',
      #  'app/views/layouts/application.html.erb',
      #  :force => true
    end

    def remove_turbolinks
      replace_in_file 'app/assets/javascripts/application.js',
        /\/\/= require turbolinks\n/,
        ''
    rescue
    end

    def use_postgres_config_template
      template 'suspender_config/postgresql_database.yml.erb', 'config/database.yml',
        :force => true
    end

    def create_database
      bundle_command 'exec rake db:create db:migrate'
    end

    def replace_gemfile
      remove_file 'Gemfile'
      copy_file 'Gemfile_clean', 'Gemfile'
    end

    def set_ruby_to_version_being_used
      inject_into_file 'Gemfile', "\n\nruby '#{RUBY_VERSION}'",
        after: /source 'https:\/\/rubygems.org'/
      create_file '.ruby-version', "#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}\n"
      create_file '.ruby-gemset', "#{app_name}\n"
    end

    def enable_database_cleaner
      #copy_file 'spec/support/database_cleaner_rspec.rb', 'spec/support/database_cleaner.rb'
    end

    def configure_spec_support_features
      empty_directory_with_keep_file 'spec/features'
      empty_directory_with_keep_file 'spec/support/features'
    end

    def use_rspec_binstub
      bundle_command 'binstub rspec-core'
      run 'rm bin/autospec'
    end

    def configure_background_jobs_for_rspec
      #copy_file 'spec/support/background_jobs_rspec.rb', 'spec/support/background_jobs.rb'
      generate 'delayed_job:active_record'
    end

    def configure_time_zone
      config = <<-RUBY
    config.active_record.default_timezone = :utc

      RUBY
      inject_into_class 'config/application.rb', 'Application', config
    end

    def configure_time_formats
      #remove_file 'config/locales/en.yml'
      #copy_file 'config/locales/en.yml', 'config/locales/en.yml'
    end

    def configure_rack_timeout
      #copy_file 'config/initializers/rack_timeout.rb', 'config/initializers/rack_timeout.rb'
    end

    def configure_action_mailer
      action_mailer_host 'development', "#{app_name}.local"
      action_mailer_host 'test', 'www.example.com'
      action_mailer_host 'staging', "staging.#{app_name}.com"
      action_mailer_host 'production', "#{app_name}.com"
    end

    def generate_rspec
      generate 'rspec:install'
    end

    def generate_clearance
      generate 'clearance:install'
    end

    def configure_unicorn
      copy_file 'unicorn.rb', 'config/unicorn.rb'
    end

    def setup_foreman
      copy_file 'sample.env', '.sample.env'
      copy_file 'Procfile', 'Procfile'
    end
    
    def generate_simple_form
      generate 'simple_form:install --foundation'
      copy_file 'lib/templates/haml/scaffold/_form.html.haml', 'lib/templates/haml/scaffold/_form.html.haml'
    end

    def setup_stylesheets
      remove_file 'app/assets/stylesheets/application.css'
      copy_file 'application.css.scss',
        'app/assets/stylesheets/application.css.scss'
    end

    def gitignore_files
      remove_file '.gitignore'
      copy_file 'suspenders_gitignore', '.gitignore'
      [
        'app/views/pages',
        'spec/lib',
        'spec/controllers',
        'spec/helpers',
        'spec/support/matchers',
        'spec/support/mixins',
        'spec/support/shared_examples'
      ].each do |dir|
        run "mkdir #{dir}"
        run "touch #{dir}/.keep"
      end
    end

    def init_git
      run 'git init'
    end

    def create_heroku_apps
      path_addition = override_path_for_tests
      run "#{path_addition} heroku create #{app_name}-production --remote=production"
      run "#{path_addition} heroku create #{app_name}-staging --remote=staging"
      run "#{path_addition} heroku config:add RACK_ENV=staging RAILS_ENV=staging --remote=staging"
    end

    def set_heroku_remotes
      remotes = <<-RUBY

# Set up staging and production git remotes
git remote add staging git@heroku.com:#{app_name}-staging.git
git remote add production git@heroku.com:#{app_name}-production.git
      RUBY

      append_file 'bin/setup', remotes
    end

    def set_heroku_rails_secrets
      path_addition = override_path_for_tests
      run "#{path_addition} heroku config:add SECRET_KEY_BASE=#{generate_secret} --remote=staging"
      run "#{path_addition} heroku config:add SECRET_KEY_BASE=#{generate_secret} --remote=production"
    end

    def create_github_repo(repo_name)
      path_addition = override_path_for_tests
      run "#{path_addition} hub create #{repo_name}"
    end

    def copy_miscellaneous_files
      #copy_file 'config/initializers/errors.rb', 'config/initializers/errors.rb'
    end

    def customize_error_pages
      meta_tags =<<-EOS
  <meta charset='utf-8' />
  <meta name='ROBOTS' content='NOODP' />
      EOS

      %w(500 404 422).each do |page|
        inject_into_file "public/#{page}.html", meta_tags, :after => "<head>\n"
        replace_in_file "public/#{page}.html", /<!--.+-->\n/, ''
      end
    end

    def remove_routes_comment_lines
      replace_in_file 'config/routes.rb',
        /Application\.routes\.draw do.*end/m,
        "Application.routes.draw do\nend"
    end

    def disable_xml_params
      #copy_file 'config/initializers/disable_xml_params.rb', 'config/initializers/disable_xml_params.rb'
    end

    def setup_default_rake_task
      append_file 'Rakefile' do
        "task(:default).clear\ntask :default => [:spec]\n"
      end
    end

    def add_saml_config
      config = <<-RUBY
SAML_IDP_ISSUER=#{app_name}
SAML_IDP_TARGET_URL=http://saml-idp.dev/saml/auth
SAML_IDP_CERT_FINGERPRINT=74:51:A0:EE:40:A5:B3:D9:6F:1C:23:8D:59:04:81:8A:4B:12:F5:FF
SAML_IDP_NAME_FORMAT=urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress
      RUBY

      inject_into_file ".sample.env", config, :after => "SECRET_KEY_BASE=development_secret\n"
    end

    def configure_saml_routes
      config = <<-RUBY
  get  '/auth/failure'       => 'sessions#failure'
  get  '/auth/saml/metadata' => 'sessions#metadata'
  post '/auth/saml/callback' => 'sessions#create'
  get  '/auth/saml/callback' => 'sessions#create' if Rails.env.test?
  get  '/auth/saml/destroy'  => 'sessions#destroy', :as => 'logout'

  # replace with real actions
  get '/internal' => 'application#internal'  # requires login

  root :to => 'root#index'
      RUBY

      inject_into_file "config/routes.rb", config, :before => "end"
    end

    private

    def override_path_for_tests
      if ENV['TESTING']
        support_bin = File.expand_path(File.join('..', '..', '..', 'features', 'support', 'bin'))
        "PATH=#{support_bin}:$PATH"
      end
    end

    def factories_spec_rake_task
      IO.read find_in_source_paths('factories_spec_rake_task.rb')
    end

    def generate_secret
      SecureRandom.hex(64)
    end

    def bundle_command(command)
      run "rvm #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}@#{app_name} --create do bundle #{command}"
    end

    def generate(command)
      bundle_command "exec rails g #{command}"
    end
  end
end
