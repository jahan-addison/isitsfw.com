def fetch(uri)
  # You should choose better exception.
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0

  req          = Net::HTTP.new(uri.host, uri.port)
  req.use_ssl  = true if uri.scheme == "https"
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


