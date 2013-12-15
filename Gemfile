source 'http://rubygems.org'

gem "sinatra", "~> 1.4.4"

gem "aws-sdk", "~> 1.29.1"

gem "mime-types", "~> 2.0"

gem "mini_magick", "~> 3.7.0"

group :development do
  gem "capistrano", "~> 3.0.1"
  gem 'capistrano-bundler', "~> 1.0.0"
  gem 'capistrano-rbenv', github: "capistrano/rbenv"
end

group :test do
  gem "rspec", "~> 2.14.1"
  gem "rspec-mocks", "~> 2.14.4"
end

group :production, :staging do
  gem "passenger", "~> 4.0.29"
end