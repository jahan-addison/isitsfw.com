require 'sinatra/base'
require 'less'
require 'sinatra/assetpack'

class App < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :bind, '0.0.0.0'
  Less.paths <<  "#{App.root}/app/css" 

  register Sinatra::AssetPack


  assets {
    serve '/js',     from: 'app/js'        # Default
    serve '/img',    from: 'app/img'       # Default
    serve '/css',    from: 'app/css'       # Default

    css :main, [
      '/css/main.less'
    ]

    # The second parameter defines where the compressed version will be served.
    # (Note: that parameter is optional, AssetPack will figure it out.)
    js :app, '/js/app.js', [
      '/js/vendor/**/*.js',
      '/js/lib/**/*.js'
    ]


    js_compression  :jsmin    # :jsmin | :yui | :closure | :uglify
    css_compression :simple   # :simple | :sass | :yui | :sqwish
  }

  get '/' do
    erb :index
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
