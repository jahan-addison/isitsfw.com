require 'sinatra/base'
require 'sinatra/json'
require 'less'
require 'uri'
require 'open-uri'
require 'rest-client'
require 'net/http'
require 'nokogiri'
require 'sinatra/assetpack'
require 'sinatra/flash'

require './lib/fetch_helper'

class App < Sinatra::Base
  set :environment, :development

  enable :sessions

  set :root, File.dirname(__FILE__)
  set :bind, '0.0.0.0'
  set :port, 8000
  Less.paths <<  "#{App.root}/public/css" 

  register Sinatra::AssetPack
  register Sinatra::Flash

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
  # 1) determine priority of content analysis via information type
  # 2) check meta-tags: description, author, keywords, et al if applicable
  # 3) analyze content
  # 4) return status code (safety level)
     # 3) (200): OK (YES)
     # 1) Maybe
     # 2) Not Sure
     # 0) NO

  post '/' do
    # status safety codes
    codes = {
      :OK       => 3,
      :MAYBE    => 1,
      :NOT_SURE => 2,
      :NO       => 0
    }

    # default safety level
    safety_level = codes[:MAYBE]

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

    # response helper for graceful degradation
    def send!(safety_level)
      if params[:async].nil?
        responses      = [
          "<div class='response no force'>NO! <a href='#'>(why?)</a></div>",
          "<div class='response maybe force'>MAYBE? <a href='#'>(why)</a></div>",
          "<div class='response not-sure force'>NOT SURE! <a href='#'>(why?)</a></div>",
          "<div class='response yes force'>YES! <a href='#'>(read more)</a></div>"
        ];
        flash[:notice] = responses[safety_level] 
        redirect '/'
      else
        # async call
        json :status => safety_level
      end
    end

    uri = URI(params[:url].end_with?('/') ? params[:url] : params[:url] << '/')

    # 0) let's see if this URL is even real
    begin
      res = fetch(uri)
    rescue Exception
      safety_level = codes[:NOT_SURE]
      # emergancy halt
      return send! safety_level
    end
    
    safety_level = codes[:NOT_SURE] unless res.code == "200"
    if safety_level == codes[:NOT_SURE]
      # emergancy halt
      return send! safety_level
    end

    suffix = File.extname(uri.path).slice(1, File.extname(uri.path).length)

    # 1) determine priority of content analysis via information type
    if !suffix.nil?
        # rule out bad files first
      if bad_files.include? suffix.downcase
        safety_level = codes[:NOT_SURE] 
      end
        # images
      if image.include? suffix.downcase
        escaped  = URI.escape(uri.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
        url      = "https://nds.p.mashape.com/?url=" << URI.escape("http://i.embed.ly/1/image/resize?url=" << escaped << "&key=92b31102528511e1a2ec4040d3dc5c07&width=600&height=500", Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
        response = RestClient::Request.execute(:method => :get, :url => url, :timeout => 15, :open_timeout => 15, :headers => {
          "X-Mashape-Authorization" => "oDpSINvANRazu7Yi9772wDrcaeHsYKMN"})
        data = JSON.parse(response.body)
        if data["is_nude"]    == 'true'
          safety_level = codes[:NO]
        elsif data["is_nude"] == 'false'
          safety_level = codes[:OK]
        end
      end
    end
    # 2) check meta-tags: description, author, keywords, et al if applicable
      # load up our list of "naughty words"
    fd            = File.open("lib/bad_words.txt")
    naughty_words = fd.read.split($/).map{|x| x.downcase}
    fd.close
    begin
      doc           = Nokogiri::HTML(open(uri))

      keywords      = doc.xpath("//meta[@name='Keywords']/@content").to_s.split(',') \
        .concat doc.xpath("//meta[@name='keywords']/@content").to_s.split(',')

      description   = doc.xpath("//meta[@name='Description']/@content").to_s.split(' ') \
        .concat doc.xpath("//meta[@name='description']/@content").to_s.split(' ')

        # and finally ...
      scan = keywords.concat description
        # include URI itself
      scan.concat uri.to_s.split(/\+|_|%20|\s|\-/)

      # 3) analyze content
      scan.map!{|x| x.downcase}
      naughty_words.each { |x|
        safety_level = codes[:NO] if scan.include? x.downcase
        safety_level = codes[:NO] if uri.host.downcase.include? x
      }

      # 4) return status code (safety level)
        # special case (youtube.com)
        family_safe = doc.xpath("//meta[@name='isFamilyFriendly']/@content").to_s
        if (!family_safe.empty? && family_safe != 'True')
          safety_level = codes[:NO]
        end
      rescue Exception
        # emergancy halt
        safety_level == codes[:NOT_SURE]
        return send! safety_level
      end
      # if it was a file that was OK, maybe
      # otherwise yes.

    if safety_level == codes[:MAYBE] && suffix.nil?
      safety_level = codes[:OK]
    end

    return send! safety_level

  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
