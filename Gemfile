source 'https://rubygems.org'

ruby '1.9.3'

# platform
gem 'sinatra'
gem 'data_mapper'
gem 'thin'

#deps
  #database
group :development do
  gem 'dm-sqlite-adapter'
end

group :production do
  gem 'dm-postgres-adapter'
end

gem 'rmagick'
gem 'sinatra-flash'
gem 'sinatra-contrib'
gem 'nokogiri'
gem 'rest-client'
gem 'rack-flash', '0.1.2'


# assets
gem 'therubyracer'
gem 'less'
gem 'sinatra-assetpack', :require => 'sinatra/assetpack'
gem 'yui-compressor',    :require => 'yui/compressor'
