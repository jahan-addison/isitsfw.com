def send_request(uri)
  req              = Net::HTTP.new(uri.host, uri.port)
  req.use_ssl      = true if uri.scheme == "https"
  req.verify_mode  = OpenSSL::SSL::VERIFY_NONE if uri.scheme == "https"
  # fake ua
  ua           = "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.10) Gecko/20100915 Ubuntu/10.04 (lucid) Firefox/3.6.10"
  
  response     = req.request_head(uri.path)
end

def fetch(uri)
  response     = send_request(uri)
  if response.code == "301"
    uri      = URI(response.header['location']) 
    response = send_request(uri)
  end
  case response
  when Net::HTTPSuccess     then return response, uri
  else
    response.error!
  end
end


