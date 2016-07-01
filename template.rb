# Rails Project Template


RUBY = '2.3.1'

insert_into_file "Gemfile", "\nruby '#{RUBY}'", after: "source 'https://rubygems.org'\n"

gem 'puma'

gem 'clearance'

gem 'sprockets-es6'

gem 'react-rails'

gem 'slim-rails'

gem 'faker'

gem_group :development, :test do
  gem 'dotenv-rails'

  gem 'pry-rails'
  gem 'rake'
  gem 'bullet'

  gem 'rspec-rails'
  gem 'capybara'
  gem 'poltergeist'

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


file('Procfile', "web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}")

insert_into_file('config/environments/development.rb', """
  config.assets.quiet = true
  
  
  config.after_initialize do
    Bullet.enable = true
    Bullet.console = true
    Bullet.rails_logger = true
    #Bullet.add_footer = true
  end
""", after: "   # config.action_view.raise_on_missing_translations = true")


append_to_file("Gemfile", <<-GEM)
\n
source 'https://rails-assets.org' do
  gem 'rails-assets-skeleton'
end
\n
GEM

insert_into_file("app/assets/stylesheets/application.css", "*= require skeleton\n", before: "*= require_tree .")

create_file('.ruby-version', RUBY)

create_file('.travis.yml', <<-TRAVIS)
language: ruby
cache: bundler
rvm:
  - #{RUBY}
script:
  - bin/rspec
bundler_args: --without production
TRAVIS

remove_file('app/views/layouts/application.html.erb')
create_file('app/views/layouts/application.html.slim', <<-HTML)
doctype html
html
  head
    meta[charset="utf-8"]
    meta[http-equiv="X-UA-Compatible" content="IE=edge"]
    meta[name="description" content=""]
    meta[name="viewport" content="width=device-width, initial-scale=1"]
    title
      = local_assigns.fetch(:title, [controller_name, action_name].map(&:titleize).join(" - "))
    = csrf_meta_tags
    = stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track' => true

  body
    nav
      - if signed_in?
        p = "Signed in as: \#{current_user.email}"
        = button_to 'Sign out', sign_out_path, method: :delete
      - else
        = link_to 'Sign in', sign_in_path


    - flash.each do |key, value|
      .flash class = key
        = value

    .main-content
      .container
        = yield

    = javascript_include_tag 'application', 'data-turbolinks-track' => true
HTML


after_bundle do
  run 'rails g react:install'
  run 'rails g rspec:install'
  run 'bundle exec guard init livereload'

  run %{echo "require 'simplecov'
SimpleCov.start
$(cat spec/spec_helper.rb)" > spec/spec_helper.rb}

  rake('db:create')
  run 'rails generate clearance:install'
  rake('db:migrate')
end
