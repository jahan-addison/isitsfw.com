require 'sinatra/base'
require 'sinatra/json'
require 'less'
require 'uri'
require 'open-uri'
require 'unirest'
require 'net/http'
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
      :OK       => 3,
      :MAYBE    => 1,
      :NOT_SURE => 2,
      :NO       => 0
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

  uri    = URI(params[:url])

  # 0) first let's see if this URL is even real
  begin
    req    = Net::HTTP.new(uri.host, uri.port)
    req.use_ssl = true if uri.scheme == "https"
    res    = req.request_head(uri.path)
  rescue Exception
    return json :status => codes[:NOT_SURE]
  end

  return json :status => codes[:NOT_SURE] unless res.code == "200"
  
  suffix = File.extname(uri.path).slice(1, File.extname(uri.path).length)

  # 1) determine priority of content analysis via information type
    # rule out bad files first
  if bad_files.include? suffix.downcase
    return json :status => codes[:NOT_SURE] 
  end
  # images
  if image.include? suffix.downcase
    Unirest.timeout(15)
    escaped  = URI.escape(uri.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    response = Unirest::get "https://nds.p.mashape.com/?url=" << URI.escape("http://i.embed.ly/1/image/resize?url=" << escaped << "&key=92b31102528511e1a2ec4040d3dc5c07&width=400&height=400", Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")), 
      headers: { 
        "X-Mashape-Authorization" => "oDpSINvANRazu7Yi9772wDrcaeHsYKMN"
      }
    data = response.body

    if data["is_nude"]    == 'true'
      json :status => codes[:NO]
    elsif data["is_nude"] == 'false'
      json :status => codes[:OK]
    end
  end

  # ...
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
