def fetch(uri)
  req          = Net::HTTP.new(uri.host, uri.port)
  req.use_ssl  = true if uri.scheme == "https"
  # fake ua
  ua           = "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.10) Gecko/20100915 Ubuntu/10.04 (lucid) Firefox/3.6.10"
  response     = req.request_head(uri.path)
  if response.code == "301"
    response = Net::HTTP.get_response(URI.parse(response.header['location']))
  end
  case response
  when Net::HTTPSuccess     then response
  else
    response.error!
  end
end


