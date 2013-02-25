require 'tempfile'
require 'cgi'
require 'json'
require 'restclient'

module DotMailer
  class Client
    def initialize(api_user, api_pass)
      self.api_user = api_user
      self.api_pass = api_pass
    end

    def get(path)
      endpoint = endpoint_for(path)
      response = RestClient.get endpoint, :accept => :json

      JSON.parse response
    rescue RestClient::BadRequest => e
      raise InvalidRequest, JSON.parse(e.http_body)['message']
    end

    def post_json(path, params)
      post path, params.to_json, :content_type => :json
    end

    # Need to use a Tempfile as the API will not accept CSVs
    # without filenames
    def post_csv(path, csv)
      file = Tempfile.new(['dotmailer-contacts', '.csv'])
      file.write csv
      file.rewind

      post path, :csv => file
    end

    def post(path, data, options = {})
      endpoint = endpoint_for(path)
      response = RestClient.post endpoint, data, options.merge(:accept => :json)

      JSON.parse response
    rescue RestClient::BadRequest => e
      raise InvalidRequest, JSON.parse(e.http_body)['message']
    end

    private
    attr_accessor :api_user, :api_pass

    def endpoint_for(path)
      URI::Generic.build(
        :scheme   => 'https',
        :userinfo => "#{CGI.escape(api_user)}:#{CGI.escape(api_pass)}",
        :host     => 'api.dotmailer.com',
        :path     => "/v2#{path}"
      ).to_s
    end
  end
end
