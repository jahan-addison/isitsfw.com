require 'RMagick'
require 'digest/sha1'
require 'open-uri'
include Magick

escaped = 'http://i.imgur.com/QKqWyHS.jpg'

url      = "http://i.embed.ly/1/image/resize?url=" << escaped << "&key=c814a1d73fcc48ccab27c8830d92f26b&width=80&height=80"

escaped = 'http://i.imgur.com/QKqWyHS.jpg'

url2    =  "http://i.embed.ly/1/image/resize?url=" << escaped << "&key=c814a1d73fcc48ccab27c8830d92f26b&width=80&height=80"


image  = Magick::Image.from_blob(open(url).read).first
image2 = Magick::Image.from_blob(open(url2).read).first

#a = image.normalize.color_histogram
#b = image2.normalize.color_histogram

#t = 0
#a.each {|key, value|
#  b.each {|key2, value2|
#    t +=  key <=> key2
#  }
#}

#puts t / b.keys.length

#pu = Magick::Image.from_blob(open(url2).read).first


# puts Digest::SHA1.hexdigest image.export_pixels_to_str
# puts Digest::SHA1.hexdigest image2.export_pixels_to_str

