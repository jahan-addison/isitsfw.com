require 'sinatra/base'
require 'less'
require 'URI'
require 'nokogiri'
require 'sinatra/assetpack'

class App < Sinatra::Base
  set :environment, :development
  set :root, File.dirname(__FILE__)
  set :bind, '0.0.0.0'
  set :port, 8000
  Less.paths <<  "#{App.root}/public/css" 

  register Sinatra::AssetPack


  assets {
    serve '/js',     from: 'public/js'        # Default
    serve '/img',    from: 'public/img'       # Default
    serve '/css',    from: 'public/css'       # Default

    css :main, [
      '/css/main.css'
    ]

    # The second parameter defines where the compressed version will be served.
    # (Note: that parameter is optional, AssetPack will figure it out.)
    js :main, '/js/main.js', [
      '/js/vendor/**/*.js',
      '/js/lib/**/*.js',
      '/js/main.js'
    ]

    js_compression  :yui  
    css_compression :yui 
  }

  get '/' do
    erb :index
  end

  ##
  # 1) check meta-tags: description, author, keywords, et al
  # 2) determine priority of content analysis via information type
  # 3) analyze content
  # 4) return status code (safety level)
     # 0) (200): OK (YES)
     # 1) Maybe
     # 2) Not Sure
     # 9) NO

  post '/' do

  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
