source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.16'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Using SQL SERVER
gem 'tiny_tds'
gem 'activerecord-sqlserver-adapter', '~> 4.1.2'

# Using Mysql server

gem 'mysql2', '~> 0.3.18'


# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
gem 'coffee-script-source', '1.8.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
 gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# jquery turbolinks for fixing the $(document).on('ready', function(){}) on the js pages for the use of turbolinks
gem 'jquery-turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# gem 'visjs-rails'

gem 'jquery-ui-rails'

gem 'gon'

# For using bootstrap datepicker
gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.42'

gem 'capistrano', '3.5.0'
gem 'capistrano-bundler', '~> 1.1.2'
gem 'capistrano-rails', '~> 1.1.1'

# Add this if you're using rbenv
# gem 'capistrano-rbenv', github: "capistrano/rbenv"

# Add this if you're using rvm (we are using rvm)
gem 'capistrano-rvm', github: "capistrano/rvm"

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
	# Use debugger
	# gem 'debugger'
	gem 'quiet_assets'
	gem "awesome_print", require:"ap"
	gem "better_errors"
  gem "puma"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin]
