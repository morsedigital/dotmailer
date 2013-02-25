require 'cgi'
require 'json'
require 'restclient'

module Dotmailer
  class Client
    def initialize(api_user, api_pass)
      self.api_user = api_user
      self.api_pass = api_pass
    end

    def get_data_fields
      fields = get 'data-fields'

      fields.map { |attributes| DataField.new(attributes) }
    end

    def create_data_field(name, options = {})
      options[:type]       ||= 'String'
      options[:visibility] ||= 'Public'

      post_json(
        'data-fields',
        'name'         => name,
        'type'         => options[:type],
        'visibility'   => options[:visibility],
        'defaultValue' => options[:default]
      )

      true
    rescue RestClient::BadRequest
      raise DuplicateDataField
    end

    def import_contacts(contacts_csv)
      response = post 'contacts/import', contacts_csv, :content_type => :csv

      response['id']
    end

    def import_status(import_id)
      response = get "contacts/import/#{import_id}"

      response['status']
    end

    private
    attr_accessor :api_user, :api_pass

    def get(path)
      endpoint = endpoint_for(path)
      response = RestClient.get endpoint, :accept => :json

      JSON.parse response
    end

    def post_json(path, params)
      post path, params.to_json, :content_type => :json
    end

    def post(path, data, options = {})
      endpoint = endpoint_for(path)
      response = RestClient.post endpoint, data, options.merge(:accept => :json)

      JSON.parse response
    end

    def endpoint_for(path)
      URI::Generic.build(
        :scheme   => 'https',
        :userinfo => "#{CGI.escape(api_user)}:#{api_pass}",
        :host     => 'api.dotmailer.com',
        :path     => "/v2/#{path}"
      ).to_s
    end
  end
end
