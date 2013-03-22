# encoding: utf-8
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
      rescue_api_errors do
        endpoint = endpoint_for(path)
        response = RestClient.get endpoint, :accept => :json

        JSON.parse response
      end
    end

    def get_csv(path)
      rescue_api_errors do
        endpoint = endpoint_for(path)
        response = RestClient.get endpoint, :accept => :csv

        # Force the encoding to UTF-8 as that is what the
        # API returns (otherwise it will be ASCII-8BIT, see
        # http://bugs.ruby-lang.org/issues/2567)
        response.force_encoding('UTF-8')

        # Remove the UTF-8 BOM if present
        response.sub!(/\A\xEF\xBB\xBF/, '')

        CSV.parse response, :headers => true
      end
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
      rescue_api_errors do
        endpoint = endpoint_for(path)
        response = RestClient.post endpoint, data, options.merge(:accept => :json)

        JSON.parse response
      end
    end

    def put_json(path, params)
      put path, params.to_json, :content_type => :json
    end

    def put(path, data, options = {})
      rescue_api_errors do
        endpoint = endpoint_for(path)
        response = RestClient.put endpoint, data, options.merge(:accept => :json)

        JSON.parse response
      end
    end

    def to_s
      "#{self.class.name} api_user: #{api_user}"
    end

    def inspect
      to_s
    end

    private
    attr_accessor :api_user, :api_pass

    def rescue_api_errors
      yield
    rescue RestClient::BadRequest => e
      raise InvalidRequest, extract_message_from_exception(e)
    rescue RestClient::ResourceNotFound => e
      raise NotFound, extract_message_from_exception(e)
    end

    def extract_message_from_exception(exception)
      JSON.parse(exception.http_body)['message']
    end

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
