require 'RMagick'
require 'digest/sha1'
require 'open-uri'
include Magick

escaped = 'http://i.imgur.com/qJqyaxI.jpg'

url      = "http://i.embed.ly/1/image/resize?url=" << escaped << "&key=c814a1d73fcc48ccab27c8830d92f26b&width=30&height=30"

escaped = 'http://s8.postimg.org/wxpb6nu91/q_Jqyax_I.jpg'

url2    =  "http://i.embed.ly/1/image/resize?url=" << escaped << "&key=c814a1d73fcc48ccab27c8830d92f26b&width=30&height=30"

image = Magick::Image.from_blob(open(url).read).first

image = Magick::Image.from_blob(open(url2).read).first


puts Digest::SHA1.hexdigest image2.export_pixels_to_str
puts Digest::SHA1.hexdigest image3.export_pixels_to_str

