require 'bundler'

# アプリ名
@app_name = app_name

# clean file
run 'rm README.rdoc'

# .gitignore
run 'gibo OSX Ruby Rails JetBrains > .gitignore' rescue nil
gsub_file '.gitignore', /^config\/initializers\/secret_token.rb$/, ''
gsub_file '.gitignore', /config\/secret.yml/, ''


# add to Gemfile
append_file 'Gemfile', <<-CODE

# Bootstrap & Bootswatch & font-awesome
gem 'bootstrap-sass'
gem 'bootswatch-rails'
gem 'font-awesome-rails'
gem 'twitter-bootswatch-rails'
gem 'twitter-bootswatch-rails-helpers'

# turbolinks support
gem 'jquery-turbolinks'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Assets log cleaner
gem 'quiet_assets'

# Views
gem 'haml-rails'
gem 'simple_form'
gem 'kaminari'
gem 'gretel'
gem 'redcarpet'

# Model
gem 'acts-as-taggable-on'
gem 'squeel'


# Auth
gem 'devise'

group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'thin'

  gem 'faker'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'launchy'
  gem 'selenium-webdriver'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'letter_opener'
  gem 'rails_layout'

end

gem 'rails_12factor', group: :production

CODE

Bundler.with_clean_env do
  run 'bundle install'
end

# set config/application.rb
application  do
  %q{
    # Set timezone
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
    # 日本語化
    I18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ja
    # generatorの設定
    config.generators do |g|
      g.orm :active_record
      g.template_engine :haml
      g.test_framework  :rspec, :fixture => true
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
      g.view_specs false
      g.controller_specs true
      g.routing_specs false
      g.helper_specs false
      g.request_specs false
      g.assets false
      g.helper false
    end
    # libファイルの自動読み込み
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
  }
end


# set Japanese locale
run 'wget https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml -P config/locales/'

# Database create
Bundler.with_clean_env do
  run 'bundle exec rake RAILS_ENV=development db:create'
end

# simple_form
generate 'simple_form:install --bootstrap'

# Kaminari config
generate 'kaminari:config'

# Device config
generate 'devise:install'
generate 'devise User'
generate 'devise:views'

# erb -> haml
Bundler.with_clean_env do
  run './bin/rake haml:erb2haml'
end

# Rspec
generate 'rspec:install'

insert_into_file 'spec/rails_helper.rb', %{

  # devise
  config.include Devise::TestHelpers, type: :controller

}, after: 'config.infer_spec_type_from_file_location!'

run 'bundle exec spring binstub --all'

run "echo '--color -f d' > .rspec"

# git init
# ----------------------------------------------------------------
git :init
git :add => '.'
git :commit => "-a -m 'Initial commit'"
