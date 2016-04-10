# Rails Project Template


file('Procfile', "web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}")

insert_into_file "Gemfile", "\nruby '2.3.0'", after: "source 'https://rubygems.org'\n"


gem 'puma'

gem 'clearance'

gem 'sprockets-es6'

gem 'react-rails'

gem 'slim-rails'

gem 'faker'

gem_group :development, :test do
  gem 'dotenv-rails'

  gem 'pry'
  gem 'bullet'

  gem 'rspec-rails'
  gem 'capybara'
  gem 'poltergeist'

  gem 'quiet_assets'
  gem 'database_cleaner'

  gem 'timecop'
  gem 'simplecov', require: false
  gem 'zonebie'

  gem 'guard-livereload', '~> 2.5', require: false
  gem 'guard-rspec', require: false
end

gem_group :production do
  gem 'rails_12factor'
end


insert_into_file('config/environments/development.rb', """
  config.after_initialize do
    Bullet.enable = true
    Bullet.console = true
    Bullet.rails_logger = true
    #Bullet.add_footer = true
  end
""", after: "   # config.action_view.raise_on_missing_translations = true")


insert_into_file("Gemfile", """
\n\n
source 'https://rails-assets.org' do
  gem 'rails-assets-skeleton'
""", after: """  gem 'rails-assets-skeleton'\nend""")

insert_into_file("app/assets/stylesheets/application.css", """
*= require skeleton
""", before: "*= require_tree .")


after_bundle do
  run 'rails g react:install'
  run 'rails g rspec:install'
  run 'bundle exec guard init livereload'

  run %{echo "require 'simplecov'
SimpleCov.start
$(cat spec/spec_helper.rb)" > spec/spec_helper.rb}

  run 'rails generate clearance:install'
end
