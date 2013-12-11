require 'unirest'
require 'open-uri'


Unirest.timeout(25)

response = Unirest::get "https://nds.p.mashape.com/?url=" << URI.escape("http://i.embed.ly/1/image/resize?url=http%3A%2F%2Fforeverotaku.com%2Fgallery%2Fwp-content%2Fuploads%2F2012%2F12%2F3721_491107730907541_395520175_n-608x695.jpg&key=92b31102528511e1a2ec4040d3dc5c07&width=300&height=300", Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")), 
  headers: { 
    "X-Mashape-Authorization" => "oDpSINvANRazu7Yi9772wDrcaeHsYKMN"
  }
puts response.body
