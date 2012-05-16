# -*- coding: utf-8 -*-
require 'oauth'
require 'json'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class UsersController < ApplicationController

  def index
    
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
  

  def oauth
    request_token = consumer.get_request_token( :oauth_callback => "http://#{ request.host_with_port}/oauth_callback" )
    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret
    redirect_to request_token.authorize_url
    return
  end

  def oauth_callback
    request_token = OAuth::RequestToken.new(
                                            consumer,
                                            session[:request_token],
                                            session[:request_secret]
                                            )
    access_token = request_token.get_access_token(
                                                  { },
                                                  :oauth_token => params[:oauth_token],
                                                  :oauth_verifier => params[:oauth_verifier]
                                                  )
    
    response = consumer.request(
                                :get,
                                '/account/verify_credentials.json',
                                access_token, {  :scheme => :query_string }
                                )
    case response
    when Net::HTTPSuccess
      @user_info = JSON.parse(response.body)
      unless @user_info['screen_name']
        flash[:notice] = "Authentication failed"
        redirect_to :action => :index
        return
      end
    else
      RAILS_DEFAULT_LOGGER.error "Failed to get user info via OAuth"
      flash[:notice] = "Authentication failed"
      redirect_to :action => :index
      return
    end

    session['user_key'] = make_key(40)
    session['access_token'] = access_token.token
    session['access_secret'] = access_token.secret
    redirect_to :action => :regist, :controller => "Users"

  end

  def regist
    unless session['user_key']
      redirect_to :action => :index, :controller => "Users"
    else
      @user = User.new({
                         :user_key => session['user_key'],
                         :access_token => session['access_token'],
                         :access_secret => session['access_secret']
                       })
      
      @user.save
    end
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

  def post
    @key = params['i']
    @title = params['t']
    @url = uxun(params['u'])
    # @url = goo_gl(params['u'])

    #respond_to do |format|
    #  format.html
    #end

  end
  
  def tweet

    begin
      postdata = { 'status' => params['status'] }
      user = User.find_by_user_key(params['key'])

      access_token = OAuth::AccessToken.new(
                                            consumer,
                                            user.access_token,
                                            user.access_secret
                                            )
      uri = URI.parse('https://api.twitter.com/1/statuses/update.json')
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      https.ca_file = 'certifications/api.twitter.com.pem' # SSL証明書のパスを書く
      https.verify_mode = OpenSSL::SSL::VERIFY_PEER
      https.verify_depth = 5


      https.start do |https|
        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data(postdata)
        request.oauth!(https, consumer, access_token) # OAuthで認証
        
        https.request(request) do |res|
          res.read_body do |body|
            @result = JSON.parse(body)
          end
        end
      end
      @tweet_url = 'http://twitter.com/'+@result['user']['id_str']+'/status/'+@result['id_str']      
      @error = false
      respond_to do |format|
        format.js
      end

    rescue
      @error = true
      respond_to do |format|
        format.js
      end
    end

  end

end
