class ApplicationController < ActionController::Base
  protect_from_forgery

  #filters
  before_filter :oauth

  #helper_methods
  helper_method :make_key,:consumer,:goo_gl,:ux_un

  private
  def oauth
    request_token = consumer.get_request_token( :oauth_callback => "http://#{ request.host_with_port}/oauth_callback" )
    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret
    redirect_to request_token.authorize_url
    return
  end
  
  def consumer
    OAuth::Consumer.new(
                        OAUTH_CONSUMER_KEY,
                        OAUTH_CONSUMER_SECRET,
                        {  :site => "http://twitter.com" }
                        )
  end

  def make_key(i = 20)
    result = []
    res = ""
    i.times{  result << [(0..9),('a'..'z'),('A'..'Z')].map{|r| r.to_a}.flatten.sample(1)}
    result.flatten.each do |m|
      res += m.to_s
    end
    return res
  end

  def goo_gl(url)
    api = "" # Input your Goo.gl URL Shorter API URL
    uri = URI.parse(api)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    https.start {  |http|
      header = { "Content-Type" => "application/json"}
      body = {'longUrl'=> url}.to_json
      response = http.post(uri.path, body, header)
      return JSON.parse(response.body).fetch("id")
    }
  end

  def uxun(url)
    result = ""
    uri = URI.parse('http://ux.nu/api/short?url='+url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.start do |https|
      request = Net::HTTP::Get.new(uri.request_uri)        
      https.request(request) do |res|        
        res.read_body do |body|          
          result = JSON.parse(body).fetch('data').fetch('url')            
        end            
      end          
    end        
    return result
  end

end
