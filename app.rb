require 'sinatra/base'
require 'less'
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

    js_compression  :yui  # :jsmin | :yui | :closure | :uglify
    css_compression :yui  # :simple | :sass | :yui | :sqwish
  }

  get '/' do
    erb :index
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
