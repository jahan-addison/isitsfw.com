require 'sinatra/base'
require 'sinatra/json'
require 'less'
require 'uri'
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

  # todo: accept parameter

  get '/' do
    erb :index
  end

  ##
  # 1) determine priority of content analysis via information type
  # 2) check meta-tags: description, author, keywords, et al if applicable
  # 3) analyze content
  # 4) return status code (safety level)
     # 0) (200): OK (YES)
     # 1) Maybe
     # 2) Not Sure
     # 9) NO

  post '/' do
    # status safety codes
    codes = {
      :OK       => 0,
      :MAYBE    => 1,
      :NOT_SURE => 2,
      :NO       => 9
    }
    # valid images
    image = [
      "jpg",
      "jpeg",
      "png",
      "bmp",
      "gif",
      "tiff"
    ]
    # bad files
    bad_files = [
    "doc", "docx", "log", "msg", "odt", "pages", "wpd", "wps", "gbr", "ged", "ibooks", "key", "keychain", "pps", "ppt", "pptx", "sdf",
    "tar", "tax2012", "aif", "iff", "m3u", "m4a", "mid", "mp3", "mpa", "ra", "wav", "wma", "3g2", "3gp", "asf", "asx", "avi", "flv", "m4v", "mov", "mp4",
    "mpg", "rm", "srt", "swf", "vob", "wmv", "3dm", "3ds", "max", "obj", "bmp", "dds",
    "psd", "pspimage", "tga", "thm", "tif",  "yuv", "ai", "eps", "ps", "svg", "indd", "pct", "pdf", "xlr", "xls", "xlsx", "accdb", "db", 
    "pdb", "apk", "app", "bat", "cgi", "com", "exe", "gadget", "jar", "pif", "vb",
    "wsf", "dem", "gam", "nes", "rom", "sav", "dwg", "dxf", "gpx", "kml", "kmz", 
    "fnt", "fon", "otf", "ttf", "cab", "cpl", "cur", "deskthemepack", "dll", "dmp", 
    "icns", "ico", "lnk", "sys", "cfg", "ini", "prf", "hqx", "mim", "uue", "7z", "cbr",
    "deb", "gz", "pkg", "rar", "rpm", "sitx", "tar.gz", "zip", "zipx", "bin", "cue", "dmg",
    "iso", "dbf", "mdb", "plugin", "mdf", "toast", "drv", "vcd", 
    "xcodeproj", "bak", "tmp", "crdownload", "ics", "msi", "part", "torrent"
  ];
    uri = {}
    begin
      uri = URI(params[:url])
    rescue URI::Error
      # ERROR! status safety not sure!
      json :status => codes[:NOT_SURE]
    end
    
    suffix = File.extname(uri.path)

  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
