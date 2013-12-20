require 'sinatra/base'
require 'sinatra/json'
require 'less'
require 'uri'
require 'open-uri'
require 'rest-client'
require 'RMagick'
require 'digest/sha1'
require 'net/http'
require 'nokogiri'
require 'sinatra/assetpack'
require 'sinatra/flash'
require 'data_mapper'
include Magick

require './database'
require './lib/fetch_helper'


class App < Sinatra::Base

  enable :sessions
  set :environment, :production

  set :root, File.dirname(__FILE__)
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

  # test server
  # get '/test/*/*.*' do |path, file, ext|
  #  send_file File.join(File.expand_path(File.dirname(__FILE__) << '/tests/' << path), file.slice(0, file.length) <<  '.' << ext )
  # end
  
  get '/' do
    erb :index
  end

  get '/about' do
    message = <<EOF
Isitsfw.com is a service for employees who work in front of a computer screen, like me. There are times when we stumble upon links or are sent links through email or some other chat protocol. We <span class="red">MUST</span> be cautious and at all cost know the safety of whether or not a link, image, video, <u>WHATEVER</u> is SFW.
<br /><br />
My name is <a href="http://www.twitter.com/_jahan_">Jahan</a>, I am currently a Front-End Web Developer at Media Matters for America, based in Washington, D.C. 
<br /> <a class='return' href='/'> Return back </a> 
EOF
    erb :page, :locals => {:message => message}
  end
  
  get %r{/status/(\byes\b|\bnot\_sure\b|\bno\b|\bmaybe\b)$} do
    status  = params[:captures].first
    message = case 
      when status === "yes"
        "The location or file passed the scanner algorithms with flying colors! Please continue to be cautious of links from whom you do not trust."
      when status === "no"
        "The scanner algorithms search through metadata and other informative details that prescribe the content thereof; in the case of files such " <<
        "as images, decisive skin algorithms were triggered and it is <span class='red'>best</span> to avoid--false-positive may occur on close shots."
      when status === "maybe"
        "This particularly happens when an OK file was scanned, however its contents were 'plain text' -- and likely safe."
      when status === "not_sure"
        "This could mean a couple of things. There could have been an error with the URL (e.g. non-existent, 404 not found, etc); or an error with the " <<
        "internal system itself during the scan. It's likely the former, though."
    end

    if !params[:async].nil?
      message << "<br /> <a onclick='javascript:void();' class='close'> Close </a> "
      json :message => message
    else
      message << "<br /> <a class='return' href='/'> Return back </a> "
      erb :page, :locals => {:message => message}
    end
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
          "<div class='response no force'>NO! <a href='/status/no'>(why?)</a></div>",
          "<div class='response maybe force'>MAYBE? <a href='/status/maybe'>(why)</a></div>",
          "<div class='response not-sure force'>NOT SURE! <a href='/status/not_sure'>(why?)</a></div>",
          "<div class='response yes force'>YES! <a href='/status/yes'>(read more)</a></div>"
        ];
        flash[:notice] = responses[safety_level] 
        redirect '/'
      else
        # async call
        json :status => safety_level
      end
    end
    # we REQUIRE a scheme
    params[:url] = "http://" << params[:url] unless params[:url].match(/^https?\:\/{2}/)
    uri = URI(params[:url])

    # we REQUIRE a path
    uri.path   = '/'    if uri.path.empty?

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
        image    = Magick::Image.from_blob(open("http://i.embed.ly/1/image/resize?url=" << escaped << "&key=c814a1d73fcc48ccab27c8830d92f26b&width=80&height=80").read).first
        hash     = Digest::SHA1.hexdigest image.export_pixels_to_str
        @image   = Images.first({:image_hash => hash})
        if @image.nil?
          url      = "https://nds.p.mashape.com/?url=" << URI.escape("http://i.embed.ly/1/image/resize?url=" << escaped << "&key=c814a1d73fcc48ccab27c8830d92f26b&width=700&height=600", Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
          response = RestClient::Request.execute(:method => :get, :url => url, :timeout => 15, :open_timeout => 15, :headers => {
            "X-Mashape-Authorization" => "oDpSINvANRazu7Yi9772wDrcaeHsYKMN"})
          data = JSON.parse(response.body)
          if data["is_nude"]    == 'true'
            safety_level = codes[:NO]
          elsif data["is_nude"] == 'false'
            safety_level = codes[:OK]
          end
          @image   = Images.new :image_hash => hash, :status => safety_level
          @image.save
        else
          # we have a status already!
          safety_level = @image[:status]
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

      title         = doc.xpath("//title").to_s.split(' ')
        # and finally ...
      scan = keywords.concat description
        # include URI itself
      scan.concat uri.to_s.split(/\+|_|%20|\s|\-/)
        # title
      title[0]  = title[0].gsub("<title>",   '')
      title[-1] = title[-1].gsub("</title>", '')
      scan.concat title

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
